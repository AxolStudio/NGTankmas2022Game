package yuleduel.game;

import yuleduel.globals.Cards.Deck;
import yuleduel.globals.Cards.Collection;

class Player
{
	public var collection:Collection;
	public var deck:Deck;
	public var money:Int;

	public function new():Void
	{
		collection = new Collection();
		for (i in 0...5)
			collection.add(i + 1, 1);

		deck = new Deck([1, 2, 3, 4, 5]);

		money = 0;
	}
}
