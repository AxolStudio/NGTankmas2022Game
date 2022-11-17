package holidayccg.game;

import flixel.util.FlxDirectionFlags;

class GameMap
{
	public var name:String = "";
	public var widthInTiles:Int = -1;
	public var heightInTiles:Int = -1;
	public var backgroundData:Array<Int> = [];
	public var objects:Array<MapObject> = [];
	public var neighbors:Map<FlxDirectionFlags, String> = [];

	// track which tileset?a
	public function new(Data:holidayccg.macros.MapBuilder.MapStructure):Void
	{
		for (p in 0...Data.properties.length)
		{
			if (Data.properties[p].name == "name")
			{
				name = Data.properties[p].value;
			}
			else if (Data.properties[p].name == "exit_DOWN")
			{
				neighbors.set(DOWN, Data.properties[p].value);
			}
			else if (Data.properties[p].name == "exit_UP")
			{
				neighbors.set(UP, Data.properties[p].value);
			}
			else if (Data.properties[p].name == "exit_LEFT")
			{
				neighbors.set(LEFT, Data.properties[p].value);
			}
			else if (Data.properties[p].name == "exit_RIGHT")
			{
				neighbors.set(RIGHT, Data.properties[p].value);
			}
		}
		widthInTiles = Data.width;
		heightInTiles = Data.height;
		var tileLayer:Dynamic = null;
		var objectLayer:Dynamic = null;
		for (l in 0...Data.layers.length)
		{
			if (Data.layers[l].name == "tiles")
				tileLayer = Data.layers[l];
			else if (Data.layers[l].name == "objects")
				objectLayer = Data.layers[l];
		}
		backgroundData = [for (i in 0...tileLayer.data.length) Std.int(tileLayer.data[i] - 1)];
		objects = [for (i in 0...objectLayer.objects.length) new MapObject(objectLayer.objects[i])];
	}
}

class MapObject
{
	public var name:String = "";
	public var objectType:MapObjectType;
	public var x:Float = -1;
	public var y:Float = -1;
	public var facing:String = "";
	public var sprite:String = "";

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
				case "sprite":
					sprite = Data.properties[p].value;
			}
		}
	}
}

@:enum abstract MapObjectType(String)
{
	var PLAYER = "player";
	var NPC = "npc";
}
