package game.graphics3d;
/*
	Цветная плоскость поверх экрана
*/

// подключим зависимости
import flash.display.*;
import flash.display3D.*;
import flash.events.*;
import flash.geom.*;
import flash.utils.*;
import com.adobe.utils.*;
import flash.Vector; // стандартный Vector.<T> для флеша

class Plane {

	public static var vertexBuffer:VertexBuffer3D; // вершинный буфер
	public static var indexBuffer:IndexBuffer3D; // индексный буфер
	public static var program:Program3D; // шейдерная программа

	public static function init(context:flash.display3D.Context3D)
	{
		// создадим буферы и программу
		// число вершин и число Float-параметров на вершину
		vertexBuffer = context.createVertexBuffer(4, 3);
		indexBuffer = context.createIndexBuffer(12);
		program = context.createProgram();

		// инициализируем ассемблер шейдерный программ
		var assembler:AGALMiniAssembler = new AGALMiniAssembler();

		// вершинный шейдер выполняется на каждой вершине
		// здесь из вершинного буфера [va0] координаты вершин передаются
		// напрямую в выходной регистр [op], т.к. координатное пространство
		// экрана находится в пределах -1..1, как и координаты вершин
		// в вершинном буфере (заполнение координат указано ниже),
		// затем в переменную, общую для вершинного и пиксельного шейдера [v0]
		// передается регистр цвета вершин [vc4] заданный при запуске шейдерной
		// программы
		var code:String = "mov op, va0\nmov v0, vc0\n";
		// скомпилируем данную программу
		var vertexShader = assembler.assemble(cast Context3DProgramType.VERTEX, code);

		// пиксельный (фргаментный) шейдер просто примет на вход
		// общую переменную цвета [v0] и запишет ее в выходной параметр цвета [oc]
		code = "mov oc, v0\n";
		// скомпилируем данную программу
		var fragmentShader = assembler.assemble(cast Context3DProgramType.FRAGMENT, code);

		// загрузим получанные программы в драйвер видеокарты
		program.upload(vertexShader, fragmentShader);

		// создадим данные для заполнения вершинного и индексного буферов
		var vertexData:Vector<Float> = Vector.ofArray ([
			-1, 1, 0,   // - 1я вершина x,y,z
			1, 1, 0,    // - 2я вершина x,y,z
			1, -1, 0,   // - 3я вершина x,y,z
			-1, -1, 0.0 // - 4я вершина x,y,z
		]);
		// 0.0 необходим, т.к. Haxe иначе воспримет данный массив как Array<Int>,
		// вместо Array<Float>

		var indexses:Array<UInt> = [0, 1, 2, 0, 2, 3, 3, 2, 0, 2, 1, 0];
		var indexData:Vector<UInt> = Vector.ofArray(indexses);

		// загрузим эти данные в драйвер видеокарты
		vertexBuffer.uploadFromVector(vertexData, 0, 4);
		indexBuffer.uploadFromVector(indexData, 0, 12);
	}
}