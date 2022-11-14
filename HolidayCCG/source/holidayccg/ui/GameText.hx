package holidayccg.ui;

import flixel.graphics.frames.FlxBitmapFont;
import flixel.text.FlxBitmapText;

class GameText extends FlxBitmapText
{
	public function new():Void
	{
		super(FlxBitmapFont.fromAngelCode(Global.asset("assets/images/basic_font.png"), Global.asset("assets/images/basic_font.xml")));
	}
}
