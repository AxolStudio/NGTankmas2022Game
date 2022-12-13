package yuleduel.states;

import yuleduel.globals.Sounds;
import flixel.FlxSprite;
import yuleduel.globals.GameGlobals;
import yuleduel.ui.TutorialMessage;
import flixel.FlxSubState;

class CollectionTutorial extends FlxSubState
{
	public var text1:TutorialMessage;
	public var text2:TutorialMessage;
	public var text3:TutorialMessage;
	public var text4:TutorialMessage;
	public var text5:TutorialMessage;
	public var text6:TutorialMessage;
	public var text7:TutorialMessage;

	public var inDeckIcon:FlxSprite;

	public var ready:Bool = false;

	public var showing:Int = 1;

	public function new(Callback:Void->Void)
	{
		super();
		closeCallback = Callback;

		openCallback = () ->
		{
			ready = true;
		};

		add(text1 = new TutorialMessage("This is the Collection Screen!\nYou can see and manage your Deck and see all the cards you have collected here.", 0,
			0, Math.ceil(Global.width / 2)));
		text1.x = Math.ceil((Global.width / 2) - (text1.width / 2));
		text1.y = Math.ceil((Global.height / 2) - (text1.height / 2));

		add(text2 = new TutorialMessage("Your Deck is shown here [", 10, 35, 190));
		add(text3 = new TutorialMessage("Your Collection down here ^", 10, 160));

		add(text4 = new TutorialMessage("Use "
			+ GameGlobals.GetInputName("move")
			+ " to select a Card from your Deck or Collection and then press "
			+ GameGlobals.GetInputName("a")
			+ "to Swap that Card with one from the other location.",
			0, 0, Math.ceil(Global.width / 2)));

		text4.x = Math.ceil((Global.width / 2) - (text4.width / 2));
		text4.y = Math.ceil(Global.height - 20 - text4.height);

		add(text5 = new TutorialMessage("Cards in your Collection marked with this symbol:\n \nare already in your Deck and cannot be moved into it.\nYou can only have one copy of each card in your Deck.",
			0, 0, Math.ceil(Global.width / 2)));
		text5.x = Math.ceil((Global.width / 2) - (text5.width / 2));
		text5.y = Math.ceil((Global.height / 2) - (text5.height / 2));

		add(inDeckIcon = new FlxSprite(Global.asset("assets/images/in_deck_icon.png")));
		inDeckIcon.scale.set(2, 2);
		inDeckIcon.updateHitbox();
		inDeckIcon.x = text5.x + (text5.width / 2) - (inDeckIcon.width / 2);
		inDeckIcon.y = text5.lines[1].y + text5.lines[1].height + TutorialMessage.lineSpacing;
		inDeckIcon.scrollFactor.set();
		inDeckIcon.visible = false;

		add(text6 = new TutorialMessage("You can also see how many Yule Coins ($) you have here ["));
		text6.x = 775 - text6.width;
		text6.y = 10;

		add(text7 = new TutorialMessage("You can buy packs of Cards with $ or Sell your duplicate Cards to gain extra $ in the Shop!", 0, 0,
			Math.ceil(Global.width / 2)));
		text7.x = (Global.width / 2) - (text7.width / 2);
		text7.y = (Global.height / 2) - (text7.height / 2);

		text2.visible = text3.visible = text4.visible = text5.visible = text6.visible = text7.visible = false;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (ready)
		{
			if (Controls.justPressed.A || Controls.justPressed.B || Controls.justPressed.PAUSE)
			{
				Sounds.playSound("jingle");
				switch (showing)
				{
					case 1:
						text1.visible = false;
						text2.visible = text3.visible = true;
						showing++;

					case 2:
						text2.visible = text3.visible = false;
						text4.visible = true;
						showing++;

					case 3:
						text4.visible = false;
						text5.visible = true;
						inDeckIcon.visible = true;
						showing++;

					case 4:
						text5.visible = false;
						inDeckIcon.visible = false;
						text6.visible = true;
						showing++;

					case 5:
						text6.visible = false;
						text7.visible = true;
						showing++;

					case 6:
						text7.visible = false;

						ready = false;
						close();
				}
			}
		}
	}
}
