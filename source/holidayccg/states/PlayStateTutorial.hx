package holidayccg.states;

import holidayccg.globals.Sounds;
import holidayccg.globals.GameGlobals;
import holidayccg.ui.TutorialMessage;
import flixel.FlxSubState;

class PlayStateTutorial extends FlxSubState
{
	public var tutorialMessage1:TutorialMessage;

	public var ready:Bool = false;

	public function new(Callback:Void->Void):Void
	{
		super();
		closeCallback = Callback;
		openCallback = () ->
		{
			ready = true;
		};

		tutorialMessage1 = new TutorialMessage("Welcome to the NORTH POLE! \n\nMove around with "
			+ GameGlobals.GetInputName("move")
			+ " and speak/interact with "
			+ GameGlobals.GetInputName("a")
			+ "\n\nTry talking to this friendly fellow in front of you!\n\nPress "
			+ GameGlobals.GetInputName("a")
			+ " to continue.",
			0, 0, Math.ceil(Global.width * .66));

		tutorialMessage1.x = (Global.width / 2) - (tutorialMessage1.width / 2);
		tutorialMessage1.y = (Global.height / 2) - (tutorialMessage1.height / 2);

		add(tutorialMessage1);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (ready)
		{
			if (Controls.justPressed.A)
			{
				ready = false;
				Sounds.playSound("jingle");
				close();
			}
		}
	}
}
