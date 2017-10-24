class EngineerInteraction extends Interaction
	config(fpsRPG);

var EngineerPointsInv EInv;
var Font TextFont;
var color WhiteColor, RedColor, GreenColor;
var localized string PointsText;
var int dummyi;

event Initialized()
{
	TextFont = Font(DynamicLoadObject("UT2003Fonts.jFontSmall", class'Font'));
	super.Initialized();
}

//Find local player's stats inventory item
function FindEPInv()
{
	local Inventory Inv;
	local EngineerPointsInv FoundEInv;

	for (Inv = ViewportOwner.Actor.Inventory; Inv != None; Inv = Inv.Inventory)
	{
		FoundEInv = EngineerPointsInv(Inv);
		if (FoundEInv != None)
		{
			if (FoundEInv.Owner == ViewportOwner.Actor || FoundEInv.Owner == ViewportOwner.Actor.Pawn)
				EInv = FoundEInv;
			return;
		}
		else
		{
			//atrocious hack for Jailbreak's bad code in JBTag (sets its Inventory property to itself)
			if (Inv.Inventory == Inv)
			{
				Inv.Inventory = None;
				foreach ViewportOwner.Actor.DynamicActors(class'EngineerPointsInv', FoundEInv)
				{
					if (FoundEInv.Owner == ViewportOwner.Actor || FoundEInv.Owner == ViewportOwner.Actor.Pawn)
					{
						EInv = FoundEInv;
						Inv.Inventory = EInv;
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
	local float XL, YL;
	local Summonifact Sf;
	local int UsedPoints, TotalPoints, PointsLeft;
	local string pText;
	local int iNumHealers;

	if ( ViewportOwner == None || ViewportOwner.Actor == None || ViewportOwner.Actor.Pawn == None || ViewportOwner.Actor.Pawn.Health <= 0
	     || (ViewportOwner.Actor.myHud != None && ViewportOwner.Actor.myHud.bShowScoreBoard)
	     || ViewportOwner.Actor.myHud.bHideHUD )
		return;

	if (EInv == None)
		FindEPInv();
	if (EInv == None)
		return;

	TotalPoints = EInv.TotalSentinelPoints+EInv.TotalTurretPoints+EInv.TotalVehiclePoints+EInv.TotalBuildingPoints;
// Spectators shouldn't get the Total/UsedXObjPoints replicated now, so
// this should detect them appropriately.  Ideally, EInv won't be found
// either, but I don't know if I trust that - so this for sure will
// result in former spectators not seeing the display on spawn.
	if(TotalPoints == 0)
		return;

	if (TextFont != None)
		Canvas.Font = TextFont;
	Canvas.FontScaleX = Canvas.ClipX / 1024.f;
	Canvas.FontScaleY = Canvas.ClipY / 768.f;

	pText = "200";
	Canvas.TextSize(pText, XL, YL);

	Canvas.FontScaleX *= 2.0; //make it larger
	Canvas.FontScaleY *= 2.0;

	Canvas.Style = 2;
	Canvas.DrawColor = WhiteColor;

	if (EInv.GetRecoveryTime() >0)
	{
		Canvas.SetPos(XL+11, Canvas.ClipY * 0.75 - YL * 3.6); 
		pText = String(EInv.GetRecoveryTime());
		Canvas.DrawText(pText);
	}

	Sf = Summonifact(ViewportOwner.Actor.Pawn.SelectedItem);
	if (Sf != None)
	{
		//Draw summoning item "Artifact" HUD info

		Canvas.FontScaleX = Canvas.default.FontScaleX * 0.80;
		Canvas.FontScaleY = Canvas.default.FontScaleY * 0.80;

		Canvas.SetPos(3, Canvas.ClipY * 0.75 - YL * 5.0);
		Canvas.DrawText(Sf.FriendlyName);

		UsedPoints=0;
		TotalPoints=0;
		pText = "";
		Canvas.DrawColor = GreenColor;
		if (DruidVehicleSummon(sf) != None)
		{
			UsedPoints=EInv.UsedVehiclePoints;
			TotalPoints=EInv.TotalVehiclePoints;
			if (!EInv.AllowedAnotherVehicle())
				Canvas.DrawColor = RedColor;
		}
		else if (DruidTurretSummon(sf) != None)
		{
			UsedPoints=EInv.UsedTurretPoints;
			TotalPoints=EInv.TotalTurretPoints;
			if (!EInv.AllowedAnotherTurret())
				Canvas.DrawColor = RedColor;
		}
		else if (DruidBuildingSummon(sf) != None)
		{
			UsedPoints=EInv.UsedBuildingPoints;
			TotalPoints=EInv.TotalBuildingPoints;
			if (!EInv.AllowedAnotherBuilding())
				Canvas.DrawColor = RedColor;
		}
		else if (DruidSentinelSummon(sf) != None)
		{
			UsedPoints=EInv.UsedSentinelPoints;
			TotalPoints=EInv.TotalSentinelPoints;
			if (!EInv.AllowedAnotherSentinel())
				Canvas.DrawColor = RedColor;
		}
		PointsLeft = TotalPoints-UsedPoints;
		Canvas.SetPos(4, Canvas.ClipY * 0.75 - YL * 1.3);
		if (EInv.GetRecoveryTime() > 0 || Sf.Points > PointsLeft)
			Canvas.DrawColor = RedColor;
		Canvas.DrawText(PointsText $ Sf.Points $ "/" $ PointsLeft);
	}

	Canvas.FontScaleX = Canvas.default.FontScaleX;
	Canvas.FontScaleY = Canvas.default.FontScaleY;
	// now lets check if we are linked in a turret
	iNumHealers = -1;
	if (DruidBallTurret(ViewportOwner.Actor.Pawn) != None)
		iNumHealers = DruidBallTurret(ViewportOwner.Actor.Pawn).NumHealers;
	else if (DruidEnergyTurret(ViewportOwner.Actor.Pawn) != None)
		iNumHealers = DruidEnergyTurret(ViewportOwner.Actor.Pawn).NumHealers;
	else if (DruidMinigunTurret(ViewportOwner.Actor.Pawn) != None)
		iNumHealers = DruidMinigunTurret(ViewportOwner.Actor.Pawn).NumHealers;
	if (iNumHealers > 0)
	{
		// first draw the links
		Canvas.SetPos(2, Canvas.ClipY * 0.75 - YL * 7.6);
		Canvas.DrawTile(Material'HudContent.Generic.fbLinks', 64, 32, 0, 0, 128, 64);
		
		// then the number linked
		pText = String(iNumHealers);
		Canvas.SetPos(30, Canvas.ClipY * 0.75 - YL * 7.1);
		Canvas.DrawColor = GreenColor;
		Canvas.DrawText(PText);	
	}
	
	Canvas.DrawColor = WhiteColor;
	super.PostRender(Canvas);
}

event NotifyLevelChange()
{
	//close stats menu if it's open
	Master.RemoveInteraction(self);
	EInv.Interaction = None;
	super.NotifyLevelChange();
}

defaultproperties
{
     WhiteColor=(B=255,G=255,R=255,A=255)
     RedColor=(B=159,G=159,R=255,A=159)
     GreenColor=(B=159,G=255,R=159,A=159)
     PointsText="Points:"
     bVisible=True
}
