package holidayccg.ui;

import openfl.geom.Rectangle;
import flixel.addons.ui.FlxUI9SliceSprite;

class GameFrame extends FlxUI9SliceSprite
{
	public function new(Width:Float, Height:Float):Void
	{
		super(0, 0, Global.asset("assets/images/dialog_frame.png"), new Rectangle(0, 0, Width, Height), [3, 6, 5, 8], FlxUI9SliceSprite.TILE_BOTH);
	}
}
