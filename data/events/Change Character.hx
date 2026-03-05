
function onEvent(e) {
    var event = e.event;
    if (event.name != "Change Character") return;
    
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
    new_character.playAnim("idle");
    
    strumLine.characters[charIndex] = new_character;
}