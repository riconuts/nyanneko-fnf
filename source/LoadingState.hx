package;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.util.FlxTimer;

class LoadingState extends MusicBeatState
{
	inline static var MIN_TIME = 1.0;
	
	var target:FlxState;
	var stopMusic = false;

	function new(target:FlxState, stopMusic:Bool)
	{
		super();
		this.target = target;
		this.stopMusic = stopMusic;
	}

	var funkay:FlxSprite;
	var loadBar:FlxSprite;

	override function create()
	{
		funkay = new FlxSprite();
		funkay.frames = Paths.getSparrowAtlas("funkay");
		funkay.animation.addByPrefix("idle", "raku", 24, true);
		funkay.animation.play("idle");
		funkay.alpha = 0;
		add(funkay);

		FlxTween.tween(funkay, {alpha: 1}, 0.6, {ease: FlxEase.circOut, onComplete: (_)->{onLoad();}});

		/* Doesn't actually load anything >< sorry
		loadBar = new FlxSprite(0, FlxG.height - 20).makeGraphic(FlxG.width, 10, 0xffff16d2);
		loadBar.antialiasing = ClientPrefs.globalAntialiasing;
		loadBar.screenCenter(X);
		add(loadBar);
		*/
	}

	/*
	override function update(elapsed:Float)
	{
		funkay.setGraphicSize(Std.int(0.88 * FlxG.width + 0.9 * (funkay.width - 0.88 * FlxG.width)));
		funkay.updateHitbox();

		if(controls.ACCEPT)
		{
			funkay.setGraphicSize(Std.int(funkay.width + 60));
			funkay.updateHitbox();
		}

		super.update(elapsed);
	}
	*/
	
	function onLoad()
	{
		FlxTween.tween(funkay, {alpha: 0}, 0.6, {ease: FlxEase.circOut});

		if (stopMusic)
			{
				if (FlxG.sound.music != null)
					FlxG.sound.music.stop();

				if (MusicBeatState.menuVox != null)
				{
					MusicBeatState.menuVox.stop();
					MusicBeatState.menuVox.destroy();
					MusicBeatState.menuVox = null;
				}
			}
			MusicBeatState.switchState(target);
	}

	override function destroy()
	{
		super.destroy();
	}

	////
	inline static public function loadAndSwitchState(target:FlxState, stopMusic = false)
	{
		MusicBeatState.switchState(getNextState(target, stopMusic));
	}
	
	static function getNextState(target:FlxState, stopMusic = false):FlxState
	{
		/*
		if (target is PlayState)
			return new LoadingState(target, stopMusic);
		*/

		if (stopMusic)
		{
			if (FlxG.sound.music != null)
				FlxG.sound.music.stop();

			if (MusicBeatState.menuVox != null)
			{
				MusicBeatState.menuVox.stop();
				MusicBeatState.menuVox.destroy();
				MusicBeatState.menuVox = null;
			}
		}
		
		return target;
	}
}