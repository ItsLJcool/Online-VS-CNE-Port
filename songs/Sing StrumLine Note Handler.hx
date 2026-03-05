using StringTools;

final NOTE_NAME:String = "Sing StrumLine";

function onNoteHit(event:NoteHitEvent) {
    if (!(event.noteType?.startsWith(NOTE_NAME) ?? false)) return;
    var nt_values:Array<String> = event.noteType.split("|"); nt_values.shift();
    var strumLine:StrumLine = strumLines.members[Std.parseInt(nt_values.shift())];

    var charIdx:Int = Std.parseInt(nt_values.shift());

    if (charIdx == null || Math.isNaN(charIdx)) event.characters = strumLine.characters;
    else event.characters = [strumLine.characters[0]];
}