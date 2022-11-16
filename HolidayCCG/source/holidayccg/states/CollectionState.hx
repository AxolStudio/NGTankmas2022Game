package holidayccg.states;

import flixel.text.FlxText.FlxTextAlign;
import holidayccg.globals.Cards;
import holidayccg.globals.GameGlobals;
import flixel.group.FlxSpriteGroup;
import holidayccg.globals.Cards.Card;
import flixel.group.FlxGroup;
import holidayccg.globals.Cards.CardGraphic;
import flixel.group.FlxGroup.FlxTypedGroup;
import holidayccg.ui.GameText;
import flixel.FlxSprite;
import holidayccg.ui.GameFrame;
import flixel.FlxSubState;

using flixel.util.FlxSpriteUtil;

class CollectionState extends FlxSubState
{
	public var back:FlxSprite;
	public var deckList:FlxTypedGroup<CardGraphic>;
	public var collection:FlxTypedSpriteGroup<CardInfo>;

	public var ready:Bool = false;

	public var inDeck:Bool = false;
	public var selectedCard:Int = -1;

	public static inline var DECK_X:Int = 217;
	public static inline var DECK_Y:Int = 40;
	public static inline var DECK_SPACE:Int = 9;

	public static inline var COLLECTION_X:Int = 11;
	public static inline var COLLECTION_Y:Int = 211;
	public static inline var COLLECTION_SPACE_W:Int = 23;
	public static inline var COLLECTION_SPACE_H:Int = 23;

	public static inline var COLLECTION_COUNT_W:Int = 8;

	public static inline var MONEY_X:Int = 948;
	public static inline var MONEY_Y:Int = 10;

	public var moneyText:GameText;

	public function new(Callback:Void->Void):Void
	{
		super();

		bgColor = 0xffffffff;

		closeCallback = Callback;

		add(collection = new FlxTypedSpriteGroup<CardInfo>());

		add(back = new FlxSprite(Global.asset("assets/images/collection_screen.png")));
		back.scrollFactor.set();

		add(deckList = new FlxTypedGroup<CardGraphic>(5));

		add(moneyText = new GameText());
		moneyText.scrollFactor.set();
		moneyText.alignment = FlxTextAlign.RIGHT;
		moneyText.x = MONEY_X - moneyText.width;
		moneyText.y = MONEY_Y;

		collection.x = COLLECTION_X;
		collection.y = COLLECTION_Y;
	}

	override function close()
	{
		for (d in deckList.members)
		{
			d.kill();
			deckList.remove(d);
			d.destroy();
		}

		for (c in collection.members)
		{
			c.kill();
			collection.remove(c);
			c.destroy();
		}

		deckList.clear();
		collection.clear();

		super.close();
	}

	public function refresh():Void
	{
		ready = false;

		moneyText.text = "$" + GameGlobals.Player.money;
		moneyText.x = MONEY_X - moneyText.width;

		var deckCard:CardGraphic = null;
		for (d in 0...GameGlobals.Player.deck.length)
		{
			deckCard = new CardGraphic();
			deckCard.spawn(GameGlobals.Player.deck.cards[d]);
			deckCard.x = 10 + DECK_X + (d * (96 + DECK_SPACE));
			deckCard.y = 10 + DECK_Y;
			deckCard.scrollFactor.set();
			deckList.add(deckCard);
			deckCard.shown = true;
		}

		var card:CardInfo = null;
		for (cID => count in GameGlobals.Player.collection.collection)
		{
			card = new CardInfo(Cards.CardList.get(cID), count);

			card.x = 10 + (collection.members.length % COLLECTION_COUNT_W) * (96 + COLLECTION_SPACE_W);
			card.y = 10 + (Std.int(collection.members.length / COLLECTION_COUNT_W) * (96 + COLLECTION_SPACE_H));
			collection.add(card);
		}

		deckList.members[0].selected = true;
		selectedCard = 0;

		inDeck = true;

		ready = true;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (!ready)
			return;
		if (Controls.justPressed.PAUSE)
			close();
		else if (Controls.justPressed.LEFT)
		{
			if (inDeck)
			{
				if (selectedCard > 0)
				{
					deckList.members[selectedCard].selected = false;
					selectedCard--;
					deckList.members[selectedCard].selected = true;
				}
				else
				{
					deckList.members[selectedCard].selected = false;
					selectedCard = deckList.members.length - 1;
					deckList.members[selectedCard].selected = true;
				}
			}
			else
			{
				if (selectedCard % COLLECTION_COUNT_W > 0)
				{
					collection.members[selectedCard].cardGraphic.selected = false;
					selectedCard--;
					collection.members[selectedCard].cardGraphic.selected = true;
				}
				else
				{
					collection.members[selectedCard].cardGraphic.selected = false;
					selectedCard += COLLECTION_COUNT_W - 1;
					selectedCard = Std.int(Math.min(selectedCard, collection.members.length - 1));
					collection.members[selectedCard].cardGraphic.selected = true;
				}
			}
		}
		else if (Controls.justPressed.RIGHT)
		{
			if (inDeck)
			{
				if (selectedCard < deckList.members.length - 1)
				{
					deckList.members[selectedCard].selected = false;
					selectedCard++;
					deckList.members[selectedCard].selected = true;
				}
				else
				{
					deckList.members[selectedCard].selected = false;
					selectedCard = 0;
					deckList.members[selectedCard].selected = true;
				}
			}
			else
			{
				if (selectedCard % COLLECTION_COUNT_W < COLLECTION_COUNT_W - 1)
				{
					collection.members[selectedCard].cardGraphic.selected = false;
					selectedCard++;
					if (selectedCard > collection.members.length - 1)
						selectedCard -= selectedCard % COLLECTION_COUNT_W;
					collection.members[selectedCard].cardGraphic.selected = true;
				}
				else
				{
					collection.members[selectedCard].cardGraphic.selected = false;
					selectedCard -= COLLECTION_COUNT_W - 1;
					collection.members[selectedCard].cardGraphic.selected = true;
				}
			}
		}
		else if (Controls.justPressed.UP)
		{
			if (inDeck)
			{
				// do nothing!
			}
			else
			{
				if (selectedCard < COLLECTION_COUNT_W)
				{
					collection.members[selectedCard].cardGraphic.selected = false;
					selectedCard = 0;
					deckList.members[selectedCard].selected = true;
					inDeck = true;
				}
				else
				{
					collection.members[selectedCard].cardGraphic.selected = false;
					selectedCard -= COLLECTION_COUNT_W;
					collection.members[selectedCard].cardGraphic.selected = true;

					if (collection.y + collection.members[selectedCard].cardGraphic.y < COLLECTION_Y)
					{
						collection.y = COLLECTION_Y - collection.members[selectedCard].cardGraphic.y;
					}
				}
			}
		}
		else if (Controls.justPressed.DOWN)
		{
			if (inDeck)
			{
				deckList.members[selectedCard].selected = false;
				selectedCard = 0;
				collection.members[selectedCard].cardGraphic.selected = true;
				inDeck = false;
			}
			else
			{
				if (selectedCard < deckList.members.length - COLLECTION_COUNT_W)
				{
					collection.members[selectedCard].cardGraphic.selected = false;
					selectedCard += COLLECTION_COUNT_W;
					collection.members[selectedCard].cardGraphic.selected = true;

					if (collection.y + collection.members[selectedCard].y + 140 > 530)
						collection.y = 530 - (collection.members[selectedCard].y + 140);
				}
				else
				{
					// do nothing!
				}
			}
		}
	}
}

class CardInfo extends FlxSpriteGroup
{
	public var card:Card;
	public var cardGraphic:CardGraphic;
	public var count:GameText;

	public function new(Card:Card, Count:Int):Void
	{
		super();
		card = Card;
		cardGraphic = new CardGraphic();
		cardGraphic.spawn(card.id);
		cardGraphic.scrollFactor.set();
		cardGraphic.shown = true;
		count = new GameText();
		count.text = 'x$Count';
		count.scrollFactor.set();
		count.x = cardGraphic.x + 92 - count.width;
		count.y = cardGraphic.y + 118 - count.height;
		add(cardGraphic);
		add(count);
	}
}
