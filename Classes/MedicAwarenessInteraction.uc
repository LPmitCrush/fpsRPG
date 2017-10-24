//This draws the health bars for the MedicAwareness ability
class MedicAwarenessInteraction extends Interaction;

var MedicAwarenessEnemyList EnemyList;
var Material HealthBarMaterial;
var float BarUSize, BarVSize;

var int AbilityLevel;

event Initialized()
{
	BarUSize = HealthBarMaterial.MaterialUSize();
	BarVSize = HealthBarMaterial.MaterialVSize();
	EnemyList = ViewportOwner.Actor.Spawn(class'MedicAwarenessEnemyList');
}

function PreRender(Canvas Canvas)
{
	local int i;
	local float Dist, XScale, YScale, ScreenX;
	local vector BarLoc, CameraLocation, X, Y, Z;
	local rotator CameraRotation;
	local Pawn Enemy;
	local float HM66, HM33, MedMax, SHMax;

	if (ViewportOwner.Actor.Pawn == None || ViewportOwner.Actor.Pawn.Health <= 0)
		return;

	for (i = 0; i < EnemyList.Enemies.length; i++)
	{
		Enemy = EnemyList.Enemies[i];
		if (Enemy == None || Enemy.Health <= 0 || (xPawn(Enemy) != None && xPawn(Enemy).bInvis))
			continue;
		Canvas.GetCameraLocation(CameraLocation, CameraRotation);
		if (Normal(Enemy.Location - CameraLocation) dot vector(CameraRotation) < 0)
			continue;
		ScreenX = Canvas.WorldToScreen(Enemy.Location).X;
		if (ScreenX < 0 || ScreenX > Canvas.ClipX)
			continue;
 		Dist = VSize(Enemy.Location - CameraLocation);
 		if (Dist > ViewportOwner.Actor.TeamBeaconMaxDist * FClamp(0.04 * Enemy.CollisionRadius, 1.0, 3.0))
 			continue;
		if (!Enemy.FastTrace(Enemy.Location + Enemy.CollisionHeight * vect(0,0,1), ViewportOwner.Actor.Pawn.Location + ViewportOwner.Actor.Pawn.EyeHeight * vect(0,0,1)))
			continue;

		GetAxes(rotator(Enemy.Location - CameraLocation), X, Y, Z);
		if (Enemy.IsA('Monster'))
		{
			BarLoc = Canvas.WorldToScreen(Enemy.Location + (Enemy.CollisionHeight * 1.25 + BarVSize / 2) * vect(0,0,1) - Enemy.CollisionRadius * Y);
		}
		else
		{
			BarLoc = Canvas.WorldToScreen(Enemy.Location + (Enemy.CollisionHeight + BarVSize / 2) * vect(0,0,1) - Enemy.CollisionRadius * Y);
		}
		XScale = (Canvas.WorldToScreen(Enemy.Location + (Enemy.CollisionHeight + BarVSize / 2) * vect(0,0,1) + Enemy.CollisionRadius * Y).X - BarLoc.X) / BarUSize;
		YScale = FMin(0.15 * XScale, 0.50);

 		Canvas.Style = 1;

		MedMax = Enemy.HealthMax + 150.0;
		HM66 = Enemy.HealthMax * 0.66;
		HM33 = Enemy.HealthMax * 0.33;
// Bah just reset it for everyone.  This *should* be everyone's SuperHealthMax.
		SHMax = Enemy.HealthMax + 99.0;

		if (AbilityLevel > 1)
		{
			Canvas.SetPos(BarLoc.X, BarLoc.Y);
// When people are ghosting, Enemy.Health way > MedMax
			if(Enemy.Health >= MedMax)
			{
				Canvas.DrawColor = class'HUD'.default.BlueColor;
				Canvas.DrawTile(HealthBarMaterial, BarUSize*XScale, BarVSize*YScale, 0, 0, BarUSize, BarVSize);
			}
			else
			{
// Make the white bar
				Canvas.DrawColor = class'HUD'.default.WhiteColor;
				Canvas.DrawTile(HealthBarMaterial, BarUSize*XScale, BarVSize*YScale, 0, 0, BarUSize, BarVSize);
				Canvas.DrawColor.A = 255;
				Canvas.DrawColor.R = Clamp(Int((1.00 - ((Enemy.Health - HM66)/(Enemy.HealthMax - HM66)))*255.0), 0, 255);
				Canvas.DrawColor.B = Clamp(Int(((Enemy.Health - Enemy.HealthMax)/(SHMax - Enemy.HealthMax))*255.0), 0, 255);
				if(Enemy.Health > Enemy.HealthMax)
				{
					Canvas.DrawColor.G = Clamp(Int((1.00 - ((Enemy.Health - SHMax)/(MedMax - SHMax)))*255.0), 0, 255);
				}else
				{
					Canvas.DrawColor.G = Clamp(Int(((Enemy.Health - HM33)/(HM66 - HM33))*255.0), 0, 255);
				}
				Canvas.SetPos(BarLoc.X+(BarUSize*XScale*((Enemy.Health/MedMax)/2)), BarLoc.Y);
				Canvas.DrawTile(HealthBarMaterial, BarUSize*XScale*(1.00 - (Enemy.Health/MedMax)), BarVSize*YScale, 0, 0, BarUSize, BarVSize);
			}
		}else
		{
			if (Enemy.Health < HM33)
			{
				Canvas.DrawColor.A = 255;
				Canvas.DrawColor.R = 200;
				Canvas.DrawColor.G = 0;
				Canvas.DrawColor.B = 0;
			}else if (Enemy.Health < HM66)
			{
				Canvas.DrawColor.A = 255;
				Canvas.DrawColor.R = 150;
				Canvas.DrawColor.G = 150;
				Canvas.DrawColor.B = 0;
			}else if (Enemy.Health < SHMax)
			{
				Canvas.DrawColor.A = 255;
				Canvas.DrawColor.R = 0;
				Canvas.DrawColor.G = 125;
				Canvas.DrawColor.B = 0;
			}else
			{
				Canvas.DrawColor.A = 255;
				Canvas.DrawColor.R = 0;
				Canvas.DrawColor.G = 0;
				Canvas.DrawColor.B = 100;
			}
			Canvas.SetPos(BarLoc.X+(BarUSize*XScale*0.25),BarLoc.Y);
			Canvas.DrawTile(HealthBarMaterial, BarUSize*XScale*0.50, BarVsize*YScale*0.50, 0, 0, BarUSize, BarVSize);
		}
	}
}

event NotifyLevelChange()
{
	EnemyList.Destroy();
	EnemyList = None;
	Master.RemoveInteraction(self);
}

defaultproperties
{
     HealthBarMaterial=Texture'Engine.WhiteSquareTexture'
     bActive=False
     bVisible=True
}
