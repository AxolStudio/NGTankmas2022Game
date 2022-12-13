package yuleduel.ui;

import openfl.geom.Rectangle;
import flixel.addons.ui.FlxUI9SliceSprite;

class GameFrame extends FlxUI9SliceSprite
{
	public function new(Width:Float, Height:Float):Void
	{
		Width = Width % 8 + Width;
		Height = Height % 8 + Height;
		super(0, 0, Global.asset("assets/images/dialog_frame.png"), new Rectangle(0, 0, Width, Height), [16, 16, 32, 32], FlxUI9SliceSprite.TILE_BOTH);
	}
}
