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

	public static function close(DialogData:DialogData, Choice:Bool = true):Void
	{
		if (Choice)
			Dialog.parseScripts(DialogData.yes);
		else
			Dialog.parseScripts(DialogData.no);
	}

	public static function parseScripts(Scripts:Array<String>):Void
	{
		var willBattle:String = "";
		var willTalk:String = "";

		for (f in Scripts)
		{
			if (f.startsWith("flag:"))
			{
				Dialog.Flags.set(f.substr(5), true);
			}
			else if (f.startsWith("flag!"))
			{
				Dialog.Flags.set(f.substr(5), false);
			}
			else if (f.startsWith("dialog:"))
			{
				// show another dialog!
				willTalk = f.substr(7);
			}
			else if (f.startsWith("battle:"))
			{
				// start a battle!!
				willBattle = f.substr(7);
			}
		}
		if (willBattle != "")
			GameGlobals.PlayState.startBattle(willBattle);
		else if (willTalk != "")
			Dialog.talk(willTalk);
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

					GameGlobals.PlayState.showDialog(dialogs[i]);
					return true;
				}
			}
		}
		return false;
	}
}

class DialogData
{
	// what does it take to trigger this dialog?
	public var requirements(default, null):Array<String> = [];

	// what is the text of this dialog? use "Q:OptA|ObtB?Dialog" for a question
	public var text(default, null):String = "";

	// what happens when the player chooses "yes" (the first option)
	public var yes(default, null):Array<String> = [];

	// what happens when the player chooses "no" (the second option)
	public var no(default, null):Array<String> = [];

	public function new(Data:Dynamic):Void
	{
		for (i in 0...Data.requirements.length)
		{
			requirements.push(Data.requirements[i]);
		}

		text = Data.text;

		for (i in 0...Data.yes.length)
		{
			yes.push(Data.yes[i]);
		}
		for (i in 0...Data.no.length)
		{
			no.push(Data.no[i]);
		}
	}
}
