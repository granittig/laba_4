package game.graphics3d;
/*
	Интерфейс класса, имеющего функцию 3D отрисовки
*/

interface IRenderable
{
	// требуется функция отрисовки
    public function render3d(context:game.graphics3d.Context):Void;
    // проверка на наличие родителя
    // свойство только для чтения
    public var parent(default,never):flash.display.DisplayObjectContainer;
}