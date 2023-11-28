package yuleduel.states;

import axollib.GraphicsCache;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxTween;
import flixel.util.FlxDestroyUtil;
import yuleduel.globals.GameGlobals;
import yuleduel.globals.Sounds;
import yuleduel.ui.TutorialMessage;

class GiveBadgeState extends FlxSubState
{
	public var badge:FlxSprite;
	public var badgeText:TutorialMessage;

	public var sparkles:FlxTypedGroup<Sparkle>;

	public var whichBadge:String = "";

	public var blackout:FlxSprite;

	public var ready:Bool = false;

	override public function create():Void
	{
		openCallback = start;

		add(blackout = new FlxSprite());
		blackout.makeGraphic(Global.width, Global.height, GameGlobals.ColorPalette[1]);
		blackout.alpha = 0;

		add(badge = GraphicsCache.loadFlxSpriteFromAtlas("badges"));
		Global.screenCenter(badge);

		add(sparkles = new FlxTypedGroup<Sparkle>());

		super.create();
	}

	public function new(WhichBadge:String):Void
	{
		super();

		whichBadge = WhichBadge;
	}

	public function start():Void
	{
		badge.alpha = 0;

		badge.animation.frameName = whichBadge + "_badge.png";

		FlxTween.tween(blackout, {alpha: 0.8}, 0.25, {
			onComplete: (_) ->
			{
				sparkles.add(new Sparkle(badge.width, badge.height));
				FlxTween.tween(badge, {alpha: 1}, .5, {
					onComplete: (_) ->
					{
						sparkles.add(new Sparkle(badge.width, badge.height));
						badgeText = new TutorialMessage("You got the " + TitleCase.toTitleCase(whichBadge) + " Badge!");
						badgeText.x = Global.width / 2 - badgeText.width / 2;
						badgeText.y = badge.y + badge.height + 10;
						add(badgeText);

						Sounds.playSound("success");

						ready = true;
					}
				});
			}
		});
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (ready && (Controls.justPressed.A || Controls.justPressed.B || Controls.justPressed.PAUSE))
		{
			Sounds.playSound("jingle");
			exit();
		}
	}

	public function exit()
	{
		ready = false;
		sparkles.kill();
		FlxTween.tween(badge, {alpha: 0}, .5, {
			onComplete: (_) ->
			{
				FlxTween.tween(blackout, {alpha: 0}, 0.25, {
					onComplete: (_) ->
					{
						close();
					}
				});
			}
		});
	}

	override function destroy()
	{
		badge = FlxDestroyUtil.destroy(badge);
		badgeText = FlxDestroyUtil.destroy(badgeText);
		sparkles = FlxDestroyUtil.destroy(sparkles);

		super.destroy();
	}
}

class Sparkle extends FlxSprite
{
	var rangeX:Float = 0;
	var rangeY:Float = 0;

	public function new(RangeX:Float = 0, RangeY:Float = 0):Void
	{
		super();

		rangeX = RangeX;
		rangeY = RangeY;

		frames = GraphicsCache.loadAtlasFrames(Global.asset("assets/images/sparkle.png"), Global.asset("assets/images/sparkle.xml"), "sparkle");
		animation.addByStringIndices("sparkle", "sparkle_", ["01", "02", "03", "02", "01"], ".png", 8, false);
		scrollFactor.set();
		animation.finishCallback = (_) ->
		{
			spawn();
		};
		spawn();
	}

	public function spawn():Void
	{
		x = (Global.width / 2) - (width / 2) + FlxG.random.float(-(rangeX / 2), rangeX / 2);
		y = (Global.height / 2) - (height / 2) + FlxG.random.float(-(rangeY / 2), rangeY / 2);

		animation.play("sparkle");
	}
}
