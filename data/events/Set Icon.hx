
import funkin.backend.system.Flags;

import funkin.game.HealthIcon;

final EVENT_NAME:String = "Set Icon";

function postCreate() {
    updateIconPositions = () -> {
        var iconOffset = Flags.ICON_OFFSET;
		var healthBarPercent = healthBar.percent;

		var center:Float = healthBar.x + healthBar.width * FlxMath.remapToRange(healthBarPercent, 0, 100, 1, 0);

        var xPos_math:Float = healthBarPercent * 0.01;

        var player_counter:Int = 0;
        var opponent_counter:Int = 0;
        for (idx=>icon in iconArray) {

            icon.x = (icon.isPlayer) ? (center - iconOffset) + (icon.width * player_counter) : center - (icon.width - iconOffset) - (icon.width * opponent_counter);
            icon.y = healthBar.y - (icon.height * 0.5);
            icon.health = (icon.isPlayer) ? xPos_math : 1 - xPos_math;
            
            if (icon.isPlayer) player_counter++;
            else opponent_counter++;

            if (!icon.extra.exists("offset")) continue;
            var offset:FlxPoint = icon.extra.get("offset");
            icon.x += (icon.isPlayer) ? offset.x : -offset.x;
            icon.y += offset.y;
        }
    }
}

function updateHealthbarColor() {
    healthBar.createFilledBar(
        getIconColor(iconP2, (PlayState.opponentMode ? 0xFF66FF33 : 0xFFFF0000)),
        getIconColor(iconP1, (PlayState.opponentMode ? 0xFFFF0000 : 0xFF66FF33))
    );
    healthBar.updateBar();
}

function getIconColor(icon:HealthIcon, defaultColor:FlxColor):FlxColor {
    var charName:String = icon.curCharacter;
    var path:String  = Paths.xml('characters/${icon.curCharacter}');
    if (!Assets.exists(path)) return defaultColor;
    var xml = null;
    try {
        var xml = Xml.parse(Assets.getText(path)).firstElement();
    } catch(e:Error) {
        return defaultColor;
    }
    if (xml == null) return defaultColor;
    
    return ( FlxColor.fromString(xml.get("color")) ?? defaultColor );
}

function onEvent(e) {
    var event = e.event;
    if (event.name != EVENT_NAME) return;

    var params:Array<Dynamic> = event.params.copy();

    var isModifyingExisting:Bool = params.shift();
    var whichIcon:String = params.shift();

    var iconToModify:HealthIcon = switch (whichIcon) {
        case "Player": iconP1;
        default: iconP2;
    };

    var newIcon_isPlayer:Bool = (whichIcon == "Player");
    var setIconChar:String = params.shift();

    var iconOffsetX:Float = params.shift();
    var iconOffsetY:Float = params.shift();

    if (isModifyingExisting) {
        iconToModify.setIcon(setIconChar);
        if (!iconToModify.extra.exists("offset")) iconToModify.extra.set("offset", FlxPoint.get());
        iconToModify.extra.get("offset").set(iconOffsetX, iconOffsetY);
    } else {
        var new_icon:HealthIcon = new HealthIcon(setIconChar, newIcon_isPlayer);
        new_icon.cameras = [camHUD];
        insert(members.indexOf((newIcon_isPlayer) ? iconP1 : iconP2), new_icon);
        
        if (!new_icon.extra.exists("offset")) new_icon.extra.set("offset", FlxPoint.get());
        new_icon.extra.get("offset").set(iconOffsetX, iconOffsetY);

        iconArray.push(new_icon);
    }

    updateHealthbarColor();
}