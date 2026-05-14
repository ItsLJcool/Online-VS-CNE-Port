//a

import StringTools;

public var noteCamIntensity:Float = 1;
final MOVEMENT_AMOUNT:Float = 10;
public var _singPosMap:Map<String, {x:Float, y:Float}> = [
	'singLEFT' => {x: -MOVEMENT_AMOUNT, y: 0},
	'singLEFT-alt' => {x: -MOVEMENT_AMOUNT, y: 0},
	'singDOWN' => {x: 0, y: MOVEMENT_AMOUNT},
	'singDOWN-alt' => {x: 0, y: MOVEMENT_AMOUNT},
	'singUP' => {x: 0, y: -MOVEMENT_AMOUNT},
	'singUP-alt' => {x: 0, y: -MOVEMENT_AMOUNT},
	'singRIGHT' => {x: MOVEMENT_AMOUNT, y: 0},
	'singRIGHT-alt' => {x: MOVEMENT_AMOUNT, y: 0},
];

public var disable_camera_movement:Bool = true;

function onCameraMove(e) {
	CURRENT_OFFSET_AMOUNT.x = CURRENT_OFFSET_AMOUNT.y = 0;
	var _anim:String = strumLines.members[curCameraTarget].characters[0].getAnimName();
	var singAnims = [for (_i in _singPosMap.keys()) _i];
	if (singAnims.contains(_anim)) {
		CURRENT_OFFSET_AMOUNT.x += _singPosMap[_anim].x*noteCamIntensity;
		CURRENT_OFFSET_AMOUNT.y += _singPosMap[_anim].y*noteCamIntensity;
	}

	if (disable_camera_movement) return;
	FlxG.camera.targetOffset.x = (CURRENT_OFFSET_AMOUNT.x / FlxG.camera.zoom);
	FlxG.camera.targetOffset.y = (CURRENT_OFFSET_AMOUNT.y / FlxG.camera.zoom);
}

function create() {
	var foundCameraMove = false;
	for(e in events) {
		if (e.time > 10) continue;
		if (e.name != "Camera Movement") continue;
		var char = strumLines.members[e.params[0]].characters[0];
		camFollow.setPosition(char.getCameraPosition().x, char.getCameraPosition().y);
		FlxG.camera.focusOn(camFollow.getPosition());
		foundCameraMove = true;
		break;
	}
	if (!foundCameraMove) {
		camFollow.setPosition(dad.getCameraPosition().x, dad.getCameraPosition().y);
		FlxG.camera.focusOn(camFollow.getPosition());
	}
}

var CURRENT_OFFSET_AMOUNT:FlxPoint = FlxPoint.get(0, 0);
function postCreate() {
	onPostStartCountdown();
}

function onPostStartCountdown() {
	FlxG.camera.zoom = defaultCamZoom;
}