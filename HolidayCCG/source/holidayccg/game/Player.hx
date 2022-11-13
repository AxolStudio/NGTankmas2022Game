package holidayccg.game;

import holidayccg.globals.Cards.Deck;
import holidayccg.globals.Cards.Collection;

class Player
{
	public var collection:Collection;
	public var deck:Deck;

	public function new():Void
	{
		collection = new Collection();
		for (i in 0...5)
			collection.add(i + 1, 1);

		deck = new Deck([1, 2, 3, 4, 5]);
	}
}
