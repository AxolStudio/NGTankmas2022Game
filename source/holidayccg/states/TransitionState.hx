package holidayccg.states;

import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxTween;
import flixel.addons.ui.FlxUI9SliceSprite;
import openfl.geom.Rectangle;

class TransitionState extends FlxTypedGroup<FlxUI9SliceSprite>
{
	public var canes:Array<FlxUI9SliceSprite> = [];

	public var transitioning:Bool = false;

	public function new():Void
	{
		super();
		cameras = [FlxG.camera];
		var cane:FlxUI9SliceSprite = null;
		for (i in 0...9)
		{
			cane = new FlxUI9SliceSprite(-60 + (i * 120), -60, Global.asset("assets/images/candy_cane.png"), new Rectangle(0, 0, 120, 660), [0, 60, 120, 120],
				FlxUI9SliceSprite.TILE_BOTH);
			cane.scrollFactor.set(0, 0);
			canes.push(cane);
			add(cane);
		}
	}

	public function start(In:Bool, Callback:Void->Void):Void
	{
		transitioning = true;
		for (i in 0...9)
		{
			if (In)
				canes[i].y = -60;
			else
				canes[i].y = i % 2 == 0 ? -canes[i].height : Global.height;
		}

		FlxTween.num(0, 600, .5, {
			onComplete: (_) ->
			{
				transitioning = false;
				Callback();
			}
		}, (Value:Float) ->
			{
				for (i in 0...9)
				{
					if (In)
					{
						canes[i].y = i % 2 == 0 ? -60 + Value : -60 - Value;
					}
					else
					{
						canes[i].y = i % 2 == 0 ? Value - canes[i].height : Global.height - Value;
					}
				}
			});
	}
}
