package globals;

import flixel.system.scaleModes.PixelPerfectScaleMode;
import lime.system.DisplayMode;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;

class Screen
{
	public static function initScreen():Void
	{
		FlxG.scaleMode = new PixelPerfectScaleMode();

		FlxG.game.setFilters([new ShaderFilter(new FlxShader())]);
		FlxG.game.stage.quality = StageQuality.LOW;

		FlxG.autoPause = false;
	}
}
