package yuleduel.globals;

#if (html5)
import flixel.FlxG;
import flixel.util.FlxSignal;
import io.newgrounds.Call;
import io.newgrounds.NG;
import io.newgrounds.NGLite.LoginOutcome;
import io.newgrounds.objects.Score;
import io.newgrounds.objects.events.Outcome;

class NGAPI
{
	inline static var DEBUG_SESSION = #if debug true #else false #end;

	public static inline var APPID:String = "57351:TNElixxi";
	public static inline var ENCKEY:String = "r6RDqSDmAX4ur6fVbtAsAA==";

	public static var userName(default, null):String;

	public static var isLoggedIn(default, null):Bool = false;
	public static var scoreboardsLoaded(default, null):Bool = false;
	public static var medalsLoaded(default, null):Bool = false;

	public static var scoreboards:Array<Score> = [];
	private static var boardsByName(default, null) = new Map<String, Int>();

	public static var ngDataLoaded(default, null):FlxSignal = new FlxSignal();
	public static var ngScoresLoaded(default, null):FlxSignal = new FlxSignal();

	private static var medalsByName(default, null) = new Map<String, Int>();

	static var loggedEvents = new Array<NgEvent>();

	static public function init():Void
	{
		if (isLoggedIn)
			return;

		attemptAutoLogin(onAutoConnectResult);
	}

	static private function onAutoConnectResult():Void
	{
		if (isLoggedIn)
			return;

		NG.core.requestLogin();
	}

	static public function attemptAutoLogin(Callback:Void->Void):Void
	{
		if (isLoggedIn)
		{
			return;
		}

		ngDataLoaded.addOnce(Callback);

		function checkSessionCallback(Outcome:LoginOutcome)
		{
			switch (Outcome)
			{
				case SUCCESS: // nothing
				case FAIL(error):
					trace("session failed:" + error);
					ngDataLoaded.remove(Callback);
					Callback();
			}
		}

		var lastSessionId:String = null;
		if (FlxG.save.data.ngioSessionId != null)
		{
			lastSessionId = FlxG.save.data.ngioSessionId;
		}

		NG.createAndCheckSession(APPID, DEBUG_SESSION, lastSessionId, checkSessionCallback);
		NG.core.setupEncryption(ENCKEY);
		NG.core.onLogin.add(onNGLogin);

		NG.core.verbose = DEBUG_SESSION;
		logEventOnce(VIEW);

		NG.core.scoreBoards.loadList(onScoreboardsRequested);

		if (!NG.core.attemptingLogin)
		{
			trace("Auto login not attemped");
			ngDataLoaded.remove(Callback);
			Callback();
		}
	}

	private static function onNGLogin():Void
	{
		isLoggedIn = true;
		userName = NG.core.user.name;
		FlxG.save.data.ngioSessionId = NG.core.sessionId;
		FlxG.save.flush();

		NG.core.medals.loadList(onMedalsRequested);

		#if debug
		giveAllMedals();
		#end

		ngDataLoaded.dispatch();
	}

	#if debug
	static function giveAllMedals():Void
	{
		for (medal in NG.core.medals)
		{
			unlockMedal(medal.id, true);
		}
	}
	#end

	private static function onScoreboardsRequested(Outcome:Outcome<CallError>):Void
	{
		switch (Outcome)
		{
			case SUCCESS: // nothing
			case FAIL(error):
				return;
		}

		for (board in NG.core.scoreBoards)
		{
			boardsByName[board.name] = board.id;
		}

		ngScoresLoaded.dispatch();
	}

	public static function getBoardById(id:String):Int
	{
		if (boardsByName.exists(id))
			return boardsByName[id];

		return -1;
	}

	static public function requestHiscores(Id:String, Limit = 10, Skip = 0, Social = false, ?Callback:(Array<Score>) -> Void):Void
	{
		if (!isLoggedIn)
			throw "Must log in to access player scores";

		if (NG.core.scoreBoards == null)
			throw "Cannot access scoreboards until ngScoresLoaded is dispatched";

		var boardId = getBoardById(Id);
		if (boardId < 0)
			throw "Invalid board id:" + Id;

		var board = NG.core.scoreBoards.get(boardId);
		if (Callback != null)
			board.onUpdate.addOnce(() -> Callback(board.scores));
		board.requestScores(Limit, Skip, ALL, Social);
	}

	static public function postPlayerHiscore(Id:String, Value:Int, ?Callback:Null<(Outcome<CallError>) -> Void>):Void
	{
		if (!isLoggedIn)
		{
			if (Callback != null)
				Callback(null);

			return;
		}

		if (NG.core.scoreBoards == null)
			throw "Cannot access scoreboards until ngScoresLoaded is dispatched";

		var boardId = getBoardById(Id);
		if (boardId < 0)
			throw "Invalid board id:" + Id;

		NG.core.scoreBoards.get(boardId).postScore(Value, null, Callback);
	}

	static function onMedalsRequested(outcome:Outcome<CallError>):Void
	{
		switch (outcome)
		{
			case SUCCESS: // nothing
			case FAIL(error):
				return;
		}

		var numMedals = 0;
		var numMedalsLocked = 0;
		for (medal in NG.core.medals)
		{
			medalsByName.set(medal.name, medal.id);
			if (!medal.unlocked)
				numMedalsLocked++;

			#if debug
			unlockMedalByName(medal.name);
			#end

			numMedals++;
		}
	}

	static public function unlockMedalByName(Name:String):Void
	{
		if (!medalsByName.exists(Name))
			throw 'invalid name: ${Name}';

		unlockMedal(medalsByName.get(Name));
	}

	static public function unlockMedal(Id:Int, showDebugUnlock = true):Void
	{
		if (isLoggedIn)
		{
			var medal = NG.core.medals.get(Id);
			if (!medal.unlocked)
				medal.sendUnlock();
			else if (showDebugUnlock)
			{
				#if debug
				medal.onUnlock.dispatch();
				#end
			}
		}
	}

	static public function hasMedal(Id:Int):Bool
	{
		return isLoggedIn && NG.core.medals.get(Id).unlocked;
	}

	static public function logEvent(Event:NgEvent, Once = false)
	{
		if (loggedEvents.contains(Event))
		{
			if (Once)
				return;
		}
		else
			loggedEvents.push(Event);

		trace("logging event: " + Event);
		if (Event == VIEW)
			NG.core.calls.app.logView();
		else
			NG.core.calls.event.logEvent(Event).send();
	}

	static public function logEventOnce(Event:NgEvent)
	{
		logEvent(Event, true);
	}
}

enum abstract NgEvent(String) from String to String
{
	var VIEW = "View";
}
#else
class NGAPI {}
#end