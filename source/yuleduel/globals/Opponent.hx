package yuleduel.globals;

import yuleduel.globals.Cards.Deck;

@:build(yuleduel.macros.OpponentBuilder.build()) // OpponentList
class Opponent
{
	public var name(default, null):String = "";
	public var deck:Deck = null;
	public var sideboard:Array<Int> = [];
	public var reward:Int = 0;
	public var subsequentReward(default, null):Int = 0;

	public function new(Data:Dynamic):Void
	{
		name = Data.name;
		deck = new Deck(Data.deck);
		sideboard = Data.sideboard;
		reward = Data.reward;
		subsequentReward = Data.subsequentReward;

		#if STAND_ALONE
		trace(name);
		trace(this);
		#end
	}
}
