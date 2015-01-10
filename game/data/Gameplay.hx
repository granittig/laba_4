package game.data;
/*
	Данный класс содержит глобальные игровые параметры,
	на основе которых строится гровой уровень.

	Инстанс класса Gameplay хранит в себе изменяемые глобальные параметры.
	Для передачи этих параметров достаточно передать ссылку на инстанс.
	Такой прием позволяет не использовать (анти)паттерн Singleton
*/
class Gameplay {
	public var level:Int = 1; // текущий уровень
	public var score:Int = 0; // количество очков
	public var lives:Int = 3; // жизни
	public var blocks:Int = 7; // количество оставшихся блоков

	public static inline var LEVELS:Int = 4; // всего уровней в игре
	public static inline var SCREEN_WIDTH:Int = 550; // ширина игрового поля
	public static inline var SCREEN_HEIGHT:Int = 400; // высота игрового поля
	public static inline var BLOCKS_PER_LINE:Int = 7; // количество блоков на полосе по горизонтали
	// число же полос блоков равно текущему уровню
}