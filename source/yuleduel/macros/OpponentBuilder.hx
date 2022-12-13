package yuleduel.macros;

import haxe.macro.Context;
import haxe.macro.Expr;

class OpponentBuilder
{
	public static macro function build():Array<Field>
	{
		var fields = Context.getBuildFields();
		var map:Array<Expr> = [];
		var e:Expr;

		var list:Array<Dynamic> = tjson.TJSON.parse(sys.io.File.getContent(#if ADVENT 'yuleduel/' + #end 'assets/data/opponents.json'));

		for (l in 0...list.length)
		{
			e = macro new yuleduel.globals.Opponent($v{list[l]});
			map.push(macro $v{list[l].name} => $e{e});
		}

		fields.push({
			pos: Context.currentPos(),
			name: "OpponentList",
			meta: null,
			kind: FieldType.FVar(macro:Map<String, yuleduel.globals.Opponent>, macro $a{map}),
			doc: null,
			access: [Access.APublic, Access.AStatic]
		});

		return fields;
	}
}
