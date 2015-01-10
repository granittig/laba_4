package game.objects;
/*
	Спрайт разрушаемого блока
*/

// подключим зависимости
import flash.display.*;
import flash.events.*;
import game.data.*;

// реализуем интерфейс трехмерного графического объекта
class Block extends Sprite implements game.graphics3d.IRenderable {

	private var gameplay:Gameplay;
	private var ball:Ball;
	private var rgb:UInt; // цвет

	public function new(gameplay:Gameplay, ball:Ball){
		super();
		// создадим случайный цвет блока
		// данный алгоритм создаст приятный светлый оттенок
		rgb =
		(
			Math.round(128 + Math.random() * 128) +
			Math.round(128 + Math.random() * 128) * 256 +
			Math.round(128 + Math.random() * 128) * 256 * 256
		);

		// отрисуем его
		graphics.beginFill(rgb);
		graphics.drawRect(0,0,70,15);
		graphics.endFill();

		// сохраним ссылки на шарик и жизни игрока
		this.gameplay = gameplay;
		this.ball = ball;

		// слушаем событие отрисовки экрана
		addEventListener(Event.ENTER_FRAME, onFrame);
	}

	private function onFrame(event:Event):Void {
		/*
			В качестве параметра "блок разрушен" и заодно для
			создания анимации исчезновения, происходит проверка
			на изменение прозрачности блока.

			Если прозрачность ниже чем 0.99, то она убывает постепенно до нуля
			с каждым кадром, а затем слушатель на событие отрисовки убирается.

			Если же альфа выше порогового значения 0.99, то происходит
			проверка на столкновение с шариком,
			и если оно имело место быть:
			- веритакльно направление движения шарика инвертируется
			- устанавливается прозрачность блока ниже порогового значения 0.99
			- число оставшихся блоков снижается на единицу
			- добавляется 10 очков игроку

		*/
		if(alpha < 0.99) {

			alpha -= 1/15;
			if(alpha < 0) removeEventListener(Event.ENTER_FRAME, onFrame);

		} else if(this.hitTestObject(ball)) {
			ball.ballYSpeed *= -1;
			alpha = 0.95;
			gameplay.blocks--;
			gameplay.score += 10;
		}
	}

	// метод отрисовки трехмерной графики через вспомогательный контекст
	public function render3d(context:game.graphics3d.Context):Void {
		context.drawBox(x, y + 15, 70, 15, rgb, alpha);
	}
}