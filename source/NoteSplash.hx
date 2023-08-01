package;

import scripts.Globals;
import math.Vector3;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

class NoteSplash extends NoteObject
{
	public var colorSwap:ColorSwap = null;
	private var idleAnim:String;
	private var textureLoaded:String = null;
	public var vec3Cache:Vector3 = new Vector3();

	public function new(x:Float = 0, y:Float = 0, ?note:Int = 0) {
		super(x, y);

		var skin:String = 'noteSplashes';
		if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) skin = PlayState.SONG.splashSkin;

		loadAnims(skin);
		
		colorSwap = new ColorSwap();
		shader = colorSwap.shader;

		setupNoteSplash(x, y, note);
	}

	public function setupNoteSplash(x:Float, y:Float, note:Int = 0, texture:String = null, hueColor:Float = 0, satColor:Float = 0, brtColor:Float = 0) {
		if (FlxG.state == PlayState.instance){
			if (PlayState.instance.callOnHScripts("preSetupNoteSplash", [x, y, note, texture, hueColor, satColor, brtColor], ["this" => this, "noteData" => noteData]) == Globals.Function_Stop)
				return;
			
		}
		setPosition(x, y);
		alpha = 0.6;
		scale.set(0.8, 0.8);
		updateHitbox();

		noteData = note;
		if(texture == null) {
			texture = 'noteSplashes';
			if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) texture = PlayState.SONG.splashSkin;
		}

		if(textureLoaded != texture) {
			var ret = Globals.Function_Continue;

			if(FlxG.state == PlayState.instance)
				ret = PlayState.instance.callOnHScripts("loadSplashAnims", [texture], ["this" => this, "noteData" => noteData]);
			
			if (ret != Globals.Function_Stop)loadAnims(texture);
			
		}

		
		colorSwap.hue = hueColor;
		colorSwap.saturation = satColor;
		colorSwap.brightness = brtColor;

		PlayState.instance.callOnHScripts("postSetupNoteSplash", [x, y, note, texture, hueColor, satColor, brtColor], ["this" => this, "noteData" => noteData]);
		var animNum:Int = FlxG.random.int(1, 2);
		animation.play('note' + note + '-' + animNum, true);
		if(animation.curAnim != null)animation.curAnim.frameRate = 24 + FlxG.random.int(-2, 2);
	}

	function loadAnims(skin:String) {
		frames = Paths.getSparrowAtlas(skin);
		for (i in 1...3)
		{
			animation.addByPrefix("note1-" + i, "note splash blue " + i, 24, false);
			animation.addByPrefix("note2-" + i, "note splash green " + i, 24, false);
			animation.addByPrefix("note0-" + i, "note splash purple " + i, 24, false);
			animation.addByPrefix("note3-" + i, "note splash red " + i, 24, false);
		}
	}

	override function update(elapsed:Float) {
		if(animation.curAnim != null)if(animation.curAnim.finished) kill();

		super.update(elapsed);
	}
}