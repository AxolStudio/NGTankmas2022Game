package holidayccg.ui;

import flixel.tweens.FlxTween;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.graphics.frames.FlxBitmapFont;
import holidayccg.globals.GameGlobals;
import flixel.math.FlxRect;
import flixel.FlxSprite;
import flixel.text.FlxBitmapText;
import flixel.group.FlxGroup;
import openfl.geom.Rectangle;

class DialogFrame extends FlxGroup
{
	public var frame:FlxUI9SliceSprite;
	public var text:FlxBitmapText;
	public var cursor:FlxBitmapText;

	public function new():Void
	{
		super(3);
		add(frame = new FlxUI9SliceSprite(0, 0, Global.asset("assets/images/dialog_frame.png"), new Rectangle(0, 0, Global.width, GameGlobals.TILE_SIZE * 4),
			[3, 6, 5, 8], FlxUI9SliceSprite.TILE_BOTH));
		frame.x = 0;
		frame.y = Global.height - frame.height;
		add(text = new FlxBitmapText(FlxBitmapFont.fromAngelCode(Global.asset("assets/images/basic_font.png"), Global.asset("assets/images/basic_font.xml"))));
		text.x = frame.x + 12;
		text.y = frame.y + 12;
		text.width = frame.width - 24;
		text.height = frame.height - 24;
		text.autoSize = false;
		text.multiLine = true;
		text.fieldWidth = Std.int(frame.width - 24);

		add(cursor = new FlxBitmapText(FlxBitmapFont.fromAngelCode(Global.asset("assets/images/basic_font.png"),
			Global.asset("assets/images/basic_font.xml"))));
		cursor.text = "^";
		cursor.x = frame.x + frame.width - 12 - cursor.width;
		cursor.y = frame.y + frame.height - 12 - cursor.height;

		frame.scrollFactor.set();
		text.scrollFactor.set();
		cursor.scrollFactor.set();

		frame.visible = false;
		text.visible = false;
		cursor.visible = false;
	}

	public function display(Text:String):Void
	{
		cursor.y = frame.y + frame.height - 12 - cursor.height;
		text.text = Text;
		frame.visible = true;
		text.visible = true;
		cursor.visible = true;
		FlxTween.tween(cursor, {y: cursor.y - 4}, 0.2, {type: FlxTweenType.PINGPONG, startDelay: 0.1});
	}

	public function hide():Void
	{
		frame.visible = false;
		text.visible = false;
		cursor.visible = false;
		Global.cancelTweensOf(cursor);
	}
}
