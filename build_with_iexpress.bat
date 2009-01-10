@Echo off
title Creating VNC2Me Package, using IExpress method
cls
echo this script will create the VNC2Me package using IExpress on WinXP.
echo.
echo consult the readme or website before running for the first time.
echo.
echo if you do not want to build this package now,
echo      press ctrl + c NOW
echo.
echo else,

pause
cls


iexpress.exe /N ./build_resources/VNC2Me.SED
echo.
echo VNC2Me_iexpress.exe building complete.
echo.
echo If unsucessful check usage of iexpress.exe in Windows XP on Google
pause
