package yuleduel.states;

import yuleduel.globals.Sounds;
import flixel.util.FlxDestroyUtil;
import flixel.FlxG;
import flixel.tweens.FlxTween;
import yuleduel.globals.GameGlobals;
import flixel.FlxSprite;
import yuleduel.states.GiveBadgeState.Sparkle;
import flixel.group.FlxGroup.FlxTypedGroup;
import yuleduel.ui.TutorialMessage;
import yuleduel.globals.Cards.CardGraphic;
import flixel.FlxSubState;

class GiveCardState extends FlxSubState
{
	public var card:CardGraphic;
	public var cardText:TutorialMessage;

	public var sparkles:FlxTypedGroup<Sparkle>;

	public var whichCard:Int = -1;

	public var blackout:FlxSprite;

	public var ready:Bool = false;

	override public function create():Void
	{
		openCallback = start;

		add(blackout = new FlxSprite());
		blackout.makeGraphic(Global.width, Global.height, GameGlobals.ColorPalette[1]);
		blackout.alpha = 0;

		add(card = new CardGraphic());

		add(sparkles = new FlxTypedGroup<Sparkle>());

		super.create();
	}

	public function new(WhichCard:Int):Void
	{
		super();
		whichCard = WhichCard;
	}

	public function start():Void
	{
		card.spawn(whichCard);
		card.displayScale = 2;

		card.x = (Global.width / 2) - (card.width / 2) + 10;
		card.y = Global.height + 10;

		GameGlobals.Player.collection.add(whichCard, 1);
		GameGlobals.save();

		FlxTween.tween(blackout, {alpha: 0.8}, 0.25, {
			onComplete: (_) ->
			{
				sparkles.add(new Sparkle(card.width, card.height));
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
				FlxTween.tween(card, {y: Global.height / 2 - card.height / 2 + 10}, .5, {
					onComplete: (_) ->
					{
						card.reveal();
						sparkles.add(new Sparkle(card.width, card.height));
						cardText = new TutorialMessage("You got a " + TitleCase.toTitleCase(card.card.name) + " Card!");
						cardText.x = Global.width / 2 - cardText.width / 2;
						cardText.y = cardText.y + cardText.height + 10;
						add(cardText);
						Sounds.playSound("success");
						ready = true;
					}
				});
			}
		});
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (ready && (Controls.justPressed.A || Controls.justPressed.B || Controls.justPressed.PAUSE))
		{
			Sounds.playSound("jingle");
			exit();
		}
	}

	public function exit()
	{
		ready = false;
		sparkles.kill();
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
		FlxTween.tween(card, {y: -card.height}, .5, {
			onComplete: (_) ->
			{
				FlxTween.tween(blackout, {alpha: 0}, 0.25, {
					onComplete: (_) ->
					{
						close();
					}
				});
			}
		});
	}

	override function destroy()
	{
		card = FlxDestroyUtil.destroy(card);
		cardText = FlxDestroyUtil.destroy(cardText);
		sparkles = FlxDestroyUtil.destroy(sparkles);

		super.destroy();
	}
}
