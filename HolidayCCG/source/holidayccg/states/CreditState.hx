package holidayccg.states;

import holidayccg.ui.GameText;
import holidayccg.ui.GameFrame;
import holidayccg.globals.GameGlobals;
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
		text.y = 50;
		add(text);

		text = new GameText();
		text.text = "bingowaders: Sprites, Card Illustrations";
		text.x = Global.width / 2 - text.width / 2;
		text.y = 70;
		add(text);

		text = new GameText();
		text.text = "Gallow: Tiles";
		text.x = Global.width / 2 - text.width / 2;
		text.y = 90;
		add(text);

		text = new GameText();
		text.text = "Albe: Music";
		text.x = Global.width / 2 - text.width / 2;
		text.y = 110;
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
