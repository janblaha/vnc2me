@echo off
title Creating VNC2Me Package, using 7zip method
cls
echo this script will create the VNC2Me package using 7zip method.
echo.
echo consult the readme or website before running for the first time.
echo.
echo if you do not want to build this package now,
echo      press ctrl + c NOW
echo.
echo else,

pause
cls
del temp\VNC2Me_7zip.7z

build_resources\7za a temp\VNC2Me_7zip.7z compiled\*.*
copy /b build_resources\7z_v2m.sfx + build_resources\7z_sfx_config.txt + temp\VNC2Me_7zip.7z temp\VNC2Me_7zip.exe

build_resources\upx -9 -f -k -o VNC2Me_SC_7zip.exe temp\VNC2Me_7zip.exe

copy temp\VNC2Me_7zip.exe .\ /y
rem copy temp\VNC2Me_7zip.exe "%HOMEDRIVE%%HOMEPATH%\desktop" /y
rem echo VNC2Me_quick.exe has been placed on your desktop ...

pause