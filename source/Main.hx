package;

import states.PlayState;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();

		addChild(new FlxGame(0, 0, PlayState, 1, 60, 60, true, false));

		Screen.initScreen();
	}
}
