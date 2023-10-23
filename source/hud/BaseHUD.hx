package hud;

import flixel.graphics.FlxGraphic;
import flixel.tweens.*;
import flixel.util.FlxStringUtil;
import flixel.ui.FlxBar;
import flixel.text.FlxText;
import JudgmentManager.JudgmentData;
import flixel.util.FlxColor;
import PlayState.FNFHealthBar;
import haxe.exceptions.NotImplementedException;
import playfields.*;

import flixel.group.FlxSpriteGroup;

// bunch of basic stuff to be extended by other HUDs

class BaseHUD extends FlxSpriteGroup {
	var stats:Stats;
	// just some ref vars
	static var fullDisplays:Map<String, String> = [
		//"epic" => "Epics", // NO EPICS
		"sick" => "Sicks",
		"good" => "Goods",
		"bad" => "Bads",
		"shit" => "Shits",
		"miss" => "Misses",
		"cb" => "Combo Breaks"
	];

	static var shortenedDisplays:Map<String, String> = [
		//"epic" => "EP", // NO EPICS
		"sick" => "SK",
		"good" => "GD",
		"bad" => "BD",
		"shit" => "ST",
		"miss" => "MS",
		"cb" => "CB"
	];
	
	public var displayNames:Map<String, String> = ClientPrefs.judgeCounter == 'Shortened' ? shortenedDisplays : fullDisplays;

	public var judgeColours:Map<String, FlxColor> = [
		"epic" => 0xFFE367E5,
		"sick" => 0xFF00A2E8,
		"good" => 0xFFB5E61D,
		"bad" => 0xFFC3C3C3,
		"shit" => 0xFF7F7F7F,
		"miss" => 0xFF7F2626,
		"cb" => 0xFF7F265A
	];

	public var displayedJudges:Array<String> = ["sick", "good", "bad", "shit", "miss"]; 

	// set by PlayState
	public var time(default, set):Float = 0;
	public var songLength(default, set):Float = 0;
	public var songName(default, set):String = '';
	public var score(get, null):Float = 0;
	function get_score()return stats.score;
	public var comboBreaks(get, null):Float = 0;
	function get_comboBreaks()return stats.comboBreaks;
	public var misses(get, null):Int = 0;
	function get_misses()return stats.misses;
	public var combo(get, null):Int = 0;
	function get_combo()return stats.combo;
	public var grade(get, null):String = '';
	function get_grade()return stats.grade;
	public var ratingFC(get, null):String = 'Clear';
	function get_ratingFC()return stats.clearType;
	public var totalNotesHit(get, null):Float = 0;
	function get_totalNotesHit()return stats.totalNotesHit;
	public var totalPlayed(get, null):Float = 0;
	function get_totalPlayed()return stats.totalPlayed;
	public var ratingPercent(get, null):Float = 0;
	function get_ratingPercent()return stats.ratingPercent;
	public var nps(get, null):Int = 0;
	function get_nps()return stats.nps;
	public var npsPeak(get, null):Int = 0;
	function get_npsPeak()return stats.npsPeak;
	public var songPercent(default, set):Float = 0;
	public var updateTime:Bool = false;
	@:isVar
	public var judgements(get, null):Map<String, Int>;
	function get_judgements()return stats.judgements;

	// just some extra variables lol
	public var healthBar:FNFHealthBar;
	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;

	public var timeBar:SowyBar;
	public var timeTxt:FlxText;

	public function new(iP1:String, iP2:String, songName:String, stats:Stats)
	{
		super();

		this.stats = stats;
		this.songName = songName;
		// if (!ClientPrefs.useEpics) // NO EPICSSS
			displayedJudges.remove("epic");

		healthBar = new FNFHealthBar(iP1, iP2);
		iconP1 = healthBar.leftIcon;
		iconP2 = healthBar.rightIcon;

		timeBar = new SowyBar(FlxG.width * 0.5 - 200, 0, "timeBar");
		timeBar.max = 1;
		timeBar.scrollFactor.set();

		timeTxt = new FlxText(0, 0, 400, "", 32);
		timeTxt.setFormat(Paths.font("vcr.ttf"), 32, 0xFFFFFFFF, CENTER, FlxTextBorderStyle.OUTLINE, 0xFF000000);
		timeTxt.borderSize = 2;
		
		add(timeBar);
		timeBar.add(timeTxt);

		updateTimeBarType();
	}

	function updateTimeBarType()
	{
		// trace("time bar update", ClientPrefs.timeBarType); // the text size doesn't get updated sometimes idk why

		updateTime = (ClientPrefs.timeBarType != 'Disabled' && ClientPrefs.timeOpacity > 0);

		timeBar.exists = updateTime;

		if (ClientPrefs.timeBarType == 'Song Name'){
			timeTxt.text = songName;
			timeTxt.size = 24;
			timeTxt.offset.y = -3;
		}else{
			timeTxt.text = "";
			timeTxt.size = 32;
			timeTxt.offset.y = 0;
		}
		
		var y = ClientPrefs.downScroll ? (FlxG.height - 44) : 19;
		timeBar.y = y + (timeTxt.height * 0.25);
		timeTxt.y = y;

		updateTimeBarAlpha();
	}

	function updateTimeBarAlpha(){
		var timeBarAlpha = ClientPrefs.timeOpacity * alpha * tweenProg;
		
		timeBar.alpha = timeBarAlpha;
	}

	override public function update(elapsed:Float){
		if (FlxG.keys.justPressed.NINE)
			iconP1.swapOldIcon();

		if (updateTime)
		{
			var curTime:Float = Conductor.songPosition - ClientPrefs.noteOffset;
			if (curTime < 0)
				curTime = 0;
			
			songPercent = (curTime / songLength);
			time = curTime;

			timeBar.value = songPercent;

			var timeCalc:Null<Float> = null;

			switch (ClientPrefs.timeBarType){
				case "Percentage":
					timeTxt.text = Math.floor(songPercent * 100) + "%";
				case "Time Left":
					timeCalc = (songLength - time);
				case "Time Elapsed":
					timeCalc = time;
			}

			if (timeCalc != null){
				timeTxt.text = (timeCalc <= 0) ? "0:00" : FlxStringUtil.formatTime(timeCalc / FlxG.timeScale / 1000, false);
			}
		}

		super.update(elapsed);
	}

	public var iconBeat = true;
	public function beatHit(beat:Int){
		if (iconBeat)
			healthBar.iconScale = 1.2;
	}

	public function changedOptions(changed:Array<String>){
		healthBar.alpha = ClientPrefs.hpOpacity;
		healthBar.y = FlxG.height * (ClientPrefs.downScroll ? 0.11 : 0.89);
		healthBar.iconScale = 1;
		healthBar.update(0);

		updateTimeBarType();
	}

	var tweenProg:Float = 0;
	public function songStarted(){
		FlxTween.num(0, 1, 0.5, 
			{
				ease: FlxEase.circOut,
				onComplete: function(tw:FlxTween){
					tweenProg = 1;
					updateTimeBarAlpha();
				}
			}, 
			function(prog:Float){
				tweenProg = prog;
				updateTimeBarAlpha();
			}
		);	
	}

	public function songEnding()
	{
		timeBar.exists = false;
	}

	public function stepHit(step:Int){}
	public function noteJudged(judge:JudgmentData, ?note:Note, ?field:PlayField){}
	public function recalculateRating(){}

	function set_songLength(value:Float)return songLength = value;
	function set_time(value:Float)return time = value;
	function set_songName(value:String)return songName = value;
	function set_songPercent(value:Float)return songPercent = value;
	function set_combo(value:Int)return combo = value;
}

class SowyBar extends flixel.group.FlxSpriteGroup{
	public var bg:FlxSprite;

	override function set_flipX(value:Bool){
		super.set_flipX(value);

		updateBar();

		return flipX; 
	}

	public var value(default, set):Float = 0;
	public var max(default, set):Float = 1;
	function set_value(val:Float){
		value = val;

		updateBar();

		return value;
	}
	function set_max(val:Float){
		value = Math.min(value, max);

		updateBar();

		return max;
	}

	public var direction:FlxBarFillDirection = RIGHT_TO_LEFT;
	public var emptyColor:FlxColor = 0xFF000000;
	public var fillColor:FlxColor = 0xFFFFFFFF;

	public var fillX:Int = 3;
	public var fillY:Int = 3;
	public var fillW:Int = 394;
	public var fillH:Int = 15;
	public var leftSide:FlxSprite;
	public var rightSide:FlxSprite;

	public var defaultWidth = 400;
	public var defaultHeight = 20;

	public function new(x:Float = 0, y:Float = 0, ?texture:String)
	{
		super(x, y);
		antialiasing = false;
		scrollFactor.set();

		//
		var graphic = texture == null ? null : Paths.image(texture);
		if (graphic == null)
			graphic = CoolUtil.makeOutlinedGraphic(defaultWidth, defaultHeight, 0xFFFFFFFF, 5, 0xFF000000);

		bg = new FlxSprite(0, 0, graphic);
		add(bg);

		var whitePixelGraphic = FlxGraphic.fromRectangle(1, 1, 0xFFFFFFFF, false, "whitePixel");
		
		leftSide = new FlxSprite(0, 0, whitePixelGraphic);
		leftSide.blend = MULTIPLY;
		add(leftSide);

		rightSide = new FlxSprite(0, 0, whitePixelGraphic);
		rightSide.blend = MULTIPLY;
		add(rightSide);

		value = 1;
	}

	public var flipDirection:Bool = false;
	
	private var limit_pos_x:Float;
	private function updateBar()
	{
		var relValue = value/max;
		if (flipDirection) relValue = 1-relValue;

		var leftColor = fillColor;
		var	rightColor = emptyColor;	

		limit_pos_x = x + fillW * relValue;
		
		var leftW:Int = Math.floor(fillW * relValue);
		var rightW:Int = fillW - leftW;

		leftSide.alpha = leftColor.alphaFloat * alpha;
		leftSide.color = leftColor.to24Bit();

		leftSide.setPosition(bg.x + fillX, bg.y + fillY);
		if (leftW > 0){
			leftSide.setGraphicSize(leftW, fillH);
			leftSide.updateHitbox();
			leftSide.visible = true;
		}else{
			leftSide.visible = false;
		}
		
		rightSide.alpha = rightColor.alphaFloat * alpha;
		rightSide.color = rightColor.to24Bit();

		rightSide.setPosition(leftSide.x + leftW, leftSide.y);
		if (rightW > 0){
			rightSide.setGraphicSize(rightW, fillH);
			rightSide.updateHitbox();
			rightSide.visible = true;
		}else{
			rightSide.visible = false;
		}
	}
}