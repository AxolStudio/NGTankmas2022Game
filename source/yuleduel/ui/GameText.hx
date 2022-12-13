package yuleduel.ui;

import flixel.graphics.frames.FlxBitmapFont;
import flixel.text.FlxBitmapText;

class GameText extends FlxBitmapText
{
	public function new(Font:Font = DEFAULT):Void
	{
		super(getFont(Font));
	}

	public function getFont(Which:Font):FlxBitmapFont
	{
		return switch (Which)
		{
			case DEFAULT:
				FlxBitmapFont.fromAngelCode(Global.asset("assets/images/basic_font.png"), Global.asset("assets/images/basic_font.xml"));
			case CARD_TEXT:
				FlxBitmapFont.fromAngelCode(Global.asset("assets/images/card_text.png"), Global.asset("assets/images/card_text.xml"));
			case CARD_NUMBERS:
				FlxBitmapFont.fromAngelCode(Global.asset("assets/images/card_numbers.png"), Global.asset("assets/images/card_numbers.xml"));
		}
	}
}

@:enum abstract Font(String)
{
	var DEFAULT = "default";
	var CARD_TEXT = "card text";
	var CARD_NUMBERS = "card number";
}
