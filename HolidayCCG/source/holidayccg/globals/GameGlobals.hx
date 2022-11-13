package holidayccg.globals;

import flixel.FlxSprite;
import holidayccg.game.Player;
import flixel.FlxG;
import flixel.util.FlxColor;
import holidayccg.states.PlayState;

@:build(holidayccg.macros.MapBuilder.build()) // MapList
class GameGlobals
{
	public static var initialized:Bool = false;

	public static var PlayState:PlayState;

	public static var Player:Player;

	public static var ColorPalette:Array<FlxColor> = [
		0xff000000, 0xff222034, 0xff45283c, 0xff663931, 0xff8f563b, 0xffdf7126, 0xffd9a066, 0xffeec39a, 0xfffbf236, 0xff99e550, 0xff6abe30, 0xff37946e,
		0xff4b692f, 0xff524b24, 0xff323c39, 0xff3f3f74, 0xff306082, 0xff5b6ee1, 0xff639bff, 0xff5fcde4, 0xffcbdbfc, 0xffffffff, 0xff9badb7, 0xff847e87,
		0xff696a6a, 0xff595652, 0xff76428a, 0xffac3232, 0xffd95763, 0xffd77bba, 0xff8f974a, 0xff8a6f30
	];

	public static inline var TILE_SIZE:Int = 32;
	public static inline var SCREEN_WIDTH:Int = 30;
	public static inline var SCREEN_HEIGHT:Int = 20;

	public static function init():Void
	{
		if (initialized)
			return;
		initialized = true;

		// check for a save file
		// if none, make a new player!
		Player = new Player();
		// otherwise, load!
	}
}
