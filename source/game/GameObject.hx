package game;

import flixel.tile.FlxTilemap;
import flixel.tweens.FlxTween;

class GameObject extends FlxSprite
{
	public var moving:Bool = false;

	public function new():Void
	{
		super();
	}

	public function spawn(Which:String, X:Float, Y:Float):Void
	{
		loadGraphic('assets/images/${Which}.png', true, 24, 24, false, Which);

		animation.add('stand-DOWN', [0], 0, false);
		animation.add('stand-UP', [3], 0, false);
		animation.add('stand-LEFT', [6], 0, false);
		animation.add('stand-RIGHT', [6], 0, false, true);
		animation.add('walk-DOWN', [1, 0, 2, 0], 24, false);
		animation.add('walk-UP', [4, 3, 5, 3], 24, false);
		animation.add('walk-LEFT', [7, 6, 8, 6], 24, false);
		animation.add('walk-RIGHT', [7, 6, 8, 6], 24, false, true);

		animation.finishCallback = (animName:String) ->
		{
			refreshAnimation();
		}

		reset(X, Y);
	}

	public function refreshAnimation():Void
	{
		if (moving)
		{
			animation.play("walk-" + GameObject.getFacingString(facing));
		}
		else if (!StringTools.startsWith(animation.curAnim.name, 'stand')
			|| animation.curAnim.name != "stand-" + GameObject.getFacingString(facing))
		{
			animation.play("stand-" + GameObject.getFacingString(facing));
		}
	}

	public static function getFacingString(facing:Int):String
	{
		switch (facing)
		{
			case FlxObject.UP:
				return "UP";
			case FlxObject.DOWN:
				return "DOWN";
			case FlxObject.LEFT:
				return "LEFT";
			case FlxObject.RIGHT:
				return "RIGHT";
		}
		return "DOWN";
	}

	public function move(DX:Int, DY:Int):Void
	{
		if (moving)
			return;

		facing = DX == -1 && DY == 0 ? FlxObject.LEFT : DX == 1 && DY == 0 ? FlxObject.RIGHT : DY == -1 ? FlxObject.UP : FlxObject.DOWN;

		trace(facing, GameObject.getFacingString(facing));

		if (x + DX < 0 || x + DX > FlxG.width || y + DY < 0 || y + DY > FlxG.height)
			return;
		var map:FlxTilemap = Globals.PlayState.map;
		if (map.getTile(Std.int(x / 24) + DX, Std.int(y / 24) + DY) >= 45)
			return;

		moving = true;

		refreshAnimation();

		FlxTween.tween(this, {x: x + (DX * 24), y: y + (DY * 24)}, 0.2, {
			type: FlxTweenType.ONESHOT,
			onComplete: (_) ->
			{
				moving = false;
			}
		});
	}
}
