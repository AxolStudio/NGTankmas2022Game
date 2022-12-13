package yuleduel.states;

import yuleduel.globals.Sounds;
import flixel.tweens.FlxTween;
import yuleduel.ui.TutorialMessage;
import flixel.FlxSprite;
import flixel.FlxSubState;

class WinScreenState extends FlxSubState
{
	public var screen:FlxSprite;
	public var message:TutorialMessage;
	public var message2:TutorialMessage;
	public var ready:Bool = false;

	override public function create():Void
	{
		add(screen = new FlxSprite(0, 0, Global.asset("assets/images/win_screen.png")));
		screen.scrollFactor.set();

		add(message = new TutorialMessage("You SAVED Christmas!", 20, 20));

		add(message2 = new TutorialMessage("See if you can collect EVERY Card, and then talk to Santa! (There are a total of 24 unique cards you can collect right now!)"));

		message.visible = message2.visible = false;

		screen.alpha = 0;

		FlxTween.tween(screen, {alpha: 1}, .2, {
			startDelay: .2,
			onComplete: (_) ->
			{
				ready = true;
			}
		});
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (ready && Controls.justPressed.ANY)
		{
			Sounds.playSound("jingle");
			if (!message.visible && !message2.visible)
				message.visible = true;
			else if (!message2.visible && message.visible)
			{
				message2.visible = true;
				message.visible = false;
			}
			else
				exit();
		}
	}

	public function exit():Void
	{
		ready = false;
		FlxTween.tween(screen, {alpha: 0}, .2, {
			onComplete: (_) ->
			{
				close();
			}
		});
	}
}
