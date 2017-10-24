Class RPGPlayerLevelsMenu extends GUIPage;



var bool bClean;

var GUIScrollTextBox MyScrollText;
var GUIButton CloseButton;
var localized string DefaultText;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(MyController, MyOwner);

	MyScrollText = GUIScrollTextBox(Controls[2]);
	bClean = true;
	MyScrollText.SetContent(DefaultText);
}

function bool CloseClick(GUIComponent Sender)
{
	Controller.CloseMenu(false);

	return true;
}

function ProcessPlayerLevel(string PlayerString)
{
	if (PlayerString == "")
	{
		bClean = true;
		MyScrollText.SetContent(DefaultText);
	}
	else
	{
		if (bClean)
			MyScrollText.SetContent(PlayerString);
		else
			MyScrollText.AddText(PlayerString);

		bClean = false;
	}
}

defaultproperties
{
     DefaultText="Receiving Player Levels from Server..."
     bRenderWorld=True
     bAllowedAsLast=True
     Begin Object Class=FloatingImage Name=FloatingFrameBackground
         Image=Texture'fpsRPGTex.Texture.Background'
         DropShadow=None
         ImageColor=(A=200)
         ImageStyle=ISTY_Stretched
         WinTop=0.000000
         WinLeft=0.000000
         WinWidth=1.000000
         WinHeight=1.000000
         RenderWeight=0.000003
     End Object
     Controls(0)=FloatingImage'fpsRPG.RPGPlayerLevelsMenu.FloatingFrameBackground'

     Begin Object Class=GUIButton Name=ButtonClose
         Caption="Close"
         StyleName="AlterEgoButtonStyle"
         WinTop=0.800000
         WinLeft=0.400000
         WinWidth=0.200000
         OnClick=RPGPlayerLevelsMenu.CloseClick
         OnKeyEvent=ButtonClose.InternalOnKeyEvent
     End Object
     Controls(1)=GUIButton'fpsRPG.RPGPlayerLevelsMenu.ButtonClose'

     Begin Object Class=GUIScrollTextBox Name=InfoText
         bNoTeletype=True
         CharDelay=0.002500
         EOLDelay=0.000000
         TextAlign=TXTA_Center
         OnCreateComponent=InfoText.InternalOnCreateComponent
         WinTop=0.143750
         WinHeight=0.700000
         bBoundToParent=True
         bScaleToParent=True
         bNeverFocus=True
     End Object
     Controls(2)=GUIScrollTextBox'fpsRPG.RPGPlayerLevelsMenu.InfoText'

     WinTop=0.100000
     WinLeft=0.300000
     WinWidth=0.400000
     WinHeight=0.800000
}
