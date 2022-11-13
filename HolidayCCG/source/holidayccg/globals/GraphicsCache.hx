package holidayccg.globals;

import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.FlxSprite;

class GraphicsCache
{
	public static function loadGraphicFromAtlas(AtlasImage:flixel.system.FlxAssets.FlxGraphicAsset, AtlasXML:String, ?Name:String):FlxGraphic
	{
		var t:FlxAtlasFrames = getAtlasFrames(AtlasImage, AtlasXML, Name);
		var g:FlxGraphic = FlxGraphic.fromFrames(t);

		return g;
	}

	public static function addGraphic(Graphic:flixel.system.FlxAssets.FlxGraphicAsset, Unique:Bool = false, ?Name:String):FlxGraphic
	{
		var g:FlxGraphic = FlxG.bitmap.add(Graphic, Unique, Name);
		if (!Unique)
		{
			g.destroyOnNoUse = false;
			g.persist = true;
		}
		return g;
	}

	public static function loadGraphic(Image:String, Unique:Bool = false, ?Name:String):FlxGraphic
	{
		var g:FlxGraphic = FlxG.bitmap.add(Image, Unique, Name == null ? Image : Name);
		if (!Unique)
		{
			g.destroyOnNoUse = false;
			g.persist = true;
		}
		return g;
	}

	public static function getAtlasFrames(AtlasImage:flixel.system.FlxAssets.FlxGraphicAsset, AtlasXML:String, ?Name:String):FlxAtlasFrames
	{
		var f:FlxAtlasFrames = FlxAtlasFrames.fromSparrow(AtlasImage, AtlasXML);
		return f;
	}

	public static function loadFlxSpriteFromAtlas(FilePrefix:String):FlxSprite
	{
		var tmp:FlxSprite = new FlxSprite();
		tmp.frames = getAtlasFrames(Global.asset("assets/images/" + FilePrefix + ".png"), Global.asset("assets/images/" + FilePrefix + ".xml"), FilePrefix);
		return tmp;
	}

	public static function loadAtlasGraphic(sprite:FlxSprite, FilePrefix:String):FlxSprite
	{
		sprite.frames = getAtlasFrames(Global.asset("assets/images/" + FilePrefix + ".png"), Global.asset("assets/images/" + FilePrefix + ".xml"), FilePrefix);
		return sprite;
	}
}
