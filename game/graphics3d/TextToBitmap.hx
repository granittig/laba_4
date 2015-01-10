package game.graphics3d;
/*
	Отрисовщик текста (TextField) в BitmapData
*/

// подключим зависимости
import flash.display.*;
import flash.text.*;
import flash.utils.*;

class TextToBitmap {
	public static function draw(tf:TextField):flash.display.BitmapData {
		var bd:BitmapData = new BitmapData(
		Math.round(tf.width),
		Math.round(tf.height),
		true, 0x00000000); // прозрачность включена
		bd.draw(tf);
		return bd;
	}
}