package;

import flixel.group.FlxSpriteGroup;
import flixel.graphics.FlxGraphic;
import flixel.*;
import flixel.math.*;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.*;
import flixel.util.FlxColor;

#if discord_rpc
import Discord.DiscordClient;
#end
#if sys
import sys.io.File;
import sys.FileSystem;
#end

using StringTools;

class CreditsState extends MusicBeatState
{	
	var bg:FlxSprite;

	var hintText:FlxText;

	var camFollow = new FlxPoint(FlxG.width * 0.5, FlxG.height * 0.5);
	var camFollowPos = new FlxObject();

    var dataArray:Array<Array<String>> = [];
	var titleArray:Array<Alphabet> = [];
	var iconArray:Array<AttachedSprite> = [];

    var curSelected(default, set):Int = 0;
	
	function set_curSelected(sowy:Int)
    {
        if (dataArray[sowy] == null){ // skip empty spaces and titles
            sowy += (sowy < curSelected) ? -1 : 1;

            // also skip any following spaces
            if (sowy >= titleArray.length)
                sowy = sowy - titleArray.length;
            else if (sowy < 0)
                sowy = titleArray.length + sowy;

            return set_curSelected(sowy); 
        }

		if (sowy >= titleArray.length)
			curSelected = sowy - titleArray.length;
		else if (sowy < 0)
			curSelected = titleArray.length + sowy;
		
		curSelected = sowy;
		updateSelection();

		return curSelected;
	}

	override function switchTo(nextState){
		persistentUpdate = false;
		return super.switchTo(nextState);
	}

	override function create()
	{
		#if discord_rpc
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		persistentUpdate = true;
		
		Paths.clearStoredMemory();
		
		PlayState.isStoryMode = false;

		FlxG.camera.follow(camFollowPos);
		FlxG.camera.bgColor = FlxColor.BLACK;

		////
		camFollowPos.setPosition(camFollow.x, camFollow.y);

		////
		bg = new FlxSprite().loadGraphic(Paths.image("newmenuu/creditsbg"));
		
		if (FlxG.height < FlxG.width)
			bg.setGraphicSize(0, FlxG.height);
		else
			bg.setGraphicSize(FlxG.width, 0);

		bg.screenCenter().scrollFactor.set();
		add(bg);


		var gridGraphic = FlxGraphic.fromRectangle(2, 2, 0xFFE1D4B9, false, "creditsGrid");
		gridGraphic.bitmap.setPixel32(0,0,0xFFB583FA);
		gridGraphic.bitmap.setPixel32(1,1,0xFFB583FA);
		gridGraphic.persist = false;

		var backdrops = new flixel.addons.display.FlxBackdrop(gridGraphic);
		backdrops.antialiasing = false;
		backdrops.scale.set(32, 32);
		backdrops.updateHitbox();
		backdrops.velocity.set(32, -32);
		backdrops.scrollFactor.set();
		backdrops.x -= 10;
		add(backdrops);

		var textWidth = Math.ceil(FlxG.width * (720/1280));
		var artWidth = Math.ceil(FlxG.width * (560/1280));

		var textBg = new FlxSprite().makeGraphic(textWidth, FlxG.height, 0xFF333333);
		textBg.scrollFactor.set();
		add(textBg);

		var titleGrp = new FlxSpriteGroup();
		titleGrp.scrollFactor.set();
		add(titleGrp);

		var titleBg = new FlxSprite().makeGraphic(textWidth, 100, 0xFF666666);
		titleGrp.add(titleBg);

		var titleTxt = new FlxText(60, 0, 0, "Mod credits! ^_^", 36);
		titleTxt.font = Paths.font("segoepr.ttf");
		titleTxt.color = 0xFFDFDFDF;
		titleTxt.y = Std.int(titleBg.y + (titleBg.height - titleTxt.height) / 2);
		titleGrp.add(titleTxt);

		titleGrp.x = FlxG.width - titleGrp.width;
		titleGrp.y = 80;

        ////
        function loadLine(line:String, ?folder:String)
			addSong(line.split("::"), folder);

		//// Get credits list
		var rawCredits:String;
		var creditsPath:String;

		function getLocalCredits(){
			#if MODS_ALLOWED
			Paths.currentModDirectory = '';
	
			var modCredits = Paths.modsTxt('credits');
			if (Paths.exists(modCredits)){
				trace('using credits from mod folder');
				creditsPath = modCredits;
			}else
			#end{
				trace('using credits from assets folder');
				creditsPath = Paths.txt('credits');
			}

			rawCredits = Paths.getContent(creditsPath);
		}

		// Just in case we forget someone!!!
		#if (final && false)
		trace('checking for updated credits');
		var http = new haxe.Http("https://raw.githubusercontent.com/riconuts/troll-engine/main/assets/data/credits.txt");
		http.onData = function(data:String){
			rawCredits = data;

			#if sys
			try{
				trace('updating credits...');
				if (FileSystem.exists("assets/data/credits.txt")){
					trace("updated credits!!!");
					File.saveContent("assets/data/credits.txt", data);
				}else
					trace("no credits file to write to!");
			}catch(e){
				trace("couldn't update credits: " + e);
			}
			#end

			trace('using credits from github');
		}
		http.onError = function(error){
			trace('error: $error');
			getLocalCredits();
		}

		http.request();
		#else
		getLocalCredits();
		#end

		for (i in CoolUtil.listFromString(rawCredits))
			loadLine(i);

		///
		hintText = new FlxText(0, 0, 0, "asfgh", 32);
		hintText.setFormat(Paths.font("segoepr.ttf"), 32, 0xFFFFFFFF, CENTER);
		//hintText.scrollFactor.set();
        add(hintText);
		
		super.create();

        updateSelection();
        curSelected = 0;

		#if !FLX_NO_MOUSE
		FlxG.mouse.visible = true;
		#end
	}

    var realIndex:Int = 0;
	public function addSong(data:Array<String>, ?folder:String)
	{
		Paths.currentModDirectory = folder == null ? "" : folder;

        var songTitle:Alphabet; 
		var id = realIndex++;

        if (data.length > 1)
        {
            songTitle = new Alphabet(0, 240 * id, data[0], false);
            songTitle.x = 120;
            songTitle.targetX = 90;

            dataArray[id] = data; 

            var songIcon = new AttachedSprite("credits/" + data[1]);

            songIcon.xAdd = songTitle.width + 15; 
            //songIcon.yAdd = 15;
            songIcon.sprTracker = songTitle;

            iconArray[id] = songIcon;
            add(songIcon);
        }else if (data[0].trim().length == 0){
            return;
        }else{
			return;
			/*
            songTitle = new Alphabet(0, 240 * id, data[0], true);
			songTitle.forceX = 10;
            //songTitle.screenCenter(X);
            songTitle.targetX = songTitle.x;
			*/
			
        }

        songTitle.sowyFreeplay = true;
        songTitle.ID = id;
        titleArray[id] = songTitle;
        add(songTitle);
	}

	var moveTween:FlxTween;
	var curTitle:Alphabet;
	
	function updateSelection(playSound:Bool = true)
	{
		if (playSound)
			FlxG.sound.play(Paths.sound("scrollMenu"), 0.4);

		// selectedSong = titleArray[curSelected];
		curTitle = null;

		for (id in 0...titleArray.length)
		{
			var title:Alphabet = titleArray[id];
            var data = dataArray[id];
			var icon = iconArray[id];

            if (data == null){ // for the category titles, whatevrr !!!
                
            }else if (id == curSelected){
				title.alpha = 1;
                title.targetX = 90;
                title.color = 0xFFFFFFFF;

				icon.color = 0xFFFFFFFF;

                var descText = data[2];
                if (descText == null || descText.rtrim().length < 1){
                    hintText.alpha = 0;
                    hintText.text = "";
                }else{
                    hintText.text = descText;
					hintText.y = title.y + 100;

					curTitle = title;

					if (moveTween != null)
						moveTween.cancel();
                    moveTween = FlxTween.num(0, 1, 0.25, {ease: FlxEase.sineOut}, function(v){
                        hintText.alpha = v;
                    });
                }

				camFollow.y = title.y + title.height * 0.5 + 20;
			}else{
				var difference = Math.abs(curSelected - id);
				
				title.targetX = 90 + difference * -20;
				title.alpha = (1 - difference * 0.15);
				title.color = 0xFF000000;
				
				var br = 1-(difference * 0.15 + 0.05);
				icon.color = FlxColor.fromRGBFloat(br,br,br);
			}

			if (icon != null)
				icon.alpha = title.alpha;
		}
	}
	
	var secsHolding:Float = 0;
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null && FlxG.sound.music.volume < 0.7)
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;

		if (curTitle != null)
			hintText.x = curTitle.x;

		////
		var speed = FlxG.keys.pressed.SHIFT ? 2 : 1;

		var mouseWheel = FlxG.mouse.wheel;
		if (mouseWheel != 0)
			curSelected -= mouseWheel * speed;

		if (controls.UI_DOWN_P){
			curSelected += speed;
			secsHolding = 0;
		}
		if (controls.UI_UP_P){
			curSelected -= speed;
			secsHolding = 0;
		}

		if (controls.UI_UP || controls.UI_DOWN){
			var checkLastHold:Int = Math.floor((secsHolding - 0.5) * 10);
			secsHolding += elapsed;
			var checkNewHold:Int = Math.floor((secsHolding - 0.5) * 10);

			if(secsHolding > 0.5 && checkNewHold - checkLastHold > 0)
				curSelected += (checkNewHold - checkLastHold) * (controls.UI_UP ? -speed : speed);
		}

		//// update camera
		var lerpVal = Math.min(
            1, 
            elapsed * (9.6 + Math.max(0, Math.abs(camFollowPos.y - camFollow.y) - 360) * 0.002)
        );
        
        camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

        if (FlxG.keys.justPressed.NINE){
            for (item in titleArray){
                if (item != null && !item.isBold)
                    item.x += 50;
            }

            for (icon in iconArray){
                if (icon != null)
                    icon.loadGraphic(Paths.image('credits/peak'));
            }
        }

		if (controls.BACK){
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}

		if (controls.ACCEPT){
            CoolUtil.browserLoad(dataArray[curSelected][3]);
		}
		
		super.update(elapsed);
	}
}