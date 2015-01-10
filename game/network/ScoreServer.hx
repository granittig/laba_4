package game.network;
/*
	Класс для работы с сервером рекордов
*/
import flash.system.Security;
import haxe.Http;

class ScoreServer
{
	static var SERVER = "http://localhost/4-stage3d+DB-hx/index.php";

	public static function getHighScores(callback:Array<Int> -> Void):Void
	{
		// разрешим доступ к серверу
		Security.allowDomain("*");
		Security.loadPolicyFile("crossdomain.xml");

		// выполним запрос стандартными средствами Haxe
		var req = new haxe.Http(SERVER);
		// успешное получение данных
		req.onData = function (data:String)
		{
			// получим строку вида 1,2,3 и разобьем ее в массив чисел
			var el:Array<String> = data.split(",");
			var result:Array<Int> = [];
			for(i in el) result.push(Std.parseInt(i));
			callback(result);
		}
		req.onError = function (error:String)
		{
			// произошла ошибка, вернем пустой массив
			callback([]);
			trace(error);
		}
		req.request(false); // false=GET, true=POST
	}

	public static function setHighScores(highscores:Array<Int>):Void
	{
		// выполним POST запрос стандартными средствами Haxe
		var req = new haxe.Http(SERVER);
		req.setParameter("highscores", highscores.join(",")); // POST-параметр
		req.onError = function (error:String)
		{
			// произошла ошибка
			trace(error);
		}
		req.request(true); // false=GET, true=POST
	}
}