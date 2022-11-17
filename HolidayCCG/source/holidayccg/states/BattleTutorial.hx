package holidayccg.states;

import holidayccg.globals.Cards.CardGraphic;
import holidayccg.globals.GameGlobals;
import holidayccg.ui.TutorialMessage;
import flixel.FlxSubState;

class BattleTutorial extends FlxSubState
{
	public var tutorial1:TutorialMessage;
	public var tutorial2:TutorialMessage;
	public var tutorial3:TutorialMessage;
	public var tutorial4:TutorialMessage;
	public var tutorial5:TutorialMessage;
	public var tutorial6:TutorialMessage;
	public var tutorial7:TutorialMessage;
	public var tutorial8:TutorialMessage;
	public var tutorial9:TutorialMessage;
	public var tutorial10:TutorialMessage;
	public var tutorial11:TutorialMessage;
	public var tutorial12:TutorialMessage;
	public var tutorial13:TutorialMessage;
	public var tutorial14:TutorialMessage;
	public var tutorial15:TutorialMessage;

	public var card:CardGraphic;

	public var ready:Bool = false;

	public var showing:Int = 1;

	public function new(Callback:Void->Void):Void
	{
		super();

		closeCallback = () ->
		{
			tutorial15.visible = card.visible = tutorial1.visible = tutorial2.visible = tutorial3.visible = tutorial4.visible = tutorial5.visible = tutorial6.visible = tutorial7.visible = tutorial8.visible = tutorial9.visible = tutorial10.visible = tutorial11.visible = tutorial12.visible = tutorial13.visible = tutorial14.visible = false;
			Callback();
		};
		openCallback = () ->
		{
			ready = true;
		};

		// 1
		add(tutorial1 = new TutorialMessage("This is the Battlefield!\nEvery game of ???? is played on this 3x3 grid.", 0, 0, Math.ceil(Global.width / 2)));

		tutorial1.x = Math.ceil((Global.width - tutorial1.width) / 2);
		tutorial1.y = Math.ceil((Global.height - tutorial1.height) / 2);

		// 2
		add(tutorial2 = new TutorialMessage("Each player enters the Battle with a Deck of 5 unique cards.\nYou can modify your deck in the Collection Screen, outside of battle.",
			0, 0,
			Math.ceil(Global.width / 2)));

		tutorial2.x = Math.ceil((Global.width - tutorial1.width) / 2);
		tutorial2.y = Math.ceil((Global.height - tutorial1.height) / 2);

		// 3
		add(tutorial3 = new TutorialMessage("^ Your Deck is here", 100, 100));
		add(tutorial4 = new TutorialMessage("Your opponent's Deck is here [", 0, 330));
		tutorial4.x = 768 - 20 - tutorial4.width;

		// 4
		add(tutorial5 = new TutorialMessage("Cards have a Name, Value, and Attack Directions.", 0, 0, Math.ceil(Global.width / 2)));
		add(card = new CardGraphic());
		card.spawn(1);

		Global.screenCenter(card);
		card.x += 10;
		card.y += 10;
		card.shown = true;
		tutorial5.x = Math.ceil((Global.width - tutorial5.width) / 2);
		tutorial5.y = card.y - tutorial5.height - 10;

		// 5
		add(tutorial6 = new TutorialMessage("Starting with the First Player (chosen randomly), each player takes turns playing a card from their Deck.\nHighlight a Card with "
			+ GameGlobals.GetInputName("move")
			+ " then use "
			+ GameGlobals.GetInputName("a")
			+ " to select it.",
			0, 0, Math.ceil(Global.width / 2)));

		tutorial6.x = Math.ceil((Global.width - tutorial1.width) / 2);
		tutorial6.y = Math.ceil((Global.height - tutorial1.height) / 2);
		// 6
		add(tutorial7 = new TutorialMessage("Move the highlighter to an empty space on the Battlefield and press "
			+ GameGlobals.GetInputName("a")
			+ " to place your Card in that space.", 0,
			0, Math.ceil(Global.width / 2)));
		tutorial7.x = Math.ceil((Global.width - tutorial1.width) / 2);
		tutorial7.y = Math.ceil((Global.height - tutorial1.height) / 2);

		// 7
		add(tutorial8 = new TutorialMessage("When a Card is placed on the Battlfield it will Attack every touching that is claimed by the other player, in the dirction of the Attacks on the Card.",
			0, 0, Math.ceil(Global.width / 2)));
		tutorial8.x = Math.ceil((Global.width - tutorial1.width) / 2);
		tutorial8.y = Math.ceil((Global.height - tutorial1.height) / 2);

		// 8
		add(tutorial9 = new TutorialMessage("If the Attacking Card has a higher Value than the Defending Card, the Defending Card is claimed by the Attacking Player and changes color.",
			0,
			0, Math.ceil(Global.width / 2)));
		tutorial9.x = Math.ceil((Global.width - tutorial1.width) / 2);
		tutorial9.y = Math.ceil((Global.height - tutorial1.height) / 2);

		// 9
		add(tutorial10 = new TutorialMessage("Cards Claimed by You are Green.\nYour Opponent's Cards are Red.", 0, 0, Math.ceil(Global.width / 2)));
		tutorial10.x = Math.ceil((Global.width - tutorial1.width) / 2);
		tutorial10.y = Math.ceil((Global.height - tutorial1.height) / 2);

		// 10
		add(tutorial14 = new TutorialMessage("Try to finish this game and see if you can beat me!\nGood Luck!", 0, 0, Math.ceil(Global.width / 2)));
		tutorial14.x = Math.ceil((Global.width - tutorial1.width) / 2);
		tutorial14.y = Math.ceil((Global.height - tutorial1.height) / 2);

		// 11
		add(tutorial11 = new TutorialMessage("After the final Card is played, the Player who has Claimed the most Cards on the Battlefield is the winner!", 0,
			0, Math.ceil(Global.width / 2)));
		tutorial11.x = Math.ceil((Global.width - tutorial1.width) / 2);
		tutorial11.y = Math.ceil((Global.height - tutorial1.height) / 2);

		// 12
		add(tutorial12 = new TutorialMessage("If You win a match, you can take a card from your Opponent to add to your Collection!\nYou'll also recieve a reward of Yule Coins($) which can be spent to buy new cards in the Shop!",
			0, 0, Math.ceil(Global.width / 2)));
		tutorial12.x = Math.ceil((Global.width - tutorial1.width) / 2);
		tutorial12.y = Math.ceil((Global.height - tutorial1.height) / 2);

		// 13
		add(tutorial13 = new TutorialMessage("Your Opponents may change their Decks around after being defeated - so try battling them again from time-to-time!",
			0, 0,
			Math.ceil(Global.width / 2)));
		tutorial13.x = Math.ceil((Global.width - tutorial1.width) / 2);
		tutorial13.y = Math.ceil((Global.height - tutorial1.height) / 2);

		// 14
		add(tutorial15 = new TutorialMessage("That's just about everything!", 0, 0, Math.ceil(Global.width / 2)));
		tutorial15.x = Math.ceil((Global.width - tutorial1.width) / 2);
		tutorial15.y = Math.ceil((Global.height - tutorial1.height) / 2);

		tutorial15.visible = card.visible = tutorial2.visible = tutorial3.visible = tutorial4.visible = tutorial5.visible = tutorial6.visible = tutorial7.visible = tutorial8.visible = tutorial9.visible = tutorial10.visible = tutorial11.visible = tutorial12.visible = tutorial13.visible = tutorial14.visible = false;
	}

	public function init(Which:Int = 0):Void
	{
		showing = Which;

		switch (showing)
		{
			case 2:
				tutorial2.visible = true;

			case 5:
				tutorial6.visible = true;

			case 6:
				tutorial7.visible = true;

			case 7:
				tutorial8.visible = true;

			case 10:
				tutorial14.visible = true;

			case 11:
				tutorial11.visible = true;
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (ready)
		{
			if (Controls.justPressed.A || Controls.justPressed.B || Controls.justPressed.PAUSE)
			{
				switch (showing)
				{
					case 2:
						tutorial2.visible = false;
						tutorial3.visible = tutorial4.visible = true;
						showing++;

					case 3:
						tutorial3.visible = tutorial4.visible = false;
						tutorial5.visible = true;
						card.visible = true;
						showing++;

					case 4:
						card.visible = tutorial5.visible = false;
						tutorial6.visible = true;
						showing++;

					case 7:
						tutorial8.visible = false;
						tutorial9.visible = true;
						showing++;

					case 8:
						tutorial9.visible = false;
						tutorial10.visible = true;
						showing++;

					case 11:
						tutorial11.visible = false;
						tutorial12.visible = true;
						showing++;

					case 12:
						tutorial12.visible = false;
						tutorial13.visible = true;
						showing++;

					case 13:
						tutorial13.visible = false;
						tutorial15.visible = true;
						showing++;

					default:
						close();
				}
			}
		}
	}
}
