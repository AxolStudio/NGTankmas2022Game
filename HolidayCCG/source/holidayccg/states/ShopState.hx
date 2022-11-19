package holidayccg.states;

import flixel.util.FlxTimer;
import holidayccg.globals.Cards;
import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import holidayccg.globals.Cards.CardGraphic;
import holidayccg.ui.TutorialMessage;
import flixel.text.FlxText.FlxTextAlign;
import flixel.tweens.FlxTween;
import holidayccg.globals.GameGlobals;
import flixel.FlxSprite;
import holidayccg.ui.GameFrame;
import holidayccg.ui.CardPack;
import holidayccg.ui.GameText;
import flixel.FlxSubState;
import holidayccg.globals.GraphicsCache;

class ShopState extends FlxSubState
{
	// show a screen that lets the player spend coins for packs of cards
	// 1 pack = $100
	// when they buy a pack, show an animation of it opening and revealing the cards they got
	// allow them to bulk-sell their duplicate cards:
	// starters can't be sold, commons = $10, uncommons = $20, rares = $50
	public var mainFrame:GameFrame;
	public var choicesFrame:GameFrame;

	public var choiceBuy:GameText;
	public var choiceSell:GameText;
	public var choiceExit:GameText;

	public var cursor:GameText;

	public var money:GameText;

	public var cardPack:FlxSprite;
	public var price:GameText;
	public var message:GameText;

	public static inline var PURCHASE_COST:Int = 100;
	public static inline var SELL_COST_C:Int = 10;
	public static inline var SELL_COST_U:Int = 20;
	public static inline var SELL_COST_R:Int = 50;

	public var selectedChoice:Int = 0;

	public var ready:Bool = false;
	public var showingMessage:Bool = false;
	public var showingReceipt:Bool = false;

	public var blackout:FlxSprite;

	public var notEnoughMoney:TutorialMessage;
	public var packOpening:OpenPackState;

	public var receipt:TutorialMessage;

	public function new(Callback:Void->Void)
	{
		super();

		destroySubStates = false;
		closeCallback = Callback;
		openCallback = start;
	}

	@:access(flixel.text.FlxBitmapText.updateText)
	override function create()
	{
		add(mainFrame = new GameFrame(Global.width, Global.height - 64));
		mainFrame.scrollFactor.set();

		add(choicesFrame = new GameFrame(Global.width, 64));
		choicesFrame.y = Global.height - 64;
		choicesFrame.scrollFactor.set();

		add(cursor = new GameText());
		cursor.text = "]";
		cursor.x = 24;
		cursor.y = choicesFrame.y + (choicesFrame.height / 2) - (cursor.height / 2);
		cursor.scrollFactor.set();

		add(choiceBuy = new GameText());
		choiceBuy.text = "Buy Pack";
		choiceBuy.x = cursor.x + cursor.width + 10;
		choiceBuy.y = choicesFrame.y + (choicesFrame.height / 2) - (choiceBuy.height / 2);
		choiceBuy.scrollFactor.set();

		add(choiceSell = new GameText());
		choiceSell.text = "Sell Duplicate Cards";
		choiceSell.x = (Global.width / 2) - ((choiceSell.width) / 2) + 10 + cursor.width;
		choiceSell.y = choicesFrame.y + (choicesFrame.height / 2) - (choiceSell.height / 2);
		choiceSell.scrollFactor.set();

		add(choiceExit = new GameText());
		choiceExit.text = "Exit";
		choiceExit.x = Global.width - 24 - choiceExit.width;
		choiceExit.y = choicesFrame.y + (choicesFrame.height / 2) - (choiceExit.height / 2);
		choiceExit.scrollFactor.set();

		add(message = new GameText());
		message.text = "Welcome to the shop!";
		message.x = Global.width / 2 - message.width / 2;
		message.y = 24;
		message.scrollFactor.set();

		add(cardPack = new FlxSprite(Global.asset("assets/images/card_pack.png")));
		cardPack.x = Global.width / 2 - cardPack.width / 2;
		cardPack.y = Global.height / 2 - cardPack.height / 2;
		cardPack.scrollFactor.set();

		add(price = new GameText());
		price.text = "$" + PURCHASE_COST;
		price.x = cardPack.x + cardPack.width / 2 - price.width / 2;
		price.y = cardPack.y + cardPack.height + 10;
		price.scrollFactor.set();

		add(money = new GameText());
		money.text = "$0";
		money.alignment = FlxTextAlign.RIGHT;
		money.x = Global.width - money.width - 24;
		money.y = 24;
		money.scrollFactor.set();

		add(notEnoughMoney = new TutorialMessage("You don't have enough money!"));
		notEnoughMoney.x = Global.width / 2 - notEnoughMoney.width / 2;
		notEnoughMoney.y = Global.height / 2 - notEnoughMoney.height / 2;

		notEnoughMoney.visible = false;

		add(blackout = new FlxSprite());
		blackout.makeGraphic(Global.width, Global.height, GameGlobals.ColorPalette[1]);
		blackout.alpha = 1;
		blackout.scrollFactor.set();

		packOpening = new OpenPackState(returnFromOpening);

		super.create();
	}

	public function returnFromOpening():Void
	{
		ready = true;
	}

	public function start()
	{
		selectChoice(0);
		money.text = "$" + GameGlobals.Player.money;
		money.x = Global.width - money.width - 24;

		blackout.alpha = 1;
		FlxTween.tween(blackout, {alpha: 0}, 0.33, {
			type: FlxTweenType.ONESHOT,
			onComplete: (_) ->
			{
				ready = true;
			}
		});
	}

	public function selectChoice(Choice:Int):Void
	{
		selectedChoice = Choice;
		cursor.x = switch (Choice)
		{
			case 0:
				choiceBuy.x - cursor.width - 10;
			case 1:
				choiceSell.x - cursor.width - 10;
			default:
				choiceExit.x - cursor.width - 10;
		};
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (!ready)
			return;

		if (showingMessage)
		{
			if (Controls.justPressed.A || Controls.justPressed.B)
			{
				showingMessage = false;
				notEnoughMoney.visible = false;
			}
			return;
		}

		if (showingReceipt)
		{
			if (Controls.justPressed.A || Controls.justPressed.B)
			{
				showingReceipt = false;
				receipt.kill();
			}
			return;
		}

		if (Controls.justPressed.LEFT)
		{
			if (selectedChoice == 0)
				selectChoice(2);
			else
				selectChoice(selectedChoice - 1);
		}
		else if (Controls.justPressed.RIGHT)
		{
			if (selectedChoice == 2)
				selectChoice(0);
			else
				selectChoice(selectedChoice + 1);
		}
		else if (Controls.justPressed.A)
		{
			switch (selectedChoice)
			{
				case 0:
					buyPack();
				case 1:
					sellCards();
				default:
					exit();
			}
		}
	}

	public function buyPack():Void
	{
		if (GameGlobals.Player.money < PURCHASE_COST)
		{
			showMessage();
			return;
		}

		ready = false;

		GameGlobals.Player.money -= PURCHASE_COST;
		money.text = "$" + GameGlobals.Player.money;

		// show opening pack animation!
		openSubState(packOpening);
	}

	public function sellCards():Void
	{
		ready = false;
		var c:Card = null;
		var amountGained:Int = 0;
		var soldCount:Int = 0;
		for (id => amount in GameGlobals.Player.collection.collection)
		{
			{
				if (amount > 1)
				{
					c = Cards.CardList.get(id);
					if (c.rarity != "epic")
					{
						amountGained += (amount - 1) * switch (c.rarity)
						{
							case "common": 10;
							case "uncommon": 25;
							case "rare": 50;
							default: 0;
						};
						soldCount += amount - 1;
						GameGlobals.Player.collection.collection.set(id, 1);
					}
				}
			}
		}
		GameGlobals.Player.money += amountGained;
		money.text = "$" + GameGlobals.Player.money;

		GameGlobals.save();

		receipt = new TutorialMessage("You sold " + soldCount + " cards for $" + amountGained + "!");
		receipt.x = Global.width / 2 - receipt.width / 2;
		receipt.y = Global.height / 2 - receipt.height / 2;
		add(receipt);
		showingReceipt = true;
		ready = true;
	}

	public function exit():Void
	{
		ready = false;
		FlxTween.tween(blackout, {alpha: 1}, 0.33, {
			type: FlxTweenType.ONESHOT,
			onComplete: (_) ->
			{
				close();
			}
		});
	}

	public function showMessage():Void
	{
		notEnoughMoney.visible = true;
		showingMessage = true;
	}
}

class OpenPackState extends FlxSubState
{
	public var cardsLayer:FlxTypedGroup<CardGraphic>;
	public var cardsRarity:FlxTypedGroup<FlxSprite>;
	public var cards:Array<CardGraphic> = [];
	public var cardRarities:Array<FlxSprite> = [];

	public var cardPack:CardPack;

	public var ready:Bool = false;

	public function new(Callback:Void->Void):Void
	{
		super();
		bgColor = GameGlobals.ColorPalette[1];

		closeCallback = Callback;

		add(cardsLayer = new FlxTypedGroup<CardGraphic>());
		add(cardsRarity = new FlxTypedGroup<FlxSprite>());
		add(cardPack = new CardPack());

		var card:CardGraphic = null;
		var cardRarity:FlxSprite = null;
		for (i in 0...3)
		{
			card = new CardGraphic();
			card.visible = false;

			cardRarity = GraphicsCache.loadFlxSpriteFromAtlas("rarity");
			cardRarity.scrollFactor.set();
			cardRarity.alpha = 0;

			cards.push(card);
			cardRarities.push(cardRarity);

			cardsLayer.add(card);
			cardsRarity.add(cardRarity);
		}

		openCallback = start;
	}

	public function getRandomCard(Rarity:String):Int
	{
		var cards:Array<Int> = switch (Rarity)
		{
			case "rare": Cards.rares.copy();
			case "uncommon": Cards.uncommons.copy();
			default: Cards.commons.copy();
		}
		for (i in 0...100)
			FlxG.random.shuffle(cards);
		return cards[0];
	}

	public function start():Void
	{
		var newCards:Array<Int> = [];
		var weights:Array<Float> = [20, 15, 10, 5];
		// 0 = C, C, U
		// 1 = C, U, U
		// 2 = C, C, R
		// 3 = C, U, R

		switch (FlxG.random.weightedPick(weights))
		{
			case 0:
				newCards = [getRandomCard("common"), getRandomCard("common"), getRandomCard("uncommon")];
			case 1:
				newCards = [getRandomCard("common"), getRandomCard("uncommon"), getRandomCard("uncommon")];
			case 2:
				newCards = [getRandomCard("common"), getRandomCard("common"), getRandomCard("rare")];
			case 3:
				newCards = [getRandomCard("common"), getRandomCard("uncommon"), getRandomCard("rare")];
		}

		cards[0].spawn(newCards[0]);
		cards[1].spawn(newCards[1]);
		cards[2].spawn(newCards[2]);

		cards[0].visible = cards[1].visible = cards[2].visible = false;

		GameGlobals.Player.collection.add(newCards[0], 1);
		GameGlobals.Player.collection.add(newCards[1], 1);
		GameGlobals.Player.collection.add(newCards[2], 1);
		GameGlobals.save();

		cardRarities[0].animation.frameName = cards[0].card.rarity;
		cardRarities[1].animation.frameName = cards[1].card.rarity;
		cardRarities[2].animation.frameName = cards[2].card.rarity;

		cardPack.reset((Global.width / 2) - (cardPack.width / 2), Global.height + 20);

		FlxTween.tween(cardPack, {y: Global.height / 2 - cardPack.height / 2}, 0.33, {
			onStart: (_) -> {},
			type: FlxTweenType.ONESHOT,
			onComplete: (_) ->
			{
				// open pack
				cards[0].x = cards[1].x = cards[2].x = cardPack.x + 2 + 5;
				cards[0].y = cards[1].y = cards[2].y = cardPack.y + 7 + 5;

				cardRarities[0].x = (Global.width / 2) - (cards[0].width / 2) - cards[0].width - 30 + (cards[0].width / 2) - (cardRarities[0].width / 2);
				cardRarities[0].y = cards[0].y + cards[0].height + 10;
				cardRarities[2].x = (Global.width / 2) - (cardRarities[2].width / 2);
				cardRarities[2].y = cards[1].y + cards[1].height + 10;
				cardRarities[1].x = (Global.width / 2) + (cards[1].width / 2) + 30 + (cards[1].width / 2) - (cardRarities[1].width / 2);
				cardRarities[1].y = cards[2].y + cards[2].height + 10;

				cards[0].visible = cards[1].visible = cards[2].visible = true;

				cardRarities[0].alpha = cardRarities[1].alpha = cardRarities[2].alpha = 0;
				cardRarities[0].visible = cardRarities[1].visible = cardRarities[2].visible = true;

				cardPack.open(() ->
				{
					// slide cards out

					FlxTween.tween(cardPack, {y: Global.height}, .33, {
						onComplete: (_) ->
						{
							FlxTween.tween(cards[0], {x: (Global.width / 2) - (cards[0].width / 2) - cards[0].width - 30 + 5}, .33, {});
							FlxTween.tween(cards[1], {x: (Global.width / 2) + (cards[1].width / 2) + 30 + 5}, .33, {});

							var t1:FlxTimer = new FlxTimer();
							t1.start(0.2, (_) ->
							{
								cards[0].reveal();
								FlxTween.tween(cardRarities[0], {alpha: 1}, .2, {});
							}, 1);

							var t2:FlxTimer = new FlxTimer();
							t2.start(0.3, (_) ->
							{
								cards[1].reveal();
								FlxTween.tween(cardRarities[1], {alpha: 1}, .2, {});
							}, 1);

							var t3:FlxTimer = new FlxTimer();
							t3.start(0.4, (_) ->
							{
								cards[2].reveal();
								FlxTween.tween(cardRarities[2], {alpha: 1}, .2, {
									onComplete: (_) ->
									{
										ready = true;
									}
								});
							}, 1);
						}
					});
				});
			}
		});
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (ready)
		{
			if (Controls.justPressed.A || Controls.justPressed.B)
			{
				ready = false;
				cardRarities[0].visible = cardRarities[1].visible = cardRarities[2].visible = false;

				FlxTween.tween(cards[0], {y: -cards[0].height}, .2, {});
				FlxTween.tween(cards[1], {y: -cards[1].height}, .2, {startDelay: .01});
				FlxTween.tween(cards[2], {y: -cards[2].height}, .2, {
					startDelay: .02,
					onComplete: (_) ->
					{
						close();
					}
				});
			}
		}
	}
}
