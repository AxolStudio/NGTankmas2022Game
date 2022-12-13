package yuleduel.game;

import flixel.util.FlxDirectionFlags;

using StringTools;

class GameMap
{
	public var name:String = "";
	public var widthInTiles:Int = -1;
	public var heightInTiles:Int = -1;
	public var baseLayerData:Array<Int> = [];
	public var decorativeLayerData:Array<Int> = [];
	public var objects:Array<MapObject> = [];
	public var neighbors:Map<FlxDirectionFlags, String> = [];
	public var tilesetFirstIDs:Array<Int> = [-1, -1];

	// track which tileset?a
	public function new(Data:yuleduel.macros.MapBuilder.MapStructure):Void
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

		for (t in 0...Data.tilesets.length)
		{
			if (Std.string(Data.tilesets[t].source).contains("base"))
				tilesetFirstIDs[0] = Data.tilesets[t].firstgid;
			else if (Std.string(Data.tilesets[t].source).contains("decorative"))
				tilesetFirstIDs[1] = Data.tilesets[t].firstgid;
		}

		widthInTiles = Data.width;
		heightInTiles = Data.height;
		var baseLayer:Dynamic = null;
		var decorativeLayer:Dynamic = null;
		var objectLayer:Dynamic = null;
		for (l in 0...Data.layers.length)
		{
			if (Data.layers[l].name == "base")
				baseLayer = Data.layers[l];
			else if (Data.layers[l].name == "decorations")
				decorativeLayer = Data.layers[l];
			else if (Data.layers[l].name == "objects")
				objectLayer = Data.layers[l];
		}
		baseLayerData = [
			for (i in 0...baseLayer.data.length)
				baseLayer.data[i] > 0 ? Std.int(baseLayer.data[i] - tilesetFirstIDs[0]) : 0
		];
		decorativeLayerData = [
			for (i in 0...decorativeLayer.data.length)
				decorativeLayer.data[i] > 0 ? Std.int(decorativeLayer.data[i] - tilesetFirstIDs[1]) : 0
		];
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
