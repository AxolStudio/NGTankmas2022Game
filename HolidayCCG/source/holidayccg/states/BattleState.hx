package holidayccg.states;

import holidayccg.globals.Sounds;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import holidayccg.globals.Cards;
import holidayccg.globals.GameGlobals;
import holidayccg.globals.GraphicsCache;
import holidayccg.globals.Opponent;
import holidayccg.ui.GameFrame;
import holidayccg.ui.GameText;

using StringTools;

class BattleState extends FlxSubState
{
	public var gameGrid:Array<Int> = [];
	public var battlefield:FlxSprite;
	// public var blocker:FlxSprite;
	public var playerHand:Deck;
	public var enemyHand:Deck;
	public var enemyCards:FlxTypedGroup<CardGraphic>;
	public var playerCards:FlxTypedGroup<CardGraphic>;
	public var playedCards:FlxTypedGroup<CardGraphic>;

	public var currentTurn:CardOwner = CardOwner.PLAYER;

	public var currentMode:BattleMode = SETUP;

	public static inline var PlayerHandX:Int = 96;
	public static inline var PlayerHandY:Int = 150;

	public static inline var EnemyHandX:Int = 768;
	public static inline var EnemyHandY:Int = 78;

	public static inline var HandCardSpacing:Int = 48;

	public static inline var BattleFieldX:Int = 314;
	public static inline var BattleFieldY:Int = 68;
	public static inline var BattleFieldCardX:Int = 324;
	public static inline var BattleFieldCardY:Int = 78;
	public static inline var BattleFieldCardSpacingX:Int = 108;
	public static inline var BattleFieldCardSpacingY:Int = 132;

	public static inline var PlayingCardX:Int = 206;
	public static inline var PlayingCardY:Int = 162;

	public var cardPlaceTarget:FlxSprite;

	public var selectedCard:Int;

	public var selectedSpot:Int;

	public var ready:Bool = false;

	public var turnEndTimer:FlxTimer;
	public var lastMode:BattleMode;

	public var enemy:Opponent;

	public var win:String = "";
	public var lose:String = "";

	public var callback:String->Void;

	public var winner:CardOwner;

	public var doingTut:Bool = false;

	public var battleTut:BattleTutorial;
	public var whichTut:Int = -1;

	public var returnFromTutCallback:Void->Void;

	public var didTut:Bool = false;

	public var coinFlip:CoinFlip;

	public var table:FlxSprite;

	public function new(Callback:String->Void):Void
	{
		super();

		destroySubStates = false;

		bgColor = GameGlobals.ColorPalette[14];

		add(table = new FlxSprite(Global.asset("assets/images/table.png")));
		Global.screenCenter(table);
		table.scrollFactor.set();

		callback = Callback;

		turnEndTimer = new FlxTimer();

		add(battlefield = new FlxSprite());
		battlefield.loadGraphic(Global.asset("assets/images/battlefield.png"));
		battlefield.scrollFactor.set(0, 0);
		Global.screenCenter(battlefield);
		battlefield.x = BattleFieldX;
		battlefield.y = BattleFieldY;

		// add(blocker = new FlxSprite());
		// blocker.loadGraphic(Global.asset("assets/images/blocker.png"));
		// blocker.scrollFactor.set();

		add(enemyCards = new FlxTypedGroup<CardGraphic>());

		add(playerCards = new FlxTypedGroup<CardGraphic>());

		add(playedCards = new FlxTypedGroup<CardGraphic>());

		add(cardPlaceTarget = new FlxSprite());
		cardPlaceTarget.loadGraphic(Global.asset("assets/images/card_outline.png"));
		cardPlaceTarget.scrollFactor.set();
		cardPlaceTarget.visible = false;

		lastMode = null;

		coinFlip = new CoinFlip(returnFromCoinFlip);

		openCallback = start;
	}

	override public function close():Void
	{
		for (e in enemyCards.members)
		{
			e.kill();
			enemyCards.remove(e);
			e.destroy();
		}
		for (p in playerCards.members)
		{
			p.kill();
			playerCards.remove(p);
			p.destroy();
		}
		for (p in playedCards.members)
		{
			p.kill();
			playedCards.remove(p);
			p.destroy();
		}
		enemyCards.clear();
		playerCards.clear();
		playedCards.clear();

		doingTut = false;

		super.close();
	}

	public function returnFromTutorial():Void
	{
		returnFromTutCallback();
		returnFromTutCallback = null;
	}

	public function init(PlayerDeck:Deck, VSWho:String):Void
	{
		if (VSWho.startsWith("intro guy"))
		{
			doingTut = true;
			battleTut = new BattleTutorial(returnFromTutorial);
		}

		if (doingTut)
			playerHand = new Deck([1, 2, 3, 4, 5]);
		else
			playerHand = new Deck(PlayerDeck.cards.copy());

		var vs:Array<String> = VSWho.split(";");

		trace(Opponent.OpponentList);

		enemy = Opponent.OpponentList.get(vs[0]);

		trace(enemy, vs[0]);

		win = vs[1];
		lose = vs[2];

		enemyHand = new Deck(enemy.deck.cards.copy());

		currentMode = SETUP;

		gameGrid = [for (i in 0...9) 0];
		// gameGrid[FlxG.random.int(0, 8)] = -1;

		ready = false;

		var cardG:CardGraphic = null;

		for (i in 0...playerHand.length)
		{
			cardG = new CardGraphic();
			cardG.spawn(playerHand.cards[i], CardOwner.PLAYER);
			cardG.x = -100 - cardG.width;
			cardG.y = PlayerHandY + (i * HandCardSpacing);
			cardG.shown = true;
			cardG.scrollFactor.set();

			playerCards.add(cardG);
		}

		for (i in 0...enemyHand.length)
		{
			cardG = new CardGraphic();
			cardG.spawn(enemyHand.cards[i], CardOwner.OPPONENT);
			cardG.x = Global.width + 100;
			cardG.y = EnemyHandY + (i * HandCardSpacing);
			cardG.shown = false;
			cardG.scrollFactor.set();

			enemyCards.add(cardG);
		}

		// blocker.x = Global.width / 2 - blocker.width / 2;
		// blocker.y = Global.height + 100;

		currentTurn = CardOwner.PLAYER; // RANDOMIZE THIS LATER!

		selectedCard = -1;
	}

	public function showTut(Step:Int, Callback:Void->Void):Void
	{
		whichTut = Step;
		battleTut.init(whichTut);
		returnFromTutCallback = Callback;
		openSubState(battleTut);
	}

	override function draw()
	{
		super.draw();
		if (GameGlobals.transition.transitioning)
			GameGlobals.transition.draw();
	}

	public function start():Void
	{
		GameGlobals.transIn(() ->
		{
			// placeBlocker();
			if (doingTut)
				showTut(1, () ->
				{
					placeCards();
				});
			else
				placeCards();
		});
	}

	// public function placeBlocker():Void
	// {
	// 	var blockerPosX:Int = BattleFieldCardX + ((gameGrid.indexOf(-1) % 3) * BattleFieldCardSpacingX);
	// 	var blockerPosY:Int = BattleFieldCardY + (Std.int(gameGrid.indexOf(-1) / 3) * BattleFieldCardSpacingY);
	// 	FlxTween.quadMotion(blocker, blocker.x, blocker.y, 200, 200, blockerPosX, blockerPosY, 1, true, {
	// 		type: FlxTweenType.ONESHOT,
	// 		onComplete: (_) ->
	// 		{
	// 			FlxG.camera.shake(0.01, 0.5);
	// 			placeCards();
	// 		}
	// 	});
	// }

	public function placeCards():Void
	{
		for (i in 0...playerCards.length)
		{
			FlxTween.num(playerCards.members[i].x, PlayerHandX, 0.5, {
				type: FlxTweenType.ONESHOT,
				startDelay: i * 0.1,
				onComplete: (_) ->
				{
					Sounds.playOneOf([
						"cardSlide1",
						"cardSlide2",
						"cardSlide3",
						"cardSlide4",
						"cardSlide6",
						"cardSlide6",
						"cardSlide7",
						"cardSlide8"
					]);
				}
			}, (Value:Float) ->
				{
					playerCards.members[i].x = Value;
				});
		}

		// onComplete:i == playerCards.length - 1 ?(_) -> {} : null

		for (i in 0...enemyCards.length)
		{
			FlxTween.num(enemyCards.members[i].x, EnemyHandX, 0.5, {
				type: FlxTweenType.ONESHOT,
				startDelay: 0.5 + (i * 0.1),
				onComplete: i == enemyCards.length - 1 ?(_) ->
				{
					Sounds.playOneOf([
						"cardSlide1",
						"cardSlide2",
						"cardSlide3",
						"cardSlide4",
						"cardSlide6",
						"cardSlide6",
						"cardSlide7",
						"cardSlide8"
					]);
					if (doingTut)
						showTut(2, () ->
						{
							startGame();
						});
					else
						startGame();
				} : (_) ->
				{
					Sounds.playOneOf([
						"cardSlide1",
						"cardSlide2",
						"cardSlide3",
						"cardSlide4",
						"cardSlide6",
						"cardSlide6",
						"cardSlide7",
						"cardSlide8"
					]);
				}
			}, (Value:Float) ->
				{
					enemyCards.members[i].x = Value;
				});
		}
	}

	public function startGame():Void
	{
		// show a 'start!' message

		if (doingTut)
			currentTurn = CardOwner.PLAYER;
		else
		{
			// random player
			currentTurn = FlxG.random.bool() ? CardOwner.PLAYER : CardOwner.OPPONENT;
		}
		coinFlip.init(currentTurn == CardOwner.PLAYER ? "Green" : "Red");
		var t:FlxTimer = new FlxTimer();
		t.start(FlxG.elapsed, (_) ->
		{
			openSubState(coinFlip);
		}, 1);
	}

	public function returnFromCoinFlip():Void
	{
		currentMode = (currentTurn == CardOwner.PLAYER) ? PLAYER_TURN : ENEMY_TURN;
		if (currentMode == PLAYER_TURN)
		{
			var t:FlxTimer = new FlxTimer();
			t.start(FlxG.elapsed, (_) ->
			{
				if (doingTut)
					showTut(5, () ->
					{
						startPlayerTurn();
					});
				else
					startPlayerTurn();
			}, 1);
		}
		else
		{
			startEnemyTurn();
		}
	}

	public function startEnemyTurn():Void
	{
		currentMode = ENEMY_TURN;
		var bestSpots:Array<Array<Int>> = [for (i in 0...enemyHand.cards.length) [for (i in 0...gameGrid.length) 0]];

		// first, enemy picks a card
		var card:Card = null;
		var pCard:Card = null;
		for (c in 0...enemyHand.cards.length)
		{
			if (enemyHand.cards[c] == -1)
			{
				bestSpots[c] = [for (i in 0...gameGrid.length) -1];
				continue;
			}

			card = Cards.CardList.get(enemyHand.cards[c]);
			for (i in 0...gameGrid.length)
			{
				if (gameGrid[i] != 0)
				{
					bestSpots[c][i] = -1;
					continue;
				}

				for (a in card.attacks)
				{
					if (a == "N")
					{
						// check space above
						if (i > 2 && gameGrid[i - 3] > 0)
						{
							pCard = Cards.CardList.get(gameGrid[i - 3]);
							if (pCard.value < card.value)
								bestSpots[c][i]++;
						}
					}
					else if (a == "S")
					{
						// check space below
						if (i < 6 && gameGrid[i + 3] > 0)
						{
							pCard = Cards.CardList.get(gameGrid[i + 3]);
							if (pCard.value < card.value)
								bestSpots[c][i]++;
						}
					}
					else if (a == "E")
					{
						// check space to the right
						if (i % 3 != 2 && gameGrid[i + 1] > 0)
						{
							pCard = Cards.CardList.get(gameGrid[i + 1]);
							if (pCard.value < card.value)
								bestSpots[c][i]++;
						}
					}
					else if (a == "W")
					{
						// check space to the left
						if (i % 3 != 0 && gameGrid[i - 1] > 0)
						{
							pCard = Cards.CardList.get(gameGrid[i - 1]);
							if (pCard.value < card.value)
								bestSpots[c][i]++;
						}
					}
				}
			}
		}
		// next enemy chooses empty space on the board

		var bestSpot:Int = -1;
		var bestValue:Int = -1;
		var bestCard:Int = -1;
		for (c in 0...bestSpots.length)
		{
			for (i in 0...bestSpots[c].length)
			{
				if (bestSpots[c][i] == -1)
					continue;
				if (bestSpots[c][i] > bestValue)
				{
					bestValue = bestSpots[c][i];
				}
			}
		}

		var choices:Array<String> = [];
		for (c in 0...bestSpots.length)
		{
			for (i in 0...bestSpots[c].length)
			{
				if (bestSpots[c][i] == bestValue)
				{
					choices.push('$c$i');
				}
			}
		}

		FlxG.random.shuffle(choices);
		var choice:Array<Int> = choices[0].split('').map(function(v:String) return Std.parseInt(v));
		bestCard = choice[0];
		bestSpot = choice[1];

		var cardG:CardGraphic = getCardGraphicFromHand(bestCard, CardOwner.OPPONENT);
		cardG.shown = true;

		var cardPosX:Int = 5 + BattleFieldCardX + ((bestSpot % 3) * BattleFieldCardSpacingX);
		var cardPosY:Int = 5 + BattleFieldCardY + (Std.int(bestSpot / 3) * BattleFieldCardSpacingY);

		FlxTween.linearMotion(cardG, cardG.x, cardG.y, cardPosX, cardPosY, .2, true, {
			type: FlxTweenType.ONESHOT,
			onComplete: (_) ->
			{
				// remove the card from the player's hand
				enemyHand.cards[bestCard] = -1;
				enemyCards.remove(cardG, true);

				// add the card to the battlefield
				gameGrid[bestSpot] = cardG.card.id;
				cardG.battleFieldPos = bestSpot;
				playedCards.add(cardG);

				Sounds.playOneOf(["cardPlace1", "cardPlace2", "cardPlace3", "cardPlace4"]);

				checkAttacks(bestSpot, OPPONENT);
			}
		});
	}

	public function startPlayerTurn():Void
	{
		currentMode = PLAYER_TURN;
		selectedCard = -1;
		for (i in 0...playerHand.length)
		{
			if (playerHand.cards[i] > -1)
			{
				selectCard(i);
				break;
			}
		}

		ready = true;
	}

	public function selectCard(Index:Int):Void
	{
		var c:CardGraphic = null;
		if (Index > -1 && selectedCard != Index)
		{
			if (selectedCard != -1)
			{
				c = getCardGraphicFromHand(selectedCard, CardOwner.PLAYER);

				c.selected = false;
				c.x = PlayerHandX;
			}
			selectedCard = Index;
			c = getCardGraphicFromHand(selectedCard, CardOwner.PLAYER);

			c.selected = true;
			c.x = PlayerHandX + (c.width * .33); // Tween?

			Sounds.playOneOf([
				"cardSlide1",
				"cardSlide2",
				"cardSlide3",
				"cardSlide4",
				"cardSlide6",
				"cardSlide6",
				"cardSlide7",
				"cardSlide8"
			]);
			sortHand(CardOwner.PLAYER);
		}
	}

	public function sortHand(Who:CardOwner):Void
	{
		(Who == CardOwner.PLAYER ? playerCards : enemyCards).sort(cardSort);
	}

	public function cardSort(Order:Int, ObjA:CardGraphic, ObjB:CardGraphic):Int
	{
		var result:Int = 0;
		if (ObjA.selected && !ObjB.selected)
			result = -Order;
		else if (!ObjA.selected && ObjB.selected)
			result = Order;
		else if (ObjA.y < ObjA.y)
		{
			result = Order;
		}
		else if (ObjA.y > ObjA.y)
		{
			result = -Order;
		}
		return result;
	}

	public function getCardGraphicFromHand(Index:Int, WhichHand:CardOwner):CardGraphic
	{
		var whichCards:FlxTypedGroup<CardGraphic> = WhichHand == CardOwner.PLAYER ? playerCards : enemyCards;
		var whichHand:Deck = WhichHand == CardOwner.PLAYER ? playerHand : enemyHand;
		for (i in whichCards.members)
		{
			if (i.card.id == whichHand.cards[Index])
			{
				return i;
			}
		}
		return null;
	}

	public function deselectCard():Void
	{
		var c:CardGraphic = getCardGraphicFromHand(selectedCard, CardOwner.PLAYER);
		c.selected = false;
		c.x = PlayerHandX;
		selectedCard = -1;
		Sounds.playOneOf([
			"cardSlide1",
			"cardSlide2",
			"cardSlide3",
			"cardSlide4",
			"cardSlide6",
			"cardSlide6",
			"cardSlide7",
			"cardSlide8"
		]);

		sortHand(CardOwner.PLAYER);
	}

	public function endTurn():Void
	{
		if (playedCards.length < 9)
		{
			if (lastMode == PLAYER_CARD_PLACING)
				startEnemyTurn();
			else if (lastMode == ENEMY_TURN)
			{
				if (doingTut && playedCards.length == 2 && !didTut)
				{
					showTut(10, () ->
					{
						didTut = true;
						startPlayerTurn();
					});
				}
				else
					startPlayerTurn();
			}
		}
		else
		{
			if (doingTut)
				showTut(11, () ->
				{
					var t:FlxTimer = new FlxTimer();
					t.start(FlxG.elapsed, (_) ->
					{
						battleEnd();
					}, 1);
				});
			else
				battleEnd();
		}
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		if (currentMode == TURN_END)
		{
			for (c in playedCards.members)
			{
				if (c.flipping)
					return;
			}

			currentMode = TURN_ENDING;

			turnEndTimer.start(.5, (_) ->
			{
				endTurn();
			});
		}
		else if (ready)
		{
			// let the player do stuff???
			if (currentMode == PLAYER_TURN)
			{
				// wait for the player to choose a card
				letPlayerChooseCard();
			}
			else if (currentMode == PLAYER_CARD_PLACING)
			{
				letPlayerPlaceCard();
			}
		}
	}

	public function letPlayerPlaceCard():Void
	{
		if (Controls.justPressed.DOWN)
		{
			if (Std.int(selectedSpot / 3) == 2)
				selectedSpot -= 6;
			else
				selectedSpot += 3;
			moveTarget();
		}
		else if (Controls.justPressed.UP)
		{
			if (Std.int(selectedSpot / 3) == 0)
				selectedSpot += 6;
			else
				selectedSpot -= 3;
			moveTarget();
		}
		else if (Controls.justPressed.RIGHT)
		{
			if (selectedSpot == 8)
				selectedSpot = 0;
			else
				selectedSpot += 1;
			moveTarget();
		}
		else if (Controls.justPressed.LEFT)
		{
			if (selectedSpot == 0)
				selectedSpot = 8;
			else
				selectedSpot -= 1;

			moveTarget();
		}
		else if (Controls.justPressed.A)
		{
			// place the card
			placeCard();
		}
		else if (Controls.justPressed.B)
		{
			ready = false;
			cardPlaceTarget.visible = true;
			var c:CardGraphic = getCardGraphicFromHand(selectedCard, CardOwner.PLAYER);
			c.selected = false;

			FlxTween.linearMotion(c, c.x, c.y, PlayerHandX, PlayerHandY + (selectedCard * HandCardSpacing), .2, true, {
				type: FlxTweenType.ONESHOT,
				onComplete: (_) ->
				{
					Sounds.playOneOf([
						"cardSlide1",
						"cardSlide2",
						"cardSlide3",
						"cardSlide4",
						"cardSlide6",
						"cardSlide6",
						"cardSlide7",
						"cardSlide8"
					]);
					sortHand(CardOwner.PLAYER);
					startPlayerTurn();
				}
			});
		}
	}

	public function moveTarget():Void
	{
		ready = false;
		FlxTween.linearMotion(cardPlaceTarget, cardPlaceTarget.x, cardPlaceTarget.y, BattleFieldCardX
			+ (selectedSpot % 3) * BattleFieldCardSpacingX
			- 5,
			BattleFieldCardY
			+ (Std.int(selectedSpot / 3)) * BattleFieldCardSpacingY
			- 5, .2, true, {
				type: FlxTweenType.ONESHOT,
				onComplete: (_) ->
				{
					ready = true;
				}
			});
	}

	public function placeCard():Void
	{
		ready = false;
		if (gameGrid[selectedSpot] != 0)
		{
			// error!
			// shake the cardplacetarget and let the player keep going
			ready = true;
		}
		else
		{
			cardPlaceTarget.visible = false;
			var c:CardGraphic = getCardGraphicFromHand(selectedCard, CardOwner.PLAYER);

			var cardPosX:Int = 5 + BattleFieldCardX + ((selectedSpot % 3) * BattleFieldCardSpacingX);
			var cardPosY:Int = 5 + BattleFieldCardY + (Std.int(selectedSpot / 3) * BattleFieldCardSpacingY);

			FlxTween.linearMotion(c, c.x, c.y, cardPosX, cardPosY, .2, true, {
				type: FlxTweenType.ONESHOT,
				onComplete: (_) ->
				{
					Sounds.playOneOf(["cardPlace1", "cardPlace2", "cardPlace3", "cardPlace4"]);
					// remove the card from the player's hand
					playerHand.cards[selectedCard] = -1;
					playerCards.remove(c, true);
					// add the card to the battlefield
					gameGrid[selectedSpot] = c.card.id;
					c.battleFieldPos = selectedSpot;
					playedCards.add(c);
					if (doingTut && !didTut)
						showTut(7, () ->
						{
							checkAttacks(selectedSpot, PLAYER);
						});
					else
						checkAttacks(selectedSpot, PLAYER);
				}
			});
		}
	}

	public function getCardGraphicFromBattlefield(Pos:Int):CardGraphic
	{
		for (i in playedCards.members)
		{
			if (i.battleFieldPos == Pos)
			{
				return i;
			}
		}
		return null;
	}

	public function checkAttacks(NewCardSpot:Int, Owner:CardOwner):Void
	{
		lastMode = currentMode;
		currentMode = TURN_END;
		var newCard:Card = Cards.CardList.get(gameGrid[NewCardSpot]);
		var card:CardGraphic = null;

		for (a in newCard.attacks)
		{
			if (a == "N")
			{
				// compare card above
				if (NewCardSpot > 2)
				{
					if (gameGrid[NewCardSpot - 3] > 0)
					{
						card = getCardGraphicFromBattlefield(NewCardSpot - 3);
						if (card.owner != Owner && card.card.value < newCard.value)
						{
							card.flip(Owner);
						}
					}
				}
			}
			else if (a == "S")
			{
				// compare card below
				if (NewCardSpot < 6)
				{
					if (gameGrid[NewCardSpot + 3] > 0)
					{
						card = getCardGraphicFromBattlefield(NewCardSpot + 3);
						if (card.owner != Owner && card.card.value < newCard.value)
						{
							card.flip(Owner);
						}
					}
				}
			}
			else if (a == "E")
			{
				// compare card to the right
				if (NewCardSpot % 3 != 2)
				{
					if (gameGrid[NewCardSpot + 1] > 0)
					{
						card = getCardGraphicFromBattlefield(NewCardSpot + 1);
						if (card.owner != Owner && card.card.value < newCard.value)
						{
							card.flip(Owner);
						}
					}
				}
			}
			else if (a == "W")
			{
				// compare card to the left
				if (NewCardSpot % 3 != 0)
				{
					if (gameGrid[NewCardSpot - 1] > 0)
					{
						card = getCardGraphicFromBattlefield(NewCardSpot - 1);
						if (card.owner != Owner && card.card.value < newCard.value)
						{
							card.flip(Owner);
						}
					}
				}
			}
		}
	}

	public function letPlayerChooseCard():Void
	{
		var nextCard:Int = selectedCard;
		if (Controls.justPressed.DOWN)
		{
			do
			{
				nextCard++;
				if (nextCard >= playerHand.cards.length)
					nextCard = 0;
			}
			while (playerHand.cards[nextCard] == -1);
			selectCard(nextCard);
		}
		else if (Controls.justPressed.UP)
		{
			do
			{
				nextCard--;
				if (nextCard < 0)
					nextCard = playerHand.cards.length - 1;
			}
			while (playerHand.cards[nextCard] == -1);
			selectCard(nextCard);
		}
		else if (Controls.justPressed.A)
		{
			// card has been selected! move it out to show that!
			if (doingTut && !didTut)
				showTut(6, () ->
				{
					cardPicked();
				})
			else
				cardPicked();
		}
	}

	public function cardPicked():Void
	{
		ready = false;
		var c:CardGraphic = getCardGraphicFromHand(selectedCard, CardOwner.PLAYER);
		c.selected = false;
		sortHand(CardOwner.PLAYER);
		FlxTween.linearMotion(c, c.x, c.y, PlayingCardX, PlayingCardY, .2, true, {
			type: FlxTweenType.ONESHOT,
			onComplete: (_) ->
			{
				Sounds.playOneOf([
					"cardSlide1",
					"cardSlide2",
					"cardSlide3",
					"cardSlide4",
					"cardSlide6",
					"cardSlide6",
					"cardSlide7",
					"cardSlide8"
				]);
				startSelectingSpot();
			}
		});
	}

	public function startSelectingSpot():Void
	{
		selectedSpot = 0;
		cardPlaceTarget.x = BattleFieldCardX - 5;
		cardPlaceTarget.y = BattleFieldCardY - 5;
		cardPlaceTarget.visible = true;

		currentMode = PLAYER_CARD_PLACING;
		ready = true;
	}

	public function battleEnd():Void
	{
		currentMode = GAME_OVER;
		var playerScore:Int = 0;
		var enemyScore:Int = 0;

		for (p in playedCards.members)
		{
			if (p.owner == CardOwner.PLAYER)
				playerScore++;
			else
				enemyScore++;
		}

		// show new screen that shows winner, let's player pick card (if they won), and get money
		winner = playerScore > enemyScore ? CardOwner.PLAYER : CardOwner.OPPONENT;
		openSubState(new BattleEndState(winner, enemy, returnFromSubState));
	}

	public function returnFromSubState():Void
	{
		closeCallback = () ->
		{
			callback(winner == CardOwner.PLAYER ? win : lose);
		}

		GameGlobals.transOut(() ->
		{
			close();
		});
	}
}

class BattleEndState extends FlxSubState
{
	public var back:GameFrame;
	public var winText:FlxSprite;
	public var cardSelections:FlxTypedGroup<CardGraphic>;
	public var selectedCard:Int = -1;
	public var doneButton:GameText;
	public var cursor:GameText;
	public var selecting:Bool = false;
	public var selectMessage:GameText;
	public var prizeMoney:GameText;

	public var opponent:Opponent;

	public function new(Winner:CardOwner, Opponent:Opponent, Callback:Void->Void):Void
	{
		super();

		opponent = Opponent;
		closeCallback = Callback;

		add(back = new GameFrame(780, 440));
		back.scrollFactor.set();
		Global.screenCenter(back);
		back.x = Std.int(back.x);
		back.y = Std.int(back.y);

		winText = holidayccg.globals.GraphicsCache.loadFlxSpriteFromAtlas("battle_text");
		winText.x = Std.int(back.x + (back.width / 2) - (winText.width / 2));
		winText.y = back.y + 20;
		winText.scrollFactor.set();
		add(winText);

		add(doneButton = new GameText());
		doneButton.text = "Done";
		doneButton.x = Std.int(back.x + (back.width / 2) - (doneButton.width / 2));
		doneButton.y = back.y + back.height - doneButton.height - 20;
		doneButton.scrollFactor.set();
		doneButton.visible = false;

		add(cursor = new GameText());
		cursor.text = "]";
		cursor.x = Std.int(doneButton.x - cursor.width - 10);
		cursor.y = doneButton.y;
		cursor.scrollFactor.set();
		cursor.visible = false;

		add(prizeMoney = new GameText());
		prizeMoney.text = "You won: $" + opponent.reward + " from your Opponent!";
		prizeMoney.x = Std.int(back.x + (back.width / 2) - (prizeMoney.width / 2));
		prizeMoney.y = doneButton.y - prizeMoney.height - 20;
		prizeMoney.scrollFactor.set();
		prizeMoney.visible = false;

		selectedCard = -1;

		var startX:Float = (Global.width / 2) - ((96 + 20) * 2.5);

		if (Winner == CardOwner.PLAYER)
		{
			GameGlobals.Player.money += opponent.reward;
			opponent.reward = opponent.subsequentReward;
			winText.animation.frameName = "win";

			add(cardSelections = new FlxTypedGroup<CardGraphic>());

			var cG:CardGraphic = null;
			for (c in Opponent.deck.cards)
			{
				cG = new CardGraphic();
				cG.spawn(c, CardOwner.OPPONENT);
				cG.x = Std.int(startX + ((cG.width + 20) * cardSelections.length));
				cG.y = -Global.height;
				cardSelections.add(cG);
			}

			selectMessage = new GameText();
			selectMessage.text = "Select a card to add to your collection!";
			selectMessage.scrollFactor.set();
			Global.screenCenter(selectMessage);
			selectMessage.y = back.y + winText.height + 50;
			add(selectMessage);

			revealCards();
		}
		else
		{
			winText.animation.frameName = "lose";

			showExit();
		}
	}

	public function revealCards():Void
	{
		for (c in 0...cardSelections.length)
		{
			FlxTween.linearMotion(cardSelections.members[c], cardSelections.members[c].x, cardSelections.members[c].y, cardSelections.members[c].x,
				back.y + winText.height + 100, .1, true, {
					type: FlxTweenType.ONESHOT,
					startDelay: c * .05,
					onComplete: c == cardSelections.length - 1 ?(_) ->
					{
						Sounds.playOneOf([
							"cardSlide1",
							"cardSlide2",
							"cardSlide3",
							"cardSlide4",
							"cardSlide6",
							"cardSlide6",
							"cardSlide7",
							"cardSlide8"
						]);
						startFlippingCards();
					} : (_) ->
					{
						Sounds.playOneOf([
							"cardSlide1",
							"cardSlide2",
							"cardSlide3",
							"cardSlide4",
							"cardSlide6",
							"cardSlide6",
							"cardSlide7",
							"cardSlide8"
						]);
					}
				});
		}
	}

	public function startFlippingCards():Void
	{
		var t1:FlxTimer = new FlxTimer();
		t1.start(1, (_) ->
		{
			cardSelections.members[0].reveal();
		});
		var t2:FlxTimer = new FlxTimer();
		t2.start(1.1, (_) ->
		{
			cardSelections.members[1].reveal();
		});
		var t3:FlxTimer = new FlxTimer();
		t3.start(1.2, (_) ->
		{
			cardSelections.members[2].reveal();
		});
		var t4:FlxTimer = new FlxTimer();
		t4.start(1.3, (_) ->
		{
			cardSelections.members[3].reveal();
		});
		var t5:FlxTimer = new FlxTimer();
		t5.start(1.4, (_) ->
		{
			cardSelections.members[4].reveal();
		});
		var t6:FlxTimer = new FlxTimer();
		t6.start(1.6, (_) ->
		{
			selecting = true;
			selectCard(4);
			// selectedCard = 4;
			// showExit();
		});
	}

	public function deselectCard(Card:Int):Void
	{
		cardSelections.members[Card].selected = false;
		cardSelections.members[Card].y -= 20;
		Sounds.playOneOf([
			"cardSlide1",
			"cardSlide2",
			"cardSlide3",
			"cardSlide4",
			"cardSlide6",
			"cardSlide6",
			"cardSlide7",
			"cardSlide8"
		]);
	}

	public function selectCard(Card:Int):Void
	{
		if (selectedCard != -1)
		{
			deselectCard(selectedCard);
		}
		cardSelections.members[Card].selected = true;
		cardSelections.members[Card].y += 20;
		Sounds.playOneOf([
			"cardSlide1",
			"cardSlide2",
			"cardSlide3",
			"cardSlide4",
			"cardSlide6",
			"cardSlide6",
			"cardSlide7",
			"cardSlide8"
		]);
		selectedCard = Card;
	}

	public function showExit():Void
	{
		doneButton.visible = true;

		cursor.visible = true;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (selecting)
		{
			if (Controls.justPressed.LEFT)
			{
				if (selectedCard == 0)
					selectCard(4);
				else
					selectCard(selectedCard - 1);
			}
			else if (Controls.justPressed.RIGHT)
			{
				if (selectedCard == 4)
					selectCard(0);
				else
					selectCard(selectedCard + 1);
			}
			else if (Controls.justPressed.A)
			{
				selecting = false;
				// deselectCard(selectedCard);
				cardSelections.members[selectedCard].selected = false;
				prizeMoney.visible = true;
				showExit();
			}
		}
		else
		{
			if (Controls.justPressed.A)
			{
				// close substates!!
				if (selectedCard == -1)
				{
					exitState();
				}
				else
				{
					var cG:CardGraphic = cardSelections.members[selectedCard];
					GameGlobals.Player.collection.add(cG.card.id, 1);

					if (opponent.sideboard.length > 0)
					{
						// take a random card out of the sideboard, and replace the taken card with it
						FlxG.random.shuffle(opponent.sideboard);
						var c:Int = opponent.sideboard.pop();
						opponent.deck.cards[selectedCard] = c;
					}

					FlxTween.linearMotion(cG, cG.x, cG.y, Global.width / 2 - cG.width / 2, Global.height + 10, .5, true, {
						onComplete: (_) ->
						{
							Sounds.playOneOf([
								"cardSlide1",
								"cardSlide2",
								"cardSlide3",
								"cardSlide4",
								"cardSlide6",
								"cardSlide6",
								"cardSlide7",
								"cardSlide8"
							]);
							exitState();
						}
					});
				}
			}
			else if (Controls.justPressed.B)
			{
				// if we have a card selected, go back and let us select again...
				selecting = true;
				selectCard(0);
			}
		}
	}

	public function exitState():Void
	{
		close();
	}
}

class CoinFlip extends FlxSubState
{
	public var coin:FlxSprite;
	public var winner:String;

	public var callback:Void->Void;

	public function new(Callback:Void->Void):Void
	{
		super();

		openCallback = start;
		callback = Callback;

		add(coin = GraphicsCache.loadFlxSpriteFromAtlas("coinflip"));
		coin.scrollFactor.set();
	}

	public function init(Winner:String = "Green"):Void
	{
		winner = Winner;
		var anim:Array<String> = [];
		var flips:Int = 0;

		var odd:Array<Int> = [1, 3];
		var even:Array<Int> = [2, 4];

		if (FlxG.random.bool())
		{
			anim.push("start_green_01.png");
			anim.push("start_green_01.png");
			anim.push("start_green_01.png");
			anim.push("start_green_01.png");
			anim.push("start_green_01.png");
			anim.push("start_green_01.png");
			anim.push("start_green_01.png");
			anim.push("start_green_01.png");
			anim.push("start_green_01.png");
			anim.push("start_green_01.png");
			anim.push("start_green_01.png");
			anim.push("start_green_01.png");
			if (winner == "Green")
			{
				flips = odd[FlxG.random.int(0, 1)];
			}
			else
			{
				flips = even[FlxG.random.int(0, 1)];
			}
			for (i in 0...flips)
			{
				if (i % 2 == 0)
				{
					anim.push("flip_to_green_01.png");
					anim.push("flip_to_green_02.png");
					anim.push("flip_to_green_03.png");
				}
				else
				{
					anim.push("flip_to_red_01.png");
					anim.push("flip_to_red_02.png");
					anim.push("flip_to_red_03.png");
				}
			}
		}
		else
		{
			anim.push("start_red_01.png");
			anim.push("start_red_01.png");
			anim.push("start_red_01.png");
			anim.push("start_red_01.png");
			anim.push("start_red_01.png");
			anim.push("start_red_01.png");
			anim.push("start_red_01.png");
			anim.push("start_red_01.png");
			anim.push("start_red_01.png");
			anim.push("start_red_01.png");
			anim.push("start_red_01.png");
			anim.push("start_red_01.png");
			if (winner == "Red")
			{
				flips = odd[FlxG.random.int(0, 1)];
			}
			else
			{
				flips = even[FlxG.random.int(0, 1)];
			}
			for (i in 0...flips)
			{
				if (i % 2 == 0)
				{
					anim.push("flip_to_red_01.png");
					anim.push("flip_to_red_02.png");
					anim.push("flip_to_red_03.png");
				}
				else
				{
					anim.push("flip_to_green_01.png");
					anim.push("flip_to_green_02.png");
					anim.push("flip_to_green_03.png");
				}
			}
		}
		if (winner == "Green")
		{
			anim.push("flip_green_end_01.png");
			anim.push("flip_green_end_02.png");
			anim.push("flip_green_end_03.png");
			anim.push("flip_green_end_04.png");
			anim.push("flip_green_end_05.png");
			anim.push("flip_green_end_06.png");
			anim.push("flip_green_end_07.png");
			anim.push("flip_green_end_08.png");
			anim.push("flip_green_end_09.png");
			anim.push("flip_green_end_10.png");
			anim.push("flip_green_end_11.png");
			anim.push("flip_green_end_12.png");
			anim.push("flip_green_end_13.png");
			anim.push("flip_green_end_14.png");
			anim.push("flip_green_end_14.png");
			anim.push("flip_green_end_14.png");
			anim.push("flip_green_end_14.png");
			anim.push("flip_green_end_14.png");
			anim.push("flip_green_end_14.png");
			anim.push("flip_green_end_14.png");
			anim.push("flip_green_end_14.png");
			anim.push("flip_green_end_14.png");
			anim.push("flip_green_end_14.png");
			anim.push("flip_green_end_14.png");
			anim.push("flip_green_end_14.png");
		}
		else
		{
			anim.push("flip_red_end_01.png");
			anim.push("flip_red_end_02.png");
			anim.push("flip_red_end_03.png");
			anim.push("flip_red_end_04.png");
			anim.push("flip_red_end_05.png");
			anim.push("flip_red_end_06.png");
			anim.push("flip_red_end_07.png");
			anim.push("flip_red_end_08.png");
			anim.push("flip_red_end_09.png");
			anim.push("flip_red_end_10.png");
			anim.push("flip_red_end_11.png");
			anim.push("flip_red_end_12.png");
			anim.push("flip_red_end_13.png");
			anim.push("flip_red_end_14.png");
			anim.push("flip_red_end_14.png");
			anim.push("flip_red_end_14.png");
			anim.push("flip_red_end_14.png");
			anim.push("flip_red_end_14.png");
			anim.push("flip_red_end_14.png");
			anim.push("flip_red_end_14.png");
			anim.push("flip_red_end_14.png");
			anim.push("flip_red_end_14.png");
			anim.push("flip_red_end_14.png");
			anim.push("flip_red_end_14.png");
			anim.push("flip_red_end_14.png");
		}

		coin.animation.addByNames("flip", anim, 12, false);
		coin.animation.finishCallback = (a:String) ->
		{
			if (a == "flip")
			{
				close();
			}
		};

		closeCallback = () ->
		{
			callback();
		};
	}

	public function start():Void
	{
		coin.x = Global.width / 2 - coin.width / 2;
		coin.y = Global.height / 2 - coin.height / 2;
		coin.animation.play("flip", true);
		var t:FlxTimer = new FlxTimer();
		t.start(1, (_) ->
		{
			Sounds.playSound("coin_up", 1);
		}, 1);
		var t2:FlxTimer = new FlxTimer();
		t2.start((coin.animation.frames / 12) - 1, (_) ->
		{
			Sounds.playSound("coin_down", 1);
		}, 1);
	}

	override public function close():Void
	{
		coin.animation.remove("flip");
		super.close();
	}
}

@:enum abstract BattleMode(String)
{
	var SETUP = "setup";
	var PLAYER_TURN = "player_turn";
	var PLAYER_CARD_PLACING = "player_card_placing";
	var ENEMY_TURN = "enemy_turn";
	var TURN_END = "turn_end";
	var TURN_ENDING = "turn_ending";
	var GAME_OVER = "game_over";
}
