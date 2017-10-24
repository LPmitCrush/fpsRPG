class DruidArtifactTripleDamage extends ArtifactTripleDamage
	config(fpsRPG);

var config Array< class<RPGWeapon> > Invalid;

function Activate()
{
	Local DruidDoubleModifier dbl;
	dbl = DruidDoubleModifier(Instigator.findInventoryType(class'DruidDoubleModifier'));
	if(dbl != None && dbl.bActive)
		return;
	
	if (!bActive && Instigator.HasUDamage())
		return;

	Super.Activate();
}

state Activated
{
	function Tick(float deltatime)
	{
		local int i;
		super.tick(deltatime);
		if(Instigator == None || RPGWeapon(Instigator.Weapon) == None )
		{
			return;
		}
		for(i = 0; i < Invalid.length; i++)
		{
			if(Instigator.Weapon.class == Invalid[i])
			{
				Instigator.ReceiveLocalizedMessage(MessageClass, 2906, None, None, Class);
				GotoState('');
				bActive=false;
				return;
			}
		}
	}
}

static function string GetLocalString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2)
{
	if (Switch == 2906)
		return "Unable to use Triple Damage on this magic weapon type.";
	else 
		return(super.getLocalString(switch, RelatedPRI_1, RelatedPRI_2));
}

defaultproperties
{
     Invalid(0)=Class'fpsRPG.RW_Vorpal'
     Invalid(1)=Class'fpsRPG.RW_Rage'
     Invalid(2)=Class'fpsRPG.RW_EnhancedPiercing'
     CostPerSec=10
     PickupClass=Class'fpsRPG.DruidArtifactTripleDamagePickup'
}
