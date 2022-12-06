package holidayccg.macros;

import haxe.macro.Context;
import haxe.macro.Expr;


class CardBuilder
{
	public static macro function build():Array<Field>
	{
		var fields = Context.getBuildFields();
		var map:Array<Expr> = [];
		var e:Expr;

		var list:Array<Dynamic> = tjson.TJSON.parse(sys.io.File.getContent(#if ADVENT 'holidayccg/' + #end 'assets/data/cards.json'));

		for (l in 0...list.length)
		{
			e = macro holidayccg.globals.Cards.Card.buildCard($v{list[l]});
			map.push(macro Std.int($v{list[l].id}) => $e{e});
		}

		fields.push({
			pos: Context.currentPos(),
			name: "CardList",
			meta: null,
			kind: FieldType.FVar(macro:Map<Int, holidayccg.globals.Cards.Card>, macro $a{map}),
			doc: null,
			access: [Access.APublic, Access.AStatic]
		});

		return fields;
	}
}
