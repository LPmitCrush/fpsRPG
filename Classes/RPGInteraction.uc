//RPGInteraction - Level/stat info and creates levelup menu
//Also saves stats on level change for Listen and Standalone servers
//because on those types of games people often quit in the middle (which servers almost never do)
class RPGInteraction extends Interaction
	config(fpsRPG);

var MutfpsRPG RPGMut;
var bool bDefaultBindings, bDefaultArtifactBindings; //use default keybinds because user didn't set any
var RPGStatsInv StatsInv;
var float LastLevelMessageTime;
var config int LevelMessagePointThreshold; //player must have more than this many stat points for message to display
var Font TextFont;
var color EXPBarColor, WhiteColor, RedTeamTint, BlueTeamTint;
var localized string LevelText, StatsMenuText, ArtifactText;

event Initialized()
{
	local EInputKey key;
	local string tmp;

	if (ViewportOwner.Actor.Level.NetMode != NM_Client)
		foreach ViewportOwner.Actor.DynamicActors(class'MutfpsRPG', RPGMut)
			break;

	//detect if user made custom binds for our aliases
	for (key = IK_None; key < IK_OEMClear; key = EInputKey(key + 1))
	{
		tmp = ViewportOwner.Actor.ConsoleCommand("KEYNAME"@Key);
		tmp = ViewportOwner.Actor.ConsoleCommand("KEYBINDING"@tmp);
		if (tmp ~= "rpgstatsmenu")
			bDefaultBindings = false;
		else if (tmp ~= "activateitem" || tmp ~= "nextitem" || tmp ~= "previtem")
			bDefaultArtifactBindings = false;
		if (!bDefaultBindings && !bDefaultArtifactBindings)
			break;
	}

	TextFont = Font(DynamicLoadObject("UT2003Fonts.jFontSmall", class'Font'));
}

//Detect pressing of a key bound to one of our aliases
//KeyType() would be more appropriate for what's done here, but Key doesn't seem to work/be set correctly for that function
//which prevents ConsoleCommand() from working on it
function bool KeyEvent(EInputKey Key, EInputAction Action, float Delta)
{
	local string tmp;

	if (Action != IST_Press)
		return false;

	//Use console commands to get the name of the numeric Key, and then the alias bound to that keyname
	if (!bDefaultBindings)
	{
		tmp = ViewportOwner.Actor.ConsoleCommand("KEYNAME"@Key);
		tmp = ViewportOwner.Actor.ConsoleCommand("KEYBINDING"@tmp);
	}

	//If it's our alias (which doesn't actually exist), then act on it
	if (tmp ~= "rpgstatsmenu" || (bDefaultBindings && Key == IK_L))
	{
		if (StatsInv == None)
			FindStatsInv();
		if (StatsInv == None)
			return false;
		//Show stat menu
		ViewportOwner.GUIController.OpenMenu("fpsRPG.RPGStatsMenu");
		RPGStatsMenu(GUIController(ViewportOwner.GUIController).TopPage()).InitFor(StatsInv);
		LevelMessagePointThreshold = StatsInv.Data.PointsAvailable;
		return true;
	}
	else if (bDefaultArtifactBindings)
	{
		if (Key == IK_U)
		{
			ViewportOwner.Actor.ActivateItem();
			return true;
		}
		else if (Key == IK_LeftBracket)
		{
			ViewportOwner.Actor.PrevItem();
			return true;
		}
		else if (Key == IK_RightBracket)
		{
			if (ViewportOwner.Actor.Pawn != None)
				ViewportOwner.Actor.Pawn.NextItem();
			return true;
		}
	}

	//Don't care about this event, pass it on for further processing
	return false;
}

//Find local player's stats inventory item
function FindStatsInv()
{
	local Inventory Inv;
	local RPGStatsInv FoundStatsInv;

	for (Inv = ViewportOwner.Actor.Inventory; Inv != None; Inv = Inv.Inventory)
	{
		StatsInv = RPGStatsInv(Inv);
		if (StatsInv != None)
			return;
		else
		{
			//atrocious hack for Jailbreak's bad code in JBTag (sets its Inventory property to itself)
			if (Inv.Inventory == Inv)
			{
				Inv.Inventory = None;
				foreach ViewportOwner.Actor.DynamicActors(class'RPGStatsInv', FoundStatsInv)
				{
					if (FoundStatsInv.Owner == ViewportOwner.Actor || FoundStatsInv.Owner == ViewportOwner.Actor.Pawn)
					{
						StatsInv = FoundStatsInv;
						Inv.Inventory = StatsInv;
						break;
					}
				}
				return;
			}
		}
	}
}

function PostRender(Canvas Canvas)
{
	local float XL, YL, XLSmall, YLSmall, EXPBarX, EXPBarY;

	if ( ViewportOwner.Actor.Pawn == None || ViewportOwner.Actor.Pawn.Health <= 0
	     || (ViewportOwner.Actor.myHud != None && ViewportOwner.Actor.myHud.bShowScoreBoard)
	     || ViewportOwner.Actor.myHud.bHideHUD )
		return;

	if (StatsInv == None)
		FindStatsInv();
	if (StatsInv == None)
		return;

	if (TextFont != None)
		Canvas.Font = TextFont;
	Canvas.FontScaleX = Canvas.ClipX / 1024.f;
	Canvas.FontScaleY = Canvas.ClipY / 768.f;
	Canvas.TextSize(LevelText@StatsInv.Data.Level, XL, YL);

	// increase size of the display if necessary for really high levels
	XL = FMax(XL + 9.f * Canvas.FontScaleX, 135.f * Canvas.FontScaleX);
	Canvas.Style = 5;
	Canvas.DrawColor = EXPBarColor;
	EXPBarX = Canvas.ClipX - XL - 1.f;
	EXPBarY = Canvas.ClipY * 0.75 - YL * 3.75;
	Canvas.SetPos(EXPBarX, EXPBarY);
	Canvas.DrawTile(Material'InterfaceContent.Hud.SkinA', XL * StatsInv.Data.Experience / StatsInv.Data.NeededExp, 15.0 * Canvas.FontScaleY, 836, 454, -386 * StatsInv.Data.Experience / StatsInv.Data.NeededExp, 36);
	if ( ViewportOwner.Actor.PlayerReplicationInfo == None || ViewportOwner.Actor.PlayerReplicationInfo.Team == None
	     || ViewportOwner.Actor.PlayerReplicationInfo.Team.TeamIndex != 0 )
		Canvas.DrawColor = BlueTeamTint;
	else
		Canvas.DrawColor = RedTeamTint;
	Canvas.SetPos(EXPBarX, EXPBarY);
	Canvas.DrawTile(Material'InterfaceContent.Hud.SkinA', XL, 15.0 * Canvas.FontScaleY, 836, 454, -386, 36);
	Canvas.DrawColor = WhiteColor;
	Canvas.SetPos(EXPBarX, EXPBarY);
	Canvas.DrawTile(Material'InterfaceContent.Hud.SkinA', XL, 16.0 * Canvas.FontScaleY, 836, 415, -386, 38);

	Canvas.Style = 2;
	Canvas.DrawColor = WhiteColor;
	Canvas.SetPos(EXPBarX + 9.f * Canvas.FontScaleX, Canvas.ClipY * 0.75 - YL * 5.0);
	Canvas.DrawText(LevelText@StatsInv.Data.Level);
	Canvas.FontScaleX *= 0.75;
	Canvas.FontScaleY *= 0.75;
	Canvas.TextSize(StatsInv.Data.Experience$"/"$StatsInv.Data.NeededExp, XLSmall, YLSmall);
	Canvas.SetPos(Canvas.ClipX - XL * 0.5 - XLSmall * 0.5, Canvas.ClipY * 0.75 - YL * 3.75 + 12.5 * Canvas.FontScaleY - YLSmall * 0.5);
	Canvas.DrawText(StatsInv.Data.Experience$"/"$StatsInv.Data.NeededExp);
	Canvas.FontScaleX *= 1.33333;
	Canvas.FontScaleY *= 1.33333;

	if (bDefaultBindings)
	{
		Canvas.TextSize(StatsMenuText, XL, YL);
		Canvas.SetPos(Canvas.ClipX - XL - 1, Canvas.ClipY * 0.75 - YL * 1.25);
		Canvas.DrawText(StatsMenuText);
		if (StatsInv.Data.PointsAvailable > LevelMessagePointThreshold && ViewportOwner.Actor.Level.TimeSeconds >= LastLevelMessageTime + 1.0)
		{
			ViewportOwner.Actor.ReceiveLocalizedMessage(class'LevelUpHUDMessage', 0);
			LastLevelMessageTime = ViewportOwner.Actor.Level.TimeSeconds;
		}
		else if (StatsInv.Data.PointsAvailable < LevelMessagePointThreshold)
			LevelMessagePointThreshold = StatsInv.Data.PointsAvailable;
	}
	else if (StatsInv.Data.PointsAvailable > LevelMessagePointThreshold && ViewportOwner.Actor.Level.TimeSeconds >= LastLevelMessageTime + 1.0)
	{
		ViewportOwner.Actor.ReceiveLocalizedMessage(class'LevelUpHUDMessage', 1);
		LastLevelMessageTime = ViewportOwner.Actor.Level.TimeSeconds;
	}
	else if (StatsInv.Data.PointsAvailable < LevelMessagePointThreshold)
		LevelMessagePointThreshold = StatsInv.Data.PointsAvailable;

	if (RPGArtifact(ViewportOwner.Actor.Pawn.SelectedItem) != None)
	{
		//Draw Artifact HUD info
		Canvas.SetPos(0, Canvas.ClipY * 0.75 - YL * 5.0);
		Canvas.DrawText(ViewportOwner.Actor.Pawn.SelectedItem.ItemName);
		if (ViewportOwner.Actor.Pawn.SelectedItem.IconMaterial != None)
		{
			Canvas.SetPos(0, Canvas.ClipY * 0.75 - YL * 3.75);
			Canvas.DrawTile(ViewportOwner.Actor.Pawn.SelectedItem.IconMaterial, YL * 2, YL * 2, 0, 0, ViewportOwner.Actor.Pawn.SelectedItem.IconMaterial.MaterialUSize(), ViewportOwner.Actor.Pawn.SelectedItem.IconMaterial.MaterialVSize());
		}
		if (bDefaultArtifactBindings)
		{
			Canvas.SetPos(0, Canvas.ClipY * 0.75 - YL * 1.25);
			Canvas.DrawText(ArtifactText);
		}
	}

	Canvas.FontScaleX = Canvas.default.FontScaleX;
	Canvas.FontScaleY = Canvas.default.FontScaleY;
}

event NotifyLevelChange()
{
	//close stats menu if it's open
	FindStatsInv();
	if (StatsInv != None && StatsInv.StatsMenu != None)
		StatsInv.StatsMenu.CloseClick(None);
	StatsInv = None;

	//Save player data (standalone/listen servers only)
	if (RPGMut != None)
	{
		RPGMut.SaveData();
		RPGMut = None;
	}

	SaveConfig();
	Master.RemoveInteraction(self);
}

defaultproperties
{
     bDefaultBindings=True
     bDefaultArtifactBindings=True
     EXPBarColor=(B=128,G=255,R=128,A=255)
     WhiteColor=(B=255,G=255,R=255,A=255)
     RedTeamTint=(R=100,A=100)
     BlueTeamTint=(B=102,G=66,R=37,A=150)
     LevelText="Level:"
     StatsMenuText="Press L for stats/levelup menu"
     ArtifactText="U to use, brackets to switch"
     bVisible=True
}
