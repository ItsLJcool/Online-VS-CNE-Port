introLength = 0;

var tordStrumLine(get, never):StrumLine;
function get_tordStrumLine() return strumLines.members[2];
var tord(get, never):Character;
function get_tord() return tordStrumLine.characters[0];

final enter_pos:Array<FlxPoint> = [];
function cache_dirs() {
    for (char in [bf, dad]) {
        remove(char);
        insert(members.indexOf(tord)+1, char);
        char.scrollFactor.set();
        for (idx in 0...4) char.playSingAnim(idx, "-enter", "LOCK", true); 
    }
    dad.x -= 125;

    dad.x -= 385; dad.y += 385;
    enter_pos.push({
        sing_pos: FlxPoint.get(dad.x + 385, dad.y - 385),
        back_pos: FlxPoint.get(dad.x, dad.y),
    });


    // do bf here
    bf.x += 95; bf.y -= 75;
    bf.x += 385; bf.y += 385;
    enter_pos.push({
        sing_pos: FlxPoint.get(bf.x - 385, bf.y - 385),
        back_pos: FlxPoint.get(bf.x, bf.y),
    });
}

var move_back_internal:FlxTimer = new FlxTimer();
function onNoteHit(event:NoteHitEvent) {
    if (event.noteType == "Rocket" || strumLines.members.indexOf(event.note.strumLine) <= 0 || event.note.isSustainNote) return;

    moveCharacter((event.noteType == null));
}

function moveCharacter(isPlayer:Bool) {
    if (enter_pos.length <= 0) return;
    var char:Character = (isPlayer) ? bf : dad;
    var pos_data:Dynamic = (!isPlayer) ? enter_pos[0] : enter_pos[1];

    move_back_internal.cancel();

    FlxTween.cancelTweensOf(char);
    FlxTween.tween(char, {x: pos_data.sing_pos.x, y: pos_data.sing_pos.y}, 0.5, {ease: FlxEase.expoOut});
    
    move_back_internal.start((Conductor.crochet*0.001), () -> {
        FlxTween.tween(char, {x: pos_data.back_pos.x, y: pos_data.back_pos.y}, 0.5, {ease: FlxEase.quadIn, onStart: () -> {
            char.extra.set("moving_char", false);
        }});
    });
}