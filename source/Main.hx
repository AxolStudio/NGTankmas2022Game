package;

import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();
		addChild(new FlxGame(720, 480, PlayState));

		Screen.initScreen();
	}
}
