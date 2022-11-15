package holidayccg.states;

import holidayccg.game.Player;
import holidayccg.globals.Cards.Deck;
import holidayccg.ui.DialogFrame;
import holidayccg.globals.Dialog;
import holidayccg.game.GameObject;
import holidayccg.game.GameMap;
import holidayccg.globals.GameGlobals;
import flixel.FlxCamera.FlxCameraFollowStyle;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tile.FlxBaseTilemap.FlxTilemapAutoTiling;
import flixel.tile.FlxTilemap;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.util.FlxDirectionFlags;

class PlayState extends FlxState
{
	public var mapLayer:FlxTypedGroup<FlxTilemap>;
	public var objectLayer:FlxTypedGroup<GameObject>;
	public var playerLayer:FlxTypedGroup<GameObject>;

	public var map:FlxTilemap = null;

	public var player:GameObject;

	public var blackOut:FlxSprite;

	public var ready:Bool = false;

	public var talking:Bool = false;

	public var dialog:DialogFrame;

	public var battleState:BattleState;

	override public function create()
	{
		GameGlobals.PlayState = this;
		GameGlobals.init();

		destroySubStates = false;

		add(mapLayer = new FlxTypedGroup<FlxTilemap>());
		add(objectLayer = new FlxTypedGroup<GameObject>());
		add(playerLayer = new FlxTypedGroup<GameObject>());
		add(dialog = new DialogFrame());

		playerLayer.add(player = new GameObject());

		FlxG.camera.follow(player, FlxCameraFollowStyle.TOPDOWN);

		add(blackOut = new FlxSprite(0, 0));
		blackOut.makeGraphic(Global.width, Global.height, GameGlobals.ColorPalette[1]);
		blackOut.scrollFactor.set();

		super.create();

		setMap("test room");

		battleState = new BattleState(returnFromBattle);

		fadeIn();
	}

	public function fadeIn():Void
	{
		blackOut.alpha = 1;
		FlxTween.tween(blackOut, {alpha: 0}, 1, {
			ease: FlxEase.quadOut,
			onComplete: (_) ->
			{
				ready = true;
			}
		});
	}

	public function setMap(RoomName:String):Void
	{
		var mapData:GameMap = GameGlobals.MapList.get(RoomName);

		if (map != null)
		{
			map.kill();
			map = new FlxTilemap();
		}
		else
			map = new FlxTilemap();

		map.loadMapFromArray(mapData.backgroundData, mapData.widthInTiles, mapData.heightInTiles, Global.asset("assets/images/temp_tiles.png"),
			GameGlobals.TILE_SIZE, GameGlobals.TILE_SIZE, FlxTilemapAutoTiling.OFF, 0, 0, 40);
		map.x = 0;
		map.y = 0;
		mapLayer.add(map);

		FlxG.worldBounds.set(0, 2, map.width, map.height - 2);

		FlxG.camera.setScrollBounds(0, map.width, 2, map.height - 2);

		// add objects
		var o:GameObject = null;
		for (obj in mapData.objects)
		{
			switch (obj.objectType)
			{
				case PLAYER:
					player.spawn("player", "player", obj.x, obj.y, GameObject.facingFromString(obj.facing));

				case NPC:
					o = objectLayer.getFirstAvailable();
					if (o == null)
						objectLayer.add(o = new GameObject());
					o.spawn(obj.name, obj.sprite, obj.x, obj.y, GameObject.facingFromString(obj.facing));

				default:
			}
		}
		FlxG.camera.snapToTarget();
	}

	public function showDialog(Dialog:DialogData):Void
	{
		talking = true;
		dialog.display(Dialog);
		ready = true;
	}

	public function checkForObjects(X:Float, Y:Float):GameObject
	{
		for (o in objectLayer.members)
		{
			if (Std.int(o.x / GameGlobals.TILE_SIZE) == X && Std.int(o.y / GameGlobals.TILE_SIZE) == Y)
				return o;
		}
		return null;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		if (!ready || player.moving)
			return;

		var a:Bool = Controls.justPressed.A;

		if (a)
		{
			// if talking, advance/close text
			if (talking)
			{
				talking = false;
				dialog.hide();
				return;
			}
			else
			{
				var dX:Int = player.facing == FlxDirectionFlags.LEFT ? -1 : player.facing == FlxDirectionFlags.RIGHT ? 1 : 0;
				var dY:Int = player.facing == FlxDirectionFlags.UP ? -1 : player.facing == FlxDirectionFlags.DOWN ? 1 : 0;

				var talkTo:GameObject = checkForObjects(Std.int(player.x / GameGlobals.TILE_SIZE) + dX, Std.int(player.y / GameGlobals.TILE_SIZE) + dY);
				if (talkTo != null)
				{
					if (Dialog.talk(talkTo.name))
					{
						return;
					}
				}
			}
			return;
		}

		if (talking && (Controls.justPressed.LEFT || Controls.justPressed.RIGHT))
		{
			if (dialog.isQuestion)
				dialog.changeSelection();
			return;
		}

		if (talking)
			return;

		var left:Bool = Controls.pressed.LEFT;
		var right:Bool = Controls.pressed.RIGHT;
		var up:Bool = Controls.pressed.UP;
		var down:Bool = Controls.pressed.DOWN;
		if (left && right)
			left = right = false;
		if (up && down)
			up = down = false;

		if (up)
			player.move(0, -1);
		else if (down)
			player.move(0, 1);
		else if (left)
			player.move(-1, 0);
		else if (right)
			player.move(1, 0);
	}

	public function returnFromBattle(Actions:String):Void
	{
		Dialog.parseScripts([Actions]);
	}

	public function startBattle(Vs:String):Void
	{
		ready = false;
		battleState.init(GameGlobals.Player.deck, Vs);
		openSubState(battleState);
	}
}
