class HUD_DWRPGHudOverlay extends HudOverlay;

var Texture MyTexture;
var float PosX,PosY, MyScaling;
var byte Red,Green,Blue;

simulated function SetCoords(int IconPosX,int IconPosY)
{
    PosX=IconPosX;
    PosY=IconPosY;
    PosX/=100;
    PosY/=100;
}

simulated function Render(Canvas C)
{
    local float X,Y,Scaler;

    if (MyTexture==None)
    {
       return;
    }

    X=C.SizeX;
    
    if (X<1024)
    {
       Scaler=1.0;
    }
    else
    {
         if (X>=1024 && X<1280)
         {
            Scaler=1.25;
         }
         else
         {
              if (X>=1280 && X<1600)
              {
                 Scaler=1.5;
              }
              else
              {
                   if (X>=1600)
                   {
                      Scaler=2.0;
                   }
              }
         }
    }
    X=C.SizeX*PosX;
    Y=C.SizeY*PosY;
    C.Style=ERenderStyle.STY_Translucent;
    C.SetDrawColor(Red,Green,Blue);
    C.SetPos(X,Y);
    C.DrawIcon(MyTexture,Scaler*MyScaling);
}

defaultproperties
{
     MyTexture=Texture'TeamSymbols_UT2004.Team.design6'
     PosX=0.900000
     PosY=0.500000
     MyScaling=1.000000
     Red=255
     Green=255
     Blue=255
}
