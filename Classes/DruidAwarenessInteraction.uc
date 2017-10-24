//This draws the health bars for the Awareness ability
class DruidAwarenessInteraction extends Interaction;

var DruidAwarenessEnemyList EnemyList;
var Material HealthBarMaterial;
var float BarUSize, BarVSize;

var int AbilityLevel;

event Initialized()
{
	BarUSize = HealthBarMaterial.MaterialUSize();
	BarVSize = HealthBarMaterial.MaterialVSize();
	EnemyList = ViewportOwner.Actor.Spawn(class'DruidAwarenessEnemyList');
}

function PreRender(Canvas Canvas)
{
	local int i;
	local float Dist, XScale, YScale, HealthScale, ScreenX, HealthMax;
	local vector BarLoc, CameraLocation, X, Y, Z;
	local rotator CameraRotation;
	local Pawn Enemy;

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

		HealthScale = Enemy.Health/Enemy.HealthMax;
 		Canvas.Style = 1;
 		if (AbilityLevel > 1)
		{
			Canvas.SetPos(BarLoc.X, BarLoc.Y);
			Canvas.DrawColor = class'HUD'.default.GreenColor;
			Canvas.DrawTile(HealthBarMaterial, BarUSize*XScale, BarVSize*YScale, 0, 0, BarUSize, BarVSize);

			if (Enemy.IsA('Monster'))
			{
				HealthMax = Enemy.HealthMax;
			}else
			{
				HealthMax = Enemy.HealthMax + 150;
			}

	 		Canvas.DrawColor.R = Clamp(Int(255.0 * 2 * (1.0 - HealthScale)), 0, 255);
	 		Canvas.DrawColor.G = Clamp(Int(255.0 * 2 * HealthScale), 0, 255);
// Enemies above their Enemy.HealthMax start getting some blue.
			Canvas.DrawColor.B = Clamp(Int(255.0 * ((Enemy.Health - Enemy.HealthMax)/150.0)), 0, 255);
		 	Canvas.DrawColor.A = 255;
// Base the max width of the bar on what we guess is their "actual max health"
// Enemy pets will mess this up so we clamp it
			Canvas.SetPos(BarLoc.X+(BarUSize*XScale*Fclamp(((Enemy.Health/HealthMax)/2), 0.0, 0.5)), BarLoc.Y);
			Canvas.DrawTile(HealthBarMaterial, BarUSize*XScale*Fclamp(1.0-(Enemy.Health/HealthMax), 0.0, 1.0), BarVSize*YScale, 0, 0, BarUSize, BarVSize);
			if (Enemy.ShieldStrength > 0 && xPawn(Enemy) != None)
			{
				Canvas.DrawColor = class'HUD'.default.GoldColor;
				YScale /= 2;
				Canvas.SetPos(BarLoc.X, BarLoc.Y - BarVSize * (YScale + 0.05));
				Canvas.DrawTile(HealthBarMaterial, BarUSize*XScale*Enemy.ShieldStrength/xPawn(Enemy).ShieldStrengthMax, BarVSize*YScale, 0, 0, BarUSize, BarVSize);
			}
		}
		else
		{
			Canvas.SetPos(BarLoc.X+(BarUSize*XScale*0.25), BarLoc.Y);
			Canvas.DrawColor.B = 0;
			Canvas.DrawColor.A = 255;
			if (HealthScale < 0.10)
			{
				Canvas.DrawColor.G = 0;
				Canvas.DrawColor.R = 200;
			}else if (HealthScale < 0.90)
			{
				Canvas.DrawColor.G = 150;
				Canvas.DrawColor.R = 150;
			}else
			{
				Canvas.DrawColor.R = 0;
				Canvas.DrawColor.G = 125;
			}
			Canvas.DrawTile(HealthBarMaterial, BarUSize*XScale*0.50, BarVSize*YScale*0.50, 0, 0, BarUSize, BarVSize);
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
