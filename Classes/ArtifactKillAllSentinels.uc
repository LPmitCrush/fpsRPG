class ArtifactKillAllSentinels extends RPGArtifact;

function Activate()
{
	local EngineerPointsInv Inv;

	Inv = class'AbilityLoadedEngineer'.static.GetEngInv(Instigator);
	if(Inv != None)
		Inv.KillAllSentinels();

	bActive = false;
	GotoState('');
	return;
}

exec function TossArtifact()
{
	//do nothing. This artifact cant be thrown
}

function PostBeginPlay()
{
	super.PostBeginPlay();
	disable('Tick');
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
     MinActivationTime=0.000000
     IconMaterial=Texture'fpsRPGTex.Icons.KillTurretIcon'
     ItemName="Kill All Summoned Sentinels"
}
