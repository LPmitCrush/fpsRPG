//This draws the shield bars for the EngineerAwareness ability
class EngineerAwarenessInteraction extends Interaction;

var EngineerAwarenessTeamList EngTeamList;
var Material HealthBarMaterial;
var float BarUSize, BarVSize;

var int AbilityLevel;

event Initialized()
{
	BarUSize = HealthBarMaterial.MaterialUSize();
	BarVSize = HealthBarMaterial.MaterialVSize();
	EngTeamList = ViewportOwner.Actor.Spawn(class'EngineerAwarenessTeamList');
}

function PreRender(Canvas Canvas)
{
	local int i;
	local float Dist, XScale, YScale, ScreenX;
	local vector BarLoc, CameraLocation, X, Y, Z;
	local rotator CameraRotation;
	local Pawn P;
	local float ShieldMax, CurShield;

	if (ViewportOwner.Actor.Pawn == None || ViewportOwner.Actor.Pawn.Health <= 0)
		return;

	for (i = 0; i < EngTeamList.TeamPawns.length; i++)
	{
		P = EngTeamList.TeamPawns[i];
		if (P == None || P.Health <= 0 || (xPawn(P) != None && xPawn(P).bInvis))
			continue;
		Canvas.GetCameraLocation(CameraLocation, CameraRotation);
		if (Normal(P.Location - CameraLocation) dot vector(CameraRotation) < 0)
			continue;
		ScreenX = Canvas.WorldToScreen(P.Location).X;
		if (ScreenX < 0 || ScreenX > Canvas.ClipX)
			continue;
 		Dist = VSize(P.Location - CameraLocation);
 		if (Dist > ViewportOwner.Actor.TeamBeaconMaxDist * FClamp(0.04 * P.CollisionRadius, 1.0, 3.0))
 			continue;
		if (!P.FastTrace(P.Location + P.CollisionHeight * vect(0,0,1), ViewportOwner.Actor.Pawn.Location + ViewportOwner.Actor.Pawn.EyeHeight * vect(0,0,1)))
			continue;

		GetAxes(rotator(P.Location - CameraLocation), X, Y, Z);
		if (P.IsA('Monster'))
		{
			BarLoc = Canvas.WorldToScreen(P.Location + (P.CollisionHeight * 1.25 + BarVSize / 2) * vect(0,0,1) - P.CollisionRadius * Y);
		}
		else
		{
			BarLoc = Canvas.WorldToScreen(P.Location + (P.CollisionHeight + BarVSize / 2) * vect(0,0,1) - P.CollisionRadius * Y);
		}
		XScale = (Canvas.WorldToScreen(P.Location + (P.CollisionHeight + BarVSize / 2) * vect(0,0,1) + P.CollisionRadius * Y).X - BarLoc.X) / BarUSize;
		YScale = FMin(0.15 * XScale, 0.20);

 		Canvas.Style = 1;

		CurShield = P.ShieldStrength;
		if (xPawn(P) != None)
			ShieldMax = xPawn(P).ShieldStrengthMax;
		else
			ShieldMax = 150;	// unfortunately ShieldStrengthMax not replicated, so default to 150
		ShieldMax = max(ShieldMax,CurShield);

		if (ShieldMax <= 0)
			continue;
		if (CurShield <0)
			CurShield = 0;
		if (CurShield > ShieldMax)
			CurShield = ShieldMax;

		Canvas.SetPos(BarLoc.X, BarLoc.Y);
		// Make the white bar
		Canvas.DrawColor = class'HUD'.default.WhiteColor;
		if(CurShield >= ShieldMax)
		{	// want bright yellow as the shield is full
			Canvas.DrawColor.A = 255;
			Canvas.DrawColor.B = 0;
			Canvas.DrawColor.G = 255;
			Canvas.DrawColor.R = 255;
		}
		Canvas.DrawTile(HealthBarMaterial, BarUSize*XScale, BarVSize*YScale, 0, 0, BarUSize, BarVSize);
		Canvas.DrawColor.A = 255;
		Canvas.DrawColor.B = 0;

		// want an orange color, with less red as it gets healthier
		Canvas.DrawColor.R = 128;
		Canvas.DrawColor.G = Clamp(Int(128*CurShield/ShieldMax), 0, 255);

		Canvas.SetPos(BarLoc.X+(BarUSize*XScale*((CurShield/ShieldMax)/2)), BarLoc.Y);
		Canvas.DrawTile(HealthBarMaterial, BarUSize*XScale*(1.00 - (CurShield/ShieldMax)), BarVSize*YScale, 0, 0, BarUSize, BarVSize);
	}
}

event NotifyLevelChange()
{
	EngTeamList.Destroy();
	EngTeamList = None;
	Master.RemoveInteraction(self);
}

defaultproperties
{
     HealthBarMaterial=Texture'Engine.WhiteSquareTexture'
     bActive=False
     bVisible=True
}
