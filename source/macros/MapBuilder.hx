package macros;

import haxe.Json;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.ExprTools;

using StringTools;

class MapBuilder
{
	@:access(flixel.system.macros.FlxAssetPaths.getFileReferences)
	public static macro function build():Array<Field>
	{
		var fields = Context.getBuildFields();
		var map:Array<Expr> = [];

		var e:Expr;
		var name:String;
		var json:haxe.DynamicAccess<Dynamic>;

		for (file in flixel.system.macros.FlxAssetPaths.getFileReferences("assets/data/maps/", false, ["tmj"]))
		{
			if (!file.name.startsWith("_"))
			{
				json = tjson.TJSON.parse(sys.io.File.getContent(file.value));

				e = macro new game.GameMap($v
					{
						{
							height: Std.parseInt(json.get("height")),
							width: Std.parseInt(json.get("width")),
							layers: cast(json.get("layers"), Array<Dynamic>),
							properties: cast(json.get("properties"), Array<Dynamic>),
						}
					});
				map.push(macro $e{e}.name => $e{e});
			}
		}

		fields.push({
			pos: Context.currentPos(),
			name: "MapList",
			meta: null,
			kind: FieldType.FVar(macro:Map<String, game.GameMap>, macro $a{map}),
			doc: null,
			access: [Access.APublic, Access.AStatic]
		});

		return fields;
	}
}

typedef MapStructure =
{
	var height:Int;
	var layers:Array<Dynamic>;
	var properties:Array<Dynamic>;
	var width:Int;
}
