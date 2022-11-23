package holidayccg.states;

import holidayccg.globals.GameGlobals;
import flixel.FlxSubState;

class CreditState extends FlxSubState
{
	public function new(Callback:Void->Void):Void
	{
		super();
		closeCallback = Callback;
	}

	override function draw()
	{
		super.draw();
		if (GameGlobals.transition.transitioning)
			GameGlobals.transition.draw();
	}
}
