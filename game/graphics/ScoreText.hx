package game.graphics;
/*
	Спрайт с отображением текста "Уровень: Х Жизни: У Очки: УХ"
	Он отображается в самом низу экрана
*/

// подключим зависимости
import flash.display.*;
import flash.events.*;
import flash.text.*;
import game.data.*;
import game.graphics3d.*;

class ScoreText extends Sprite implements game.graphics3d.IRenderable {
	private var gameplay:Gameplay;
	private var textField:TextField;
	private var texture:ImageTexture;

	public function new(gameplay:Gameplay) {
		super();
		// сохраним ссылку на объект геймплея, чтобы иметь
		// к нему доступ в событии updateTextFields
		this.gameplay = gameplay;

		// позиционирование внизу экрана
		y = Gameplay.SCREEN_HEIGHT * (3.0/4.0)
			+ Gameplay.SCREEN_HEIGHT * (1.0/4.0) * (3.0/4.0)
			+ 5;
		x = Gameplay.SCREEN_WIDTH / 2.0;

		// настроим шрифт
		var format:TextFormat = new TextFormat();
		format.size = 15;
		format.align = TextFormatAlign.CENTER;
		format.font = "Arial";

		// создадим текстовое поле
		textField = new TextField();
		textField.textColor = 0xFFFFFF;
		textField.border = false;
		textField.wordWrap = false;
		textField.width = 256;
		textField.height = 22;
		textField.selectable = false;
		textField.x = -128;
		textField.defaultTextFormat = format;
		textField.embedFonts = false;
		textField.antiAliasType = AntiAliasType.ADVANCED;
		addChild(textField);

		// обновим текст, чтобы он уже был перед началом кадра
		updateTextFields();

		// слушаем событие отрисовки экрана
		addEventListener(Event.ENTER_FRAME, updateTextFields);
	}

	private function updateTextFields(event:Event = null):Void {
		// обновим текст, если он был изменен
		var newText = Texts.Level + gameplay.level + "  " +
		Texts.Lives + gameplay.lives + "  " +
		Texts.Score + gameplay.score + "  ";

		// если текст изменился - пересоздадим текстуру
		if(newText != textField.text)
		{
			textField.text = newText;
			if(texture != null) texture.dispose();
			texture = new ImageTexture(TextToBitmap.draw(textField));
		}
	}

	public function render3d(context:game.graphics3d.Context):Void {
		// отрисуем изображение текста с заданной ранее текстурой
		context.drawBitmap(x + textField.x, y + textField.y,
		                   textField.width, textField.height,
		                   texture);
	}
}