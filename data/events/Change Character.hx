
import Xml;
import haxe.io.Path;

import funkin.backend.system.Flags;

final EVENT_NAME:String = "Change Character";

function PRELOAD(?event, ?onComplete:String->Void) {
    var charName:String = "UNKNOWN";
    var params:Array<Dynamic> = [];
    var toCache:Array<String> = [];
    try {
        params = event.params.copy();
        charName = params[2];
        var xml = Xml.parse(Assets.getText(Paths.xml('characters/$charName'))).firstElement();
        var folder = (xml.get("sprite") ?? charName);
        var iconPath = (xml.get("icon") ?? charName);
        toCache = [Paths.image('characters/$folder'), Paths.image('icons/$iconPath')];
        if (onComplete != null) onComplete(toCache);
    } catch(e:Error) {
        trace('Failed to cache character: $charName | $e');
        if (onComplete != null) onComplete(toCache);
    }
}

function postCreate() {
    for (event in events) {
        if (event.name != EVENT_NAME) continue;
        PRELOAD(event);
    }
}

function onEvent(e) {
    var event = e.event;
    if (event.name != EVENT_NAME) return;
    
    var params = event.params.copy();
    var strumlineIDX:Int = params.shift();
    var charIndex:Int = params.shift();
    var charName:String = params.shift();

    var strumLine = switch(strumlineIDX) {
        case 0: cpu;
        case 1: player;
        default: strumLines.membres[strumlineIDX];
    }
    if (strumLine == null) return trace('StrumLine "${strumlineIDX}" does not exist!');

    var character = strumLine.characters[charIndex];
    if (character == null) return trace('Character "${charIndex}" does not exist on StrumLine "${strumlineIDX}"!');
    
    var strumLineData = PlayState.SONG.strumLines[strumlineIDX];
    var charPosName = (strumLineData.position == null) ? (switch(strumLineData.type) {
        case 1: "boyfriend";
        case 2: "gf";
        default: "dad";
    }) : strumLineData.position;

    var new_character = new Character(character.x, character.y, charName, character.isPlayer);
    insert(members.indexOf(character), new_character);
    remove(character, true);
    stage.applyCharStuff(new_character, charPosName, charIndex);

    var icon = (new_character.isPlayer) ? iconP1 : iconP2;
    icon.setIcon(new_character.icon);
    
    strumLine.characters[charIndex] = new_character;
}