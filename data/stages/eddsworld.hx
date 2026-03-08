
import funkin.backend.utils.FlxInterpolateColor;
import openfl.geom.ColorTransform;

import funkin.editors.charter.Charter;

using StringTools;

final isEndMix:Bool = (PlayState.SONG.meta?.variant?.toLowerCase() == "end mix");

function postCreate() {
    matt.x = -65; matt.y = 265;
    insert(members.indexOf(fences)+1, matt);
    
    doorStuck.x = 520; doorStuck.y = 325;
    insert(members.indexOf(bg)+1, doorStuck);

    plane.x = -900;
    plane.scrollFactor.set(skyBox.scrollFactor.x, skyBox.scrollFactor.y);
    insert(members.indexOf(skyBox)+1, plane);

    tom.y = 245;
    if (isEndMix) {
        tom.x = bf.x;
        add(tom);
    }
    else {
        // HOLY SHIT I FOUND DESS!!!
        tom.x = 1225; 
        insert(members.indexOf(fences)+1, tom);
    }
    
    if (!isEndMix) normal_postCreate();
    else end_mix_postCreate();
}

function beatHit(curBeat:Int) {

    switch (curBeat) {
        case 52: planeGoBrrr();
    }

    if (curBeat % 2 == 0) {
        if (matt?.getAnimName()?.startsWith("idle")) matt.playAnim(matt.getAnimName());
        if (tom?.getAnimName()?.startsWith("idle")) tom.playAnim(tom.getAnimName());
    }

    if (!isEndMix) normal_beatHit(curBeat);
    // else end_mix_beatHit(curBeat);
}

//region Plane passes by

var plane:FlxSprite = new FlxSprite(0, 0, Paths.image('stages/eddsworld/plane'));
plane.antialiasing = true;
plane.visible = false;
plane.updateHitbox();

function planeGoBrrr() {
    plane.visible = true;
    plane.moves = true;
    plane.velocity.x = 95;
}

//endregion

//region Characters Walking Animations

var doorStuck:FunkinSprite = new FunkinSprite(0, 0, Paths.image('stages/eddsworld/door'));
doorStuck.antialiasing = true;
doorStuck.scale.set(1.5, 1.5);
doorStuck.updateHitbox();
doorStuck.addAnim("opening", "Door Opening");
doorStuck.alpha = 0;
doorStuck.playAnim("opening", true);

var matt:FunkinSprite = new FunkinSprite(0, 0, Paths.image('stages/eddsworld/matt'));
matt.antialiasing = true;
matt.scale.set(1.5, 1.5);
matt.updateHitbox();
matt.addAnim("walking", "MattWalking", 24, true);
matt.addAnim("idle", "MattSnappingFinger");
matt.addAnim("idle-pissed", "MattPISSED");
matt.addAnim("eduardoReaction", "MattReaction");
if (isEndMix) {
    matt.addAnim("tordReaction", "MattReactionTord");
    matt.addAnim("lookAtTord", "MattHarpoonBit", 24, true, false, CoolUtil.numberArray(5));
    matt.addAnim("phew", "MattHarpoonBit", 24, false, false, CoolUtil.numberArray(19, 8));
}
matt.playAnim("idle", true);
matt.visible = false;

var tom:FunkinSprite = new FunkinSprite(0, 0, Paths.image('stages/eddsworld/tom'));
tom.antialiasing = true;
tom.scale.set(1.5, 1.5);
tom.updateHitbox();
tom.flipX = !isEndMix;
tom.visible = false;
// so it saves on loading the animations into memory
if (!isEndMix) {
    tom.addAnim("walking", "TomWalkingBy", 24, true);
    tom.addAnim("walking-transition", "TomTransition", 24, false, false, null, 25, 15);

    tom.addAnim("idle", "TomLooking", 24, false, false, CoolUtil.numberArray(14), 25, 15);
    tom.addAnim("looks", "TomLooking", 24, false, false, CoolUtil.numberArray(22, 14), 25, 15);
    tom.addAnim("idle-looks", "TomLooking", 24, false, false, CoolUtil.numberArray(31, 22), 25, 15);

    tom.addAnim("eduardoReaction", "TomReaction", 24, false, false, null, 25, 15);
} else {
    tom.addAnim("tordReaction", "Tom Running In");
    tom.addAnim("idle-talking", "TomHarpoonLine", 24, true, false, CoolUtil.numberArray(5));
    tom.addAnim("transition-talking", "TomHarpoonLine", 24, false, false, CoolUtil.numberArray(9, 5));
    tom.addAnim("talking", "TomHarpoonLine", 12, true, false, CoolUtil.numberArray(11, 9));
    tom.addAnim("talking-finished", "TomHarpoonLine", 24, false, false, CoolUtil.numberArray(22, 11));
}
tom.playAnim("walking", true);


function open_door() {
    doorStuck.alpha = 1;
    doorStuck.animation.finishCallback = () -> {
        doorStuck.animation.finishCallback = () -> doorStuck.alpha = 0;
        new FlxTimer().start(0.5, () -> doorStuck.playAnim("opening", true, "NONE", true));
    };
    doorStuck.playAnim("opening", true);
}
function matt_walks() {
    final walk_to_pos:Float = matt.x;
    open_door();
    matt.visible = true;
    matt.playAnim("walking", true);

    matt.x += 650;
    FlxTween.tween(matt, {x: walk_to_pos + 75}, (Conductor.crochet * 0.001)*8, {onComplete: () -> {
        matt.playAnim("idle", true);
        matt.x = walk_to_pos;
    }});
}

function tom_walks() {
    open_door();
    final walk_to_pos:Float = tom.x;
    tom.visible = true;
    tom.playAnim("walking", true);

    tom.x -= 650;
    FlxTween.tween(tom, {x: walk_to_pos}, (Conductor.crochet * 0.001)*12, {onComplete: () -> {
        tom.flipX = !tom.flipX;
        tom.playAnim("walking-transition", true);
        tom.animation.finishCallback = (name:String) -> {
            tom.animation.finishCallback = null;
            tom.playAnim("idle");
        };
        tom.x = walk_to_pos;
    }});
}

function onEvent(e) {
    var event = e.event;
    if (event.name != "Camera Movement") return;

    var isLooking:Bool = (event.params[0] != 1);
    tom.playAnim("looks", true, "LOOK", !isLooking);
    tom.animation.finishCallback = () -> {
        tom.animation.finishCallback = null;
        tom.playAnim((isLooking) ? "idle-looks" : "idle");
    };
}
//endregion


function fixHealthColor() {
    healthBar.createFilledBar((!isEndMix) ? 0xFF10712B : 0xFFD9104B, 0xFF30B0D1);
    healthBar.updateBar();
    var point:FlxPoint = iconArray[2].extra.get("offset");
    if (point == null) return;
    var originalX:Float = point.x;
    point.x = -250;
    FlxTween.tween(point, {x: originalX}, 0.25);
}

if (!isEndMix){
//region Normal Stage


var isEduardoTime:Bool = false;

function onGameOver(event:GameOverEvent) {
    if (curCameraTarget == 0 && isEduardoTime) {
        isEduardoTime = false;
        event.cancel();
        gameOver(dad, "eddie");
    }
}

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


function normal_postCreate() {

    eduardo.x = -1051 + 25; eduardo.y = -18;

    remove(eduardo);
    insert(members.indexOf(fences), eduardo);

    john.x = -1128 + 25; john.y = -276;
    insert(members.indexOf(eduardo), john);

    mark.x = -1384 + 25; mark.y = -200;
    insert(members.indexOf(john), mark);
}

function everyone_reacts() {
    dad.playAnim("turnAround", true);
    matt.playAnim("eduardoReaction", true);
    tom.playAnim("eduardoReaction", true);
}

function normal_beatHit(curBeat:Int) {
    if (curBeat % 2 != 0) return;
    john.playAnim("idle", true);
    mark.playAnim("idle", true);
}

var darkenedColor:FlxInterpolateColor = new FlxInterpolateColor();
var lerp_darken_color:Float = 0;
var lerp_darken_color_current:Float = 0;
function well() {
    eduardo.playAnim("well", true, "LOCK");

    function killMe() { defaultCamZoom = FlxG.camera.zoom; }

    FlxTween.cancelTweensOf(FlxG.camera);
    FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom + 0.05}, 0.5, {ease: FlxEase.expoOut, onUpdate: killMe, onComplete: killMe});

    lerp_darken_color += 0.15;
}

function wellDone() {
    isEduardoTime = true;
    lerp_darken_color = 0;
}

function edd_camera() {
    dad.cameraOffset.x -= 300;
    dad.cameraOffset.y -= 50;
    matt.playAnim("idle-pissed", true);
}

function punch_mark() {
    john.visible = mark.visible = false;
    eduardo.playAnim("punch", true, "LOCK");
}

function update(elapsed:Float) {
    lerp_darken_color_current = lerp(lerp_darken_color_current, lerp_darken_color, 0.15);

    darkenedColor.color = FlxColor.WHITE;
    darkenedColor.lerpTo(FlxColor.BLACK, lerp_darken_color_current);

    skyBox.color = bg_paralax.color = darkenedColor.color;
}

//endregion

}else{

//region End Mix stuff

var tord_plane:FlxSprite = new FlxSprite();
tord_plane.frames = Paths.getSparrowAtlas('stages/eddsworld/tord helicopter');
tord_plane.antialiasing = true;
tord_plane.animation.addByIndices("falling", "TordHelicopter0", [0]);
tord_plane.animation.addByPrefix("saves", "TordHelicopter0", 24, false);
tord_plane.animation.play("saves");
tord_plane.visible = false;

var tordbot:FunkinSprite = new FunkinSprite(0, 0, Paths.image('stages/eddsworld/tordbot'));
tordbot.antialiasing = true;
tordbot.scale.set(1.5, 1.5);
tordbot.updateHitbox();
tordbot.addAnim("idle", "TordBot");
tordbot.addAnim("aboutToExplode", "TordBotBlowingUp", 24, true, false, CoolUtil.numberArray(3));
tordbot.addAnim("explode", "TordBotBlowingUp");
tordbot.playAnim("idle", true);
tordbot.animation.finishCallback = (name:String) -> {
    if (name != "explode") return;
    tordbot.visible = false;
}

var tordCockpitBG:FlxSprite = new FlxSprite(0, 0, Paths.image('stages/eddsworld/TordBG'));
tordCockpitBG.antialiasing = true;
tordCockpitBG.scale.set(1.15, 1.15);
tordCockpitBG.updateHitbox();

var tordCloseUp:FlxSprite = new FlxSprite(0, 0, Paths.image('stages/eddsworld/CockPitUpClose'));
tordCloseUp.antialiasing = true;
tordCloseUp.scale.set(1.65, 1.45);
tordCloseUp.updateHitbox();

var ohNo_alarm:FlxSprite = new FlxSprite().makeSolid(FlxG.width, FlxG.height, FlxColor.RED);
ohNo_alarm.alpha = 0;
ohNo_alarm.antialiasing = true;
ohNo_alarm.cameras = [camHUD];
ohNo_alarm.scrollFactor.set();

var tord_strumline(get, never):StrumLine;
function get_tord_strumline() return strumLines.members[2];

var tord(get, never):Character;
function get_tord() return tord_strumline.characters[0];

var tord_follow_plane:Bool = true;
function end_mix_postCreate() {
    tord.y = 1500;

    plane.onDraw = (spr:FlxSprite) -> {
        if (tord_follow_plane) tord_plane.setPosition(spr.x + (spr.width - tord_plane.width) * 0.5, (spr.y + (spr.height - tord_plane.height) * 0.5));
        spr.draw();
    }

    tord_plane.scrollFactor.set(skyBox.scrollFactor.x, skyBox.scrollFactor.y);
    insert(members.indexOf(plane), tord_plane);

    tordbot.x = 635; tordbot.y = 55;
    // tordbot.y -= 785;
    insert(members.indexOf(bg), tordbot);


    tordCloseUp.setPosition(tord.x - 650, tord.y - 300);
    add(tordCloseUp);

    tordCockpitBG.setPosition(tord.x - 550, tord.y - 525);
    insert(members.indexOf(bg), tordCockpitBG);

    insert(0, ohNo_alarm);
}

function drop_the_tord() {
    tord_follow_plane = false;

    tord_plane.visible = true;
    tord_plane.animation.play("falling", true);
    new FlxTimer().start(1.85, () -> tord_plane.animation.play("saves", true));
    FlxTween.tween(tord_plane, {y: tord_plane.y + 100}, 2, {ease:FlxEase.quartIn, onComplete: () -> {
        tord_plane.moves = true;
        tord_plane.velocity.x = 100;
        tord_plane.velocity.y = -100;
        FlxTween.tween(tord_plane.velocity, {y: 50}, 0.85);
        tord_tween_but_why_not_update_well_thats_because_tweening_is_easier_said_the_lj_when_tord_decided_to_bounde_only_RIGHT_when_tweening_so_fuckYOU();
    }});
}

var kms:FlxTween = null;
function tord_tween_but_why_not_update_well_thats_because_tweening_is_easier_said_the_lj_when_tord_decided_to_bounde_only_RIGHT_when_tweening_so_fuckYOU() {
    if (tord_plane == null) return;
    kms = FlxTween.tween(tord_plane.velocity, {x: -tord_plane.velocity.x}, 1.25, {ease:FlxEase.quadIn, onComplete: tord_tween_but_why_not_update_well_thats_because_tweening_is_easier_said_the_lj_when_tord_decided_to_bounde_only_RIGHT_when_tweening_so_fuckYOU});
}

var do_cooler_shake:Bool = false;
var tordTime:Bool = false;
function omgTord() {
    tordTime = true;
    var time:Float = (Conductor.stepCrochet*0.001)*60;
    FlxTween.tween(tordbot, {y: tordbot.y - 785}, time);
    // tordbot.y -= 785;
    FlxTween.tween(skyBox, {y: skyBox.y - 350}, time, {ease: FlxEase.smoothStepInOut});
    /*if (!Charter.startHere) */camGame.shake(0.005, time);

    matt.playAnim("tordReaction", true);  
    new FlxTimer().start((Conductor.crochet * 0.001)*3, () -> {
        tom.visible = true;
        tom.playAnim("tordReaction", true);
    });
}

function weZoomin() {

    function killMe() { defaultCamZoom = FlxG.camera.zoom; }

    var time:Float = (Conductor.crochet*0.001)*1.75;
    final ease:FlxEase = FlxEase.expoIn;

    FlxTween.tween(FlxG.camera.scroll, {y: FlxG.camera.scroll.y - 250}, time, {ease: FlxEase.quadIn});
    FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom + 2}, time, {ease: ease, onUpdate: killMe, onComplete: killMe});
}

function weSwitchin() {
    FlxTween.cancelTweensOf(FlxG.camera);
    FlxTween.cancelTweensOf(FlxG.camera.scroll);
    FlxG.camera.snapToTarget();
    FlxG.camera.zoom = defaultCamZoom = 0.8;
    
    FlxTween.tween(tordCloseUp, {alpha: 0}, (Conductor.crochet*0.001)*1);
    
    function killMe() { defaultCamZoom = FlxG.camera.zoom; }
    FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.crochet*0.001)*4, {ease: FlxEase.expoOut, onUpdate: killMe, onComplete: killMe});
}

var tordExploding:Bool = false;
function tordAlarm() {
    tordTime = false;
    tordExploding = true;
    FlxTween.tween(ohNo_alarm, {alpha: 0.15}, (Conductor.crochet*0.001)*1.5, {type: FlxTween.PINGPONG});
}

function tordOut() {
    FlxTween.cancelTweensOf(ohNo_alarm);
    FlxTween.tween(ohNo_alarm, {alpha: 0}, (Conductor.crochet*0.001)*1.5);
    
    function killMe() { defaultCamZoom = FlxG.camera.zoom; }
    FlxTween.tween(tordCloseUp, {alpha: 1}, (Conductor.crochet*0.001)*1, {onComplete: () -> {
        tordbot.playAnim("aboutToExplode", true);

        executeEvent({name: "Camera Movement", params: [3, false]});
        executeEvent({name: "Camera Position", params: [0, -950, false, null, null, null, true]});
        FlxTween.cancelTweensOf(FlxG.camera);
        FlxG.camera.zoom = 0.75;
        FlxTween.tween(FlxG.camera, {zoom: 0.6}, (Conductor.crochet*0.001)*4, {ease: FlxEase.expoOut, onUpdate: killMe, onComplete: killMe});

        remove(tord);
        insert(members.indexOf(tordbot), tord);
        tord.playAnim("falling", true);
        tord.setPosition((tordbot.x - (tordbot.x + tord.width) * 0.25) + 50, tordbot.y - 335);
        
        skyBox.y -= 165;
    }});
    
    FlxTween.tween(FlxG.camera, {zoom: 0.8}, (Conductor.crochet*0.001)*1, {ease: FlxEase.expoIn, onUpdate: killMe, onComplete: killMe});
}

function tordExplode() {
    FlxTween.tween(tord, {y: tord.y - 800}, (Conductor.crochet*0.001)*3, {startDelay: 0.25});
    FlxTween.tween(tord, {y: tord.y + 1500}, (Conductor.crochet*0.001)*8, {startDelay: (Conductor.crochet*0.001)*4});
    tordbot.playAnim("explode", true);

    tom.scale.set(1, 1);
    tom.updateHitbox();
    tom.x -= 385; tom.y += 175;
    tom.playAnim("idle-talking", true);

    matt.playAnim("lookAtTord", true);

    dad.playAnim("looksUp", true);
    bf.playAnim("looksUp", true);

    for (char in [bf, dad]) {
        char.scrollFactor.set(1, 1);
        char.cameras = [camGame];
        stage.applyCharStuff(char, (char == dad) ? "dad" : "boyfriend", 0);
    }
}

function broDies() {
    FlxTween.tween(skyBox, {y: skyBox.y + 515}, (Conductor.stepCrochet*0.001)*42, {ease: FlxEase.smoothStepInOut});
}

function tomUseful() {
    dad.playAnim("turn", true);
    tom.playAnim("transition-talking", true);
    tom.animation.finishCallback = (name:String) -> {
        if (name != "transition-talking") return;
        tom.animation.finishCallback = null;
        tom.playAnim("talking", true);
    };
}

function amazingFLA() {
    matt.playAnim("phew", true);
    tom.playAnim("talking-finished", true);
}

function onDadHit(event:NoteHitEvent) {
    if (!tordTime) return;
    if (health <= 0.15) return;
    event.healthGain = 0.0225;
    if (event.note.isSustainNote) event.healthGain *= 0.75;
}

function onPostNoteHit(event:NoteHitEvent) {
    if (!tordTime || !event.characters.contains(tord)) return;
    var intensity:Float = (tord.getAnimName().startsWith("sing")) ? 0.008 : 0.0055;
    camGame.shake(intensity, 0.095);
}

function update(elapsed:Float) {
    if (tordExploding) tordbot.offset.x = - 433.5 + FlxG.random.float(-1, 1)*10;
    if (plane.x >= 1200 && tord_follow_plane) drop_the_tord();
    if (tord_plane.y > 500) {
        kms?.cancel();
        FlxTween.cancelTweensOf(tord_plane);
        remove(tord_plane, true);
        tord_plane.kill();
        tord_plane.destroy();
    }

}

//endregion

}