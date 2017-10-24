class DruidsRPGKeysInteraction extends Interaction
		config(fpsRPG);

// Aliases for artifact switching placed in ArtifactKeyConfigs in the DruidsRPGKeyMut, and transfered via GiveItemsInv.
struct ArtifactKeyConfig
{
	Var String Alias;
	var Class<RPGArtifact> ArtifactClass;
};
var Array<ArtifactKeyConfig> ArtifactKeyConfigs;

event NotifyLevelChange()
{
	//close stats menu if it's open
	Master.RemoveInteraction(self);
	super.NotifyLevelChange();
}

//Detect pressing of a key bound to one of our aliases
function bool KeyEvent(EInputKey Key, EInputAction Action, float Delta)
{

	local string tmp;
	local Pawn P;

	if (Action != IST_Press)
		return false;

	//Use console commands to get the name of the numeric Key, and then the alias bound to that keyname
	tmp = ViewportOwner.Actor.ConsoleCommand("KEYNAME"@Key);
	tmp = ViewportOwner.Actor.ConsoleCommand("KEYBINDING"@tmp);

	if (ViewportOwner.Actor.Pawn != None)
	{
		P = ViewportOwner.Actor.Pawn;
		//If it's our alias (which doesn't actually exist), then act on it
		if (tmp ~= "DropHealth" ) 
		{
			class'GiveItemsInv'.static.DropHealth(P);
			return true;
		}
		if (tmp ~= "DropAdrenaline" ) 
		{
			class'GiveItemsInv'.static.DropAdrenaline(P);
			return true;
		}
	}
	//Don't care about this event, pass it on for further processing
	return false;
}

exec function SelectTriple()
{
	SelectThisArtifact("SelectTriple");
}

exec function SelectGlobe()
{
	SelectThisArtifact("SelectGlobe");
}

exec function SelectMWM()
{
	SelectThisArtifact("SelectMWM");
}

exec function SelectDouble()
{
	SelectThisArtifact("SelectDouble");
}

exec function SelectMax()
{
	SelectThisArtifact("SelectMax");
}

exec function SelectPlusOne()
{
	SelectThisArtifact("SelectPlusOne");
}

exec function SelectBolt()
{
	SelectThisArtifact("SelectBolt");
}

exec function SelectRepulsion()
{
	SelectThisArtifact("SelectRepulsion");
}

exec function SelectFreezeBomb()
{
	SelectThisArtifact("SelectFreezeBomb");
}

exec function SelectPoisonBlast()
{
	SelectThisArtifact("SelectPoisonBlast");
}

exec function SelectMegaBlast()
{
	SelectThisArtifact("SelectMegaBlast");
}

exec function SelectHealingBlast()
{
	SelectThisArtifact("SelectHealingBlast");
}

exec function SelectMedic()
{
	SelectThisArtifact("SelectMedic");
}

exec function SelectFlight()
{
	SelectThisArtifact("SelectFlight");
}

exec function SelectMagnet()
{
	SelectThisArtifact("SelectMagnet");
}

exec function SelectTeleport()
{
	SelectThisArtifact("SelectTeleport");
}

exec function SelectBeam()
{
	SelectThisArtifact("SelectBeam");
}

exec function SelectRod()
{
	SelectThisArtifact("SelectRod");
}

exec function SelectSphereInv()
{
	SelectThisArtifact("SelectSphereInv");
}

exec function SelectSphereHeal()
{
	SelectThisArtifact("SelectSphereHeal");
}

exec function SelectSphereDamage()
{
	SelectThisArtifact("SelectSphereDamage");
}

exec function SelectRemoteDamage()
{
	SelectThisArtifact("SelectRemoteDamage");
}

exec function SelectRemoteInv()
{
	SelectThisArtifact("SelectRemoteInv");
}

exec function SelectRemoteMax()
{
	SelectThisArtifact("SelectRemoteMax");
}

exec function SelectShieldBlast()
{
	SelectThisArtifact("SelectShieldBlast");
}

function string GetSummonFriendlyName(Inventory Inv)
{
	// if this inventory item is a monster or turret etc, return the FriendlyName
	if (DruidMonsterMasterArtifactMonsterSummon(Inv) != None)
	{
		// its a monster summoning artifact
		return DruidMonsterMasterArtifactMonsterSummon(Inv).FriendlyName;
	}

	if (Summonifact(Inv) != None)
	{
		// its a building/turret/vehicle summoning artifact
		return Summonifact(Inv).FriendlyName;
	}

	return "";	//?
}

function SelectThisArtifact (string ArtifactAlias)
{
	local class<RPGArtifact> ThisArtifactClass;
	local class<RPGArtifact> InitialArtifactClass;
	local int Count;
	local Inventory Inv, StartInv;
	local Pawn P;
	local int i;
	local bool GoneRound;
	local String InitialFriendlyName;
	local String curFriendlyName;

	P = ViewportOwner.Actor.Pawn;
	// first find the exact class we are looking for
	ThisArtifactClass = None;
	for (i = 0; i < ArtifactKeyConfigs.length; i++)
	{
		if (ArtifactKeyConfigs[i].Alias == ArtifactAlias) 
		{
			ThisArtifactClass = ArtifactKeyConfigs[i].ArtifactClass;
			i = ArtifactKeyConfigs.length;
		}
	}
	if (ThisArtifactClass == None)
		return;		// not configured in, so don't use

	// now it would be nice to just step through the artifacts using NextItem() until we get to the required one
	// however, the server responds too slowly.
	// so, we find where we are in the inventory. Find how many more artifacts we have to step over
	// and issue that many NextItem requests. Eventually the server catches up with us.

	InitialArtifactClass = None;

	if (P.SelectedItem == None)
	{
		P.NextItem();
		InitialArtifactClass = class<RPGArtifact>(P.Inventory.Class);
		// it would be nice just to compare the class.
		// however with monsters and construction artifacts we also need to check it is the correct one
		// because there are many artifacts with the same class
		InitialFriendlyName = GetSummonFriendlyName(P.Inventory);
	}
	else
	{
		InitialArtifactClass = class<RPGArtifact>(P.SelectedItem.class);
		InitialFriendlyName = GetSummonFriendlyName(P.SelectedItem);
	}

	if ((InitialArtifactClass != None) && (InitialArtifactClass == ThisArtifactClass ))
	{
		return;
	}

	// first find current item in inventory
	Count = 0;
	for( Inv=P.Inventory; Inv!=None && Count < 500; Inv=Inv.Inventory )
	{
		if ( Inv.class == InitialArtifactClass )
		{
			if (InitialFriendlyName == GetSummonFriendlyName(Inv))	// got the correct one
			{
				StartInv = Inv;
				Count = 501;
			}
		}
		Count++;
	}
	if (count<501)
	{
		// didn't find it. Start at beginning.
		StartInv=P.Inventory;
	}
	if (StartInv == None)
	{
		// don't know what we do here
		return;
	}
	// now step through until we get to the one we want
	Count = 0;
	GoneRound = false;
	P.NextItem();	// for the Inv=StartInv.Inventory step
	for( Inv=StartInv.Inventory; Count < 500; Inv=Inv.Inventory )
	{
		if (Inv == None)
		{
			Inv=P.Inventory;	//loop back to beginning again
			GoneRound = true;
		}

		curFriendlyName = GetSummonFriendlyName(Inv);
		if ( Inv.class == ThisArtifactClass)
		{
			return;
		}
		else if ( Inv.class == InitialArtifactClass && InitialFriendlyName == curFriendlyName && GoneRound)
		{
			return;			// got back to start again, so mustn't have it
		}
		else if (RPGArtifact(Inv) != None)
		{
			// its an artifact, so need to skip
			P.NextItem();
		}
		Count++;
	}
}

defaultproperties
{
     ArtifactKeyConfigs(0)=(Alias="SelectTriple",ArtifactClass=Class'fpsRPG.DruidArtifactTripleDamage')
     bVisible=True
     bRequiresTick=True
}
