import animate.internal.elements.FlxSpriteElement;
import haxe.ds.ObjectMap;

var bf_sing:FunkinSprite = new FunkinSprite(0, 0, Paths.image('stages/usa/bf_car'));
bf_sing.origin.set();

var alien_sing:FunkinSprite = new FunkinSprite(0, 0, Paths.image('stages/usa/alien_car'));
alien_sing.origin.set();

var animations_map:ObjectMap< Array<{name:String, ref:String}> > = new ObjectMap();
animations_map.set(bf_sing, [
	{name: "idle", ref: "BFCarIdle"},
	{name: "singLEFT", ref: "BFCarLeft"},
	{name: "singDOWN", ref: "BFCarDown"},
	{name: "singUP", ref: "BFCarUp"},
	{name: "singRIGHT", ref: "BFCarRight"},
]);
animations_map.set(alien_sing, [
	{name: "idle", ref: "AHCarIdle"},
	{name: "singLEFT", ref: "AHCarLeft"},
	{name: "singDOWN", ref: "AHCarDown"},
	{name: "singUP", ref: "AHCarUp"},
	{name: "singRIGHT", ref: "AHCarRight"},
]);

function postCreate() {
	// var idleSymbol:SymbolItem = bf_sing.library.getSymbol("BFCarIdle");
	// var singLeftSymbol:SymbolItem = bf_sing.library.getSymbol("BFCarLeft");
	// var singDownSymbol:SymbolItem = bf_sing.library.getSymbol("BFCarDown");
	// var singUpSymbol:SymbolItem = bf_sing.library.getSymbol("BFCarUp");
	// var singRightSymbol:SymbolItem = bf_sing.library.getSymbol("BFCarRight");
	// bf_sing.animation.addByTimeline("idle", idleSymbol.timeline, 24, false);
	// bf_sing.animation.addByTimeline("singLEFT", singLeftSymbol.timeline, 24, false);
	// bf_sing.animation.addByTimeline("singDOWN", singDownSymbol.timeline, 24, false);
	// bf_sing.animation.addByTimeline("singUP", singUpSymbol.timeline, 24, false);
	// bf_sing.animation.addByTimeline("singRIGHT", singRightSymbol.timeline, 24, false);
	
	for (char=>anim_data in animations_map) {
		for (data in anim_data) char.animation.addBySymbol(data.name, data.ref, 24, false);
		char.playAnim("idle", true);
		char.antialiasing = antialiasing;

		var element:FlxSpriteElement = new FlxSpriteElement(char);
		element.active = false;

		var placeholder_animation:SymbolItem = library.getSymbol(anim_data[0].ref);
		for (layer in placeholder_animation.timeline.layers) layer.forEachFrame((frame) -> for (i in frame.elements) i.visible = false);
		placeholder_animation.timeline.layers[0].forEachFrame((frame) -> {
			frame.add(element);
		});
	}
}

function onPlaySingAnim(event:DirectionAnimEvent) {
	// for (char=>anim_data in animations_map) char.playAnim(event.animName, event.force, event.context, event.reversed, event.frame);
	alien_sing.playAnim(event.animName, event.force, event.context, event.reversed, event.frame);
}

function onNoteHit(event:NoteHitEvent) {
	if (event.note.strumLine.opponentSide) return;
	bf_sing.playAnim(getSingAnim(event.direction, ""), true);
}

function onDance(event:DanceEvent) {
	for (char=>anim_data in animations_map) char.playAnim("idle" + idleSuffix, "DANCE");
}

function update(elapsed:Float) {
	for (char=>anim_data in animations_map) char.update(elapsed);
}

function destroy() {
	for (char=>anim_data in animations_map) char.destroy();
	animations_map = null;
}