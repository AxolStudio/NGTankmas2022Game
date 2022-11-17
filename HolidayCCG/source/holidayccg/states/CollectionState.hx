package holidayccg.states;

import holidayccg.globals.Dialog;
import holidayccg.globals.GraphicsCache;
import flixel.util.FlxDirectionFlags;
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
using holidayccg.globals.GameGlobals.TitleCase;

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

	public static inline var CARD_SWAPPING_X:Int = 60;

	public var swapping:Bool = false;

	public var moneyText:GameText;
	public var swappingCardArrow:FlxSprite;

	public var swappingCardInDeck:Int = -1;
	public var swappingCardID:Int = -1;

	public var tmpSwappingCard:CardGraphic;

	public var cardName:GameText;

	public function new(Callback:Void->Void):Void
	{
		super();

		bgColor = 0xffffffff;

		openCallback = () ->
		{
			if (!Dialog.Flags.get("seenCollTut"))
			{
				ready = false;
				openSubState(new CollectionTutorial(returnFromTutorial));
			}
		}

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

		add(swappingCardArrow = new FlxSprite(Global.asset("assets/images/swapCard_arrows.png")));
		swappingCardArrow.scrollFactor.set();
		swappingCardArrow.x = 168;
		swappingCardArrow.y = 94;

		swappingCardArrow.setFacingFlip(FlxDirectionFlags.LEFT, false, false);
		swappingCardArrow.setFacingFlip(FlxDirectionFlags.RIGHT, true, false);

		swappingCardArrow.visible = false;

		add(tmpSwappingCard = new CardGraphic());
		tmpSwappingCard.scrollFactor.set();
		tmpSwappingCard.spawn(1);
		tmpSwappingCard.x = 10 + CARD_SWAPPING_X;
		tmpSwappingCard.y = 10 + DECK_Y;
		tmpSwappingCard.shown = true;

		tmpSwappingCard.visible = false;

		add(cardName = new GameText());
		cardName.scrollFactor.set();
		// cardName.alignment = FlxTextAlign.CENTER;
		cardName.x = Std.int((Global.width / 2) - (cardName.width / 2));
		cardName.y = 512;
		// cardName.visible = false;
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
			deckCard.x = Std.int(10 + DECK_X + (d * (96 + DECK_SPACE)));
			deckCard.y = 10 + DECK_Y;
			deckCard.scrollFactor.set();
			deckList.add(deckCard);
			deckCard.shown = true;
		}

		var card:CardInfo = null;
		for (cID => count in GameGlobals.Player.collection.collection)
		{
			card = new CardInfo(Cards.CardList.get(cID), count);

			card.x = Std.int(10 + (collection.members.length % COLLECTION_COUNT_W) * (96 + COLLECTION_SPACE_W));
			card.y = Std.int(10 + (Std.int(collection.members.length / COLLECTION_COUNT_W) * (96 + COLLECTION_SPACE_H)));

			if (GameGlobals.Player.deck.cards.contains(cID))
				card.inDeck = true;

			collection.add(card);
		}

		deckList.members[0].selected = true;
		selectedCard = 0;

		inDeck = true;

		cardName.text = deckList.members[selectedCard].card.name.toTitleCase();
		cardName.x = Std.int((Global.width / 2) - (cardName.width / 2));

		ready = true;
	}

	public function returnFromTutorial():Void
	{
		Dialog.Flags.set("seenCollTut", true);
		GameGlobals.save();
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
					cardName.text = deckList.members[selectedCard].card.name.toTitleCase();
					cardName.x = Std.int((Global.width / 2) - (cardName.width / 2));
				}
				else
				{
					deckList.members[selectedCard].selected = false;
					selectedCard = deckList.members.length - 1;
					deckList.members[selectedCard].selected = true;
					cardName.text = deckList.members[selectedCard].card.name.toTitleCase();
					cardName.x = Std.int((Global.width / 2) - (cardName.width / 2));
				}
			}
			else
			{
				if (selectedCard % COLLECTION_COUNT_W > 0)
				{
					collection.members[selectedCard].cardGraphic.selected = false;
					selectedCard--;
					collection.members[selectedCard].cardGraphic.selected = true;
					cardName.text = collection.members[selectedCard].cardGraphic.card.name.toTitleCase();
					cardName.x = Std.int((Global.width / 2) - (cardName.width / 2));
				}
				else
				{
					collection.members[selectedCard].cardGraphic.selected = false;
					selectedCard += COLLECTION_COUNT_W - 1;
					selectedCard = Std.int(Math.min(selectedCard, collection.members.length - 1));
					collection.members[selectedCard].cardGraphic.selected = true;

					cardName.text = collection.members[selectedCard].cardGraphic.card.name.toTitleCase();
					cardName.x = Std.int((Global.width / 2) - (cardName.width / 2));
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
					cardName.text = deckList.members[selectedCard].card.name.toTitleCase();
					cardName.x = Std.int((Global.width / 2) - (cardName.width / 2));
				}
				else
				{
					deckList.members[selectedCard].selected = false;
					selectedCard = 0;
					deckList.members[selectedCard].selected = true;
					cardName.text = deckList.members[selectedCard].card.name.toTitleCase();
					cardName.x = Std.int((Global.width / 2) - (cardName.width / 2));
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
					cardName.text = collection.members[selectedCard].cardGraphic.card.name.toTitleCase();
					cardName.x = Std.int((Global.width / 2) - (cardName.width / 2));
				}
				else
				{
					collection.members[selectedCard].cardGraphic.selected = false;
					selectedCard -= COLLECTION_COUNT_W - 1;
					collection.members[selectedCard].cardGraphic.selected = true;
					cardName.text = collection.members[selectedCard].cardGraphic.card.name.toTitleCase();
					cardName.x = Std.int((Global.width / 2) - (cardName.width / 2));
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
					if (swapping)
						return;
					collection.members[selectedCard].cardGraphic.selected = false;
					selectedCard = 0;
					deckList.members[selectedCard].selected = true;
					cardName.text = deckList.members[selectedCard].card.name.toTitleCase();
					cardName.x = Std.int((Global.width / 2) - (cardName.width / 2));
					inDeck = true;
				}
				else
				{
					collection.members[selectedCard].cardGraphic.selected = false;
					selectedCard -= COLLECTION_COUNT_W;
					collection.members[selectedCard].cardGraphic.selected = true;
					cardName.text = collection.members[selectedCard].cardGraphic.card.name.toTitleCase();
					cardName.x = Std.int((Global.width / 2) - (cardName.width / 2));

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
				if (swapping)
					return;
				deckList.members[selectedCard].selected = false;
				selectedCard = 0;
				collection.members[selectedCard].cardGraphic.selected = true;
				cardName.text = collection.members[selectedCard].cardGraphic.card.name.toTitleCase();
				cardName.x = Std.int((Global.width / 2) - (cardName.width / 2));
				inDeck = false;
			}
			else
			{
				if (selectedCard < deckList.members.length - COLLECTION_COUNT_W)
				{
					collection.members[selectedCard].cardGraphic.selected = false;
					selectedCard += COLLECTION_COUNT_W;
					collection.members[selectedCard].cardGraphic.selected = true;
					cardName.text = collection.members[selectedCard].cardGraphic.card.name.toTitleCase();
					cardName.x = Std.int((Global.width / 2) - (cardName.width / 2));

					if (collection.y + collection.members[selectedCard].y + 140 > 530)
						collection.y = 510 - (collection.members[selectedCard].y + 140);
				}
				else
				{
					// do nothing!
				}
			}
		}
		else if (Controls.justPressed.A)
		{
			if (!swapping)
			{
				if (inDeck)
				{
					swapping = true;
					swappingCardInDeck = selectedCard;
					swappingCardID = -1;

					deckList.members[selectedCard].selected = false;
					deckList.members[selectedCard].visible = false;
					tmpSwappingCard.spawn(deckList.members[selectedCard].card.id);
					tmpSwappingCard.visible = true;
					tmpSwappingCard.shown = true;
					selectedCard = 0;
					collection.members[selectedCard].cardGraphic.selected = true;
					cardName.text = collection.members[selectedCard].cardGraphic.card.name.toTitleCase();
					cardName.x = Std.int((Global.width / 2) - (cardName.width / 2));
					swappingCardArrow.visible = true;
					swappingCardArrow.facing = FlxDirectionFlags.LEFT;
					inDeck = false;
				}
				else if (!collection.members[selectedCard].inDeck)
				{
					// we want to put this card into the deck
					swapping = true;
					swappingCardInDeck = -1;
					swappingCardID = collection.members[selectedCard].cardGraphic.card.id;
					collection.members[selectedCard].cardGraphic.selected = false;
					selectedCard = 0;
					inDeck = true;
					deckList.members[selectedCard].selected = true;
					swappingCardArrow.visible = true;
					swappingCardArrow.facing = FlxDirectionFlags.RIGHT;
					tmpSwappingCard.spawn(swappingCardID);
					tmpSwappingCard.visible = true;
					tmpSwappingCard.shown = true;
					cardName.text = deckList.members[selectedCard].card.name.toTitleCase();
					cardName.x = Std.int((Global.width / 2) - (cardName.width / 2));
				}
			}
			else if (swapping)
			{
				if (inDeck)
				{
					deckList.members[selectedCard].spawn(swappingCardID);
					deckList.members[selectedCard].shown = true;
					tmpSwappingCard.visible = false;
					swapping = false;
					swappingCardArrow.visible = false;
					GameGlobals.Player.deck.cards[selectedCard] = swappingCardID;
					swappingCardInDeck = -1;
					swappingCardID = -1;
					cardName.text = deckList.members[selectedCard].card.name.toTitleCase();
					cardName.x = Std.int((Global.width / 2) - (cardName.width / 2));

					updateInDeck();

					GameGlobals.save();
				}
				else
				{
					if (collection.members[selectedCard].inDeck)
						return;
					deckList.members[swappingCardInDeck].spawn(collection.members[selectedCard].cardGraphic.card.id);
					deckList.members[swappingCardInDeck].visible = true;
					deckList.members[swappingCardInDeck].shown = true;
					tmpSwappingCard.visible = false;
					swapping = false;
					swappingCardArrow.visible = false;
					GameGlobals.Player.deck.cards[swappingCardInDeck] = collection.members[selectedCard].cardGraphic.card.id;

					selectedCard = swappingCardInDeck;
					deckList.members[selectedCard].selected = true;
					inDeck = true;
					cardName.text = deckList.members[selectedCard].card.name.toTitleCase();
					cardName.x = Std.int((Global.width / 2) - (cardName.width / 2));

					swappingCardInDeck = -1;
					swappingCardID = -1;

					updateInDeck();

					GameGlobals.save();
				}
			}
		}
	}

	public function updateInDeck():Void
	{
		for (c in collection.members)
		{
			c.inDeck = GameGlobals.Player.deck.cards.contains(c.cardGraphic.card.id);
		}
	}
}

class CardInfo extends FlxSpriteGroup
{
	public var card:Card;
	public var cardGraphic:CardGraphic;
	public var count:GameText;
	public var inDeckIcon:FlxSprite;

	public var inDeck(default, set):Bool = false;
	public var rarity:FlxSprite;

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

		count.x = cardGraphic.x + 90 - count.width;
		count.y = cardGraphic.y + cardGraphic.height - 6;

		inDeckIcon = new FlxSprite(Global.asset("assets/images/in_deck_icon.png"));
		inDeckIcon.scrollFactor.set();
		inDeckIcon.x = cardGraphic.x + 2;
		inDeckIcon.y = cardGraphic.y + cardGraphic.height - 4;

		rarity = GraphicsCache.loadFlxSpriteFromAtlas("rarity");
		rarity.scrollFactor.set();
		rarity.x = cardGraphic.x - 10 + (cardGraphic.width / 2) - (rarity.width / 2);
		rarity.y = cardGraphic.y - 10 + cardGraphic.height + 2;
		rarity.animation.frameName = card.rarity;

		add(cardGraphic);
		add(count);

		add(inDeckIcon);
		add(rarity);
		inDeck = false;
	}

	private function set_inDeck(Value:Bool):Bool
	{
		inDeck = Value;
		inDeckIcon.visible = Value;
		return Value;
	}
}
