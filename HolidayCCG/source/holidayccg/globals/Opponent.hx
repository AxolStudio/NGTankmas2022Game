package holidayccg.globals;

import holidayccg.globals.Cards.Deck;

@:build(holidayccg.macros.OpponentBuilder.build()) // OpponentList
class Opponent
{
	public var name(default, null):String = "";
	public var deck(default, null):Deck = null;
	public var sideboard(default, null):Array<Int> = [];
	public var reward(default, null):Int = 0;

	public function new(Data:Dynamic):Void
	{
		name = Data.name;
		deck = new Deck(Data.deck);
		sideboard = Data.sideboard;
		reward = Data.reward;
	}
}
