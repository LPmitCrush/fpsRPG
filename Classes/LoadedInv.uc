class LoadedInv extends Inventory;

var Name type;

var bool bGotLoadedWeapons;
var bool bGotLoadedArtifacts;
var bool bGotLoadedMonsters;
var bool bGotLoadedEngineer;

var int AbilityLevel;
var int MAbilityLevel;
var int EAbilityLevel;
var int LWAbilityLevel;
var int LAAbilityLevel;
var int LMAbilityLevel;
var int LEAbilityLevel;

var bool ProtectArtifacts;
var bool ProtectMaker;
var bool DirectMonsters;

defaultproperties
{
     bOnlyRelevantToOwner=False
     bAlwaysRelevant=True
     bReplicateInstigator=True
     RemoteRole=ROLE_DumbProxy
}
