package holidayccg.states;

import flixel.util.FlxDestroyUtil;
import holidayccg.globals.GameGlobals;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxG;
import flixel.tweens.FlxTween;
import holidayccg.globals.GraphicsCache;
import flixel.FlxSprite;
import holidayccg.ui.TutorialMessage;
import flixel.FlxSubState;

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
				FlxTween.tween(badge, {alpha: 1}, .5, {
					onComplete: (_) ->
					{
						sparkles.add(new Sparkle());
						badgeText = new TutorialMessage("You got the " + TitleCase.toTitleCase(whichBadge) + " Badge!");
						badgeText.x = FlxG.width / 2 - badgeText.width / 2;
						badgeText.y = badge.y + badge.height + 10;
						add(badgeText);

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
			exit();
		}
	}

	public function exit()
	{
		ready = false;
		FlxTween.tween(blackout, {alpha: 0}, 0.25, {
			onComplete: (_) ->
			{
				close();
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
	public function new():Void
	{
		super();

		frames = GraphicsCache.getAtlasFrames(Global.asset("assets/images/sparkle.png"), Global.asset("assets/images/sparkle.xml"), "sparkle");
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
		x = FlxG.random.float(Global.width / 2 - 32 - 16, Global.width / 2 + 32 - 16);
		y = FlxG.random.float(Global.height / 2 - 32 - 16, Global.height / 2 + 32 - 16);

		animation.play("sparkle");
	}
}
