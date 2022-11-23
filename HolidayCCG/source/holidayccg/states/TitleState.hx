package holidayccg.states;

import flixel.FlxSubState;
import holidayccg.ui.GameFrame;
import holidayccg.ui.GameText;
import flixel.FlxG;
import flixel.util.FlxColor;
import holidayccg.globals.GameGlobals;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;
import flixel.FlxState;

using flixel.util.FlxSpriteUtil;

class TitleState extends FlxState
{
	public var background:FlxSprite;
	public var backSnow:FlxTypedGroup<Snow>;
	public var logo:FlxSprite;
	public var frontSnow:FlxTypedGroup<Snow>;
	public var blackout:FlxSprite;

	public var ready:Bool = false;
	public var menuShown:Bool = false;

	public var options:Array<GameText>;
	public var cursor:GameText;
	public var menuBack:GameFrame;

	public var selected:Int = -1;

	override public function create():Void
	{
		GameGlobals.init();

		add(background = new FlxSprite(Global.asset("assets/images/title-back.png")));
		add(backSnow = new FlxTypedGroup<Snow>());
		add(logo = new FlxSprite(Global.asset("assets/images/logo-game-version.png")));
		Global.screenCenter(logo);

		add(frontSnow = new FlxTypedGroup<Snow>());

		for (i in 0...10)
		{
			for (i in 0...12)
			{
				backSnow.add(new Snow(1));
			}
			for (i in 0...10)
			{
				backSnow.add(new Snow(2));
			}

			for (i in 0...8)
			{
				backSnow.add(new Snow(3));
			}

			for (i in 0...6)
			{
				backSnow.add(new Snow(4));
			}
		}

		for (i in 0...3)
		{
			for (i in 0...2)
			{
				frontSnow.add(new Snow(5));
			}

			frontSnow.add(new Snow(6));
		}
		buildMenu();

		super.create();

		FlxG.camera.fade(GameGlobals.ColorPalette[1], 1, true, () ->
		{
			ready = true;
		});
	}

	public function buildMenu():Void
	{
		var widest:Float = -1;
		var option:GameText = new GameText();
		options = [];
		option.text = "Continue";
		options.push(option);
		option.visible = false;
		widest = option.width;

		option = new GameText();
		option.text = "New Game";
		options.push(option);
		option.visible = false;
		if (option.width > widest)
		{
			widest = option.width;
		}

		option = new GameText();
		option.text = "Credits";
		options.push(option);
		option.visible = false;
		if (option.width > widest)
		{
			widest = option.width;
		}

		cursor = new GameText();
		cursor.text = "]";
		cursor.visible = false;

		menuBack = new GameFrame(widest + 24 + cursor.width + 10 + 24, options.length * cursor.height + 24 + 24 + 10 + 10);
		menuBack.visible = false;

		add(menuBack);
		menuBack.x = Global.width - menuBack.width;
		menuBack.y = Global.height - menuBack.height;

		add(cursor);
		for (o in options)
		{
			add(o);

			o.x = menuBack.x + 24 + cursor.width + 10;
		}
		options[0].y = menuBack.y + 24;
		options[1].y = options[0].y + options[0].height + 10;
		options[2].y = options[1].y + options[1].height + 10;
		cursor.x = menuBack.x + 24;

		if (GameGlobals.hasSave)
		{
			options[0].alpha = 1;
			selected = 0;
			cursor.y = options[0].y;
		}
		else
		{
			options[0].alpha = 0.33;
			selected = 1;
			cursor.y = options[1].y;
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (ready)
		{
			if (Controls.justPressed.A || Controls.justPressed.PAUSE)
			{
				if (!menuShown)
				{
					showMenu();
				}
				else
				{
					choose();
				}
			}
			else if (menuShown)
			{
				if (Controls.justPressed.DOWN)
				{
					if (selected < options.length - 1)
					{
						selected++;
					}
					else
					{
						if (GameGlobals.hasSave)
						{
							selected = 0;
						}
						else
						{
							selected = 1;
						}
					}
					cursor.y = options[selected].y;
				}
				else if (Controls.justPressed.UP)
				{
					if (selected > 0 && (selected != 1 || GameGlobals.hasSave))
					{
						selected--;
					}
					else
					{
						selected = options.length - 1;
					}
					cursor.y = options[selected].y;
				}
			}
		}
	}

	public function returnFromCredits():Void
	{
		GameGlobals.transIn(() ->
		{
			ready = true;
		});
	}

	public function returnFromConfirmState():Void
	{
		persistentDraw = false;
		persistentUpdate = false;
		ready = true;
	}

	public function choose():Void
	{
		ready = false;
		switch (selected)
		{
			case 0:
				// continue!
				GameGlobals.loadSave();
				GameGlobals.transOut(() ->
				{
					Global.switchState(GameGlobals.PlayState);
				});

			case 1:
				// new Game!
				// if they ahve a save, confirm!
				if (GameGlobals.hasSave)
				{
					persistentDraw = true;
					persistentUpdate = true;
					openSubState(new ConfirmState(returnFromConfirmState));
				}
				else
				{
					// no save, just start!

					GameGlobals.transOut(() ->
					{
						Global.switchState(GameGlobals.PlayState);
					});
				}
			case 2:
				// credits!
				GameGlobals.transOut(() ->
				{
					openSubState(new CreditState(returnFromCredits));
				});
		}
	}

	public function showMenu():Void
	{
		if (menuShown)
			return;
		menuShown = true;
		menuBack.visible = true;
		cursor.visible = true;
		for (o in options)
		{
			o.visible = true;
		}
		selected = 0;
	}
}

class Snow extends FlxSprite
{
	public var depth:Int = 0;
	public var speed:Float = 0;

	public function new(Depth:Int):Void
	{
		super();
		makeGraphic(Depth * Depth * 2, Depth * Depth * 2, FlxColor.TRANSPARENT);
		flixel.util.FlxSpriteUtil.drawCircle(this, -1, -1, Depth * Depth, FlxColor.WHITE);
		depth = Depth;
		alpha = .15 * (13 - (depth * 2));
		trace(depth, alpha);
		speed = FlxG.random.int(10, 20) * depth * depth;
		x = FlxG.random.int(Global.width + Global.height);
		y = FlxG.random.int(-10, Global.height + 10);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		var tmp:Float = (speed / 5000) * elapsed;
		var dX:Float = (-1 * elapsed * speed * Math.cos(tmp));
		var dY:Float = Math.sin(tmp) / 40 + (speed * elapsed * 50) / 30;
		x += dX;
		y += dY;
		// trace(dX, dY);

		if (y > Global.height)
		{
			y = -height;
			x = FlxG.random.int(0, Global.width + Global.height);
		}
	}

	override function draw()
	{
		super.draw();
		if (GameGlobals.transition.transitioning)
			GameGlobals.transition.draw();
	}
}

class ConfirmState extends FlxSubState
{
	public var back:GameFrame;
	public var text:GameText;
	public var lines:Array<GameText>;
	public var choiceYes:GameText;
	public var choiceNo:GameText;
	public var cursor:GameText;

	public var selected:Int = -1;

	public static inline var lineSpacing:Float = 4;

	public var ready:Bool = false;

	@:access(flixel.text.FlxBitmapText.updateText)
	@:access(flixel.text.FlxBitmapText._lines)
	public function new(Callback:Void->Void):Void
	{
		super();

		closeCallback = Callback;

		cursor = new GameText();
		cursor.text = "]";

		text = new GameText();
		text.text = "You have Saved Data from a previous game.\nAre you sure you want to start a new game?\nThis will ERASE your existing data!";
		text.wordWrap = true;
		text.multiLine = true;

		text.autoSize = false;
		text.fieldWidth = Std.int((Global.width * .8) - 20);
		text.updateText();

		lines = [];

		var line:GameText = null;
		var h:Float = 20;
		var w:Float = 0;
		for (l in text._lines)
		{
			line = new GameText();
			line.text = l;
			h += line.height + lineSpacing;
			lines.push(line);
			if (line.width > w)
				w = line.width;
		}

		back = new GameFrame(w + 20, h + lineSpacing + (line.height * 2));
		back.x = Global.width / 2 - back.width / 2;
		back.y = Global.height / 2 - back.height / 2;

		add(back);

		for (l in lines)
		{
			l.x = Global.width / 2 - l.width / 2;
			l.y = back.y + 10 + (lines.indexOf(l) * (l.height + lineSpacing));
			add(l);
		}

		choiceYes = new GameText();
		choiceYes.text = "Yes";
		choiceYes.x = Global.width / 2 - choiceYes.width - 10;
		choiceYes.y = back.y + back.height - choiceYes.height - 10;
		add(choiceYes);

		choiceNo = new GameText();
		choiceNo.text = "No";
		choiceNo.x = Global.width / 2 + 10 + cursor.width + 10;
		choiceNo.y = back.y + back.height - choiceNo.height - 10;
		add(choiceNo);

		cursor.x = choiceNo.x - 10 - cursor.width;
		cursor.y = choiceNo.y;
		add(cursor);
	}

	override function create()
	{
		super.create();

		// ready = true;
	}

	override function draw()
	{
		super.draw();
		if (GameGlobals.transition.transitioning)
			GameGlobals.transition.draw();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (!ready && selected == -1)
		{
			ready = true;
			selected = 1;
		}
		else if (ready)
		{
			if (Controls.justPressed.LEFT || Controls.justPressed.RIGHT)
			{
				if (selected == 1)
				{
					selected = 0;
					cursor.x = choiceYes.x - 10 - cursor.width;
				}
				else
				{
					selected = 1;
					cursor.x = choiceNo.x - 10 - cursor.width;
				}
			}
			else if (Controls.justPressed.A || Controls.justPressed.PAUSE)
			{
				ready = false;
				if (selected == 0)
				{
					GameGlobals.transOut(() ->
					{
						Global.switchState(GameGlobals.PlayState);
					});
				}
				else
				{
					close();
				}
			}
			else if (Controls.justPressed.B)
			{
				ready = false;
				close();
			}
		}
	}
}
