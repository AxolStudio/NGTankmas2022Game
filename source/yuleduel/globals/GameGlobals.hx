package yuleduel.globals;

import axollib.GraphicsCache;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxShader;
import flixel.util.FlxColor;
import flixel.util.FlxSave;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;
import yuleduel.game.Player;
import yuleduel.globals.Cards.Collection;
import yuleduel.globals.Cards.Deck;
import yuleduel.states.PlayState;
import yuleduel.states.TransitionState;

@:build(yuleduel.macros.MapBuilder.build()) // MapList
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

	public static var transition:TransitionState;

	public static var hasSave:Bool = false;

	public static var OpponentList:Map<String, Opponent> = [];

	public static function init():Void
	{
		if (initialized)
			return;
		initialized = true;

		FlxG.mouse.visible = false;
		preloadGraphics();

		NGAPI.init();

		


		Global.camera.bgColor = FlxColor.TRANSPARENT;
		Global.camera.pixelPerfectRender = true;
		Global.camera.antialiasing = false;
		FlxSprite.defaultAntialiasing = false;

		transition = new TransitionState();

		#if STAND_ALONE
		FlxG.game.setFilters([new ShaderFilter(new FlxShader())]);
		FlxG.game.stage.quality = StageQuality.LOW;
		FlxG.resizeWindow(960, 540);
		FlxG.autoPause = false;
		#end

		// check for a save file
		GameSave = new FlxSave();
		GameSave.bind("YuleDuel");

		Player = new Player();
		Dialog.Flags = [];
		OpponentList = Opponent.OpponentList.copy();

		if (GameSave.data.savedData != null)
		{
			hasSave = true;
		}
		else
		{
			//	NO SAVE!
			hasSave = false;
		}

		PlayState = new PlayState();
	}

	#if ADVENT
	public static function uninit()
	{
		FlxG.mouse.visible = true;
		FlxSprite.defaultAntialiasing = true;
	}
	#end

	public static function preloadGraphics():Void
	{
		GraphicsCache.preloadGraphics();

		// getOrMakeGradient(FlxG.width, FlxG.height, [0x0, 0xff000000, 0xff000000, 0xff000000, 0x0], 1, 180);
	}

	public static function loadSave():Void
	{
		var SavedData:SaveData = GameSave.data.savedData;
		Dialog.Flags = SavedData.dialogFlags.copy();
		Player.money = SavedData.money;
		Player.collection = SavedData.collection;
		Player.deck = SavedData.deck;
		OpponentList = SavedData.opponents.copy();

		// #if debug
		// Dialog.Flags.set("tutSeen", true);
		// Dialog.Flags.set("krampus-dead", true);
		// Dialog.Flags.set("beatSanta", true);
		// Dialog.Flags.set("yeti-dead", true);
		// Dialog.Flags.set("blockade-dead", true);
		// Dialog.Flags.set("seenIntro", true);
		// GameGlobals.save();
		// #end

		PlayState.tutSeen = Dialog.Flags.exists("tutSeen");

		if (Dialog.Flags.exists("seenIntro"))
		{
			if (Dialog.Flags.get("seenIntro"))
			{
				Dialog.Flags.set("blockade-dead", true);
			}
		}

		// if they load the game and yeti is dead but they don't have his card, give it to them
		if (Dialog.Flags.exists("yeti-dead"))
		{
			if (Dialog.Flags.get("yeti-dead"))
			{
				NGAPI.unlockMedal(76228);

				if (!Player.collection.collection.exists(22))
					Player.collection.add(22, 1);
			}
		}

		// if they load the game and they had beaten santa but don't have his card, give it to them
		if (Dialog.Flags.exists("beatSanta"))
		{
			if (Dialog.Flags.get("beatSanta"))
			{
				NGAPI.unlockMedal(76227);
				
				if (!Player.collection.collection.exists(23))
					Player.collection.add(23, 1);
			}
		}

		// if they load the game and krampus is dead but they don't have his card, give it to them
		if (Dialog.Flags.exists("krampus-dead"))
		{
			if (Dialog.Flags.get("krampus-dead"))
			{
				Dialog.Flags.set("beatKrampus", true);

				if (!Player.collection.collection.exists(24))
					Player.collection.add(24, 1);
			}
		}

		// fixes the baricades getting stuck on continue
		for (o in PlayState.objectLayer.members)
		{
			if (Dialog.Flags.exists(o.name + "-dead"))
			{
				o.kill();
			}
		}


		if (Player.collection.collection.exists(25))
		{
			NGAPI.unlockMedal(76229);
		}


		GameGlobals.save();
	}

	public static function save():Void
	{
		var SavedData:SaveData = {
			money: Player.money,
			collection: Player.collection,
			deck: Player.deck,
			opponents: OpponentList.copy(),
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

	public static function transIn(Callback:Void->Void):Void
	{
		transition.start(true, Callback);
	}

	public static function transOut(Callback:Void->Void):Void
	{
		transition.start(false, Callback);
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
