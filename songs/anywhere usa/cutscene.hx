import haxe.ds.ObjectMap;

// pausable = false;
skippable = true;

var HAS_SKIPPED:Bool = false;

var dad(get, set):Character;
function get_dad() { return game.dad; }
function set_dad(v) { return game.dad = v; }
var bf(get, set):Character;
function get_bf() { return game.bf; }
function set_bf(v) { return game.bf = v; }
var gf(get, set):Character;
function get_gf() { return game.gf; }
function set_gf(v) { return game.gf = v; }

final alien_fall:FlxSound = FlxG.sound.load(Paths.sound("usa/fall ship"));
final ship_explode:FlxSound = FlxG.sound.load(Paths.sound("usa/ship explo"));
final landing_alien:FlxSound = FlxG.sound.load(Paths.sound("usa/alien fall"));

var ORIGINAL_CHAR_POS:ObjectMap<FlxPoint> = new ObjectMap();

final prev_volume:Float = game.inst.volume;
var state(default, set):Int = 0;
function set_state(v) {
	state = v;
	return state;
}

function pauseCutscene() { game.inst.pause(); }
function onResumeCutscene() { game.inst.resume(); }

var introGF:Character = new Character(0, 0, "usa/gf");
introGF.danceOnBeat = false;

var ship_image:FlxSprite = new FlxSprite(0, 0, Paths.image("stages/usa/ShipAlone"));
ship_image.antialiasing = true;

function create() {

	Conductor.songPosition = 0;
	game.inst.play(true, 0);
	game.inst.volume = 0;

	gf.alpha = 0;
	introGF.setPosition(gf.x, gf.y);
	game.insert(game.members.indexOf(gf), introGF);
	introGF.playAnim("intro-loop");

	ship_image.setPosition(dad.x - 185, dad.y + 250);
	ship_image.alpha = 0;
	game.insert(game.members.indexOf(dad), ship_image);
	
	game.camFollow.setPosition(game.stage.startCam.x, game.stage.startCam.y);
	FlxG.camera.focusOn(game.camFollow.getPosition());

	dad.alpha = 0;
	bf.alpha = 0;

	for (char in [dad, bf, gf]) ORIGINAL_CHAR_POS.set(char, FlxPoint.get(char.x, char.y));

	start_timer.start(0.5, startAlienFall);
}

var start_timer:FlxTimer = new FlxTimer();

function startAlienFall() {
	alien_fall.play(true);

	dad.alpha = 1;
	dad.playAnim("ship", true, "LOCK");

	dad.x -= 800; dad.y -= 800;

	var final_pos:FlxPoint = ORIGINAL_CHAR_POS.get(dad);
	FlxTween.tween(dad, {x: final_pos.x, y: final_pos.y}, alien_fall.length * 0.001, {onComplete: () -> {
		if (HAS_SKIPPED) return;
		state++;
		introGF.playAnim("look", true, "LOCK");

		ship_image.alpha = 1;
		ship_explode.play(true);
		dad.playAnim("flying-dead", true, "LOCK");
		dad.moves = true;
		dad.y -= 25;
		dad.x -= 150;
		dad.velocity.y = -2500;

		FlxTween.tween(dad.velocity, {y: 2500}, 0.5, {startDelay: 0.1});
		FlxTween.tween(dad, {x: final_pos.x}, 0.7);
	}});
}

function update(elapsed:Float) {
	introGF.danceOnBeat = false;
	// if (FlxG.keys.justPressed.P) state++;
	// if (FlxG.keys.justPressed.O) state--;
	if (state == 1) {
		var ogPos = ORIGINAL_CHAR_POS.get(dad);
		if (dad.y >= ogPos.y) {
			cleanupDad();
			dad.playAnim("ship-dies", true, "LOCK");
			landing_alien.play(true);
			state++;
		}
	}
}

function beatHit(beat:Int) {
	switch (state) {
		case 0:
			introGF.playAnim("intro-loop");
		case 2:
			introGF.playAnim("look-loop");

	}
}

function destroy() {
	HAS_SKIPPED = true;
	cleanupDad();
	start_timer.cancel();

	game.remove(ship_image, true);
	ship_image.destroy();

	game.remove(introGF, true);
	introGF.destroy();

	for (char=>pos in ORIGINAL_CHAR_POS) {
		char.alpha = 1;
		char.setPosition(pos.x, pos.y);
		char.playAnim("idle", true, "DANCE");
	}
	
	// cleanup sounds
	// alien_fall.cleanup(true, true);

	game.inst.volume = prev_volume;
}

function cleanupDad() {
	var ogPos = ORIGINAL_CHAR_POS.get(dad);
	dad.moves = false;
	dad.velocity.set();
	dad.setPosition(ogPos.x, ogPos.y);
	FlxTween.cancelTweensOf(dad);
}