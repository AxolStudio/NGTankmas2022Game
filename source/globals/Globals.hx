package globals;

import states.PlayState;

@:build(macros.MapBuilder.build()) // MapList
class Globals
{
	public static var initialized:Bool = false;

	public static var PlayState:PlayState;

	public static function init():Void
	{
		if (initialized)
			return;
		initialized = true;
		Actions.init();

		trace(MapList.get("test room"));
	}
}
