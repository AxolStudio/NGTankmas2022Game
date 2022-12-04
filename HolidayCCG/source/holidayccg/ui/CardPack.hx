package holidayccg.ui;

import holidayccg.globals.Sounds;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;

class CardPack extends FlxTypedGroup<FlxSprite>
{
	public var top:FlxSprite;
	public var base:FlxSprite;
	public var spark:FlxSprite;

	public var x(get, set):Float;
	public var y(get, set):Float;

	public var width(get, never):Float;
	public var height(get, never):Float;

	private var baseX:Float = 0;
	private var baseY:Float = 0;

	public function new()
	{
		super();
		top = new FlxSprite(0, 0, Global.asset("assets/images/card_pack_top.png"));
		base = new FlxSprite(0, 0, Global.asset("assets/images/card_pack_base.png"));
		spark = new FlxSprite(0, 0, Global.asset("assets/images/card_pack_spark.png"));

		spark.visible = false;

		add(base);
		add(top);
		add(spark);
	}

	public function reset(X:Float, Y:Float):Void
	{
		x = X;
		y = Y;

		top.alpha = 1;
		base.alpha = 1;

		spark.visible = false;
	}

	private function set_x(Value:Float):Float
	{
		baseX = Value;
		top.x = base.x = Value;

		spark.x = Value - 10;
		return baseX;
	}

	private function set_y(Value:Float):Float
	{
		baseY = Value;
		top.y = Value;
		base.y = top.y + top.height - 1;

		spark.y = base.y - 10;

		return baseY;
	}

	private function get_x():Float
	{
		return baseX;
	}

	private function get_y():Float
	{
		return baseY;
	}

	private function get_width():Float
	{
		return base.width;
	}

	private function get_height():Float
	{
		return base.height + top.height;
	}

	public function open(Callback:Void->Void):Void
	{
		spark.visible = true;
		Sounds.playSound("rip");
		FlxTween.tween(spark, {x: base.x + base.width + 10}, .33, {
			type: FlxTweenType.ONESHOT,
			onComplete: (_) ->
			{
				spark.visible = false;
				Sounds.playSound("cardTakeOutPackage1");
				FlxTween.tween(top, {y: top.y - 20, alpha: 0}, .4, {
					type: FlxTweenType.ONESHOT,
					onComplete: (_) ->
					{
						Callback();
					}
				});
			}
		});
	}
}
