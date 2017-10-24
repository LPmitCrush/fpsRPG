class LevelUpHUDMessage extends LocalMessage;

// Levelup Message - tell local player he has stat points to distibute
//
// Switch 0: Using default bindings, so add "(Press L)"
//
// Switch 1: Not using default bindings

var(Message) localized string LevelUpString, PressLString;
var(Message) color YellowColor;

static function color GetColor(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2
	)
{
		return Default.YellowColor;
}

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	if (Switch == 0)
	    return Default.LevelUpString@Default.PressLString;
	else
	    return Default.LevelUpString;
}

defaultproperties
{
     LevelUpString="You have stat points to distribute!"
     PressLString="(Press L)"
     YellowColor=(G=255,R=255,A=255)
     bIsUnique=True
     bIsConsoleMessage=False
     bFadeMessage=True
     Lifetime=1
     DrawColor=(G=160,R=0)
     StackMode=SM_Down
     PosY=0.100000
     FontSize=1
}
