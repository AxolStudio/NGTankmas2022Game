package holidayccg.globals;

import holidayccg.globals.Cards.Collection;
import holidayccg.globals.Cards.Deck;
import flixel.util.FlxSave;
import flixel.FlxSprite;
import holidayccg.game.Player;
import flixel.FlxG;
import flixel.util.FlxColor;
import holidayccg.states.PlayState;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;
import flixel.system.FlxAssets.FlxShader;

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

	public static var GameSave:FlxSave;

	public static function init():Void
	{
		if (initialized)
			return;
		initialized = true;

		FlxG.game.setFilters([new ShaderFilter(new FlxShader())]);
		FlxG.game.stage.quality = StageQuality.LOW;
		FlxG.resizeWindow(960, 540);

		FlxG.camera.pixelPerfectRender = true;
		FlxG.camera.antialiasing = false;
		FlxG.autoPause = false;

		// check for a save file
		GameSave = new FlxSave();
		GameSave.bind("HolidayCCG");

		Player = new Player();

		if (GameSave.data.savedData != null #if debug && false #end)
		{
			var SavedData:SaveData = GameSave.data.savedData;
			Dialog.Flags = SavedData.dialogFlags.copy();
			Player.money = SavedData.money;
			Player.collection = SavedData.collection;
			Player.deck = SavedData.deck;
			Opponent.OpponentList = SavedData.opponents.copy();
		}
	}

	public static function save():Void
	{
		var SavedData:SaveData = {
			money: Player.money,
			collection: Player.collection,
			deck: Player.deck,
			opponents: Opponent.OpponentList.copy(),
			dialogFlags: Dialog.Flags.copy(),
			savedTime: Date.now()
		};
		GameSave.data.savedData = SavedData;
		GameSave.flush();
	}

	public static function GetInputName(Input:String):String
	{
		if (Controls.mode == Keys)
		{
			return switch (Input)
			{
				case "move": "WASD or ARROW KEYS";
				case "a": "Z, J or SPACE";
				case "b": "X, K or ESCAPE";
				case "pause": "P or ENTER";
				default: "UNKNOWN";
			}
		}
		else
		{
			return switch (Input)
			{
				case "move": "D-PAD or LEFT STICK";
				case "a": "A or X";
				case "b": "B or Y";
				case "pause": "START";
				default: "UNKNOWN";
			}
		}
	}
}

class TitleCase
{
	public static var exempt:Array<String> = [
		"a", "an", "the", "at", "by", "for", "in", "of", "on", "to", "up", "and", "as", "but", "or", "nor"
	];

	public static var roman = ~/^(?=[MDCLXVI])M*(C[MD]|D?C*)(X[CL]|L?X*)(I[XV]|V?I*)$/i;

	public static function toTitleCase(str:String):String
	{
		var words:Array<String> = str.toLowerCase().split(" ");

		for (i in 0...words.length)
		{
			if (roman.match(words[i]))
				words[i] = words[i].toUpperCase();
			else if (i == 0 || exempt.indexOf(words[i]) == -1)
				words[i] = words[i].charAt(0).toUpperCase() + words[i].substr(1);
		}

		return words.join(" ");
	}
}

class Slugify
{
	public static function toSlug(str:String):String
	{
		var regex = ~/[^a-z0-9]+/g;
		return regex.replace(str.toLowerCase(), '_');
	}
}

typedef SaveData =
{
	var money:Int;
	var collection:Collection;
	var deck:Deck;
	var dialogFlags:Map<String, Bool>;
	var opponents:Map<String, Opponent>;
	var savedTime:Date;
}
