Class RPGAbilityDescMenu extends GUIPage;



var automated GUIScrollTextBox MyScrollText;
var automated GUILabel MyLabel;
var automated GUIButton CloseButton;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(MyController, MyOwner);

	MyScrollText = GUIScrollTextBox(Controls[1]);
}

function bool CloseClick(GUIComponent Sender)
{
	Controller.CloseMenu(false);

	return true;
}

defaultproperties
{
     bRenderWorld=True
     bAllowedAsLast=True
     Begin Object Class=FloatingImage Name=FloatingFrameBackground
         Image=Texture'fpsRPGTex.Texture.Background'
         DropShadow=None
         ImageColor=(A=200)
         ImageStyle=ISTY_Stretched
         WinTop=-0.250000
         WinLeft=-0.125000
         WinWidth=1.250000
         WinHeight=1.600000
         RenderWeight=0.000003
     End Object
     Controls(0)=FloatingImage'fpsRPG.RPGAbilityDescMenu.FloatingFrameBackground'

     Begin Object Class=GUIScrollTextBox Name=InfoText
         CharDelay=0.002500
         EOLDelay=0.002500
         OnCreateComponent=InfoText.InternalOnCreateComponent
         WinTop=0.300000
         WinLeft=0.210000
         WinWidth=0.580000
         WinHeight=0.390000
         bNeverFocus=True
     End Object
     Controls(1)=GUIScrollTextBox'fpsRPG.RPGAbilityDescMenu.InfoText'

     Begin Object Class=GUIButton Name=ButtonClose
         Caption="Close"
         WinTop=0.700000
         WinLeft=0.400000
         WinWidth=0.200000
         OnClick=RPGAbilityDescMenu.CloseClick
         OnKeyEvent=ButtonClose.InternalOnKeyEvent
     End Object
     Controls(2)=GUIButton'fpsRPG.RPGAbilityDescMenu.ButtonClose'

     WinTop=0.300000
     WinLeft=0.210000
     WinWidth=0.580000
     WinHeight=0.390000
}
