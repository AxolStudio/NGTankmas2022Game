package holidayccg.macros;

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

		var list:Array<Dynamic> = tjson.TJSON.parse(sys.io.File.getContent(#if ADVENT 'holidayccg/' + #end 'assets/data/dialog.json'));

		for (l in 0...list.length)
		{
			name = list[l].who;
			dialogs = [];
			for (d in 0...list[l].dialogs.length)
			{
				//trace($v{list[l].dialogs[d]});
				e = macro new holidayccg.globals.DialogData($v{list[l].dialogs[d]});
				dialogs.push(e);
			}

			// trace(dialogs);

			map.push(macro $v{name} => $a{dialogs});
		}

		fields.push({
			pos: Context.currentPos(),
			name: 'DialogList',
			meta: null,
			kind: FieldType.FVar(macro:Map<String, Array<holidayccg.globals.DialogData>>, macro $a{map}),
			doc: null,
			access: [Access.APublic, Access.AStatic]
		});

		return fields;
	}
}
