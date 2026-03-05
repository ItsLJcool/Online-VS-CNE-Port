using StringTools;

final EVENT_NAME:String = "Alt Animation Toggle";

function onEvent(e) {
	var event = e.event;
	if (event.name != EVENT_NAME) return;
	if (event.params.length <= 2) return;
	e.cancel();

	var params = event.params.copy();

	var doAltSing:Bool = params.shift();
	var doAltIdle:Bool = params.shift();
	var strumLine:StrumLine = strumLines.members[params.shift()];
	var suffix:String = (params.shift()).trim();
	if (suffix.length  <= 0) suffix = "-alt";

	if (doAltSing && strumLine != null) strumLine.animSuffix = suffix;
	if (strumLine.characters != null) {
		for (char in strumLine.characters) {
			if (char == null) continue;
			char.idleSuffix = (doAltIdle) ? suffix : "";
		}
	}
}
