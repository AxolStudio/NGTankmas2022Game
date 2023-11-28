package yuleduel.globals;

using StringTools;

@:build(yuleduel.macros.DialogBuilder.build()) // DialogList
class Dialog
{
	public static var Flags:Map<String, Bool> = [];

	public static function checkFlag(Flag:String):Bool
	{
		return Flags.exists(Flag) && Flags.get(Flag);
	}

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
			Dialog.parseScripts(DialogData.yes.copy());
		else
			Dialog.parseScripts(DialogData.no.copy());
	}

	public static function parseScripts(Scripts:Array<String>):Void
	{
		var willBattle:String = "";
		var willTalk:String = "";
		var message:String = "";
		var willOpenShop:Bool = false;
		var givingBadge:String = "";
		var gamingOver:Bool = false;

		var spawning:String = "";

		for (f in Scripts)
		{
			if (f == "openShop")
			{
				willOpenShop = true;
			}
			else if (f.startsWith("flag:"))
			{
				Dialog.Flags.set(f.substr(5), true);
			}
			else if (f.startsWith("flag!"))
			{
				Dialog.Flags.set(f.substr(5), false);
			}
			else if (f.startsWith("message:"))
			{
				message = f.substr(8);
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
			else if (f.startsWith("destroy:"))
			{
				Dialog.Flags.set(f.substr(8) + "-dead", true);
				GameGlobals.save();
				GameGlobals.PlayState.killObject(f.substr(8));
			}
			else if (f.startsWith("giveBadge:"))
			{
				givingBadge = f.substr(10);
			}
			else if (f.startsWith("giveCard:"))
			{
				GameGlobals.PlayState.giveCard(Std.parseInt(f.substr(9)));
			}
			else if (f.startsWith("spawn:"))
			{
				spawning = f.substr(6);
			}
			else if (f == "gameOver")
			{
				gamingOver = true;
			}
			else if (f.startsWith("giveMedal:"))
			{
				NGAPI.unlockMedal(Std.parseInt(f.substr(10)));

			}
		}
		if (willBattle != "")
			GameGlobals.PlayState.startBattle(willBattle);
		else if (message != "")
			Dialog.message(message);
		else if (willTalk != "")
			Dialog.talk(willTalk);
		else if (willOpenShop)
			GameGlobals.PlayState.openShop();
		else if (givingBadge != "")
			GameGlobals.PlayState.giveBadge(givingBadge);
		else if (spawning != "")
			GameGlobals.PlayState.spawnObject(spawning);
		else if (gamingOver)
			GameGlobals.PlayState.gameOver();
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
					if (dialogs[i].text == "")
					{
						parseScripts(dialogs[i].yes.copy());
					}
					else
					{
						GameGlobals.PlayState.showDialog(dialogs[i]);
					}
					return true;
				}
			}
		}
		return false;
	}

	public static function message(Message:String):Void
	{
		GameGlobals.PlayState.showMessage(Message);
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
