package holidayccg.globals;

import flixel.tweens.FlxTween;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.group.FlxGroup;

@:build(holidayccg.macros.CardBuilder.build()) // CardList
class Cards {}

class Card
{
	public var id:Int = -1;
	public var name:String = "";
	public var value:Int = 0;
	public var rarity:CardRarity = CardRarity.COMMON;
	public var attacks:Array<String> = [];

	public function new(id:Int, name:String, value:Int, attacks:Array<String>, rarity:CardRarity)
	{
		this.id = id;
		this.name = name;
		this.value = value;
		this.rarity = rarity;
		this.attacks = attacks;
	}

	public static function buildCard(Data:Dynamic):Card
	{
		return new Card(Data.id, Data.name, Data.value, Data.attacks, Data.rarity);
	}

	// function to generate the card graphic
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

class CardGraphic extends FlxSpriteGroup
{
	public var back:FlxSprite;
	public var value:FlxSprite;
	public var attacks:Array<FlxSprite> = [];

	public var battleFieldPos:Int = -1;

	public var card:Card;

	// public var x(get, set):Float;
	// public var y(get, set):Float;
	// public var alpha(default, set):Float;
	public var owner:CardOwner;
	public var shown(default, set):Bool = false;

	public var outline:FlxSprite;

	public var selected(default, set):Bool = false;

	public var flipping:Bool = false;

	// public var width(get, never):Float;
	// public var height(get, never):Float;

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

		add(value = GraphicsCache.loadFlxSpriteFromAtlas("card_values"));

		var tmpA:FlxSprite = GraphicsCache.loadFlxSpriteFromAtlas("attack_arrows");
		attacks.push(tmpA);
		add(tmpA);

		tmpA = GraphicsCache.loadFlxSpriteFromAtlas("attack_arrows");
		attacks.push(tmpA);
		add(tmpA);

		tmpA = GraphicsCache.loadFlxSpriteFromAtlas("attack_arrows");
		attacks.push(tmpA);
		add(tmpA);

		tmpA = GraphicsCache.loadFlxSpriteFromAtlas("attack_arrows");
		attacks.push(tmpA);
		add(tmpA);

		attacks[0].animation.frameName = "N";
		attacks[1].animation.frameName = "S";
		attacks[2].animation.frameName = "E";
		attacks[3].animation.frameName = "W";

		back.scrollFactor.set(0, 0);
		outline.scrollFactor.set(0, 0);
		value.scrollFactor.set(0, 0);
		attacks[0].scrollFactor.set(0, 0);
		attacks[1].scrollFactor.set(0, 0);
		attacks[2].scrollFactor.set(0, 0);
		attacks[3].scrollFactor.set(0, 0);

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

		value.animation.frameName = Std.string(card.value);
		shown = false;
		selected = false;

		updateVisibility();
	}

	public function flip(NewOwner:CardOwner):Void
	{
		if (NewOwner == owner)
		{
			return;
		}
		flipping = true;
		FlxTween.tween(scale, {x: 0}, .1, {
			onComplete: (_) ->
			{
				owner = NewOwner;
				back.animation.frameName = owner == PLAYER ? "player" : "enemy";
				FlxTween.tween(scale, {x: 1}, .1, {
					onComplete: (_) ->
					{
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
				FlxTween.tween(scale, {x: 1}, .1, {
					onComplete: (_) ->
					{
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

@:enum abstract CardRarity(String)
{
	var COMMON = "common";
	var UNCOMMON = "uncommon";
	var RARE = "rare";
	var STARTER = "starter";
}

@:enum abstract CardOwner(Int)
{
	var PLAYER = 0;
	var OPPONENT = 1;
}
