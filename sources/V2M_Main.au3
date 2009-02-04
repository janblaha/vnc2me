#Region --- Script patched by FreeStyle code Start 01.02.2009 - 08:58:04
#EndRegion --- Script patched by FreeStyle code Start 01.02.2009 - 08:58:04
#RequireAdmin
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=..\compiled\v2m.ico
#AutoIt3Wrapper_Outfile=..\compiled\VNC2Me.exe
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_UseUpx=n
#AutoIt3Wrapper_Res_Comment=Creates Secure SSH tunnel, VNC then tunnels through this, making VNC ALOT more secure.
#AutoIt3Wrapper_Res_Description=VNC2Me - Allows remote screen sharing securely over the internet.
#AutoIt3Wrapper_Res_Fileversion=0.2.0.31
#AutoIt3Wrapper_Res_FileVersion_AutoIncrement=y
#AutoIt3Wrapper_Res_LegalCopyright=Sec IT (AGPL) 2008-2009
#AutoIt3Wrapper_Res_Field="Made By"|"Jim Dolby"
#AutoIt3Wrapper_Res_Icon_Add=..\compiled\v2m.ico
#AutoIt3Wrapper_Au3Check_Stop_OnWarning=y
#AutoIt3Wrapper_Au3Check_Parameters=-q -d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6
#AutoIt3Wrapper_Run_Tidy=y
#Tidy_Parameters=/rel /gd
#AutoIt3Wrapper_Run_Obfuscator=y
#Obfuscator_Parameters=/striponly
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#Region Options and includes
Opt("TrayIconDebug", 1) ;If enabled shows the current script line in the tray icon tip to help debugging.		0 = no debug information (default)	1 = show debug
Opt("TrayIconHide", 0) ;Hides the AutoIt tray icon. Note: The icon will still initially appear ~750 milliseconds.		0 = show icon (default)	1 = hide icon
Opt("TrayMenuMode", 1) ;Extend the behaviour of the script tray icon/menu. This can be done with a combination (adding) of the following values.		0 = default menu items (Script Paused/Exit) are appended to the usercreated menu; usercreated checked items will automatically unchecked; if you double click the tray icon then the controlid is returned which has the "Default"-style (default).		1 = no default menu		2 = user created checked items will not automatically unchecked if you click it		4 = don't return the menuitemID which has the "default"-style in the main contextmenu if you double click the tray icon		8 = turn off auto check of radio item groups
Opt("MustDeclareVars", 0)
;Opt("TrayAuto", 0)		;Pause Script pauses when click on tray icon.		0 = no pause	1 = pause (default). If there is no DefaultMenu no pause will occurs.
;Opt("ExpandEnvStrings", 1)
;Opt("ExpandVarStrings", 1)
;Opt("RunErrorsFatal", 0)
#include "V2M_GlobalVars.au3"
If IniRead(@ScriptDir & "\vnc2me_sc.ini", "V2M_GUI", "MAIN_ENABLE_DEBUG", "") <> 0 Then
	$V2M_Status[1][2] = 1
EndIf
#include "V2M_Functions.au3"
#include "Includes\_RefreshSystemTray.au3"
;#include "Includes\Autoit_funcs.au3"
#include <Constants.au3>
#include <WindowsConstants.au3>
#include <StaticConstants.au3>
#include <GuiStatusBar.au3>
#include <ProgressConstants.au3>
;#Include <GUIConstantsEx.au3>
;#Include <GuiConstants.au3>
;#Include <Date.au3>
;;#Include "Includes\XSkin.au3"
;;#Include "Includes\XSkinTray.au3"
;#include "V2M_Private_server_details.au3" ;uncomment out this line to NOT ask for host, user & pass (and them not be stored in the INI)
#EndRegion Options and includes
#Region languages
If $V2M_GUI_Language = 'Lang_' Then
	$V2M_GUI_Language = "Lang_" & _Language()
Else
	$V2M_EventDisplay = V2M_EventLog("Language - Using language from INI file: " & $V2M_GUI_Language, $V2M_EventDisplay, 'dll')
EndIf
#include "V2M_GUI.au3"
#EndRegion languages
#Region Mouse Sonar
If IniRead(@ScriptDir & "\vnc2me_sc.ini", "Common", "MAIN_ENABLE_SONAR", 1) = 1 Then
	DllCall("User32", "int", "SystemParametersInfo", _
			"int", $SPI_SETMOUSESONAR, _
			"int", 0, _
			"int", 1, _
			"int", BitOR($SPIF_UPDATEINIFILE, $SPIF_SENDCHANGE) _
			)
	$V2M_EventDisplay = V2M_EventLog("Usability - Sonar is now enabled", $V2M_EventDisplay, 'dll')
EndIf
#EndRegion Mouse Sonar
#Region clean the decks
; uncomment the following to start the timer as soon as the application is opened ...
;V2M_Timer('Start')
If ProcessExists($V2M_VNC_SC) Then
	ProcessClose($V2M_VNC_SC)
EndIf
If ProcessExists($V2M_VNC_SVR) Then
	ProcessClose($V2M_VNC_SVR)
EndIf
If ProcessExists($V2M_VNC_VWR) Then
	ProcessClose($V2M_VNC_VWR)
EndIf
If ProcessExists("v2mplink.exe") Then
	ProcessClose("v2mplink.exe")
EndIf
#EndRegion clean the decks
#Region TrayIcon setup
TraySetState(1) ;flash the trayicon (stops flashing when ssh connected)
TraySetIcon("v2m.ico")
$V2M_Tray[9] = TrayCreateItem(" ")
$V2M_Tray[8] = TrayCreateItem(IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "TRAY_MNU_ABOUT", "ABOUT"))
TrayCreateItem("")
$V2M_Tray[2] = TrayCreateMenu(IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "TRAY_MNU_SHOW", "SHOW"))
$V2M_Tray[1] = TrayCreateItem(IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "TRAY_MNU_EXIT", "EXIT"))
$V2M_Tray[3] = TrayCreateItem(IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "TRAY_MNU_SHOW_MAIN", "MAIN"), $V2M_Tray[2], -1, 1)
$V2M_Tray[4] = TrayCreateItem(IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "TRAY_MNU_SHOW_MINI", "MINI"), $V2M_Tray[2], -1, 1)
;$V2M_Tray[5] = TrayCreateItem(IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "TRAY_MNU_SHOW_TIMER", "TIMER"), $V2M_Tray[2], -1, 1)
If $V2M_Status[1][2] = 1 Then
	$V2M_Tray[6] = TrayCreateItem(IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "TRAY_MNU_SHOW_DEBUG", "DEBUG"), $V2M_Tray[2], -1, 1)
Else
	$V2M_Tray[6] = 1
EndIf
$V2M_Tray[7] = TrayCreateItem(IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "TRAY_MNU_SHOW_NONE", "NONE"), $V2M_Tray[2], -1, 1)
#EndRegion TrayIcon setup
#Region Commandline
;=========================================================================================================================================================
;=================== If commandline arguments, what to do ...
;=========================================================================================================================================================
If $cmdline[0] > 0 Then
	$V2M_cmdline[1] = StringLower($cmdline[1])
	$V2M_EventDisplay = V2M_EventLog("$cmdline[1] = " & $cmdline[1], $V2M_EventDisplay, 'dll')
	Switch $V2M_cmdline[1]
		Case "install", "-i", "/i"
			V2M_EventLog("INSTALL Cmdline Arguement found", $V2M_EventDisplay, 1)
			;			InstallService()
			;			$V2M_Exit = 1
		Case "remove", "-u", "/u", "uninstall"
			V2M_EventLog("REMOVE Cmdline Arguement found", $V2M_EventDisplay, 1)
			;			RemoveService()
			;			$V2M_Exit = 1
		Case "/connect", "/c", "-c"
			V2M_EventLog("CONNECT Cmdline Arguement found", $V2M_EventDisplay, 1)
			; when launched with connect string, port setting (and if defined server, user & pass) are read from the INI file.
			;			$V2M_Exit = 1
		Case "/?", "-help", "-h"
			V2M_EventLog("HELP Cmdline Arguement found", $V2M_EventDisplay, 1)
			ConsoleWrite(" - - - Help - - - " & @CRLF)
			ConsoleWrite("params : " & @CRLF)
			ConsoleWrite("  -c : Read host:port user:pass from INI and connect" & @CRLF)
			ConsoleWrite("  -h : Show this help" & @CRLF)
			ConsoleWrite("  -i : install service" & @CRLF)
			ConsoleWrite("  -u : remove service" & @CRLF)
			ConsoleWrite(" - - - - - - - - " & @CRLF)
			;			$V2M_Exit = 1
			;start service.
		Case Else
			$V2M_EventDisplay = V2M_EventLog("Cmdline Arguements not recognised", $V2M_EventDisplay, 'dll')
			TrayTip(IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "TRAYTIP_APP_START_TITLE", "APP_START_TITLE"), IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "TRAYTIP_APP_START_LINE1", "") & @CR & IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "TRAYTIP_APP_START_LINE2", ""), 10)
	EndSwitch
Else
	$V2M_EventDisplay = V2M_EventLog(IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "TRAYTIP_APP_START_LINE1", "APP_START_TITLE"), $V2M_EventDisplay, 'full')
EndIf
#EndRegion Commandline
#Region Vista Mods
;=========================================================================================================================================================
;=================== Vista Modifications to allow faster vista support
;=========================================================================================================================================================
Global $curVal = ""
If @OSVersion = "WIN_VISTA" Then
	Run(@ScriptDir & "\Aero_disable.exe")
	If RegRead("HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System", "PromptOnSecureDesktop_VNC") = "" Then ; if the value doesn't exist
		$curVal = RegRead("HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System", "PromptOnSecureDesktop")
		RegWrite("HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System", "PromptOnSecureDesktop_VNC", "REG_DWORD", $curVal)
	EndIf
	RegWrite("HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System", "PromptOnSecureDesktop", "REG_DWORD", 0)
	If RegRead("HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System", "ConsentPromptBehaviorAdmin_VNC") = "" Then ; if the value doesn't exist
		$curVal = RegRead("HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System", "ConsentPromptBehaviorAdmin")
		RegWrite("HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System", "ConsentPromptBehaviorAdmin_VNC", "REG_DWORD", $curVal)
	EndIf
	RegWrite("HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System", "ConsentPromptBehaviorAdmin", "REG_DWORD", 0)
EndIf
#EndRegion Vista Mods
#Region Main Application Loop
;=========================================================================================================================================================
;=================== Loop unitl we hit Exit (or get an error)
;=========================================================================================================================================================
While $V2M_Exit = 0
	;		do the following every cycle (imediate action)
	$V2M_LoopCount[1] = $V2M_LoopCount[1] + 1
	$V2M_LoopCount[2] = $V2M_LoopCount[2] + 1
	If $V2M_LoopCount[1] > 50 Then
		;		Do the following every X loops (allows for things that DONT need imediate actions to not chew the CPU (should be about every 1/2 to 1 second
		$V2M_LoopCount[1] = 0
		V2M_CheckRunning()
		If $V2M_Status[3][1] Then ;sshwanted
			If Not $V2M_Status[3][2] Then ;ssh not started
				$V2M_ProcessIDs[1] = V2MSSHConnect()
				$V2M_Status[3][2] = 1 ;ssh started
			Else
				If Not $V2M_ProcessIDs[1] = '' And ProcessExists("v2mplink.exe") Then
					$V2M_EventDisplay = V2M_EventLog("$V2M_ProcessIDs[1] And ProcessExists(v2mplink.exe)", $V2M_EventDisplay, 'dll')
					;  version 3.2.12.0 changed the way StdoutRead and StderrRead behaves within autoit. If you use a version before this, it likely will not work.
					$V2M_SSH[8] = StdoutRead($V2M_ProcessIDs[1])
					$V2M_SSH[9] = StderrRead($V2M_ProcessIDs[1]) ;V2M_SSH_ErrCharsWaiting
					If Not $V2M_SSH[9] = '' Then ;V2M_SSH_ErrCharsWaiting
						GUICtrlSetData($V2M_GUI_DebugOutputEdit, @HOUR & ':' & @MIN & ':' & @SEC & '- STDERR' & @CRLF & $V2M_SSH[9], 1)
						V2M_EventLog(@HOUR & ':' & @MIN & ':' & @SEC & '- STDERR' & @CRLF & $V2M_SSH[9], $V2M_EventDisplay, 'dll')
						$V2M_SSH[16] = StringRegExp($V2M_SSH[9], $V2M_SSH[15]) ;is host key detected
						$V2M_SSH[18] = StringRegExp($V2M_SSH[9], $V2M_SSH[17]) ;is port refused detected
						$V2M_SSH[20] = StringRegExp($V2M_SSH[9], $V2M_SSH[19]) ;is port forwarding closed detected
						$V2M_SSH[22] = StringRegExp($V2M_SSH[9], $V2M_SSH[21]) ;is stable ssh detected
						$V2M_SSH[24] = StringRegExp($V2M_SSH[9], $V2M_SSH[23]) ;is pass detected
						$V2M_SSH[26] = StringRegExp($V2M_SSH[9], $V2M_SSH[25]) ;is pass detected
						If $V2M_SSH[16] = 1 Then ;host key not cached
							$V2M_EventDisplay = V2M_EventLog("SSH STDERR Host key no cached", $V2M_EventDisplay, 'full')
							V2MAddHostKey()
							ContinueLoop
						ElseIf $V2M_SSH[18] = 1 Then ;Port refused
							$V2M_EventDisplay = V2M_EventLog("VNC - Disconnected from viewer", $V2M_EventDisplay, 'dll')
							V2MPortRefused()
						ElseIf $V2M_SSH[22] = 1 Then ;we now have stable ssh connection
							$V2M_EventDisplay = V2M_EventLog("SSH - Stable Connection", $V2M_EventDisplay, 'full')
							$V2M_Status[3][3] = 1 ; ssh is connected
							TrayTip(IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "TRAYTIP_SSH_CONNECTED_TITLE", ""), IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "TRAYTIP_SSH_CONNECTED_LINE1", "") & @CR & IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "TRAYTIP_SSH_CONNECTED_LINE2", "") & @CR & $V2M_SessionCode, 10)
							TrayItemSetText($V2M_Tray[9], IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "MAIN_SC_SSN", "SESSION CODE") & " = " & $V2M_SessionCode)
							GUICtrlSetData($V2M_GUI[12] & @CRLF, $V2M_SessionCode) ; send the session code to the GUI's
							GUICtrlSetData($V2M_GUI[26] & @CRLF, $V2M_SessionCode) ; send the session code to the GUI's
							V2M_Timer('Start') ; start the timer
							$V2MGUITimer = 1 ; set the var to say timer started
							;							$V2M_Status[2][4] = 1 ; set timer to show
							$V2M_EventDisplay = V2M_EventLog(V2MGuiChangeState($V2M_GUI_Main, $V2M_GUI_MainTitle, 'hide'), $V2M_EventDisplay, 'dll')
							$V2M_EventDisplay = V2M_EventLog(V2MGuiChangeState($V2M_GUI_Mini, $V2M_GUI_MiniTitle, 'show'), $V2M_EventDisplay, 'dll')
						ElseIf $V2M_SSH[20] = 1 Then ;VNC App closed or disconnected
							If $V2M_Status[3][4] = 1 Then ;scwanted
								If ProcessExists($V2M_VNC_SC) Then
									Sleep(1000)
									If Not ProcessExists($V2M_VNC_SC) Then
										Run($V2M_VNC_SC & " -connect 127.0.0.1:25400", @ScriptDir, @SW_HIDE, 7)
										$V2M_EventDisplay = V2M_EventLog("VNC App Restarting" & @CRLF, $V2M_EventDisplay)
									EndIf
								EndIf
							EndIf
						ElseIf $V2M_SSH[24] = 1 Then ; forced disconnect found
							$V2M_EventDisplay = V2M_EventLog("SSH - disconnect detected", $V2M_EventDisplay, 'full')
							Sleep(10000)
						ElseIf $V2M_SSH[26] = 1 Then ; AES-256 found
							$V2M_EventDisplay = V2M_EventLog("SSH - AES-256 Encryption", $V2M_EventDisplay, 'full')
							Sleep(1000)
						EndIf
					EndIf
					If Not $V2M_SSH[8] = '' Then ;$V2M_SSH_ReadCharsWaiting
						GUICtrlSetData($V2M_GUI_DebugOutputEdit, @HOUR & ':' & @MIN & ':' & @SEC & '- STDOUT' & @CRLF & $V2M_SSH[8], 1)
						V2M_EventLog(@HOUR & ':' & @MIN & ':' & @SEC & '- STDOUT' & @CRLF & $V2M_SSH[8], $V2M_EventDisplay, 'dll')
						$V2M_SSH[12] = StringRegExp($V2M_SSH[8], $V2M_SSH[11]) ;is login detected
						$V2M_SSH[14] = StringRegExp($V2M_SSH[8], $V2M_SSH[13]) ;is pass detected
						If $V2M_SSH[12] = 1 Then ;login found
							$V2M_EventDisplay = V2M_EventLog("SSH AUTH - 'login' detected", $V2M_EventDisplay, 'full')
							If IniRead(@ScriptDir & "\vnc2me_sc.ini", "V2M_Server", "USERNAME", "") = "" Then
								$V2M_EventDisplay = V2M_EventLog("SSH AUTH - using compiled username, or asking for it.", $V2M_EventDisplay, 'dll')
								$V2M_SSH[2] = V2MInBoxSTDINWrite($V2M_ProcessIDs[1], $V2M_SSH[2], IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "MSG_SSHUSER_TITLE", "SSH USERNAME"), IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "MSG_SSHUSER_TEXT", "ENTER SSH USERNAME"))
							Else
								$V2M_EventDisplay = V2M_EventLog("SSH AUTH - using username from INI file.", $V2M_EventDisplay, 'dll')
								$V2M_SSH[2] = V2MInBoxSTDINWrite($V2M_ProcessIDs[1], IniRead(@ScriptDir & "\vnc2me_sc.ini", "V2M_Server", "USERNAME", ""), IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "MSG_SSHUSER_TITLE", "SSH USERNAME"), IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "MSG_SSHUSER_TEXT", "ENTER SSH USERNAME"))
							EndIf
							ContinueLoop
						ElseIf $V2M_SSH[14] = 1 Then ; password found
							$V2M_Status[1][3] = $V2M_Status[1][3] + 1
							$V2M_EventDisplay = V2M_EventLog("SSH AUTH - 'password' detected", $V2M_EventDisplay, 'full')
							If IniRead(@ScriptDir & "\vnc2me_sc.ini", "V2M_Server", "PASSWORD", "") = "" Then
								$V2M_EventDisplay = V2M_EventLog("SSH AUTH - using compiled password, or asking for it.", $V2M_EventDisplay, 'dll')
								$V2M_SSH[3] = V2MInBoxSTDINWrite($V2M_ProcessIDs[1], $V2M_SSH[3], IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "MSG_SSHPASS_TITLE", "SSH PASSWORD"), IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "MSG_SSHPASS_TEXT", "ENTER SSH PASSWORD"), IniRead(@ScriptDir & "\vnc2me_sc.ini", "V2M_Server", "PASSWORDHASH", "*"))
							Else
								$V2M_EventDisplay = V2M_EventLog("SSH AUTH - using password from INI file.", $V2M_EventDisplay, 'dll')
								$V2M_SSH[3] = V2MInBoxSTDINWrite($V2M_ProcessIDs[1], IniRead(@ScriptDir & "\vnc2me_sc.ini", "V2M_Server", "PASSWORD", ""), IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "MSG_SSHPASS_TITLE", "SSH PASSWORD"), IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "MSG_SSHSVR_TITLE", "ENTER SSH PASSWORD"), IniRead(@ScriptDir & "\vnc2me_sc.ini", "V2M_Server", "PASSWORDHASH", "*"))
							EndIf
							ContinueLoop
						EndIf
					EndIf
				EndIf
				If $V2M_Status[3][3] Then ;ssh connected
					If $V2M_Status[3][5] <> 1 And $V2M_Status[3][7] <> 1 And $V2M_Status[3][10] <> 1 Then ; if no vnc started
						If $V2M_Status[3][4] = 1 Or $V2M_Status[3][6] = 1 Or $V2M_Status[3][8] = 1 Or $V2M_Status[3][9] = 1 Then
							V2M_startvnc('ssh') ;start vnc using ssh encryption
							TraySetState(4) ;start icon flashing
							; Set icon in main window
							_GUICtrlStatusBar_SetIcon($V2M_GUI[42], 1, _WinAPI_LoadShell32Icon(111))
							_GUICtrlStatusBar_SetIcon($V2M_GUI[43], 2, _WinAPI_LoadShell32Icon(111))
						ElseIf $V2M_Status[3][8] Then ;vwrscwanted
							$V2M_EventDisplay = V2M_EventLog("vwrscwanted", $V2M_EventDisplay, 'debug')
							V2M_startvnc('ssh') ;start vnc using ssh encryption
						ElseIf $V2M_Status[3][9] Then ;vwrsvrwanted
							$V2M_EventDisplay = V2M_EventLog("vwrsvrwanted", $V2M_EventDisplay, 'debug')
							V2M_startvnc('ssh') ;start vnc using ssh encryption
						EndIf
						$V2M_EventDisplay = V2M_EventLog("Starting Secure VNC Connection", $V2M_EventDisplay, 'full')
					EndIf
				EndIf
			EndIf ;
		Else ;ssh not wanted
			TraySetState(8)
		EndIf
		If $V2MGUITimer = 1 Then
			_GUICtrlStatusBar_SetText($V2M_GUI[42], @TAB & V2M_Timer('Read'), 1)
			_GUICtrlStatusBar_SetText($V2M_GUI[43], @TAB & V2M_Timer('Read'), 2)
		EndIf
	EndIf
	If $V2M_LoopCount[2] > 500 Then
		;		V2M_EventLog("                    $V2M_Status[1][3] = " & $V2M_Status[1][3] & " - " & @HOUR & ":" & @MIN & ":" & @SEC & ":" & @MSEC, $V2M_EventDisplay, 'dll')
		$V2M_LoopCount[2] = 0
		If $V2M_Status[1][3] > 1 Then
			$V2M_Status[1][3] = 0
			$V2M_EventDisplay = V2M_EventLog("SSH - authentication failure, too many password requests", $V2M_EventDisplay, 'full')
			$V2M_SSH[3] = ""
			Sleep(500)
		EndIf
	EndIf
	
	;=========================================================================================================================================================
	;=================== Get any messages from the GUI
	;=========================================================================================================================================================
	$V2M_GUI_Msg = GUIGetMsg()
	Switch $V2M_GUI_Msg
		;	GUI Window Events
		Case - 3 ;Or -3
			; GUI Window Closed
			If $V2M_Status[2][3] = 'show' Then ;debug GUI
				$V2M_EventDisplay = V2M_EventLog(V2MGuiChangeState($V2M_GUI[27], $V2M_GUI_DebugTitle, 'hide'), $V2M_EventDisplay, 'dll')
				GUICtrlSetState($V2M_GUI[33], 4) ;uncheck the checkbox
				$V2M_Status[2][3] = 'hide'
			ElseIf $V2M_Status[2][1] = 'show' Then ;main GUI
				;				MsgBox(0, "Exit VNC2Me", "Do you wish to close VNC2Me ?", 30)
				$V2M_EventDisplay = V2M_EventLog(V2MGuiChangeState($V2M_GUI_Main, $V2M_GUI_MainTitle, 'hide'), $V2M_EventDisplay, 'dll')
				$V2M_EventDisplay = V2M_EventLog(V2MGuiChangeState($V2M_GUI_Mini, $V2M_GUI_MiniTitle, 'show'), $V2M_EventDisplay, 'dll')
				$V2M_Status[2][1] = 'hide'
				TrayTip(IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "TRAYTIP_APP_GUISWITCH_TITLE", "APP_GUISWITCH_TITLE"), IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "TRAYTIP_APP_GUISWITCH_LINE1", "") & @CR & IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "TRAYTIP_APP_GUISWITCH_LINE2", ""), 10)
				;				TrayTip("V2M Tip ", "To Exit VNC2Me" & @CR & "Right Click this Icon", 10)
			ElseIf $V2M_Status[2][2] = 'show' Then ;mini GUI
				$V2M_EventDisplay = V2M_EventLog(V2MGuiChangeState($V2M_GUI_Mini, $V2M_GUI_MiniTitle, 'hide'), $V2M_EventDisplay, 'dll')
				$V2M_EventDisplay = V2M_EventLog(V2MGuiChangeState($V2M_GUI_Main, $V2M_GUI_MainTitle, 'show'), $V2M_EventDisplay, 'dll')
				$V2M_Status[2][2] = 'hide'
				TrayTip(IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "TRAYTIP_APP_GUISWITCH_TITLE", "APP_GUISWITCH_TITLE"), IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "TRAYTIP_APP_GUISWITCH_LINE1", "") & @CR & IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "TRAYTIP_APP_GUISWITCH_LINE2", ""), 10)
				;				TrayTip("V2M Tip ", "To Exit VNC2Me" & @CR & "Right Click this Icon", 10)
			EndIf
		Case $V2M_GUI[17] ;Main exit button
			$V2M_EventDisplay = V2M_EventLog("GUI - Exiting (MainButtonExit)", $V2M_EventDisplay, 'dll')
			$V2M_Exit = 1
		Case $V2M_GUI[31] ;Mini exit button
			$V2M_EventDisplay = V2M_EventLog("GUI - Exiting (MiniButtonExit)", $V2M_EventDisplay, 'dll')
			$V2M_Exit = 1
		Case $V2M_GUI[32] ; MainGUI File > Exit Clicked
			$V2M_EventDisplay = V2M_EventLog("Exiting (MainMenuExit)", $V2M_EventDisplay, 'dll')
			$V2M_Exit = 1
		Case $V2M_GUI[30] ; debug copy > clipboard clicked
			$clipboard = GUICtrlRead($V2M_GUI_DebugOutputEdit)
			ClipPut($clipboard)
			TrayTip(IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "TRAYTIP_DEBUG_COPIED_TITLE", "DEBUG_COPIED_TITLE"), IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "TRAYTIP_DEBUG_COPIED_LINE1", "") & @CR & IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "TRAYTIP_DEBUG_COPIED_LINE2", ""), 10)
		Case $V2M_GUI[15] ; MainGUI Help > About Clicked
			$V2M_EventDisplay = V2M_EventLog("GUI - MainAbout", $V2M_EventDisplay, 'dll')
			V2MAboutBox()
			;	GUI Main Button's
		Case $V2M_GUI[20] ;Tab_SC_ButtonConnect
			$V2M_EventDisplay = V2M_EventLog("GUI - VNC SC ButtonConnect", $V2M_EventDisplay, 'dll')
			$V2M_EventDisplay = V2M_EventLog("VNC - Support Session Requested", $V2M_EventDisplay, 'full')
			$V2M_Status[1][1] = 'SC'
			$V2M_Status[3][1] = 1 ; ssh wanted
			$V2M_Status[3][2] = 0 ; ssh started
			$V2M_Status[3][3] = 0 ; ssh Connected
			$V2M_Status[3][4] = 1 ; SC wanted
			$V2M_Status[3][6] = 0 ; svrwanted
			$V2M_Status[3][8] = 0 ; vwrscwanted
			$V2M_Status[3][9] = 0 ; vwrsvrwanted
			$V2M_SessionCode = GUICtrlRead($V2M_GUI[19])
		Case $V2M_GUI[36] ;GUI_SVR_ButtonConnect
			$V2M_EventDisplay = V2M_EventLog("GUI - VNC SVR ButtonConnect", $V2M_EventDisplay, 'dll')
			$V2M_EventDisplay = V2M_EventLog("VNC - Collaboration Session Requested", $V2M_EventDisplay, 'full')
			$V2M_Status[1][1] = 'SVR'
			$V2M_Status[3][1] = 1 ; ssh wanted
			$V2M_Status[3][2] = 0 ; ssh started
			$V2M_Status[3][3] = 0 ; ssh Connected
			$V2M_Status[3][4] = 0 ; SC wanted
			$V2M_Status[3][6] = 1 ; svr wanted
			$V2M_Status[3][8] = 0 ; vwr scwanted
			$V2M_Status[3][9] = 0 ; vwr svrwanted
			$V2M_SessionCode = GUICtrlRead($V2M_GUI[35])
		Case $V2M_GUI[10] ;Tab_VWR_ButtonConnect clicked
			$V2M_EventDisplay = V2M_EventLog("GUI - VNC VWR ButtonConnect", $V2M_EventDisplay, 'dll')
			$V2M_EventDisplay = V2M_EventLog("VNC - Viewer Session Requested", $V2M_EventDisplay, 'full')
			$V2M_Status[1][1] = 'VWR'
			$V2M_Status[3][1] = 1 ; ssh wanted
			$V2M_Status[3][2] = 0 ; ssh started
			$V2M_Status[3][3] = 0 ; ssh Connected
			$V2M_Status[3][4] = 0 ; SC wanted
			$V2M_Status[3][6] = 0 ; svr wanted
			;			$V2M_Status[3][8] = 0 ; vwr scwanted
			;			$V2M_Status[3][9] = 0 ; vwr svrwanted
			$V2M_SessionCode = GUICtrlRead($V2M_GUI[12])
		Case $V2M_GUI[21] ;Tab_SC_ButtonStop Clicked
			$V2M_EventDisplay = V2M_EventLog("GUI - VNC SC ButtonStop", $V2M_EventDisplay, 'dll')
			$V2M_Status[1][1] = ''
			$V2M_Status[3][4] = 0 ; SC wanted
			$V2M_Status[3][6] = 0 ; svrwanted
			$V2M_Status[3][8] = 0 ; vwrscwanted
			$V2M_Status[3][9] = 0 ; vwrsvrwanted
			V2MExitVNC()
			_RefreshSystemTray(50)
		Case $V2M_GUI[37] ;GUI_SVR_ButtonStop
			$V2M_EventDisplay = V2M_EventLog("GUI - VNC SVR ButtonStop", $V2M_EventDisplay, 'dll')
			$V2M_Status[1][1] = ''
			$V2M_Status[3][4] = 0 ; SC wanted
			$V2M_Status[3][6] = 0 ; svrwanted
			$V2M_Status[3][8] = 0 ; vwrscwanted
			$V2M_Status[3][9] = 0 ; vwrsvrwanted
			V2MExitVNC()
			_RefreshSystemTray(50)
		Case $V2M_GUI[11] ;Tab_VWR_ButtonStop clicked
			$V2M_EventDisplay = V2M_EventLog("GUI - VNC VWR ButtonStop", $V2M_EventDisplay, 'dll')
			$V2M_Status[1][1] = ''
			$V2M_Status[3][4] = 0 ; SC wanted
			$V2M_Status[3][6] = 0 ; svrwanted
			$V2M_Status[3][8] = 0 ; vwrscwanted
			$V2M_Status[3][9] = 0 ; vwrsvrwanted
			V2MExitVNC()
			_RefreshSystemTray(50)
			;	GUI Debug Buttons
		Case $V2M_GUI[28] ;DEBUG SSH button pressed
			$V2M_EventDisplay = V2M_EventLog("GUI - Debug SSH button pressed", $V2M_EventDisplay, 'dll')
			$V2M_Status[1][1] = 'SSH'
			$V2M_Status[3][1] = 1
			$V2M_Status[3][4] = 0 ; SC wanted
			$V2M_Status[3][6] = 0 ; svrwanted
			$V2M_Status[3][8] = 0 ; vwrscwanted
			$V2M_Status[3][9] = 0 ; vwrsvrwanted
		Case $V2M_GUI[29] ;Debug SSH Stop button pressed
			$V2M_EventDisplay = V2M_EventLog("GUI - Debug SSH ButtonStop", $V2M_EventDisplay, 'dll')
			$V2M_Status[3][1] = 0
			$V2M_Status[3][2] = 0
			$V2M_Status[3][4] = 0 ; SC wanted
			$V2M_Status[3][6] = 0 ; svrwanted
			$V2M_Status[3][8] = 0 ; vwrscwanted
			$V2M_Status[3][9] = 0 ; vwrsvrwanted
			V2MExitSSH()
			_RefreshSystemTray(50)
		Case $V2M_GUI[38] ;GUI_VWR_SsnRndChbx
			If (IniRead(@ScriptDir & "\vnc2me_sc.ini", "V2M_Server", "SESSION_CODE", "") = "") Then
				If GUICtrlRead($V2M_GUI[38]) = 1 Then
					$V2M_EventDisplay = V2M_EventLog("GUI - Random Session Code Generated", $V2M_EventDisplay, 'dll')
					$V2M_SessionCode = V2MRandomPort()
					GUICtrlSetData($V2M_GUI[12] & @CRLF, $V2M_SessionCode) ;generate random code
					GUICtrlSetState($V2M_GUI[12], 128) ;disable the session code box after setting random session code
				Else
					GUICtrlSetData($V2M_GUI[12] & @CRLF, '') ;Clear Session code
					GUICtrlSetState($V2M_GUI[12], 256 + 64) ;enable the session code box after clearing session code
					GUICtrlSetState($V2M_GUI[10], 512)
				EndIf
			EndIf
		Case $V2M_GUI[39] ;GUI_SVR_SsnRndChbx
			If (IniRead(@ScriptDir & "\vnc2me_sc.ini", "V2M_Server", "SESSION_CODE", "") = "") Then
				If GUICtrlRead($V2M_GUI[39]) = 1 Then
					$V2M_EventDisplay = V2M_EventLog("GUI - Random Session Code Generated", $V2M_EventDisplay, 'dll')
					$V2M_SessionCode = V2MRandomPort()
					GUICtrlSetData($V2M_GUI[35] & @CRLF, $V2M_SessionCode) ;generate random code
					GUICtrlSetState($V2M_GUI[35], 128) ;disable the session code box after setting random session code
				Else
					GUICtrlSetData($V2M_GUI[35] & @CRLF, '') ;Clear Session code
					GUICtrlSetState($V2M_GUI[35], 256 + 64) ;enable the session code box after clearing session code
					GUICtrlSetState($V2M_GUI[36], 512)
				EndIf
			EndIf
		Case $V2M_GUI[33] ;debug window show/hide
			If GUICtrlRead($V2M_GUI[33]) = 1 Then
				If $V2M_Status[1][2] = 1 Then
					$V2M_Status[2][3] = 'show' ;debug window show
					$V2M_EventDisplay = V2M_EventLog(V2MGuiChangeState($V2M_GUI[27], $V2M_GUI_DebugTitle, 'show'), $V2M_EventDisplay, 'dll')
				EndIf
			Else
				$V2M_Status[2][3] = 'hide' ;debug window hide
				$V2M_EventDisplay = V2M_EventLog(V2MGuiChangeState($V2M_GUI[27], $V2M_GUI_DebugTitle, 'hide'), $V2M_EventDisplay, 'dll')
			EndIf
		Case $V2M_GUI[40] ;TAB VWR Radio Items
			$V2M_EventDisplay = V2M_EventLog("VWR - SC Connection", $V2M_EventDisplay, 'dll')
			$V2M_Status[3][8] = 1 ;vwrscwanted
			;			MsgBox(0, "", "SC", 1)
			;the following where a trial that didn't work
		Case $V2M_GUI[41] ;TAB VWR Radio Items
			$V2M_EventDisplay = V2M_EventLog("VWR - SVR Connection", $V2M_EventDisplay, 'dll')
			$V2M_Status[3][9] = 1 ;vwrSVRwanted
			;			MsgBox(0, "", "SVR", 1)
	EndSwitch
	;
	;=========================================================================================================================================================
	; Get any messages from the TrayIcon
	$V2M_TrayMsg = TrayGetMsg()
	Switch $V2M_TrayMsg
		Case $V2M_Tray[1] ; Exit
			$V2M_EventDisplay = V2M_EventLog("GUI - Exiting (Tray)", $V2M_EventDisplay, 'dll')
			$V2M_Exit = 1
		Case $V2M_Tray[3] ;show > main
			TrayItemSetState($V2M_Tray[3], 1)
			$V2M_EventDisplay = V2M_EventLog(V2MGuiChangeState($V2M_GUI_Mini, $V2M_GUI_MiniTitle, 'hide'), $V2M_EventDisplay, 'dll')
			$V2M_Status[2][2] = 'hide'
			$V2M_EventDisplay = V2M_EventLog(V2MGuiChangeState($V2M_GUI_Main, $V2M_GUI_MainTitle, 'show'), $V2M_EventDisplay, 'dll')
			$V2M_Status[2][1] = 'show'
		Case $V2M_Tray[4] ;show > mini
			TrayItemSetState($V2M_Tray[4], 1)
			$V2M_EventDisplay = V2M_EventLog(V2MGuiChangeState($V2M_GUI_Main, $V2M_GUI_MainTitle, 'hide'), $V2M_EventDisplay, 'dll')
			$V2M_Status[2][1] = 'hide'
			$V2M_EventDisplay = V2M_EventLog(V2MGuiChangeState($V2M_GUI_Mini, $V2M_GUI_MiniTitle, 'show'), $V2M_EventDisplay, 'dll')
			$V2M_Status[2][2] = 'show'
		Case $V2M_Tray[6] ;show > debug
			TrayItemSetState($V2M_Tray[6], 1)
			GUICtrlSetState($V2M_GUI[33], 1)
			$V2M_EventDisplay = V2M_EventLog(V2MGuiChangeState($V2M_GUI[27], $V2M_GUI_DebugTitle, 'show'), $V2M_EventDisplay, 'dll')
		Case $V2M_Tray[7] ;show > none
			TrayItemSetState($V2M_Tray[7], 1)
			$V2M_EventDisplay = V2M_EventLog(V2MGuiChangeState($V2M_GUI_Main, $V2M_GUI_MainTitle, 'hide'), $V2M_EventDisplay, 'dll')
			$V2M_Status[2][1] = 'hide'
			$V2M_EventDisplay = V2M_EventLog(V2MGuiChangeState($V2M_GUI_Mini, $V2M_GUI_MiniTitle, 'hide'), $V2M_EventDisplay, 'dll')
			$V2M_Status[2][2] = 'hide'
			ToolTip("")
			;		Case $V2M_Tray[5]
			;			TrayItemSetState($V2M_Tray[5], 1)
			;			$V2M_Status[2][4] = 1
			;			;			ToolTip("Connected for : " & V2M_Timer('Read'), 10, 30)
	EndSwitch
WEnd
TraySetState(8);### Tidy Error -> if is never closed in your script.