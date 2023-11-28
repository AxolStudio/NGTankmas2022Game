package;

import axollib.AxolAPI;
import axollib.DissolveState;
import flixel.FlxG;
import flixel.FlxGame;
import yuleduel.globals.GameGlobals;

class Main extends openfl.display.Sprite
{
	public function new()
	{
		super();
		AxolAPI.firstState = yuleduel.states.TitleState;
		AxolAPI.init = initializeGame;

		addChild(new FlxGame(0, 0, DissolveState));

		FlxG.mouse.visible = false;
	}

	private function initializeGame():Void
	{
		Controls.init();

		GameGlobals.initialized = false;
		GameGlobals.init();
	}
}

class BootState extends flixel.FlxState
{
	override function create()
	{
		super.create();

		// Only needs to be called once
		Controls.init();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		Global.switchState(new yuleduel.states.TitleState());
	}
}
