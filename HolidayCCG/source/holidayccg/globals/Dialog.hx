package holidayccg.globals;

using StringTools;

@:build(holidayccg.macros.DialogBuilder.build()) // DialogList
class Dialog
{
	public static var Flags:Map<String, Bool> = [];

	public static function meetsRequirements(Requirements:Array<String>):Bool
	{
		for (r in Requirements)
		{
			if (r.startsWith("flag:")) // flag is true
			{
				if (!Flags.exists(r.substr(5)) || !Flags.get(r.substr(5)))
				{
					return false;
				}
			}
			else if (r.startsWith("flag!")) // flag is false
			{
				if (Flags.exists(r.substr(5)) && Flags.get(r.substr(5)))
				{
					return false;
				}
			}
		}
		return true;
	}

	public static function showDialog(Text:String):Void
	{
		GameGlobals.PlayState.showDialog(Text);
	}

	public static function setFlags(Flags:Array<String>):Void
	{
		for (f in Flags)
		{
			if (f.startsWith("flag:"))
			{
				Dialog.Flags.set(f.substr(5), true);
			}
			else if (f.startsWith("flag!"))
			{
				Dialog.Flags.set(f.substr(5), false);
			}
		}
	}

	public static function talk(Who:String):Bool
	{
		if (DialogList.exists(Who))
		{
			var dialogs:Array<DialogData> = DialogList.get(Who);
			for (i in 0...dialogs.length)
			{
				if (meetsRequirements(dialogs[i].requirements))
				{
					// show the dialog box!
					showDialog(dialogs[i].text);
					setFlags(dialogs[i].after);
					return true;
				}
			}
		}
		return false;
	}
}

class DialogData
{
	public var requirements(default, null):Array<String> = [];
	public var text(default, null):String = "";
	public var after(default, null):Array<String> = [];

	public function new(Data:Dynamic):Void
	{
		for (i in 0...Data.requirements.length)
		{
			requirements.push(Data.requirements[i]);
		}
		text = Data.text;
		for (i in 0...Data.after.length)
		{
			after.push(Data.after[i]);
		}
	}
}
