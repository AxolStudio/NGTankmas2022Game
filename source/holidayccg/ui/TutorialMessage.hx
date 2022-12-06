package holidayccg.ui;

import flixel.group.FlxGroup;

class TutorialMessage extends FlxGroup
{
	public var frame:GameFrame;
	public var message:GameText;

	public var x(default, set):Float;
	public var y(default, set):Float;

	public var width(get, never):Float;
	public var height(get, never):Float;

	public var lines:Array<GameText> = [];

	public static inline var lineSpacing:Float = 4;

	@:access(flixel.text.FlxBitmapText.updateText)
	@:access(flixel.text.FlxBitmapText._lines)
	public function new(Message:String = "", X:Float = 0, Y:Float = 0, MaxWidth:Float = -1):Void
	{
		super();

		message = new GameText();
		message.text = Message;
		message.wordWrap = true;
		message.multiLine = true;
		message.autoSize = true;
		message.updateText();
		if (MaxWidth > -1 && message.fieldWidth > MaxWidth)
		{
			message.autoSize = false;
			message.fieldWidth = Std.int(MaxWidth);
			message.updateText();
		}
		var line:GameText = null;
		var h:Float = 20;
		var w:Float = 0;
		for (l in message._lines)
		{
			line = new GameText();
			line.text = l;
			line.scrollFactor.set();
			h += line.height + lineSpacing;
			if (line.width > w)
				w = line.width;
			lines.push(line);
		}
		h -= lineSpacing;
		w += 20;

		message.scrollFactor.set();

		frame = new GameFrame(w, h);
		frame.scrollFactor.set();

		add(frame);
		for (l in lines)
			add(l);

		x = X;
		y = Y;
	}

	private function set_x(Value:Float):Float
	{
		x = Value;
		frame.x = Math.ceil(x);
		for (l in lines)
		{
			l.x = Math.ceil(x + (frame.width / 2) - (l.width / 2));
			// trace(l.x);
		}
		return x;
	}

	private function set_y(Value:Float):Float
	{
		y = Value;
		frame.y = Math.ceil(y);
		for (l in 0...lines.length)
		{
			lines[l].y = Math.ceil(y + 10 + (lines[l].height + lineSpacing) * l);
			// trace(lines[l].y);
		}

		return y;
	}

	private function get_width():Float
	{
		return frame.width;
	}

	private function get_height():Float
	{
		return frame.height;
	}
}
