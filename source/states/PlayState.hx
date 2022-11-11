package states;

import flixel.FlxState;
import flixel.tile.FlxBaseTilemap.FlxTilemapAutoTiling;
import flixel.tile.FlxTilemap;
import globals.Actions;

class PlayState extends FlxState
{
	public var map:FlxTilemap;

	public var player:GameObject;
	public var mapData:Array<Int> = [
		56, 73, 73, 73, 73, 73, 73, 73, 73, 73, 73, 73, 55, 0, 0, 0, 0, 54, 73, 73, 73, 73, 73, 73, 73, 73, 73, 73, 73, 57, 75, 137, 137, 137, 137, 137, 137,
		137, 137, 137, 137, 137, 138, 0, 0, 0, 0, 136, 137, 137, 137, 137, 137, 137, 137, 137, 137, 137, 137, 74, 75, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 74, 75, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 47, 0, 0, 0, 0, 74, 75, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 46, 0, 0, 0, 0, 74, 75, 0, 0, 0, 0, 47, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 46, 0, 0, 0, 0, 74, 75, 0, 0, 0, 68, 71, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 45, 0, 0, 0, 0, 74, 75, 0, 0, 0, 45, 135, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 52, 53, 0, 0, 0, 0, 135, 0, 0, 0, 0, 74, 75, 0, 0, 0, 135, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 60, 64, 50, 0, 0,
		0, 0, 0, 0, 0, 0, 74, 75, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 46, 137, 138, 0, 0, 0, 0, 0, 0, 0, 0, 74, 75, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 46, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 74, 75, 0, 0, 0, 0, 0, 0, 51, 0, 0, 51, 0, 0, 0, 0, 0, 0, 0, 45, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 74, 75, 0, 0, 0, 0, 0, 0, 135, 0, 0, 135, 0, 0, 0, 0, 0, 0, 0, 135, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 74, 75, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 74, 75, 0, 0, 0, 0, 0, 0, 51, 0, 0, 51, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 52, 53, 0, 0, 0, 0, 0, 74, 75, 0,
		0, 0, 0, 0, 0, 135, 0, 0, 135, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 54, 55, 0, 0, 0, 0, 0, 74, 75, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 136, 138, 0, 0, 0, 0, 0, 74, 75, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 74, 75, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 74, 58, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 72, 53, 0, 0, 0, 0, 52, 72, 72,
		72, 72, 72, 72, 72, 72, 72, 72, 72, 59
	];

	// change to read json files! *.tmj

	override public function create()
	{
		Globals.PlayState = this;
		Globals.init();

		map = new FlxTilemap();
		map.loadMapFromArray(mapData, 30, 20, "assets/images/temp_tiles.png", 24, 24, FlxTilemapAutoTiling.OFF, 0, 0, 45);
		// FlxG.worldBounds.set(0, 0, map.width, map.height);

		add(map);

		add(player = new GameObject());
		var tX:Float = Std.int((FlxG.width / 2) / 24) * 24;
		var tY:Float = Std.int((FlxG.height / 2) / 24) * 24;
		player.spawn("temp_player", tX, tY);

		super.create();
	}

	public function new():Void
	{
		super();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		// trace(Actions.leftStick.x, Actions.leftStick.y);
		var left:Bool = Actions.leftStick.x < -0.01 || Actions.left.triggered;
		var right:Bool = Actions.leftStick.x > 0.01 || Actions.right.triggered;
		var up:Bool = Actions.leftStick.y < -0.01 || Actions.up.triggered;
		var down:Bool = Actions.leftStick.y > 0.01 || Actions.down.triggered;

		if (left && right)
			left = right = false;
		if (up && down)
			up = down = false;

		if (up)
			player.move(0, -1);
		else if (down)
			player.move(0, 1);
		else if (left)
			player.move(-1, 0);
		else if (right)
			player.move(1, 0);
	}
}
