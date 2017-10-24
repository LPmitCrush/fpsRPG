@echo off

set projn=fpsRPG

title %projn%
color 0F

echo.
echo Deleting compiled files %projn%
echo.
cd..
cd system
del %projn%.u
del %projn%.ucl
del %projn%.int

cd..
cd System
ucc.exe MakeCommandletUtils.EditPackagesCommandlet 1 AUDInvasion
ucc.exe MakeCommandletUtils.EditPackagesCommandlet 1 %projn%
ucc.exe editor.MakeCommandlet -EXPORTCACHE -SHOWDEP -SILENTBUILD -AUTO
ucc.exe MakeCommandletUtils.EditPackagesCommandlet 0 %projn%
ucc.exe MakeCommandletUtils.EditPackagesCommandlet 0 AUDInvasion

echo.
echo Generate files?
echo.
pause

echo.
echo Generating cache files
echo.
ucc.exe dumpintCommandlet %projn%.u
pause