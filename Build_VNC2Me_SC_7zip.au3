#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=compiled\v2m.ico
#AutoIt3Wrapper_Outfile=Build_VNC2Me_SC_7zip.exe
#AutoIt3Wrapper_Res_Comment=Builds VNC2Me SC
#AutoIt3Wrapper_Res_Description=Builds VNC2Me SC
#AutoIt3Wrapper_Res_Fileversion=0.0.0.2
#AutoIt3Wrapper_Res_FileVersion_AutoIncrement=y
#AutoIt3Wrapper_Res_LegalCopyright=Sec IT 2009
#AutoIt3Wrapper_res_requestedExecutionLevel=requireAdministrator
#AutoIt3Wrapper_Res_Icon_Add=compiled\v2m.ico
#AutoIt3Wrapper_Run_Tidy=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#cs ----------------------------------------------------------------------------
	
	AutoIt Version: 3.2.12.1
	Author:         JDaus
	
	Script Function:
	A setup script for customising and building VNC2Me
	
#ce ----------------------------------------------------------------------------
; VARs
Global $V2M_GUI_Language = "Lang_English", $title = "Creating VNC2Me Package (7zip method)"
$MsgBox = MsgBox(4, "VNC2Me ", "Have you run the VNC2Me Application yet ???", 60)
If $MsgBox = 7 Then
	Run("compiled\VNC2Me.exe")
	Exit
EndIf
$MsgBox = MsgBox(4, "VNC2Me ", "this will create the VNC2Me SC package." & @CRLF & "Do you want to continue", 60)
If $MsgBox = 7 Then
	;	MsgBox(0, "Debug", "No pressed, exiting", 1)
	Exit
EndIf
FileDelete(@ScriptDir & "\temp\VNC2Me_SC_7zip.7z")
MsgBox(0, "Debug", "Deleted old 7z archive", 2)
;RunWait(@ComSpec & " /c " & "build_resources\7za a temp\VNC2Me_SC_7zip.7z compiled\*.*", @ScriptDir)
RunWait(@ScriptDir & "\build_resources\7za.exe a temp\VNC2Me_SC_7zip.7z compiled\*.*", @ScriptDir)
MsgBox(0, "Debug", "new 7z archive created", 2)
;RunWait(@ComSpec & " /c " & 'copy /b build_resources\7z_v2m.sfx + build_resources\7z_sfx_config.txt + temp\VNC2Me_SC_7zip.7z temp\VNC2Me_SC_7zip.exe', @ScriptDir, @SW_SHOW)
RunWait(@ComSpec & " /c " & 'copy /b build_resources\7z_v2m.sfx + build_resources\7z_sfx_config.txt + temp\VNC2Me_SC_7zip.7z temp\VNC2Me_SC_7zip.exe', @ScriptDir, @SW_SHOW)
MsgBox(0, "Debug", "Created 7z sfx", 2)
;RunWait(@ComSpec & " /c " & "build_resources\upx -9 -f -k -o VNC2Me_SC_7zip.exe temp\VNC2Me_SC_7zip.exe", @ScriptDir)
$MsgBox = MsgBox(4, "VNC2Me ", "Do you want to compress using UPX ??? ???", 60)
If $MsgBox = 6 Then
	RunWait(@ScriptDir & "\build_resources\upx -9 -f -k -o VNC2Me_SC_7zip.exe temp\VNC2Me_SC_7zip.exe", @ScriptDir)
	;	Run("compiled\VNC2Me.exe")
	;	Exit
	MsgBox(0, "VNC2Me", "Compressed EXE using UPX")
Else
	FileCopy(@ScriptDir & "\temp\VNC2Me_SC_7zip.exe", @ScriptDir & "\VNC2Me_SC_7zip.exe")
	MsgBox(0, "Debug", "EXE not compressed using UPX")
EndIf

$MsgBox = MsgBox(4, "VNC2Me ", "VNC2Me SC package has been created." & @CRLF & "Do you want to run it.", 60)
If $MsgBox = 6 Then
	Run(@ScriptDir & "\VNC2Me_SC_7zip.exe")
	;	MsgBox(0, "Debug", "No pressed, exiting", 1)
	Exit
EndIf

;rem copy temp\VNC2Me_SC_7zip.exe .\ /y
;rem copy temp\VNC2Me_SC_7zip.exe "%HOMEDRIVE%%HOMEPATH%\desktop" /y
;rem echo VNC2Me_quick.exe has been placed on your desktop ...

;pause