package holidayccg.states;

import flixel.text.FlxText;
import flixel.util.FlxTimer;
import holidayccg.globals.Cards;
import holidayccg.globals.Cards.Card;
import flixel.util.FlxSort;
import holidayccg.globals.Cards.Deck;
import flixel.FlxG;
import flixel.tweens.FlxTween;
import holidayccg.globals.Cards.CardOwner;
import holidayccg.globals.Cards.CardGraphic;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;
import holidayccg.globals.GameGlobals;
import flixel.FlxSubState;

class BattleState extends FlxSubState
{
	public var gameGrid:Array<Int> = [];
	public var battlefield:FlxSprite;
	public var blocker:FlxSprite;
	public var playerHand:Deck;
	public var enemyHand:Deck;
	public var enemyCards:FlxTypedGroup<CardGraphic>;
	public var playerCards:FlxTypedGroup<CardGraphic>;
	public var playedCards:FlxTypedGroup<CardGraphic>;

	public var currentTurn:CardOwner = CardOwner.PLAYER;

	public var currentMode:BattleMode = SETUP;

	public var blackout:FlxSprite;

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

	public function new():Void
	{
		super();
		bgColor = GameGlobals.ColorPalette[14];

		add(battlefield = new FlxSprite());
		battlefield.loadGraphic(Global.asset("assets/images/battlefield.png"));
		battlefield.scrollFactor.set(0, 0);
		Global.screenCenter(battlefield);
		battlefield.x = BattleFieldX;
		battlefield.y = BattleFieldY;

		add(blocker = new FlxSprite());
		blocker.loadGraphic(Global.asset("assets/images/blocker.png"));
		blocker.scrollFactor.set();

		add(enemyCards = new FlxTypedGroup<CardGraphic>());

		add(playerCards = new FlxTypedGroup<CardGraphic>());

		add(playedCards = new FlxTypedGroup<CardGraphic>());

		add(cardPlaceTarget = new FlxSprite());
		cardPlaceTarget.loadGraphic(Global.asset("assets/images/card_outline.png"));
		cardPlaceTarget.scrollFactor.set();
		cardPlaceTarget.visible = false;

		add(blackout = new FlxSprite());
		blackout.makeGraphic(Global.width, Global.height, GameGlobals.ColorPalette[1]);
		blackout.alpha = 1;
		blackout.scrollFactor.set();

		lastMode = null;

		openCallback = start;
	}

	public function init(PlayerDeck:Deck, EnemyDeck:Deck):Void
	{
		playerHand = PlayerDeck;
		enemyHand = EnemyDeck;

		currentMode = SETUP;

		gameGrid = [for (i in 0...9) 0];
		gameGrid[FlxG.random.int(0, 8)] = -1;

		blackout.alpha = 1;

		ready = false;

		var cardG:CardGraphic = null;

		for (i in 0...playerHand.length)
		{
			cardG = new CardGraphic();
			cardG.spawn(playerHand.cards[i], CardOwner.PLAYER);
			cardG.x = -100 - cardG.width;
			cardG.y = PlayerHandY + (i * HandCardSpacing);
			cardG.shown = true;

			playerCards.add(cardG);
		}

		for (i in 0...enemyHand.length)
		{
			cardG = new CardGraphic();
			cardG.spawn(enemyHand.cards[i], CardOwner.OPPONENT);
			cardG.x = Global.width + 100;
			cardG.y = EnemyHandY + (i * HandCardSpacing);
			cardG.shown = false;

			enemyCards.add(cardG);
		}

		blocker.x = Global.width / 2 - blocker.width / 2;
		blocker.y = Global.height + 100;

		currentTurn = CardOwner.PLAYER; // RANDOMIZE THIS LATER!

		selectedCard = -1;
	}

	public function start():Void
	{
		FlxTween.tween(blackout, {alpha: 0}, 1, {
			type: FlxTweenType.ONESHOT,
			onComplete: (_) ->
			{
				placeBlocker();
			}
		});
	}

	public function placeBlocker():Void
	{
		var blockerPosX:Int = BattleFieldCardX + ((gameGrid.indexOf(-1) % 3) * BattleFieldCardSpacingX);
		var blockerPosY:Int = BattleFieldCardY + (Std.int(gameGrid.indexOf(-1) / 3) * BattleFieldCardSpacingY);

		FlxTween.quadMotion(blocker, blocker.x, blocker.y, 200, 200, blockerPosX, blockerPosY, 1, true, {
			type: FlxTweenType.ONESHOT,
			onComplete: (_) ->
			{
				FlxG.camera.shake(0.01, 0.5);
				placeCards();
			}
		});
	}

	public function placeCards():Void
	{
		for (i in 0...playerCards.length)
		{
			FlxTween.num(playerCards.members[i].x, PlayerHandX, 0.5, {
				type: FlxTweenType.ONESHOT,
				startDelay: i * 0.1
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
					startGame();
				} : null
			}, (Value:Float) ->
				{
					enemyCards.members[i].x = Value;
				});
		}
	}

	public function startGame():Void
	{
		// show a 'start!' message
		currentMode = (currentTurn == CardOwner.PLAYER) ? PLAYER_TURN : ENEMY_TURN;
		if (currentMode == PLAYER_TURN)
		{
			startPlayerTurn();
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
					bestSpot = i;
					bestCard = c;
				}
			}
		}

		// show the card then move it from the player's hand to the board
		trace(bestSpots);
		trace(enemyHand.cards);
		trace("bestValue:", bestValue, "bestSpot:", bestSpot, "bestCard:", bestCard);

		var cardG:CardGraphic = getCardGraphicFromHand(bestCard, CardOwner.OPPONENT);
		cardG.shown = true;

		var cardPosX:Int = BattleFieldCardX + ((bestSpot % 3) * BattleFieldCardSpacingX);
		var cardPosY:Int = BattleFieldCardY + (Std.int(bestSpot / 3) * BattleFieldCardSpacingY);

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

		sortHand(CardOwner.PLAYER);
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
			if (playerCards.length > 1 || enemyCards.length > 1)
			{
				if (lastMode == PLAYER_CARD_PLACING)
					startEnemyTurn();
				else if (lastMode == ENEMY_TURN)
					startPlayerTurn();
			}
			else
			{
				battleEnd();
			}
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

			var cardPosX:Int = BattleFieldCardX + ((selectedSpot % 3) * BattleFieldCardSpacingX);
			var cardPosY:Int = BattleFieldCardY + (Std.int(selectedSpot / 3) * BattleFieldCardSpacingY);

			FlxTween.linearMotion(c, c.x, c.y, cardPosX, cardPosY, .2, true, {
				type: FlxTweenType.ONESHOT,
				onComplete: (_) ->
				{
					// remove the card from the player's hand
					playerHand.cards[selectedCard] = -1;
					playerCards.remove(c, true);
					// add the card to the battlefield
					gameGrid[selectedSpot] = c.card.id;
					c.battleFieldPos = selectedSpot;
					playedCards.add(c);

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
				playerScore += p.card.value;
			else
				enemyScore += p.card.value;
		}

		// show new screen that shows winner, let's player pick card (if they won), and get money

		openSubState(new BattleEndState(playerScore, enemyScore));
	}
}

class BattleEndState extends FlxSubState
{
	public function new(PlayerScore:Int, EnemyScore:Int):Void
	{
		super();
		var winner:FlxText = new FlxText(0, 0, FlxG.width, PlayerScore > EnemyScore ? "You won!" : (PlayerScore < EnemyScore ? "You Lost!" : "Tie!"));
		winner.alignment = FlxTextAlign.CENTER;
		winner.scrollFactor.set();
		Global.screenCenter(winner);
		add(winner);
	}
}

@:enum abstract BattleMode(String)
{
	var SETUP = "setup";
	var PLAYER_TURN = "player_turn";
	var PLAYER_CARD_PLACING = "player_card_placing";
	var ENEMY_TURN = "enemy_turn";
	var TURN_END = "turn_end";
	var GAME_OVER = "game_over";
}
