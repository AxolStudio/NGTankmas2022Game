package yuleduel.game;

import axollib.GraphicsCache;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.tile.FlxTilemap;
import flixel.tweens.FlxTween;
import flixel.util.FlxDirectionFlags;
import yuleduel.globals.GameGlobals;

using axollib.GraphicsCache;

class GameObject extends FlxSprite
{
	public var moving:Bool = false;
	public var hasAnims:Bool = false;

	public var name:String = "";

	public function new():Void
	{
		super();

		GraphicsCache.loadAtlasGraphic(this, "sprites");
		width = height = 32;
	}

	public function spawn(Name:String, Which:String, X:Float, Y:Float, ?Facing:FlxDirectionFlags = FlxDirectionFlags.DOWN):Void
	{
		name = Name;

		offset.x = 0;
		offset.y = 16;
		if (Which == "yeti")
			offset.x = 8;
		else if (Which == "sparkle")
			offset.y = 0;
		else if (Which == "santa" || Which == "krampus")
			offset.x = 4;

		buildAnimations(Which);

		animation.finishCallback = (animName:String) ->
		{
			refreshAnimation();
		}

		reset(X, Y);
		facing = Facing;
		animation.play("stand-" + facing.toString());
	}

	public function buildAnimations(Which:String):Void
	{
		if (hasAnims)
		{
			animation.remove('stand-D');
			animation.remove('stand-U');
			animation.remove('stand-L');
			animation.remove('stand-R');
			animation.remove('walk-D');
			animation.remove('walk-U');
			animation.remove('walk-L');
			animation.remove('walk-R');
		}
		hasAnims = true;
		if (Which == "blockade")
		{
			animation.addByNames("stand-D", ["blockade_" + Std.string(FlxG.random.int(0, 2)) + ".png"], 0, false);
		}
		else if (Which == "sparkle")
		{
			animation.addByStringIndices("stand-D", "sparkle_", [
				"00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "01", "02", "03", "02", "01"
			], ".png", 8, true);
		}
		else if (Which == "statue")
		{
			animation.addByNames('stand-D', ['${Which}_DOWN_0.png'], 0, false);
		}
		else if (Which != "player")
		{
			animation.addByNames('stand-D', ['${Which}_DOWN_0.png', '${Which}_DOWN_1.png'], 4, true);
			animation.play("stand-D");
		}
		else
		{
			animation.addByNames('stand-D', ['${Which}_DOWN_0.png'], 0, false);
			animation.addByNames('stand-U', ['${Which}_UP_0.png'], 0, false);
			animation.addByNames('stand-L', ['${Which}_SIDE_0.png'], 0, false);
			animation.addByNames('stand-R', ['${Which}_SIDE_0.png'], 0, false, true);
			animation.addByNames('walk-D', [
				'${Which}_DOWN_1.png',
				'${Which}_DOWN_0.png',
				'${Which}_DOWN_2.png',
				'${Which}_DOWN_0.png'
			], 16, false);
			animation.addByNames('walk-U', [
				'${Which}_UP_1.png',
				'${Which}_UP_0.png',
				'${Which}_UP_2.png',
				'${Which}_UP_0.png'
			], 16, false);
			animation.addByNames('walk-L', [
				'${Which}_SIDE_1.png',
				'${Which}_SIDE_0.png',
				'${Which}_SIDE_2.png',
				'${Which}_SIDE_0.png'
			], 16, false);
			animation.addByNames('walk-R', [
				'${Which}_SIDE_1.png',
				'${Which}_SIDE_0.png',
				'${Which}_SIDE_2.png',
				'${Which}_SIDE_0.png'
			], 16, false, true);
		}
	}

	public function refreshAnimation():Void
	{
		if (moving)
		{
			animation.play("walk-" + facing.toString());
		}
		else
		{
			if (animation.curAnim != null)
			{
				if (animation.curAnim.name == "stand-" + facing.toString())
					return;
			}

			animation.play("stand-" + facing.toString());
		}
	}

	public static function facingFromString(Facing:String):Int
	{
		return switch (Facing)
		{
			case "UP":
				FlxDirectionFlags.UP;
			case "LEFT":
				FlxDirectionFlags.LEFT;
			case "RIGHT":
				FlxDirectionFlags.RIGHT;
			default:
				FlxDirectionFlags.DOWN;
		}
	}

	public function move(DX:Int, DY:Int, ?Callback:Void->Void):Void
	{
		if (moving)
			return;

		facing = DX == -1
			&& DY == 0 ? FlxDirectionFlags.LEFT : DX == 1
			&& DY == 0 ? FlxDirectionFlags.RIGHT : DY == -1 ? FlxDirectionFlags.UP : FlxDirectionFlags.DOWN;

		var baseMap:FlxTilemap = GameGlobals.PlayState.baseMap;
		var decorativeMap:FlxTilemap = GameGlobals.PlayState.decorativeMap;
		var mapX:Int = Std.int(x / GameGlobals.TILE_SIZE) + DX;
		var mapY:Int = Std.int(y / GameGlobals.TILE_SIZE) + DY;

		if (baseMap.getTile(mapX, mapY) >= 150
			|| decorativeMap.getTile(mapX, mapY) >= 1
			|| GameGlobals.PlayState.checkForObjects(mapX, mapY) != null)
		{
			// trace(mapX, mapY, baseMap.getTile(mapX, mapY), decorativeMap.getTile(mapX, mapY), GameGlobals.PlayState.checkForObjects(mapX, mapY));
			moving = false;

			refreshAnimation();
			return;
		}

		moving = true;

		refreshAnimation();

		FlxTween.tween(this, {x: x + (DX * GameGlobals.TILE_SIZE), y: y + (DY * GameGlobals.TILE_SIZE)}, 0.2, {
			type: FlxTweenType.ONESHOT,
			onComplete: (_) ->
			{
				moving = false;
				if (Callback != null)
					Callback();
			}
		});
	}
}
