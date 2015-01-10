package game.graphics3d;
/*
	Цветной параллелограмм
*/

// подключим зависимости
import flash.display.*;
import flash.display3D.*;
import flash.events.*;
import flash.geom.*;
import flash.utils.*;
import com.adobe.utils.*;
import flash.Vector; // стандартный Vector.<T> для флеша

class Box {

	public static var vertexBuffer:VertexBuffer3D; // вершинный буфер
	public static var indexBuffer:IndexBuffer3D; // индексный буфер
	public static var program:Program3D; // шейдерная программа

	public static function init(context:flash.display3D.Context3D)
	{
		// создадим буферы и программу
		// число вершин и число Float-параметров на вершину
		vertexBuffer = context.createVertexBuffer(4, 4);
		indexBuffer = context.createIndexBuffer(12);
		program = context.createProgram();

		// инициализируем ассемблер шейдерный программ
		var assembler:AGALMiniAssembler = new AGALMiniAssembler();

		// вершинный шейдер выполняется на каждой вершине
		// в нем происходи перемножение матрицы трансформации [vc0] на координаты вершины
		// из буфера вершин [va0],
		// затем в переменную, общую для вершинного и пиксельного шейдера [v0]
		// передается регистр цвета вершин [vc4] заданный при запуске шейдерной
		// программы
		var code:String = "m44 op, va0, vc0\nmov v0, vc4\n";
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
			0, 1, 0, 1, // - 1я вершина x,y,z,w
			1, 1, 0, 1, // - 2я вершина x,y,z,w
			1, 0, 0, 1, // - 3я вершина x,y,z,w
			0, 0, 0, 1.0// - 4я вершина x,y,z,w
		]);

		var indexses:Array<UInt> = [0, 1, 2, 0, 2, 3, 3, 2, 0, 2, 1, 0];
		var indexData:Vector<UInt> = Vector.ofArray(indexses);

		// загрузим эти данные в драйвер видеокарты
		vertexBuffer.uploadFromVector(vertexData, 0, 4);
		indexBuffer.uploadFromVector(indexData, 0, 12);
	}
}