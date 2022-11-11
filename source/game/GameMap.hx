package game;

import haxe.DynamicAccess;

class GameMap
{
	public var name:String = "";
	public var widthInTiles:Int = -1;
	public var heightInTiles:Int = -1;
	public var backgroundData:Array<Int> = [];
	public var objects:Array<MapObject> = [];

	// track which tileset?a
	public function new(Data:macros.MapBuilder.MapStructure):Void
	{
		trace(Data);
		// for (p in 0...Data.properties.length)
		// {
		// 	if (Data.properties[p].name == "name")
		// 	{
		// 		name = Data.properties[p].value;
		// 		break;
		// 	}
		// }
		// widthInTiles = Data.width;
		// heightInTiles = Data.height;
		// var tileLayer:Dynamic = null;
		// var objectLayer:Dynamic = null;
		// for (l in 0...Data.layers.length)
		// {
		// 	if (Data.layers[l].name == "tiles")
		// 		tileLayer = Data.layers[l];
		// 	else if (Data.layers[l].name == "objects")
		// 		objectLayer = Data.layers[l];
		// }
		// backgroundData = [for (i in 0...tileLayer.data.length) Std.int(tileLayer.data[i] - 1)];
		// objects = [for (i in 0...objectLayer.objects.length) new MapObject(objectLayer.objects[i])];
		// trace(this);
	}
}

class MapObject
{
	public var name:String = "";
	public var objectType:MapObjectType;
	public var x:Float;
	public var y:Float;
	public var facing:String;

	public function new(Data:Dynamic):Void
	{
		name = Data.name;
		x = Data.x;
		y = Data.y;
		for (p in 0...Data.properties.length)
		{
			switch (Data.properties[p].name)
			{
				case "objectType":
					objectType = Data.properties[p].value;
				case "facing":
					facing = Data.properties[p].value;
			}
		}
	}
}

@:enum abstract MapObjectType(String)
{
	var PLAYER = "player";
	var NPC = "npc";
}
