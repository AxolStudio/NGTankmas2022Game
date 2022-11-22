package holidayccg.globals;

import flixel.system.FlxSound;
import flixel.FlxG;

class Sounds
{
	public static function playSound(SoundName:String, ?Volume:Float = .5):Void
	{
		var s:FlxSound = FlxG.sound.play(Global.asset('assets/sounds/$SoundName.ogg'), Volume);
		
	}

	public static function playOneOf(SoundList:Array<String>, ?Volume:Float = .5):Void
	{
		FlxG.random.shuffle(SoundList);
		playSound(SoundList[0], Volume);
	}
}
