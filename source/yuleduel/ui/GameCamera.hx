package yuleduel.ui;

import flixel.math.FlxMath;
import flixel.FlxCamera;

class GameCamera extends FlxCamera
{
	override public function updateScroll():Void
	{
		var minY:Null<Float> = minScrollY == null ? null : minScrollY; // - (zoom - 1) * height / (2 * zoom);
		var minX:Null<Float> = minScrollX == null ? null : minScrollX; // - (zoom - 1) * width / (2 * zoom);
		var maxX:Null<Float> = maxScrollX == null ? null : maxScrollX; // + (zoom - 1) * width / (2 * zoom);
		var maxY:Null<Float> = maxScrollY == null ? null : maxScrollY; // + (zoom - 1) * height / (2 * zoom);

		// Make sure we didn't go outside the camera's bounds
		scroll.x = FlxMath.bound(scroll.x, minX, (maxX != null) ? maxX - width : null);
		scroll.y = FlxMath.bound(scroll.y, minY, (maxY != null) ? maxY - height : null);
	}
}
