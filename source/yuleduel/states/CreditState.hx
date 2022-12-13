package yuleduel.states;

import yuleduel.globals.Sounds;
import yuleduel.ui.GameText;
import yuleduel.ui.GameFrame;
import yuleduel.globals.GameGlobals;
import flixel.FlxSubState;

class CreditState extends FlxSubState
{
	public var ready:Bool = false;

	public function new(Callback:Void->Void):Void
	{
		super();
		closeCallback = Callback;
	}

	override function create()
	{
		var frame:GameFrame = new GameFrame(Global.width, Global.height);
		add(frame);

		var text:GameText = new GameText();
		text.text = "Credits";
		text.x = Global.width / 2 - text.width / 2;
		text.y = 10;
		add(text);

		text = new GameText();
		text.text = "Tim I Hely: Programming, Design";
		text.x = Global.width / 2 - text.width / 2;
		text.y = 60;
		add(text);

		text = new GameText();
		text.text = "bingowaders: Sprites, Card Illustrations";
		text.x = Global.width / 2 - text.width / 2;
		text.y = 100;
		add(text);

		text = new GameText();
		text.text = "Gallow: Tiles";
		text.x = Global.width / 2 - text.width / 2;
		text.y = 140;
		add(text);

		text = new GameText();
		text.text = "Albe: Music";
		text.x = Global.width / 2 - text.width / 2;
		text.y = 180;
		add(text);

		text = new GameText();
		text.text = "Press any key";
		text.x = Global.width / 2 - text.width / 2;
		text.y = Global.height - text.height - 10;
		add(text);

		super.create();

		GameGlobals.transIn(() ->
		{
			ready = true;
		});
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (ready)
		{
			if (Controls.justPressed.ANY)
			{
				Sounds.playSound("jingle");
				ready = false;
				GameGlobals.transOut(() ->
				{
					close();
				});
			}
		}
	}

	override function draw()
	{
		super.draw();
		if (GameGlobals.transition.transitioning)
			GameGlobals.transition.draw();
	}
}
