class FM_DruidLink_Fire extends FM_LinkTurret_Fire;

function Projectile SpawnProjectile(Vector Start, Rotator Dir)
{
    local PROJ_LinkTurret_Plasma Proj;

    Start += Vector(Dir) * 10.0 * Weapon_DruidLink(Weapon).Links;
    Proj = Weapon.Spawn(class'UT2k4AssaultFull.PROJ_LinkTurret_Plasma',,, Start, Dir);
    if ( Proj != None )
    {
		Proj.Links = Weapon_DruidLink(Weapon).Links;
		Proj.LinkAdjust();
	}
    return Proj;
}

function ServerPlayFiring()
{
    if ( Weapon_DruidLink(Weapon).Links > 0 )
        FireSound = LinkedFireSound;
    else
        FireSound = default.FireSound;

    super.ServerPlayFiring();
}

function PlayFiring()
{
    if ( Weapon_DruidLink(Weapon).Links > 0 )
        FireSound = LinkedFireSound;
    else
        FireSound = default.FireSound;
    super.PlayFiring();
}

defaultproperties
{
     FireRate=0.450000
}
