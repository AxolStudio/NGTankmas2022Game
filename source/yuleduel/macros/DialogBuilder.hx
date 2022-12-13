package yuleduel.macros;

import haxe.macro.Context;
import haxe.macro.Expr;

using StringTools;

class DialogBuilder
{
	public static macro function build():Array<Field>
	{
		var fields = Context.getBuildFields();
		var map:Array<Expr> = [];
		var dialogs:Array<Expr> = [];
		var e:Expr;
		var name:String;

		var list:Array<Dynamic> = tjson.TJSON.parse(sys.io.File.getContent(#if ADVENT 'yuleduel/' + #end 'assets/data/dialog.json'));

		for (l in 0...list.length)
		{
			name = list[l].who;
			dialogs = [];
			for (d in 0...list[l].dialogs.length)
			{
				e = macro new yuleduel.globals.DialogData($v{list[l].dialogs[d]});
				dialogs.push(e);
			}

			map.push(macro $v{name} => $a{dialogs});
		}

		fields.push({
			pos: Context.currentPos(),
			name: 'DialogList',
			meta: null,
			kind: FieldType.FVar(macro:Map<String, Array<yuleduel.globals.DialogData>>, macro $a{map}),
			doc: null,
			access: [Access.APublic, Access.AStatic]
		});

		return fields;
	}
}
