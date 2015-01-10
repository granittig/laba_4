package game.graphics3d;
/*
	Контекст отрисовки трехмерной графики
*/

// подключим зависимости
import flash.display.*;
import flash.display3D.*;
import flash.events.*;
import flash.geom.*;
import flash.utils.*;
import com.adobe.utils.*;

class Context {

	private var W:Int; // ширина кадра
	private var H:Int; // высота кадра
	private var context:Context3D; // внутренний контекст отображения
	private var stage:Stage; // сцена

	/*
		Приватные методы
	*/

	// событие создания контекста
	private function onCreate(event:Event):Void {
		// получим нулевой слой (во флеше их несколько, на случай использования
		// нескольких различных движков отображения)
		context = stage.stage3Ds[0].context3D;
		context.enableErrorChecking = true; // включим обработку ошибок

		// настроим буфер кадра - и включим сглаживание для повышения качества
		context.configureBackBuffer(W, H, 4, true);
		// применим смешение цветов по альфа каналу
		context.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
		// зарешим запись цвета во всех каналах - 4й параметр это прозрачность (альфа)
		context.setColorMask(true,true,true,true);

		// инициализируем шейдерные программы
		Plane.init(context);
		Image.init(context);
		Box.init(context);
	}

	// конвертация цвета из формата uint/hex во Float вектор для передачи в шейдер
	private function rgbaToVec(value:UInt, alpha:Float):flash.Vector<Float> {
		var color:Array<Float> = [
		((value >> 16) & 0xFF) / 255, // r
		((value >> 8) & 0xFF) / 255, // g
		(value & 0xFF) / 255, // b
		alpha];
		return flash.Vector.ofArray(color);
	}

	// отмасштабируем текстуру в размер кратный двойке
	// т.к. это частое аппаратное ограничение графических систем
	function BitmapScaled(do_source:BitmapData, thumbWidth:Int, thumbHeight:Int):BitmapData {
		// создадим матрицу масштабирования
	    var mat:Matrix = new Matrix();
	    mat.scale(thumbWidth/do_source.width, thumbHeight/do_source.height);
	    // созаддим временное изображение
	    var bmpd_draw:BitmapData = new BitmapData(thumbWidth, thumbHeight, true, 0x00000000);
	    // отрисуем его
	    bmpd_draw.draw(do_source, mat, null, null, null, true);
	    return bmpd_draw;
	}

	// функция поиска ближайшего кратного двойке
	private static function nextPowerOfTwo(v:UInt): Int
	{
		v--;
		v |= v >> 1;
		v |= v >> 2;
		v |= v >> 4;
		v |= v >> 8;
		v |= v >> 16;
		v++;
		return v;
	}

	/*
		Публичные методы
	*/

	public function new(stage:Stage, width, height) {
		W = width;
		H = height;
		this.stage = stage;
		// слушаем событие создания контекста
		stage.stage3Ds[0].addEventListener(Event.CONTEXT3D_CREATE, onCreate);
		// установим тип контекста - автоматический
		stage.stage3Ds[0].requestContext3D("auto");
	}

	// метод отрисовки плоского изображения с текстурой
	public function drawBitmap(x:Float, y:Float, width:Float, height:Float, bitmap:ImageTexture) {
		// установим текущую шейдерную программу
		context.setProgram(Image.program);
		// укажем вершинный буфер для использования
		context.setVertexBufferAt(0, Image.vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_3);

		// создадим матрицу позиции и масштаба
		var m = new Matrix3D();
		m.identity(); // единичная матрица
		m.appendScale(1, -1, 1); // отразим вертикально (иначе текстура отображена)
		m.appendScale(width/W*2, height/H*2, 1); // отмасштабируем
		m.appendTranslation(-1 + 2*(x)/W, -1 + 2*(H-y)/H, 0); // разместим на экране

		// зададим матрицу в шейдер через нулевой регистр [vc0]
		context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, m, true);

		// создадим текстуру по требованию
		if(bitmap.texture == null) {
			var bd = bitmap.bitmap;
			// расчитаем размер изображения кратным двойке, в форме квадрата
			var pot:Int = Math.round(Math.max(nextPowerOfTwo(bd.width), nextPowerOfTwo(bd.height)));

			// создадим текстуру
			bitmap.texture = context.createTexture(
				pot,
				pot,
				Context3DTextureFormat.BGRA,
				false
			);

			// отправим в драйвер видеокарты
			bitmap.texture.uploadFromBitmapData(BitmapScaled(bd, pot, pot));
		}

		// установим текстуру в нулевой слот
		context.setTextureAt(0, bitmap.texture);
		// отрисуем вершины с помозью индексного буфера в нужном порядке
		context.drawTriangles(Image.indexBuffer);
	}

	// метод отрисовки полноэкранного цветоного прямоугольника
	public function drawRectangle(color:UInt, alpha:Float) {
		// очистим слот текстуры
		context.setTextureAt(0,null);
		// установим текущую шейдерную программу
		context.setProgram(Plane.program);
		// укажем вершинный буфер для использования
		context.setVertexBufferAt(0, Plane.vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_3);
		// установим в нулевой регистр [vc0] вектор цвета
		context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 0,
			rgbaToVec(color, alpha)
		);
		// отрисуем вершины с помозью индексного буфера в нужном порядке
		context.drawTriangles(Plane.indexBuffer);
	}

	// свойства поворота экрана в пространстве,
	// используются для создания эффекта глубины
	public var rotateX = 0.0;
	public var rotateY = 0.0;

	// метод отрисовки цветной плоскости в пространстве
	public function drawBox(x:Float, y:Float, width:Float, height:Float, color:UInt, alpha:Float) {
		context.setDepthTest(false,Context3DCompareMode.LESS);
		// установим текущую шейдерную программу
		context.setProgram(Box.program);
		// укажем вершинный буфер для использования
		context.setVertexBufferAt(0, Box.vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_3);

		// создадим матрицу перспективной проекции
		var projection:PerspectiveMatrix3D = new PerspectiveMatrix3D();
		// угол обзора, соотношение сторон экрана, минимальная глубина, максимальная глубина
		projection.perspectiveFieldOfViewLH(130*Math.PI/180, W/H, 0.25, 10);

		// повернем матрицу для интересного эффекта
		projection.appendRotation(rotateX * 30, Vector3D.Z_AXIS);
		projection.appendRotation(-rotateX * 20, Vector3D.Y_AXIS);
		projection.appendRotation(-rotateY * 15, Vector3D.X_AXIS);

		// создадим матрицу в пространстве объекта
		var m = new Matrix3D();
		m.identity(); // единичная матрица

		// разместим фигурки ближе к игроку
		y = (y + H) / 2.0;
		// масштабируем
		m.appendScale(width/W*2, height/H*2, 1);
		// позиционируем
		m.appendTranslation((-1 + 2*(x)/W), (-1 + 2*(H-y)/H)/2 + 0.1, 1.1 - 0.8 * (y/H));

		// отобразим на экран с помозью матрицы проекции
		m.append(projection);
		// установим матрицу в нулевой регистр [vc0]
		// и вектор цвета в четвертый (поскольку матрица занимает четыре регистра)
		context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, m, true);
		context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 4,
			rgbaToVec(color, alpha)
		);
		// очистим слот текстуры
		context.setTextureAt(0, null);
		// отрисуем вершины с помозью индексного буфера в нужном порядке
		context.drawTriangles(Box.indexBuffer);
		// отключим тест глубины, чтобы отслаьные плоские объекты всегда отрисовываолись
		context.setDepthTest(false,Context3DCompareMode.ALWAYS);
	}

	// начало отрисовки кадра
	public function renderBegin():Void {
		context.clear(); // очистка экрана
	}

	// завершение отрисовки кадра
	public function renderEnd():Void {
		context.present(); // отобразим созданное изображение кадра на экран
	}
}