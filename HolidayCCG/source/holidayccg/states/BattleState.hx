package holidayccg.states;

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

	public static inline var PlayerHandX:Int = 144;
	public static inline var PlayerHandY:Int = 150;

	public static inline var EnemyHandX:Int = 720;
	public static inline var EnemyHandY:Int = 78;

	public static inline var HandCardSpacing:Int = 48;

	public static inline var BattleFieldX:Int = 314;
	public static inline var BattleFieldY:Int = 68;
	public static inline var BattleFieldCardX:Int = 324;
	public static inline var BattleFieldCardY:Int = 78;
	public static inline var BattleFieldCardSpacingX:Int = 108;
	public static inline var BattleFieldCardSpacingY:Int = 132;

	public var selectedCard:Int;

	public var ready:Bool = false;

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

		add(blackout = new FlxSprite());
		blackout.makeGraphic(Global.width, Global.height, GameGlobals.ColorPalette[1]);
		blackout.alpha = 1;
		blackout.scrollFactor.set();

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

	public function startEnemyTurn():Void {}

	public function startPlayerTurn():Void
	{
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
		if (Index > -1 && selectedCard != Index)
		{
			selectedCard = Index;
			var c:CardGraphic = getCardGraphic(selectedCard, CardOwner.PLAYER);

			c.selected = true;
			c.x = PlayerHandX + (c.width * .33); // Tween?
			playerCards.sort(cardSort);
		}
	}

	public function cardSort(Order:Int, ObjA:CardGraphic, ObjB:CardGraphic):Int
	{
		var result:Int = 0;
		if (ObjA.selected && !ObjB.selected)
			result = Order;
		else if (!ObjA.selected && ObjB.selected)
			result = Order;
		else if (ObjA.y < ObjA.y)
		{
			result = -Order;
		}
		else if (ObjA.y > ObjA.y)
		{
			result = -Order;
		}
		return result;
	}

	public function getCardGraphic(Index:Int, WhichHand:CardOwner):CardGraphic
	{
		for (i in playerCards.members)
		{
			if (i.card.id == playerHand.cards[selectedCard])
			{
				return i;
			}
		}
		return null;
	}

	public function deselectCard():Void
	{
		var c:CardGraphic = getCardGraphic(selectedCard, CardOwner.PLAYER);
		c.selected = false;
		c.x = PlayerHandX;
		selectedCard = -1;

		playerCards.sort(cardSort);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		if (ready)
		{
			// let the player do stuff???
		}
	}
}

@:enum abstract BattleMode(String)
{
	var SETUP = "setup";
	var PLAYER_TURN = "player_turn";
	var ENEMY_TURN = "enemy_turn";
	var GAME_OVER = "game_over";
}
