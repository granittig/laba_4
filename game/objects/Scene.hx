package game.objects;
/*
	Основной класс игры
	Сцена, на которую помещаются игровые объекты
*/

// подключим зависимости
import flash.display.*;
import flash.events.*;
import game.data.*;
import game.graphics.*;
import game.graphics3d.*;
import game.network.*;

class Scene extends Sprite {

	// основная фукнция старта приложения в языке Haxe
	public static function main() {
		// flash.Lib.current является базовым спрайтом приложения
		// разместим на него сцену
		flash.Lib.current.addChild(new Scene());
	}

	public function new(){
		// Haxe требует указывать вызов конструктора базового класса
		super();
		addEventListener(Event.ADDED_TO_STAGE, onAdded);
	}

	// ссылки на игровые обьекты
	private var gameplay:Gameplay;
	private var paddle:Paddle;
	private var ball:Ball;
	private var scoreText:ScoreText;
	private var bricks:Array<Block>; // типизированный массив блоков
	private var context:Context; // контекст отрисовки 3D
	private var overlay:IRenderable; // объекты поверх всего экрана

	private function onAdded(event:Event):Void
	{
		removeEventListener(Event.ADDED_TO_STAGE, onAdded);
		// игровая сцена добавлена

		// создание вспомогательного контекста для 3D отрисовки
		context = new Context(stage, Gameplay.SCREEN_WIDTH, Gameplay.SCREEN_HEIGHT);
		addEventListener(Event.ENTER_FRAME, onRender3D); // запустим отрисовку
		alpha = 0; // скроем 2D графику, но оставим ее
		// для возможности использования стандартных методов флеша
		// нажатия мыши и столкновения объектов

		// установим приятную частоту отрисовки игрового экрана
		stage.frameRate = 60;

		// запустим игру
		startGame();
	}

	private function startGame(event:Event = null):Void
	{
		// Начата новая игра
		gameplay = new Gameplay();

		// создадим игровые объекты
		paddle = new Paddle();
		ball = new Ball(paddle, gameplay);
		scoreText = new ScoreText(gameplay);

		// расставим их на сцене
		addChild(paddle);
		addChild(ball);
		addChild(scoreText);

		bricks = new Array<Block>();

		addEventListener(Event.ENTER_FRAME, onFrame);
		startLevel();
	}

	private function startLevel():Void
	{
		// уберем слушатель события отрисовки жкрана
		removeEventListener(Event.ENTER_FRAME, onFrame);

		// рассчитаем необходимое количество блоков для разрушения
		gameplay.blocks = Gameplay.BLOCKS_PER_LINE * gameplay.level * 4;

		var block:Block;

		// удалим старые блоки со сцены
		while(bricks.length > 0) {
			block = bricks.pop();
			block.parent.removeChild(block);
		}

		bricks = new Array<Block>();

		var col:Int = 0; // столбец
		var row:Int = 0; // строка

		while(bricks.length < gameplay.blocks) {
			block = new Block(gameplay, ball);

			block.x = 15 + col * 75;
			block.y = 10 + row * 20;

			col++;

			// переход на новую строку
			if(col == Gameplay.BLOCKS_PER_LINE) {
				row++;
				col = 0;
			}

			addChild(block);
			bricks.push(block);
		}

		// центрируем игровые объекты
		paddle.y = Gameplay.SCREEN_HEIGHT * (3.0/4.0)
			+ Gameplay.SCREEN_HEIGHT * (1.0/4.0) * (3.0/4.0);
		paddle.x = Gameplay.SCREEN_WIDTH / 2.0;

		ball.x = Gameplay.SCREEN_WIDTH / 2.0;
		ball.y = Gameplay.SCREEN_HEIGHT / 2.0;
		// остановим шар
		ball.ballXSpeed = 0.0;
		ball.ballYSpeed = 0.0;

		// попросим игрока нажать на экран для старта
		overlay = cast addChild(new ClickToPlayScreen(play));
	}

	private function play():Void {
		// запустим шар
		ball.ballXSpeed = 6.0;
		ball.ballYSpeed = 6.0;

		// добавим слушатель на событие отрисовки экрана
		addEventListener(Event.ENTER_FRAME, onFrame);
	}

	private function restart():Void
	{
		// перезапустим игру
		// очистим игровое поле
		ball.parent.removeChild(ball);
		paddle.parent.removeChild(paddle);
		scoreText.parent.removeChild(scoreText);
		while(bricks.length > 0) {
			var block = bricks.pop();
			block.parent.removeChild(block);
		}
		// запустим игру
		startGame();
	}

	private function onFrame(event:Event):Void {
		// если число жизней равно нулю,
		if(gameplay.lives < 1) {
			// приостановим игру
			removeEventListener(Event.ENTER_FRAME, onFrame);
			ball.ballXSpeed = 0.0;
			ball.ballYSpeed = 0.0;
			// сообщим игроку о проигрыше
			overlay = cast addChild(new YouLoseScreen(gameplay.score, gameplay.level, restart));
			// загрузим таблицу результатов
			ScoreServer.getHighScores(highScoresLoaded);
		} else
		if(gameplay.blocks < 1) {
			// приостановим игру
			removeEventListener(Event.ENTER_FRAME, onFrame);
			ball.ballXSpeed = 0.0;
			ball.ballYSpeed = 0.0;
			// увеличим номер уровня
			gameplay.level++;
			// провреим, не прошел ли он все уровни
			if(gameplay.level > Gameplay.LEVELS) {
				// сообщим о победе
				overlay = cast addChild(new YouWonScreen(gameplay.score, gameplay.level, restart));
				// загрузим таблицу результатов
				ScoreServer.getHighScores(highScoresLoaded);
			} else {
				// попросим кликнуть на экран для продолжения
				overlay = cast addChild(new ClickToPlayScreen(startLevel));
			}
		}
	}

	// событие отрисовки 3D графики
	private function onRender3D(event:Event):Void {
		// начнем отрисовку кадра
		context.renderBegin();

		// зададим поворот камеры в пространстве
		context.rotateX = (stage.mouseX - Gameplay.SCREEN_WIDTH / 2) / Gameplay.SCREEN_WIDTH;
		context.rotateY = (stage.mouseY - Gameplay.SCREEN_HEIGHT / 2) / Gameplay.SCREEN_HEIGHT;

		// заполним фон
		context.drawRectangle(0xAABBFF, 0.2);

		// отрисуем блоки
		var i = 0;
		while(i < bricks.length) {
			bricks[i].render3d(context);
			i++;
		}

		// отрисовка шара и доски
		ball.render3d(context);
		paddle.render3d(context);

		// отрисовка очков и жизней
		scoreText.render3d(context);

		// если задан оверлей и он добавлен на сцену, отрисуем его
		if(overlay != null && overlay.parent != null) overlay.render3d(context);

		// завершим отрисовку
		context.renderEnd();
	}

	// событие успешной загрузки результатов
	private function highScoresLoaded(scores:Array<Int>) {
		// массив новой таблицы результатов
		var newScores = [];
		// позиция счета игрока в таблице
		var myScorePos = -1;
		// отсортируем очки по убыванию
		scores.sort(function(a:Int, b:Int):Int {
			if (a == b)
			    return 0;
			if (a > b)
			    return -1;
			else
			    return 1;
		});
		// добавим сначала результаты, лучшие чем у игрока
		for(s in scores) if(s > gameplay.score) newScores.push(s);
		// добавим результат игрока
		newScores.push(gameplay.score);
		// сохраним его позицию в таблице
		myScorePos = newScores.length - 1;
		// добавим результаты, строго худшие чем у игрока (избежим дублироввания,
		// если похожий счет уже был в таблице)
		for(s in scores) if(s < gameplay.score) newScores.push(s);
		// сократим таблицу до пяти элементов
		while(newScores.length > 5) newScores.pop();
		// заполним недостающие элементы нулями
		while(newScores.length < 5) newScores.push(0);
		// добавим таблицу в оверлей, если он все еще отображен на сцене,
		// пока производился запрос
		if(overlay != null && overlay.parent != null)
		if(Std.is(overlay,YouLoseScreen) || Std.is(overlay,YouWonScreen))
		cast(overlay,DisplayObjectContainer).addChild(new HighScores(myScorePos, newScores));
		// отрпавим новую таблицу рекордов на сервер
		ScoreServer.setHighScores(newScores);
	}
}