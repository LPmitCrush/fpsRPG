class ArtifactMakeSuperHealer extends DruidArtifactMakeMagicWeapon;

var int AbilityLevel;
var int MaxHealth;
var float EXPMultiplier;

function int getMaxHealth()
{
	if(MaxHealth == 0)
		return class'RW_Healer'.default.MaxHealth;
	else
		return MaxHealth;
}

function float getEXPMultiplier()
{
	if(EXPMultiplier == 0.0)
		return class'RW_Healer'.default.EXPMultiplier;
	else
		return EXPMultiplier;
}

function int getCost()
{
	return 10;
}

function bool shouldBreak()
{
	return false;
}

function constructionFinished(RPGWeapon result)
{
	local RW_SuperHealer SuperHealer;

	if(RW_SuperHealer(result) != None)
	{
		SuperHealer = RW_SuperHealer(Instigator.FindInventoryType(class'RW_SuperHealer'));
		if(SuperHealer != None)
		{
			SuperHealer.AMSH = None;
			if(SuperHealer.ModifiedWeapon != Result.ModifiedWeapon)
				SuperHealer.Destroy();
		}
		RW_SuperHealer(result).AMSH = Self;
	}
}

function class<RPGWeapon> GetRandomWeaponModifier(class<Weapon> WeaponType, Pawn Other)
{
	if(class'RW_SuperHealer'.static.AllowedFor(WeaponType, Other))
		return class'RW_SuperHealer';
	return class'RPGWeapon';
}

exec function TossArtifact()
{
	//do nothing. This artifact cant be thrown
}

function DropFrom(vector StartLocation)
{
	if (bActive)
		GotoState('');
	bActive = false;

	Destroy();
	Instigator.NextItem();
}

defaultproperties
{
     IconMaterial=Combiner'XGameTextures.SuperPickups.DOMPabBc'
     ItemName="Medic Weapon Maker"
}
