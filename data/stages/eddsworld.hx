introLength = 0;

final isEndMix:Bool = (PlayState.SONG.meta?.variant?.toLowerCase() == "end mix");

if (!isEndMix){
//region Normal Stage

var eduardo_strumline(get, never):StrumLine;
function get_eduardo_strumline() return strumLines.members[2];

var eduardo(get, never):Character;
function get_eduardo() return eduardo_strumline.characters[0];

var john:FunkinSprite = new FunkinSprite(0, 0, Paths.image('stages/eddsworld/john'));
john.antialiasing = true;
john.scale.set(0.95, 0.95);
john.updateHitbox();
john.addAnim("idle", "JohnIdle");
john.playAnim("idle", true);

var mark:FunkinSprite = new FunkinSprite(0, 0, Paths.image('stages/eddsworld/mark'));
mark.antialiasing = true;
mark.scale.set(0.85, 0.85);
mark.updateHitbox();
mark.addAnim("idle", "MarkIdle");
mark.playAnim("idle", true);

function postCreate() {
    eduardo.x = -1051 + 25; eduardo.y = -18;

    john.x = -1128 + 25; john.y = -276;
    insert(members.indexOf(eduardo), john);

    mark.x = -1384 + 25; mark.y = -200;
    insert(members.indexOf(john), mark);
}

function beatHit(curMeasure:Int) {
    if (curBeat % 2 != 0) return;
    john.playAnim("idle", true);
    mark.playAnim("idle", true);
}

function well() {
    eduardo.playAnim("well", true, "LOCK");

    function killMe() { defaultCamZoom = FlxG.camera.zoom; }

    FlxTween.cancelTweensOf(FlxG.camera);
    FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom + 0.05}, 0.5, {ease: FlxEase.expoOut, onUpdate: killMe, onComplete: killMe});
}

function edd_camera() {
    dad.cameraOffset.x -= 300;
    dad.cameraOffset.y -= 50;
}

function punch_mark() {
    john.visible = mark.visible = false;
    eduardo.playAnim("punch", true, "LOCK");
}


//endregion

}else{

//region End Mix stuff

//endregion
}