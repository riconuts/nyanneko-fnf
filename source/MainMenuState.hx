package;

import options.GameplaySettingsSubState;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.input.FlxPointer;
import flixel.util.FlxTimer;
import flixel.addons.display.FlxBackdrop;
import flixel.ui.FlxButton.FlxTypedButton;
import openfl.events.MouseEvent;
import editors.MasterEditorMenu;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.effects.FlxFlicker;
import flixel.util.FlxSort;
import flixel.math.FlxMath;
import flixel.math.FlxAngle;
import flixel.group.FlxGroup.FlxTypedGroup;
import flash.ui.Mouse;
import flash.ui.MouseCursor;
using StringTools;

typedef MenuOptionData = {
	text:String,
	onSelect:Void->Void
}

class MainMenuState extends MusicBeatState
{
	//// Useless!!!
	public static var engineVersion:String = '0.2.0'; // Used for autoupdating n stuff
	public static var betaVersion(get, default):String = 'beta.6'; // beta version, make blank if not on a beta version, otherwise do it based on semantic versioning (alpha.1, beta.1, rc.1, etc)
	public static var beta:Bool = betaVersion.trim() != '';
	@:isVar
	public static var displayedVersion(get, null):String = '';
	static function get_displayedVersion()
		return 'v${engineVersion}${(beta?("-" + betaVersion):"")}';
	
	static function get_betaVersion()
		return beta ? betaVersion : "0";

	//// Real
	final optionNames = [
		"play",
		"donate",
		"credits",
		"options"
	];
	final optionData:Map<String, MenuOptionData>;

	var artMap = new Map<String, FlxSprite>();
	var textArray = new Array<FlxText>();

	var artGroup:FlxSpriteGroup;
	var textGroup:FlxSpriteGroup;

	var selectionArrow:FlxText;
	static var curSelected:Int = 0; 

	public function new(){
		super();
		optionData = [
			"play" => {
				text: "play ^o^", 
				onSelect: ()->{
					FlxTween.tween(titleGrp, {x: -760, alpha: 0}, 0.6, {ease: FlxEase.expoOut});
					fadeTexts(()->{
						LoadingState.loadAndSwitchState(new PlayState());
					});
				}
			},
			"donate" => {
				text: "watch seeries", 
				onSelect: ()->{
					var snd = FlxG.sound.play(Paths.sound('confirmMenu'));
					FlxFlicker.flicker(textArray[curSelected], snd.length / 1000, 0.06, true, true, (_)->{
						CoolUtil.browserLoad('https://youtube.com/playlist?list=PLEA4FA04230851E59');
					});
				}
			},
			"credits" => {
				text: "credit s", 
				onSelect: ()->{
					fadeTexts(()->{
						MusicBeatState.switchState(new CreditsState());
					});
				}
			},
			"options" => {
				text: "option", 
				onSelect: ()->{
					fadeTexts(()->{
						MusicBeatState.switchState(new newoptions.OptionsState());
					});
				}
			}
		];
	}

	var titleGrp:FlxSpriteGroup;
	var titleBg:FlxSprite;
	var titleTxt:FlxText;

	var artSpr:FlxSprite;

	var artWidth = 680;
	var textWidth = 600;

	override public function create()
	{
		#if desktop
		// Updating Discord Rich Presence
		Discord.DiscordClient.changePresence("In the Menus", null);
		#end

		////
		FlxG.camera.bgColor = 0xFFFFCC00;

		// dynamism haha i love that song
		artWidth = Math.ceil(FlxG.width * (680/1280));
		textWidth = Math.ceil(FlxG.width * (600/1280));
		
		var artGroup = new FlxSpriteGroup();
		add(artGroup);

		artSpr = new FlxSprite();
		artSpr.frames = Paths.getSparrowAtlas("menushit/art");
		artSpr.exists = false;
		artGroup.add(artSpr);

		var textGroup = new FlxSpriteGroup(artWidth);
		add(textGroup);

		var textBg = new FlxSprite().makeGraphic(textWidth, FlxG.height, 0xFF333333);
		textGroup.add(textBg);

		for (idx in 0...optionNames.length)
		{
			var name = optionNames[idx];
			var test = new FlxText(
				0, 
				128 + 140 * idx, 
				textBg.width, 
				optionData.get(name).text, 
				48
			);
			test.font = Paths.font("segoepr.ttf");
			test.alignment = CENTER;
			test.ID = idx;

			textArray.push(test);
			textGroup.add(test);

			artSpr.animation.addByPrefix(name, name, 24, true);

			/*
			var art = new FlxSprite();
			art.frames = Paths.getSparrowAtlas('menushit/ART_${name}');
			art.animation.addByPrefix("idle", "idle", 24, true);
			art.animation.play("idle", true);
			
			art.exists = false;
			art.alpha = 0;

			artMap.set(name, art);
			artGroup.add(art);
			*/
		}

		selectionArrow = new FlxText(380, 0, ">", 48);
		selectionArrow.font = Paths.font("segoepr.ttf");
		selectionArrow.color = 0xFFFF9900;
		add(selectionArrow);

		changeSelected(curSelected, true);

		////
		titleGrp = new FlxSpriteGroup();
		add(titleGrp);

		titleBg = new FlxSprite(0, 0).makeGraphic(760, 100, 0xFF666666);
		titleGrp.add(titleBg);

		titleTxt = new FlxText(60, 0, 0, "nyan neko sugar girls ^o^", 48);
		titleTxt.font = Paths.font("segoepr.ttf");
		titleTxt.color = 0xFFCCCCCC;
		titleTxt.y = Std.int(titleBg.y + (titleBg.height - titleTxt.height) / 2);
		titleGrp.add(titleTxt);

		//titleGrp.x = -760;
		titleGrp.y = 24;

		var scoreTxt = new FlxText(8, FlxG.height - 30, 0, '', 16);
		scoreTxt.setFormat(Paths.font("segoepr.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		add(scoreTxt);

		function updateScore(?state){
			var score = Highscore.getScore("Sugoi");
			scoreTxt.text = (score > 0) ? 'Hi-score: $score': "";
		}

		updateScore();
		subStateClosed.add(updateScore);


		if (FlxG.sound.music == null)
			MusicBeatState.playMenuMusic();

		super.create();
	}

	var scoreTxt:FlxText;

	function changeSelected(val:Int, ?isAbs:Bool) {
		var oldSelected = curSelected;

		if (isAbs)
			curSelected = FlxMath.wrap(val, 0, optionNames.length-1);
		else
			curSelected = FlxMath.wrap(curSelected + val, 0, optionNames.length-1);

		if (oldSelected != curSelected){
			FlxG.sound.play(Paths.sound("scrollMenu"));
		}
		
		var curTxt = textArray[curSelected];
		if (curTxt == null)
			selectionArrow.exists = false;
		else{
			selectionArrow.exists = true;
			selectionArrow.setPosition(
				curTxt.x + 10,
				curTxt.y
			);
		}

		var optionName = optionNames[curSelected];
		artSpr.animation.play(optionName);
		artSpr.updateHitbox();
		artSpr.screenCenter(Y);
		artSpr.x = switch(optionName){
			case "play" | "credits": artWidth - artSpr.width;
			case "donate": 0;
			default: (artWidth - artSpr.width) / 2;
		}
		artSpr.exists = true;
	}

	function onAccept() {
		var data = optionData.get(optionNames[curSelected]);
		data.onSelect();
	}

	function fadeTexts(?onComplete){
		FlxG.sound.play(Paths.sound("confirmMenu"));
		inputsEnabled = false;

		for (idx in 0...textArray.length){
			var text = textArray[idx];

			if (idx == curSelected)
				FlxFlicker.flicker(text, 1, 0.06, false, true, (_)->{onComplete();});				
			else
				FlxTween.tween(text, {alpha: 0}, 0.4, {ease: FlxEase.quadOut, onComplete: (_)->{text.exists = false;}});
		}

		if (optionNames[curSelected] != "options"){
			artSpr.updateHitbox();
			artSpr.origin.x = artWidth - artSpr.x;
			FlxTween.tween(artSpr, {alpha: 0}, 0.6, {ease: FlxEase.expoOut, onUpdate: (twn)->{
				artSpr.scale.x = 1-FlxEase.expoOut(twn.percent);
			}});
		}else{
			FlxTween.tween(artSpr, {alpha: 0}, 0.6, {ease: FlxEase.expoOut, onUpdate: (twn)->{
				artSpr.scale.y = 1-FlxEase.expoOut(twn.percent);
			}});
		}
	}


	var inputsEnabled = true;
	override function update(elapsed:Float) {
		if (inputsEnabled){
			if (controls.UI_UP_P)
				changeSelected(-1);
			if (controls.UI_DOWN_P)
				changeSelected(1);
			if (controls.ACCEPT)
				onAccept();
			else if (FlxG.keys.justPressed.CONTROL)
				openSubState(new GameplayChangersSubstate());
			else if (FlxG.keys.justPressed.R && Highscore.getScore("Sugoi") > 0)
				openSubState(new ResetScoreSubState("Sugoi"));
		}

		super.update(elapsed);
	}
}