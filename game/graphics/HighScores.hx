package game.graphics;
/*
	Спрайт с отображением таблицы лучших результатов
	Он отображается ТОЛЬКО поверх спрайтов с сообщением победы или проигрыша
*/

// подключим зависимости
import flash.display.*;
import flash.events.*;
import flash.text.*;
import game.data.*;
import game.graphics3d.*;

class HighScores extends Sprite implements game.graphics3d.IRenderable {

	private var textField:TextField;
	private var texture:ImageTexture;

	public function new(myScorePos:Int, scores:Array<Int>) {
		super();

		// настроим шрифт
		var format:TextFormat = new TextFormat();
		format.size = 15;
		format.align = TextFormatAlign.CENTER;
		format.font = "Arial";

		// создадим текстовое поле
		textField = new TextField();
		textField.textColor = 0xFFFFFF;
		textField.border = false;
		textField.wordWrap = true;
		textField.multiline = true;
		textField.width = 242;
		textField.height = 22;
		textField.selectable = false;
		textField.x = -111;
		textField.defaultTextFormat = format;
		textField.embedFonts = false;
		textField.antiAliasType = AntiAliasType.ADVANCED;
		textField.autoSize = TextFieldAutoSize.LEFT;
		addChild(textField);

		// установим текст
		var text = "Таблица результатов: \n";

		for(i in 0...scores.length) {
			text += " " + (i + 1) + " место: " +
			if(i != myScorePos) "[ " + scores[i] + " ]\n"
			else "[ Ваш результат: " + scores[i] + " ]\n";
		};

		textField.text = text;

		// создадим текстуру из изображения текста
		texture = new ImageTexture(TextToBitmap.draw(textField));

		// разместим чуть ниже центра экрана
		x = Gameplay.SCREEN_WIDTH / 2.0;
		y = Gameplay.SCREEN_HEIGHT / 2.0 + 35 + 22;
	}

	public function render3d(context:game.graphics3d.Context):Void {
		// отрисуем изображение текста с заданной ранее текстурой
		context.drawBitmap(x + textField.x, y + textField.y,
		                   textField.width, textField.height,
		                   texture);
	}
}