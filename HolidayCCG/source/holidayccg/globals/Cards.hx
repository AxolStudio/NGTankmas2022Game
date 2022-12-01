package holidayccg.globals;

import flixel.FlxG;
import flixel.system.debug.watch.Watch;
import holidayccg.ui.GameText;
import flixel.util.FlxDestroyUtil;
import flixel.tweens.FlxTween;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.group.FlxGroup;

@:build(holidayccg.macros.CardBuilder.build()) // CardList
class Cards
{
	public static var commons:Array<Int> = [];
	public static var uncommons:Array<Int> = [];
	public static var rares:Array<Int> = [];
	public static var epics:Array<Int> = [];
}

class Card
{
	public var id:Int = -1;
	public var name:String = "";
	public var value:Int = 0;
	public var rarity:String = "common";
	public var attacks:Array<String> = [];

	public function new(id:Int, name:String, value:Int, attacks:Array<String>, rarity:String)
	{
		this.id = id;
		this.name = name;
		this.value = value;
		this.rarity = rarity;
		this.attacks = attacks;
	}

	public static function buildCard(Data:Dynamic):Card
	{
		switch (Data.rarity)
		{
			case "C":
				Cards.commons.push(Data.id);

			case "U":
				Cards.uncommons.push(Data.id);
			case "R":
				Cards.rares.push(Data.id);
			case "E":
				Cards.epics.push(Data.id);
			default:
		}
		return new Card(Data.id, Data.name, Data.value, Data.attacks.split(','), switch (Data.rarity)
		{
			case "C":
				"common";
			case "U":
				"uncommon";
			case "R":
				"rare";
			case "E":
				"epic";
			default:
				"starter";
		});
	}
}

class Deck
{
	public var cards:Array<Int> = [];

	public var length(get, never):Int;

	public function new(Cards:Array<Int>):Void
	{
		cards = Cards;
	}

	public function get_length():Int
	{
		return cards.length;
	}

	// sort?
}

class Collection
{
	public var collection:Map<Int, Int> = [];

	public function new()
	{
		collection = [];
	}

	public function add(ID:Int, Amount:Int):Void
	{
		if (collection.exists(ID))
		{
			collection.set(ID, collection.get(ID) + Amount);
		}
		else
		{
			collection.set(ID, Amount);
		}
		if (!Dialog.Flags.exists("hasAll"))
		{
			var count:Int = 0;
			for (k in collection.keys())
			{
				count++;
			}
			if (count == 24)
				Dialog.Flags.set("hasAll", true);
		}
	}

	public function remove(ID:Int, Amount:Int):Void
	{
		if (collection.exists(ID))
		{
			collection.set(ID, collection.get(ID) - Amount);

			if (collection.get(ID) <= 0)
			{
				collection.remove(ID);
			}
		}
	}
}

@:access(flixel.text.FlxBitmapText._lines)
@:access(flixel.text.FlxBitmapText.updateText)
class CardGraphic extends FlxSpriteGroup
{
	public var back:FlxSprite;
	public var value:GameText;
	public var attacks:Array<FlxSprite> = [];
	public var name:GameText;
	public var nameLine1:GameText;
	public var nameLine2:GameText;
	public var illustration:FlxSprite;

	public var battleFieldPos:Int = -1;

	public var card:Card;

	// public var rarity:FlxSprite;
	// public var x(get, set):Float;
	// public var y(get, set):Float;
	// public var alpha(default, set):Float;
	public var owner:CardOwner;
	public var shown(default, set):Bool = false;

	public var outline:FlxSprite;

	public var selected(default, set):Bool = false;

	public var flipping:Bool = false;

	public var displayScale(default, set):Float = 1;

	// public var width(get, never):Float;
	// public var height(get, never):Float;

	override function destroy()
	{
		back = FlxDestroyUtil.destroy(back);
		value = FlxDestroyUtil.destroy(value);
		attacks = FlxDestroyUtil.destroyArray(attacks);
		card = null;
		owner = null;
		outline = FlxDestroyUtil.destroy(outline);
		name = FlxDestroyUtil.destroy(name);
		nameLine1 = FlxDestroyUtil.destroy(nameLine1);
		nameLine2 = FlxDestroyUtil.destroy(nameLine2);
		illustration = FlxDestroyUtil.destroy(illustration);
		// rarity = FlxDestroyUtil.destroy(rarity);

		super.destroy();
	}

	private function set_displayScale(Value:Float):Float
	{
		displayScale = Value;
		scale.set(displayScale, displayScale);
		updateHitbox();
		back.updateHitbox();
		outline.updateHitbox();
		value.updateHitbox();
		nameLine1.updateHitbox();
		nameLine2.updateHitbox();
		illustration.updateHitbox();
		for (attack in attacks)
		{
			attack.updateHitbox();
		}

		updatePositions();

		return displayScale;
	}

	public function updatePositions():Void
	{
		// adjust the positions of each element based on displayScale
		outline.x = back.x - (5 * displayScale);
		outline.y = back.y - (5 * displayScale);

		illustration.x = back.x + (3 * displayScale);
		illustration.y = back.y + (3 * displayScale);

		nameLine1.x = Std.int(back.x + (back.width / 2) - (nameLine1.width / 2));
		nameLine1.y = back.y + (back.height - (35 * displayScale));

		nameLine2.x = Std.int(back.x + (back.width / 2) - (nameLine2.width / 2));
		nameLine2.y = back.y + (back.height - (22 * displayScale));

		value.x = back.x + (5 * displayScale);
		value.y = back.y + (4 * displayScale);

		for (attack in attacks)
		{
			attack.x = Std.int(back.x + back.width - attack.width - (4 * displayScale));
			attack.y = back.y + (5 * displayScale);
		}
	}

	public function new():Void
	{
		super();

		add(outline = new FlxSprite());
		outline.loadGraphic(Global.asset("assets/images/card_outline.png"));
		outline.offset.x = outline.offset.y = 5;
		outline.width -= 10;
		outline.height -= 10;
		outline.x = outline.y -= 5;

		add(back = GraphicsCache.loadFlxSpriteFromAtlas("card_backs"));

		// add illustration
		add(illustration = GraphicsCache.loadFlxSpriteFromAtlas("card_illustrations"));
		illustration.x = illustration.y = 3;

		// add(value = GraphicsCache.loadFlxSpriteFromAtlas("card_values"));

		name = new GameText(Font.CARD_TEXT); // name.alignment = FlxTextAlign.CENTER;
		name.width = 90;
		name.autoSize = false;
		name.multiLine = true;
		name.fieldWidth = 90;
		name.wordWrap = true;

		add(nameLine1 = new GameText(Font.CARD_TEXT));

		nameLine1.y = back.y + back.height - 35;

		add(nameLine2 = new GameText(Font.CARD_TEXT));

		nameLine2.y = back.y + back.height - 22;

		add(value = new GameText(Font.CARD_NUMBERS));
		value.x = Std.int(back.x + 5);
		value.y = Std.int(back.y + 4);

		var tmpA:FlxSprite = new FlxSprite(Global.asset("assets/images/attack_UP.png"));
		tmpA.x = Std.int(back.x + back.width - tmpA.width - 4);
		tmpA.y = back.y + 5;
		attacks.push(tmpA);
		add(tmpA);

		tmpA = new FlxSprite(Global.asset("assets/images/attack_DOWN.png"));
		tmpA.x = Std.int(back.x + back.width - tmpA.width - 4);
		tmpA.y = back.y + 5;
		attacks.push(tmpA);
		add(tmpA);

		tmpA = new FlxSprite(Global.asset("assets/images/attack_RIGHT.png"));
		tmpA.x = Std.int(back.x + back.width - tmpA.width - 4);
		tmpA.y = back.y + 5;
		attacks.push(tmpA);
		add(tmpA);

		tmpA = new FlxSprite(Global.asset("assets/images/attack_LEFT.png"));
		tmpA.x = Std.int(back.x + back.width - tmpA.width - 4);
		tmpA.y = back.y + 5;
		attacks.push(tmpA);
		add(tmpA);

		// add(rarity = GraphicsCache.loadFlxSpriteFromAtlas("rarity"));
		// rarity.x = back.x + back.width - rarity.width - 5;
		// rarity.y = back.y + back.height - rarity.height - 5;

		back.scrollFactor.set(0, 0);
		outline.scrollFactor.set(0, 0);
		value.scrollFactor.set(0, 0);
		attacks[0].scrollFactor.set(0, 0);
		attacks[1].scrollFactor.set(0, 0);
		attacks[2].scrollFactor.set(0, 0);
		attacks[3].scrollFactor.set(0, 0);
		name.scrollFactor.set(0, 0);
		nameLine1.scrollFactor.set(0, 0);
		nameLine2.scrollFactor.set(0, 0);
		illustration.scrollFactor.set(0, 0);
		// rarity.scrollFactor.set(0, 0);

		offset.x = offset.y = 5;
		width -= 10;
		height -= 10;

		kill();
	}

	public function spawn(ID:Int, ?Owner:CardOwner = PLAYER):Void
	{
		revive();
		visible = true;
		alpha = 1;

		card = holidayccg.globals.Cards.CardList.get(ID);

		owner = Owner;

		back.animation.frameName = Owner == PLAYER ? "player" : "enemy";

		illustration.animation.frameName = Std.string(card.id);

		name.text = card.name.toUpperCase();
		name.updateText();

		if (name.numLines > 1)
		{
			nameLine1.text = name._lines[0];
			nameLine2.text = name._lines[1];
		}
		else
		{
			nameLine1.text = name.text;
		}

		nameLine1.x = Std.int(back.x + (back.width / 2) - (nameLine1.width / 2));
		nameLine2.x = Std.int(back.x + (back.width / 2) - (nameLine2.width / 2));

		value.text = card.value == 10 ? "A" : Std.string(card.value);

		// rarity.animation.frameName = card.rarity;

		shown = false;
		selected = false;

		updateVisibility();

		FlxG.watch.add(scale, "x");
	}

	public function flip(NewOwner:CardOwner):Void
	{
		if (NewOwner == owner)
		{
			return;
		}

		owner = NewOwner;

		flipping = true;
		FlxTween.tween(scale, {x: 0}, .1, {
			onComplete: (_) ->
			{
				back.animation.frameName = owner == PLAYER ? "player" : "enemy";
				FlxTween.tween(scale, {x: displayScale}, .1, {
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
						flipping = false;
					}
				});
			}
		});
	}

	public function reveal():Void
	{
		flipping = true;
		FlxTween.tween(scale, {x: 0}, .1, {
			onComplete: (_) ->
			{
				shown = true;
				FlxTween.tween(scale, {x: displayScale}, .1, {
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
						flipping = false;
					}
				});
			}
		});
	}

	public function hide():Void
	{
		flipping = true;
		FlxTween.tween(scale, {x: 0}, .1, {
			onComplete: (_) ->
			{
				shown = false;
				FlxTween.tween(scale, {x: 1}, .1, {
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
						flipping = false;
					}
				});
			}
		});
	}

	public function updateVisibility():Void
	{
		back.visible = visible;
		value.visible = visible && shown;
		attacks[0].visible = visible && shown && card.attacks.contains("N");
		attacks[1].visible = visible && shown && card.attacks.contains("S");
		attacks[2].visible = visible && shown && card.attacks.contains("E");
		attacks[3].visible = visible && shown && card.attacks.contains("W");
		nameLine1.visible = visible && shown;
		nameLine2.visible = visible && shown && name.numLines > 1;
		illustration.visible = visible && shown;
		// rarity.visible = visible && shown;
		outline.visible = visible && selected;
	}

	override public function set_visible(Visible:Bool):Bool
	{
		super.set_visible(Visible);

		updateVisibility();

		return visible;
	}

	public function set_shown(Value:Bool):Bool
	{
		shown = Value;
		updateVisibility();

		return shown;
	}

	public function set_selected(Value:Bool):Bool
	{
		selected = Value;
		updateVisibility();

		return selected;
	}

	// override public function set_x(Value:Float):Float
	// {
	// 	x = Value;
	// 	back.x = value.x = attacks[0].x = attacks[1].x = attacks[2].x = attacks[3].x = Value;
	// 	outline.x = back.x - 5;
	// 	return back.x;
	// }
	// override public function set_y(Value:Float):Float
	// {
	// 	back.y = value.y = attacks[0].y = attacks[1].y = attacks[2].y = attacks[3].y = Value;
	// 	outline.y = back.y - 5;
	// 	return back.y;
	// }
	// private function get_x():Float
	// {
	// 	return back.x;
	// }
	// private function get_y():Float
	// {
	// 	return back.y;
	// }
	// override private function set_alpha(Value:Float):Float
	// {
	// 	alpha = FlxMath.bound(0, 1, Value);
	// 	back.alpha = value.alpha = attacks[0].alpha = attacks[1].alpha = attacks[2].alpha = attacks[3].alpha = alpha;
	// 	return alpha;
	// }
	// override private function get_width():Float
	// {
	// 	return back.width;
	// }
	// override private function get_height():Float
	// {
	// 	return back.height;
	// }
}

@:enum abstract CardOwner(Int)
{
	var PLAYER = 0;
	var OPPONENT = 1;
}
