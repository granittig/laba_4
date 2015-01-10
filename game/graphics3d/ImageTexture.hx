package game.graphics3d;
/*
	Этот контейнер текстуры позволяет
	не создавать текстуру каждый кадр.
	Создание происходит по-требованию единожды.
	Здесь также реализован метод быстрого освобождения
	памяти одновременно для текстуры и данных изображения
*/
class ImageTexture {
	public var bitmap:flash.display.BitmapData;
	public var texture:flash.display3D.textures.Texture;

	public function new(bitmap:flash.display.BitmapData)
	{
		this.bitmap = bitmap;
		this.texture = null;
	}

	public function dispose()
	{
		if(bitmap != null) this.bitmap.dispose();
		if(texture != null) this.texture.dispose();
		bitmap = null;
		texture = null;
	}
}