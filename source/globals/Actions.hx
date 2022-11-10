package globals;

import flixel.input.actions.FlxAction.FlxActionAnalog;
import flixel.input.actions.FlxAction.FlxActionDigital;
import flixel.input.actions.FlxActionInput.FlxInputDevice;
import flixel.input.actions.FlxActionInput.FlxInputDeviceID;
import flixel.input.actions.FlxActionManager;
import flixel.input.actions.FlxActionSet;

class Actions
{
	public static var actions:FlxActionManager;
	public static var setGameplay:FlxActionSet;
	public static var up:FlxActionDigital;
	public static var down:FlxActionDigital;
	public static var left:FlxActionDigital;
	public static var right:FlxActionDigital;
	public static var any:FlxActionDigital;
	public static var leftStick:FlxActionAnalog;
	public static var gameplayIndex:Int = -1;

	public static function init():Void
	{
		if (Actions.actions != null)
			return;
		Actions.actions = FlxG.inputs.add(new FlxActionManager());
		Actions.actions.resetOnStateSwitch = ResetPolicy.NONE;
		Actions.up = new FlxActionDigital();
		Actions.down = new FlxActionDigital();
		Actions.left = new FlxActionDigital();
		Actions.right = new FlxActionDigital();
		Actions.any = new FlxActionDigital();
		Actions.leftStick = new FlxActionAnalog();
		var gameplaySet:FlxActionSet = new FlxActionSet("GameplayControls", [Actions.up, Actions.down, Actions.left, Actions.right], [Actions.leftStick]);
		gameplayIndex = Actions.actions.addSet(gameplaySet);
		Actions.up.addKey(UP, PRESSED);
		Actions.up.addKey(W, PRESSED);
		Actions.down.addKey(DOWN, PRESSED);
		Actions.down.addKey(S, PRESSED);
		Actions.left.addKey(LEFT, PRESSED);
		Actions.left.addKey(A, PRESSED);
		Actions.right.addKey(RIGHT, PRESSED);
		Actions.right.addKey(D, PRESSED);
		Actions.up.addGamepad(DPAD_UP, PRESSED);
		Actions.down.addGamepad(DPAD_DOWN, PRESSED);
		Actions.left.addGamepad(DPAD_LEFT, PRESSED);
		Actions.right.addGamepad(DPAD_RIGHT, PRESSED);
		Actions.leftStick.addGamepad(LEFT_ANALOG_STICK, MOVED, EITHER);
		Actions.any.addGamepad(A, JUST_RELEASED);
		Actions.any.addGamepad(B, JUST_RELEASED);
		Actions.any.addGamepad(X, JUST_RELEASED);
		Actions.any.addGamepad(Y, JUST_RELEASED);
		Actions.any.addGamepad(START, JUST_RELEASED);
		Actions.any.addKey(ANY, JUST_RELEASED);
		Actions.actions.activateSet(Actions.gameplayIndex, FlxInputDevice.ALL, FlxInputDeviceID.ALL);
	}
}
