class MonsterMasterInteraction extends Interaction
	config(fpsRPG);

var MonsterPointsInv MInv;
var Font TextFont;
var color MPBarColor, WhiteColor, RedTeamTint, BlueTeamTint;
var localized string MPText, AdrenalineText, MonsterPointsText;

event Initialized()
{
	TextFont = Font(DynamicLoadObject("UT2003Fonts.jFontSmall", class'Font'));
	super.Initialized();
}

//Find local player's stats inventory item
function FindMPInv()
{
	local Inventory Inv;
	local MonsterPointsInv FoundMInv;

	for (Inv = ViewportOwner.Actor.Inventory; Inv != None; Inv = Inv.Inventory)
	{
		FoundMInv = MonsterPointsInv(Inv);
		if (FoundMInv != None)
		{
			if (FoundMInv.Owner == ViewportOwner.Actor || FoundMInv.Owner == ViewportOwner.Actor.Pawn)
				MInv = FoundMInv;
			return;
		}
		else
		{
			//atrocious hack for Jailbreak's bad code in JBTag (sets its Inventory property to itself)
			if (Inv.Inventory == Inv)
			{
				Inv.Inventory = None;
				foreach ViewportOwner.Actor.DynamicActors(class'MonsterPointsInv', FoundMInv)
				{
					if (FoundMInv.Owner == ViewportOwner.Actor || FoundMInv.Owner == ViewportOwner.Actor.Pawn)
					{
						MInv = FoundMInv;
						Inv.Inventory = MInv;
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
	local float XL, YL, XLSmall, YLSmall, MPBarX, MPBarY;
	local DruidMonsterMasterArtifactMonsterSummon DMMAMS;

	if ( ViewportOwner == None || ViewportOwner.Actor == None || ViewportOwner.Actor.Pawn == None || ViewportOwner.Actor.Pawn.Health <= 0
	     || (ViewportOwner.Actor.myHud != None && ViewportOwner.Actor.myHud.bShowScoreBoard)
	     || ViewportOwner.Actor.myHud.bHideHUD )
		return;

	if (MInv == None)
		FindMPInv();
	if (MInv == None)
		return;
// TotalMonsterPoints not replicated to spectators.  You'd hope MInv would not spawn
// an interaction at all, but worst case they'll be detected here.
	if(MInv.TotalMonsterPoints == 0)
		return;

	if (TextFont != None)
		Canvas.Font = TextFont;
	Canvas.FontScaleX = Canvas.ClipX / 1024.f;
	Canvas.FontScaleY = Canvas.ClipY / 768.f;

	Canvas.FontScaleX *= 0.75; //make it smaller
	Canvas.FontScaleY *= 0.75;

	Canvas.TextSize(MPText, XL, YL);

	// increase size of the display if necessary for really high levels
	XL = FMax(XL + 9.f * Canvas.FontScaleX, 135.f * Canvas.FontScaleX);

	Canvas.Style = 5;
	Canvas.DrawColor = MPBarColor;
	MPBarX = Canvas.ClipX - XL - 1.f;
	MPBarY = Canvas.ClipY * 0.75 - YL * 2.5; //used to be 1.75. 
	Canvas.SetPos(MPBarX, MPBarY);
	Canvas.DrawTile(Material'InterfaceContent.Hud.SkinA', XL * MInv.UsedMonsterPoints / MInv.TotalMonsterPoints, 15.0 * Canvas.FontScaleY * 1.25, 836, 454, -386 * MInv.UsedMonsterPoints / MInv.TotalMonsterPoints, 36);
	if ( ViewportOwner.Actor.PlayerReplicationInfo == None || ViewportOwner.Actor.PlayerReplicationInfo.Team == None
	     || ViewportOwner.Actor.PlayerReplicationInfo.Team.TeamIndex != 0 )
		Canvas.DrawColor = BlueTeamTint;
	else
		Canvas.DrawColor = RedTeamTint;
	Canvas.SetPos(MPBarX, MPBarY);
	Canvas.DrawTile(Material'InterfaceContent.Hud.SkinA', XL, 15.0 * Canvas.FontScaleY * 1.25, 836, 454, -386, 36);
	Canvas.DrawColor = WhiteColor;
	Canvas.SetPos(MPBarX, MPBarY);
	Canvas.DrawTile(Material'InterfaceContent.Hud.SkinA', XL, 16.0 * Canvas.FontScaleY * 1.25, 836, 415, -386, 38);

	Canvas.Style = 2;
	Canvas.DrawColor = WhiteColor;

	Canvas.SetPos(MPBarX + 9.f * Canvas.FontScaleX, Canvas.ClipY * 0.75 - YL * 3.7); //used to be 3
	Canvas.DrawText(MPText);

	Canvas.TextSize(MInv.UsedMonsterPoints$"/"$MInv.TotalMonsterPoints, XLSmall, YLSmall);
	Canvas.SetPos(Canvas.ClipX - XL * 0.5 - XLSmall * 0.5, Canvas.ClipY * 0.75 - YL * 2.5 + 12.5 * Canvas.FontScaleY - YLSmall * 0.5); //used to be 3.75
	Canvas.DrawText(MInv.UsedMonsterPoints$"/"$MInv.TotalMonsterPoints);

	DMMAMS = DruidMonsterMasterArtifactMonsterSummon(ViewportOwner.Actor.Pawn.SelectedItem);
	if (DMMAMS != None)
	{
		//Draw Monster Master "Artifact" HUD info

		Canvas.FontScaleX = Canvas.default.FontScaleX * 0.80;
		Canvas.FontScaleY = Canvas.default.FontScaleY * 0.80;

		Canvas.SetPos(10, Canvas.ClipY * 0.75 - YL * 7.65);
		Canvas.DrawText(DMMAMS.FriendlyName);
		Canvas.SetPos(10, Canvas.ClipY * 0.75 - YL * 6.75);
		Canvas.DrawText(AdrenalineText $ DMMAMS.Adrenaline);
		Canvas.SetPos(10, Canvas.ClipY * 0.75 - YL * 5.85);
		Canvas.DrawText(MonsterPointsText $ DMMAMS.MonsterPoints);
	}

	Canvas.FontScaleX = Canvas.default.FontScaleX;
	Canvas.FontScaleY = Canvas.default.FontScaleY;
	super.PostRender(Canvas);
}

event NotifyLevelChange()
{
	//close stats menu if it's open
	Master.RemoveInteraction(self);
	MInv.Interaction = None;
	super.NotifyLevelChange();
}

defaultproperties
{
     MPBarColor=(B=128,G=255,R=128,A=255)
     WhiteColor=(B=255,G=255,R=255,A=255)
     RedTeamTint=(R=100,A=100)
     BlueTeamTint=(B=102,G=66,R=37,A=150)
     MPText="Monster Points:"
     AdrenalineText="Adrenaline:"
     MonsterPointsText="Monster Points:"
     bVisible=True
}
