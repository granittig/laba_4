package game.objects;
/*
	Спрайт с игровым шариком
*/

// подключим зависимости
import flash.display.*;
import flash.events.*;
import game.data.*;

// реализуем интерфейс трехмерного графического объекта
class Ball extends Sprite implements game.graphics3d.IRenderable {

	// свойства шарика:
	public var ballXSpeed:Float = 8.0; // скорость
	public var ballYSpeed:Float = 8.0; // скорость
	private var paddle:Paddle; // отбивающая доска
	private var gameplay:Gameplay; // глобальные параметры игры

	public function new(paddle:Paddle, gameplay:Gameplay){
		super();
		// отрисуем шарик
		graphics.beginFill(0xFF3210);
		graphics.drawCircle(-6,-6,6);
		graphics.endFill();

		// сохраним ссылки на доску и параметры геймплея
		this.paddle = paddle;
		this.gameplay = gameplay;

		// сделаем его очень маленьким, чтобы реализовать затем анимацию
		// увеличения
		scaleX = scaleY = 0.01;

		// слушаем каждый кадр отрисовки
		addEventListener(Event.ENTER_FRAME, onFrame);
	}

	private function onFrame(event:Event):Void {
		// сдвинем шар в направлении движения
		this.x += ballXSpeed;
		this.y += ballYSpeed;

		// анимация увеличения шара
		if(scaleY < 1.0) scaleX = scaleY = scaleY + 1/15;

		/*
			Здесь происходит расчет столкновения шарика с границами игрового экрана
		*/

		// правая граница
		if(this.x >= Gameplay.SCREEN_WIDTH-this.width){
			// сменим направление движения
			ballXSpeed *= -1;
		}
		// левая
		if(this.x <= 0){
			ballXSpeed *= -1;
		}
		// шар пролетел в нижнюю границу, необходимо это обработать:
		if(this.y >= Gameplay.SCREEN_HEIGHT-this.height){
			ballYSpeed *= -1;
			// уменьшим число жизней игрока
			gameplay.lives--;
			// поставим шар в центре экрана
			x = Gameplay.SCREEN_WIDTH / 2.0;
			y = Gameplay.SCREEN_HEIGHT / 2.0;
			// уменьшим размеры шара, чтобы запустить анимацию
			scaleX = scaleY = 0.2;
		}
		// потолок (верхняя граница)
		if(this.y <= 0){
			ballYSpeed *= -1;
		}
		// проверим, столкнулся ли шар с доской
		if(this.hitTestObject(paddle)){
			// дополнительная проверка сделана чтобы шар мог вылетать
			// "из под" доски, когда коснется нижней границы.
			// Она полезна, если не центрировать шар после проигрыша,
			// а продолжить его движение далее (как вариант игровой механики)
			if(y < paddle.y) calcBallAngle();
		}
	}

	private function calcBallAngle():Void {
		/*
			Эта функция расчитывает новое направление движения шарика
			после столкновения с доской.
			Алгоритм не претендует на точность, но за счет этого
			усложняет игру, делая поведение шарика менее предсказуемым
		*/
		var ballPosition:Float = this.x - paddle.x;
		var hitPercent:Float = (ballPosition / (paddle.width/2 - this.width/2)) - .5;
		ballXSpeed = hitPercent * 6;
		ballYSpeed *= -1;
	}

	// метод отрисовки трехмерной графики через вспомогательный контекст
	public function render3d(context:game.graphics3d.Context):Void {
		context.drawBox(x, y, scaleX * 12, scaleX * 12, 0xFF3210, 1.0);
	}
}