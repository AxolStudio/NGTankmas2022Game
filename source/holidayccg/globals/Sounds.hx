package holidayccg.globals;

import flixel.system.FlxSound;
import flixel.FlxG;

class Sounds
{
	public static var currentMusic:String = "";

	public static function playSound(SoundName:String, ?Volume:Float = .5):Void
	{
		FlxG.sound.play(Global.asset('assets/sounds/$SoundName.ogg'), Volume);
	}

	public static function playOneOf(SoundList:Array<String>, ?Volume:Float = .5):Void
	{
		FlxG.random.shuffle(SoundList);
		playSound(SoundList[0], Volume);
	}

	public static function playMusic(TrackName:String):Void
	{
		if (currentMusic == TrackName)
			return;
		currentMusic = TrackName;
		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.fadeOut(.2, 0, (_) ->
			{
				if (TrackName != "")
				{
					FlxG.sound.playMusic(Global.asset('assets/music/$TrackName.ogg'));
					FlxG.sound.music.fadeIn(.2);
				}
			});
		}
		else
		{
			if (TrackName != "")
			{
				FlxG.sound.playMusic(Global.asset('assets/music/$TrackName.ogg'));
				FlxG.sound.music.fadeIn(.2);
			}
		}
	}
}
