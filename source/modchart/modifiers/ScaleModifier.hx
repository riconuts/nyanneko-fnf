package modchart.modifiers;

import modchart.Modifier.RenderInfo;
import flixel.math.FlxPoint;
import modchart.Modifier.ModifierOrder;
import math.Vector3;
import playfields.NoteField;

class ScaleModifier extends NoteModifier {
	override function getName()return 'tiny';
	override function getOrder()return PRE_REVERSE;
	inline function lerp(a:Float, b:Float, c:Float)
	{
		return a + (b - a) * c;
	}
	function daScale(sprite:Dynamic, scale:FlxPoint, data:Int, player:Int)
	{
		var y = scale.y;
		var tiny = getValue(player) + getSubmodValue('tiny${data}', player);
		var tinyX = (getSubmodValue("tinyX", player) + getSubmodValue('tiny${data}X', player));
		var tinyY = (getSubmodValue("tinyY", player) + getSubmodValue('tiny${data}Y', player));

		scale.x *= Math.pow(0.5, tinyX) * Math.pow(0.5, tiny);
		scale.y *= Math.pow(0.5, tinyY) * Math.pow(0.5, tiny);
		var angle = 0;

		var stretch = getSubmodValue("stretch", player) + getSubmodValue('stretch${data}', player);
		var squish = getSubmodValue("squish", player) + getSubmodValue('squish${data}', player);

		var stretchX = lerp(1, 0.5, stretch);
		var stretchY = lerp(1, 2, stretch);

		var squishX = lerp(1, 2, squish);
		var squishY = lerp(1, 0.5, squish);

		scale.x *= (Math.sin(angle * Math.PI / 180) * squishY) + (Math.cos(angle * Math.PI / 180) * squishX);
		scale.x *= (Math.sin(angle * Math.PI / 180) * stretchY) + (Math.cos(angle * Math.PI / 180) * stretchX);

		scale.y *= (Math.cos(angle * Math.PI / 180) * stretchY) + (Math.sin(angle * Math.PI / 180) * stretchX);
		scale.y *= (Math.cos(angle * Math.PI / 180) * squishY) + (Math.sin(angle * Math.PI / 180) * squishX);
		if ((sprite is Note) && sprite.isSustainNote)
			scale.y = y;

		return scale;
	}
	
	override function shouldExecute(player:Int, val:Float)
		return true;

	override function ignorePos()
		return false;

	override function getPos(visualDiff:Float, timeDiff:Float, beat:Float, pos:Vector3, data:Int, player:Int, obj:FlxSprite, field:NoteField)
	{
		var tiny = getValue(player) + getSubmodValue('tiny${data}', player);
		var tinyPerc = Math.min(Math.pow(0.5, tiny), 1);
		switch (player)
		{
			case 0:
				pos.x -= FlxG.width * 0.5 - Note.swagWidth * 2 - 100;
			case 1:
				pos.x += FlxG.width * 0.5 - Note.swagWidth * 2 - 100;
		}
		pos.x -= FlxG.width / 2;
		pos.x *= tinyPerc;
		pos.x += FlxG.width / 2;
		switch (player)
		{
			case 0:
				pos.x += FlxG.width * 0.5 - Note.swagWidth * 2 - 100;
			case 1:
				pos.x -= FlxG.width * 0.5 - Note.swagWidth * 2 - 100;
		} 

		return pos;
	}


	override function isRenderMod()
		return true;

	override function getExtraInfo(diff:Float, tDiff:Float, beat:Float, info:RenderInfo, sprite:FlxSprite, player:Int, data:Int):RenderInfo
	{
		if (!(sprite is NoteObject))
			return info;

		var obj:NoteObject = cast sprite;
		var scale = daScale(obj, info.scale, obj.noteData, player);
		if ((sprite is Note))
		{
			var note:Note = cast sprite;
			if (note.isSustainNote)
				scale.y = 1;
		}
		info.scale = scale;
		return info;
	}

	override function getSubmods()
	{
		var subMods:Array<String> = ["squish", "stretch", "tinyX", "tinyY"];

		for (i in 0...4)
		{
			subMods.push('tiny${i}');
			subMods.push('tiny${i}X');
			subMods.push('tiny${i}Y');
			subMods.push('squish${i}');
			subMods.push('stretch${i}');
		}
		return subMods;
	}

}