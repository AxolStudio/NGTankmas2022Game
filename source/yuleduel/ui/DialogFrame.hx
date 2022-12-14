package yuleduel.ui;

import yuleduel.globals.Sounds;
import flixel.FlxG;
import yuleduel.globals.Dialog;
import flixel.tweens.FlxTween;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.graphics.frames.FlxBitmapFont;
import yuleduel.globals.GameGlobals;
import flixel.math.FlxRect;
import flixel.FlxSprite;
import flixel.text.FlxBitmapText;
import flixel.group.FlxGroup;
import openfl.geom.Rectangle;

using StringTools;

class DialogFrame extends FlxGroup
{
	public var frame:GameFrame;
	public var text:FlxBitmapText;
	public var cursor:FlxBitmapText;
	public var choiceA:FlxBitmapText;
	public var choiceB:FlxBitmapText;
	public var selector:FlxBitmapText;
	public var isQuestion:Bool = false;
	public var selected:Int = -1;

	public var isMessage:Bool = false;

	public var dialogData:DialogData;

	public function new():Void
	{
		super(6);
		add(frame = new GameFrame(GameGlobals.TILE_SIZE * 30, GameGlobals.TILE_SIZE * 4));
		//
		frame.x = 0;
		frame.y = Global.height - frame.height;
		add(text = new GameText());
		text.x = frame.x + 12;
		text.y = frame.y + 12;
		text.width = frame.width - 24;
		text.height = frame.height - 24;
		text.autoSize = false;
		text.multiLine = true;
		text.fieldWidth = Std.int(frame.width - 24);

		add(cursor = new GameText());
		cursor.text = "^";
		cursor.x = frame.x + frame.width - 12 - cursor.width;
		cursor.y = frame.y + frame.height - 12 - cursor.height;

		add(choiceA = new GameText());
		// choiceA.x = frame.x + 24;
		// choiceA.y = frame.y + frame.height - 24 - choiceA.height;

		add(choiceB = new GameText());
		// choiceB.x = frame.x + frame.width - 24 - choiceB.width;
		// choiceB.y = frame.y + frame.height - 24 - choiceB.height;

		add(selector = new GameText());
		selector.text = "]";
		// selector.x = choiceA.x - selector.width - 4;
		// selector.y = choiceA.y;

		frame.scrollFactor.set();
		text.scrollFactor.set();
		cursor.scrollFactor.set();
		choiceA.scrollFactor.set();
		choiceB.scrollFactor.set();
		selector.scrollFactor.set();

		frame.visible = false;
		text.visible = false;
		cursor.visible = false;
		choiceA.visible = false;
		choiceB.visible = false;
		selector.visible = false;
	}

	public function displayMessage(Message:String):Void
	{
		isQuestion = false;
		selected = -1;
		text.text = Message;
		choiceA.visible = false;
		choiceB.visible = false;
		selector.visible = false;
		cursor.y = frame.y + frame.height - 12 - cursor.height;
		cursor.visible = true;
		FlxTween.tween(cursor, {y: cursor.y - 4}, 0.2, {type: FlxTweenType.PINGPONG, startDelay: 0.1});
		frame.visible = true;
		text.visible = true;

		isMessage = true;
	}

	public function fixText(Text:String):String
	{
		Text = Text.replace("{PAUSE}", GameGlobals.GetInputName("pause"));

		return Text;
	}

	public function display(DialogData:DialogData):Void
	{
		dialogData = DialogData;
		var dText:String = fixText(dialogData.text);

		if (dText.startsWith("Q:"))
		{
			choiceA.text = dText.substr(2, dText.indexOf("|") - 2);
			choiceB.text = dText.substr(dText.indexOf("|") + 1, dText.indexOf(";") - dText.indexOf("|") - 1);

			choiceA.x = frame.x + 24 + selector.width + 10;
			choiceA.y = frame.y + frame.height - 24 - choiceA.height;

			choiceB.x = frame.x + (frame.width / 2) + 10 + selector.width + 10;
			choiceB.y = frame.y + frame.height - 24 - choiceB.height;

			text.text = dText.substr(dText.indexOf(";") + 1);
			choiceA.visible = true;
			choiceB.visible = true;
			selector.visible = true;
			selector.x = choiceA.x - selector.width - 8;
			selector.y = choiceA.y - 1;

			isQuestion = true;
			selected = 0;
		}
		else
		{
			isQuestion = false;
			selected = -1;
			text.text = dText;
			choiceA.visible = false;
			choiceB.visible = false;
			selector.visible = false;
			cursor.y = frame.y + frame.height - 12 - cursor.height;
			cursor.visible = true;
			FlxTween.tween(cursor, {y: cursor.y - 4}, 0.2, {type: FlxTweenType.PINGPONG, startDelay: 0.1});
		}

		isMessage = false;

		frame.visible = true;
		text.visible = true;
	}

	public function hide():Void
	{
		Sounds.playSound("jingle");
		if (!isQuestion)
		{
			Global.cancelTweensOf(cursor);
		}

		frame.visible = false;
		text.visible = false;
		cursor.visible = false;
		choiceA.visible = false;
		choiceB.visible = false;
		selector.visible = false;

		if (!isMessage)
			Dialog.close(dialogData, selected != 1);
	}

	public function changeSelection():Void
	{
		Sounds.playSound("tink");
		if (selected == 0)
		{
			selected = 1;
			selector.x = choiceB.x - selector.width - 10;
		}
		else
		{
			selected = 0;
			selector.x = choiceA.x - selector.width - 10;
		}
	}
}
