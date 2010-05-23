#region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_icon=..\vnc2me\v2m.ico
#AutoIt3Wrapper_outfile=..\vnc2me\vnc2me.exe
#AutoIt3Wrapper_Compression=0
#AutoIt3Wrapper_UseUpx=n
#AutoIt3Wrapper_Res_Comment=Creates Secure SSH tunnel through which VNC then tunnels, making VNC secure.
#AutoIt3Wrapper_Res_Description=VNC2Me - Allows remote screen sharing securely over the internet.
#AutoIt3Wrapper_Res_Fileversion=0.10.5.30
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=p
#AutoIt3Wrapper_Res_LegalCopyright=Secure Technology Group (AGPL) 2008-2009
#AutoIt3Wrapper_Res_Field="Made By"|"YTS_Jim"
#AutoIt3Wrapper_Res_Icon_Add=..\vnc2me\icon1.ico
#AutoIt3Wrapper_Res_Icon_Add=..\vnc2me\icon2.ico
#AutoIt3Wrapper_AU3Check_Stop_OnWarning=y
#AutoIt3Wrapper_AU3Check_Parameters=-q -d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6
#AutoIt3Wrapper_Run_Tidy=y
#AutoIt3Wrapper_Run_Obfuscator=y
#Obfuscator_Parameters=/striponly
#endregion ;**** Directives created by AutoIt3Wrapper_GUI ****
;#RequireAdmin
#region --- Script patched by FreeStyle code Start 01.02.2009 - 08:58:04
#endregion --- Script patched by FreeStyle code Start 01.02.2009 - 08:58:04
#region Options and includes
Global $DebugLevel = 9, $DEBUGLOG = 0, $AppINI = @ScriptDir & "\vnc2me_sc.ini"

If @Compiled Then
	TraySetToolTip(IniRead($AppINI, "Common", "APPName", "VNC2Me") & " - " & FileGetVersion(@ScriptFullPath))
Else
	Opt("TrayIconDebug", 1) ;If enabled shows the current script line in the tray icon tip to help debugging.		0 = no debug information (default)	1 = show debug
EndIf
If @OSVersion = "WIN_7" Or @OSVersion = "WIN_VISTA" Then
	#RequireAdmin
EndIf
Opt("TrayIconHide", 0) ;Hides the AutoIt tray icon. Note: The icon will still initially appear ~750 milliseconds.		0 = show icon (default)	1 = hide icon
Opt("TrayMenuMode", 1) ;Extend the behaviour of the script tray icon/menu. This can be done with a combination (adding) of the following values.		0 = default menu items (Script Paused/Exit) are appended to the usercreated menu; usercreated checked items will automatically unchecked; if you double click the tray icon then the controlid is returned which has the "Default"-style (default).		1 = no default menu		2 = user created checked items will not automatically unchecked if you click it		4 = don't return the menuitemID which has the "default"-style in the main contextmenu if you double click the tray icon		8 = turn off auto check of radio item groups
;Opt("MustDeclareVars", 0)
;Opt("TrayAuto", 0)		;Pause Script pauses when click on tray icon.		0 = no pause	1 = pause (default). If there is no DefaultMenu no pause will occurs.
;Opt("ExpandEnvStrings", 1)
;Opt("ExpandVarStrings", 1)
;Opt("RunErrorsFatal", 0)
#include "V2M_GlobalVars.au3"
#include <Date.au3>
If IniRead($AppINI, "V2M_GUI", "MAIN_ENABLE_DEBUG", "") <> 0 Then
	$V2M_Status[1][2] = 1
EndIf
#include <WindowsConstants.au3>
#include <GUIConstantsEx.au3>
#include <ButtonConstants.au3>
#include "V2M_Functions.au3"
;V2M_Update()
#include "Includes\_RefreshSystemTray.au3"
;#include "Includes\_InetFileUpdate.au3"
;#include "Includes\Autoit_funcs.au3"
#include <Constants.au3>
#include <StaticConstants.au3>
#include <GuiStatusBar.au3>
#include <GuiButton.au3>
#include <ProgressConstants.au3>
#include <IE.au3>
;#Include <Date.au3>
;;#Include "Includes\XSkin.au3"
;;#Include "Includes\XSkinTray.au3"
;$V2M_SSH[1] = IniRead($AppINI, "Vnc2MeServer", "Hostname", "69.64.47.216 -P 443")
;$V2M_SSH[2] = IniRead($AppINI, "Vnc2MeServer", "Username", "sshuser-eec832613dae")
;$V2M_SSH[3] = IniRead($AppINI, "Vnc2MeServer", "Password", "jkeek2teen")
#include "V2M_Private_server_details.au3" ;uncomment out this line to NOT ask for host, user & pass (and them not be stored in the INI)
#endregion Options and includes
#region Debuglog
If $DEBUGLOG = 1 Or StringInStr($CmdLineRaw, "-debuglog") Then
	If FileExists(@ScriptFullPath & "_LOG.txt") Then
		$V2M_EventDisplay = YTS_EventLog("Log File Exists ...", $V2M_EventDisplay, 5)
		$return = MsgBox(1, @ScriptName, "Log File Exists ..." & @CRLF & @CRLF & "Log will now be deleted ...", 10)
		If $return = 1 Or $return = -1 Then
			FileDelete(@ScriptFullPath & "_LOG.txt")
		EndIf
	EndIf
	;	$TrayMenuLog = TrayCreateItem("Disable Log")
	;Else
	;	$TrayMenuLog = 1
EndIf
#endregion Debuglog
#region languages
If $V2M_GUI_Language = 'Lang_' Then
	$V2M_GUI_Language = "Lang_" & _Language()
	$V2M_EventDisplay = YTS_EventLog("Language - Determined OSLang (" & @OSLang & ") to be: " & $V2M_GUI_Language, $V2M_EventDisplay, '3')
Else
	$V2M_EventDisplay = YTS_EventLog("Language - Using language from INI file: " & $V2M_GUI_Language, $V2M_EventDisplay, '3')
EndIf
#include "V2M_GUI.au3"
#endregion languages
#region Mouse Sonar
If IniRead($AppINI, "Common", "MAIN_ENABLE_SONAR", 1) = 1 Then
	DllCall("User32", "int", "SystemParametersInfo", _
			"int", $SPI_SETMOUSESONAR, _
			"int", 0, _
			"int", 1, _
			"int", BitOR($SPIF_UPDATEINIFILE, $SPIF_SENDCHANGE) _
			)
	$V2M_EventDisplay = YTS_EventLog("Usability - Sonar is now enabled", $V2M_EventDisplay, '5')
EndIf
#endregion Mouse Sonar
#region clean the decks
V2MExitSSH()
V2MExitVNC()
#endregion clean the decks
#region TrayIcon setup
TraySetState(2) ;flash the trayicon (stops flashing when ssh connected)
TraySetIcon("v2m.ico")
$V2M_Tray[8] = TrayCreateItem(_Translate($V2M_GUI_Language, "TRAY_MNU_ABOUT", "ABOUT"))
TrayItemSetState($V2M_Tray[8], 64 + 512) ;$TRAY_CHECKED = 1, $TRAY_UNCHECKED = 4, $TRAY_ENABLE = 64, $TRAY_DISABLE = 128, $TRAY_FOCUS = 256, $TRAY_DEFAULT = 512
TrayCreateItem("")
$V2M_Tray[2] = TrayCreateMenu(_Translate($V2M_GUI_Language, "TRAY_MNU_SHOW", "SHOW"))
$V2M_Tray[1] = TrayCreateItem(_Translate($V2M_GUI_Language, "TRAY_MNU_EXIT", "EXIT"))
$V2M_Tray[3] = TrayCreateItem(_Translate($V2M_GUI_Language, "TRAY_MNU_SHOW_MAIN", "MAIN"), $V2M_Tray[2], -1, 1)
$V2M_Tray[4] = TrayCreateItem(_Translate($V2M_GUI_Language, "TRAY_MNU_SHOW_MINI", "MINI"), $V2M_Tray[2], -1, 1)
;$V2M_Tray[5] = TrayCreateItem(_Translate($V2M_GUI_Language, "TRAY_MNU_SHOW_TIMER", "TIMER"), $V2M_Tray[2], -1, 1)
If $V2M_Status[1][2] = 1 Then
	$V2M_Tray[6] = TrayCreateItem(_Translate($V2M_GUI_Language, "TRAY_MNU_SHOW_DEBUG", "DEBUG"), $V2M_Tray[2], -1, 1)
Else
	$V2M_Tray[6] = 1
EndIf
$V2M_Tray[7] = TrayCreateItem(_Translate($V2M_GUI_Language, "TRAY_MNU_SHOW_NONE", "NONE"), $V2M_Tray[2], -1, 1)
TraySetClick(16)
If FileExists(@ScriptDir & "\disclaimer.htm") Then
	TraySetState(2)
Else
	TraySetState()
EndIf
#endregion TrayIcon setup
#region Commandline
;=========================================================================================================================================================
;=================== If commandline arguments, what to do ...
;=========================================================================================================================================================
If $cmdline[0] > 0 Then
	YTS_EventLog("CmdLine Options found", $V2M_EventDisplay, "1")
	_cmdline()
Else
	YTS_EventLog("No CmdLine ", $V2M_EventDisplay, "1")
EndIf
#endregion Commandline
;#Region Commandline
;;=========================================================================================================================================================
;;=================== If commandline arguments, what to do ...
;;=========================================================================================================================================================
;If $cmdline[0] > 0 Then
;	$V2M_cmdline[1] = StringLower($cmdline[1])
;	$V2M_EventDisplay = YTS_EventLog("$cmdline[1] = " & $cmdline[1], $V2M_EventDisplay, '8')
;	Switch $V2M_cmdline[1]
;		Case "install", "-i", "/i"
;			YTS_EventLog("INSTALL Cmdline Arguement found", $V2M_EventDisplay, 1)
;			;			InstallService()
;			;			$V2M_Exit = 1
;		Case "remove", "-u", "/u", "uninstall"
;			YTS_EventLog("REMOVE Cmdline Arguement found", $V2M_EventDisplay, 1)
;			;			RemoveService()
;			;			$V2M_Exit = 1
;		Case "/connect", "/c", "-c"
;			YTS_EventLog("CONNECT Cmdline Arguement found", $V2M_EventDisplay, 1)
;			; when launched with connect string, port setting (and if defined server, user & pass) are read from the INI file.
;			;			$V2M_Exit = 1
;			$V2M_NoGUI = 1
;		Case "/?", "-help", "-h"
;			YTS_EventLog("HELP Cmdline Arguement found", $V2M_EventDisplay, 1)
;			ConsoleWrite(" - - - Help - - - " & @CRLF)
;			ConsoleWrite("params : " & @CRLF)
;			ConsoleWrite("  -c : Read host:port user:pass from INI and connect" & @CRLF)
;			ConsoleWrite("  -h : Show this help" & @CRLF)
;			ConsoleWrite("  -i : install service" & @CRLF)
;			ConsoleWrite("  -u : remove service" & @CRLF)
;			ConsoleWrite(" - - - - - - - - " & @CRLF)
;			;			$V2M_Exit = 1
;			;start service.
;		Case Else
;			$V2M_EventDisplay = YTS_EventLog("Cmdline Arguements not recognised", $V2M_EventDisplay, '8')
;			TrayTip(_Translate($V2M_GUI_Language, "TRAYTIP_APP_START_TITLE", "APP_START_TITLE"), _Translate($V2M_GUI_Language, "TRAYTIP_APP_START_LINE1", "") & @CR & _Translate($V2M_GUI_Language, "TRAYTIP_APP_START_LINE2", ""), 10)
;	EndSwitch
;Else
;	$V2M_EventDisplay = YTS_EventLog(_Translate($V2M_GUI_Language, "TRAYTIP_APP_START_LINE1", "APP_START_TITLE"), $V2M_EventDisplay, '1')
;EndIf
;#EndRegion Commandline
#region Vista Mods
;=========================================================================================================================================================
;=================== Vista Modifications to allow faster vista support
;=========================================================================================================================================================
YTS_EventLog("CORE - @OSVersion = " & @OSVersion, $V2M_EventDisplay, '7')
;If @OSVersion = "WIN_VISTA" Then
If (@OSVersion = "WIN_VISTA") Or RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion", "CurrentVersion") >= 6 Then
	$V2M_EventDisplay = YTS_EventLog("CORE - @OSVersion >= WIN_VISTA", $V2M_EventDisplay, "2")
	;Get current Aero State
	$Current_CompositionState = Vista_GetComposition()
	YTS_EventLog("USABILITY - $Current_CompositionState = " & $Current_CompositionState, $V2M_EventDisplay, " 9")
	;disable UAC
	Vista_ControlUAC("Disable")
	;disable Aero
	Vista_ControlAero("Disable")
EndIf
#endregion Vista Mods
#region Main Application Loop
; uncomment the following to start the timer as soon as the application is opened ...
;V2M_Timer('Start')
;=========================================================================================================================================================
;=================== Loop unitl we hit Exit (or get an error)
;=========================================================================================================================================================
While $V2M_Exit = 0
	If _DateDiff('s', $sTimestamp[1], _NowCalc()) >= 0 Then ; if last entered here was more than 1 second, then ...
		$sTimestamp[1] = _DateAdd('s', 1, _NowCalc()) ;ONLY enter into here, once every second (saves CPU cycles without using sleep functions)
		;		Do the following every 1 second (allows for things that DONT need imediate actions to not chew the CPU)
		;		V2M_CheckRunning()
		If $V2M_Status[3][1] Then ; if sshwanted then ...
			If Not $V2M_Status[3][2] Then ; if ssh-not-started then ...
				$V2M_ProcessIDs[1] = V2MSSHConnect()
				Sleep(500)
				If $V2M_ProcessIDs[1] <> "" Then
					$V2M_Status[3][2] = 1 ;ssh started
				EndIf ; $V2M_ProcessIDs[1] <> ""
			Else ; SSH-is-started
				If Not $V2M_ProcessIDs[1] = '' And ProcessExists($V2M_SSH_APP) Then ; if there is a processID for plink, and processexists for plink then ...
					;					$V2M_EventDisplay = YTS_EventLog("$V2M_ProcessIDs[1] And ProcessExists(" & $V2M_SSH_APP & ")", $V2M_EventDisplay, '9')
					;  autoit version 3.2.12.0 changed the way StdoutRead and StderrRead behaves within autoit. If you use a version before this, it likely will not work.
					$V2M_SSH[8] = StdoutRead($V2M_ProcessIDs[1]) ;V2M_SSH_OutCharsWaiting
					$V2M_SSH[9] = StderrRead($V2M_ProcessIDs[1]) ;V2M_SSH_ErrCharsWaiting
					If Not $V2M_SSH[9] = '' Then ;V2M_SSH_ErrCharsWaiting
						GUICtrlSetData($V2M_GUI_DebugOutputEdit, @HOUR & ':' & @MIN & ':' & @SEC & '- STDERR' & @CRLF & $V2M_SSH[9], 1)
						YTS_EventLog(@HOUR & ':' & @MIN & ':' & @SEC & '- STDERR' & @CRLF & $V2M_SSH[9], $V2M_EventDisplay, '7')
						$V2M_SSH[16] = StringRegExp($V2M_SSH[9], $V2M_SSH[15]) ;is host key detected
						$V2M_SSH[18] = StringRegExp($V2M_SSH[9], $V2M_SSH[17]) ;is port refused detected
						$V2M_SSH[20] = StringRegExp($V2M_SSH[9], $V2M_SSH[19]) ;is port forwarding closed detected
						$V2M_SSH[22] = StringRegExp($V2M_SSH[9], $V2M_SSH[21]) ;is stable ssh detected
						$V2M_SSH[24] = StringRegExp($V2M_SSH[9], $V2M_SSH[23]) ;is SSH_DISCONNECT_PROTOCOL_ERROR
						$V2M_SSH[26] = StringRegExp($V2M_SSH[9], $V2M_SSH[25]) ;is Initialised AES-256
						If $V2M_SSH[16] = 1 Then ;host key not cached
							$V2M_EventDisplay = YTS_EventLog("SSH STDERR Host key no cached", $V2M_EventDisplay, '2')
							V2MAddHostKey()
							ContinueLoop
						ElseIf $V2M_SSH[18] = 1 Then ;Port refused
							$V2M_EventDisplay = YTS_EventLog("VNC - Disconnected from viewer", $V2M_EventDisplay, '2')
							V2MPortRefused()
							ContinueLoop
						ElseIf $V2M_SSH[22] = 1 Then ;we now have stable ssh connection
							$V2M_EventDisplay = YTS_EventLog("SSH - Stable Connection", $V2M_EventDisplay, '2')
							$V2M_Status[3][3] = 1 ; ssh is connected
							TrayTip(_Translate($V2M_GUI_Language, "TRAYTIP_SSH_CONNECTED_TITLE", ""), _Translate($V2M_GUI_Language, "TRAYTIP_SSH_CONNECTED_LINE1", "") & @CR & _Translate($V2M_GUI_Language, "TRAYTIP_SSH_CONNECTED_LINE2", "") & @CR & $V2M_SessionCode, 10)
							If $V2M_Tray[9] = "" Then
								$V2M_Tray[9] = TrayCreateItem(" ")
							Else
								YTS_EventLog("$V2M_Tray[9] = " & $V2M_Tray[9], $V2M_EventDisplay, '2')
							EndIf
							TrayItemSetText($V2M_Tray[9], _Translate($V2M_GUI_Language, "MAIN_SC_SSN", "SESSION CODE") & " = " & $V2M_SessionCode)
							If @Compiled Then
								TraySetToolTip(IniRead($AppINI, "Common", "APPName", "VNC2Me") & " - " & FileGetVersion(@ScriptFullPath) & " - SSN = " & $V2M_SessionCode)
							EndIf
							GUICtrlSetData($V2M_GUI[12] & @CRLF, $V2M_SessionCode) ; send the session code to the GUI's
							GUICtrlSetData($V2M_GUI[26] & @CRLF, $V2M_SessionCode) ; send the session code to the GUI's
							V2M_Timer('Start') ; start the timer
							$V2MGUITimer = 1 ; set the var to say timer started
							;							$V2M_Status[2][4] = 1 ; set timer to show
							$V2M_EventDisplay = YTS_EventLog(V2MGuiChangeState($V2M_GUI_Main, $V2M_GUI_MainTitle, 'hide'), $V2M_EventDisplay, '6')
							$V2M_EventDisplay = YTS_EventLog(V2MGuiChangeState($V2M_GUI_Mini, $V2M_GUI_MiniTitle, 'show'), $V2M_EventDisplay, '6')
							ContinueLoop
						ElseIf $V2M_SSH[20] = 1 Then ; If secure port tunnel closed then ...
							If $V2M_Status[3][4] = 1 Then ; if scwanted then ...
								If ProcessExists($V2M_VNC_SC) Then ; if UVNC-SC processexists then ...
									$sTimestamp[1] = _DateAdd('s', 2, _NowCalc()) ; wait X seconds before returning to the delay loop that we are in ...
									If Not ProcessExists($V2M_VNC_SC) Then ; if UVNC-SC not processexist then ...
										V2M_startvnc('ssh') ;start vnc using ssh encryption
										TraySetState(4) ;start icon flashing
										;										Run($V2M_VNC_SC & " -connect 127.0.0.1:25400", @ScriptDir, @SW_HIDE, 7)
										$V2M_EventDisplay = YTS_EventLog("VNC App Restarting" & @CRLF, $V2M_EventDisplay, '2')
									EndIf
								EndIf
							EndIf
						ElseIf $V2M_SSH[24] = 1 Then ; forced disconnect found
							$V2M_EventDisplay = YTS_EventLog("SSH - disconnect detected", $V2M_EventDisplay, '2')
							Sleep(500)
							If Not ProcessExists($V2M_SSH_APP) Then
								$V2M_Status[3][2] = 0 ; ssh started
								$V2M_Status[3][3] = 0 ; ssh connected
								$V2MGUITimer = 0 ; turn timer updating off
							EndIf
							$sTimestamp[1] = _DateAdd('s', 5, _NowCalc()) ; wait X seconds before returning to the delay loop that we are in ...
						ElseIf $V2M_SSH[26] = 1 Then ; AES-256 found
							$V2M_EventDisplay = YTS_EventLog("SSH - AES-256 Encryption", $V2M_EventDisplay, '2')
							$V2M_SSH_EncryptionType = "AES-256"
							$sTimestamp[1] = _DateAdd('s', 2, _NowCalc()) ; wait X seconds before returning to the delay loop that we are in ...
						EndIf
					EndIf
					If Not $V2M_SSH[8] = '' Then ;$V2M_SSH_ReadCharsWaiting
						YTS_EventLog(@HOUR & ':' & @MIN & ':' & @SEC & '- STDOUT' & @CRLF & $V2M_SSH[8], $V2M_EventDisplay, '7')
						$V2M_SSH[12] = StringRegExp($V2M_SSH[8], $V2M_SSH[11]) ;is login detected
						$V2M_SSH[14] = StringRegExp($V2M_SSH[8], $V2M_SSH[13]) ;is pass detected
						If $V2M_SSH[12] = 1 Then ;login found
							$V2M_EventDisplay = YTS_EventLog("SSH AUTH - 'login' detected", $V2M_EventDisplay, '2')
							If $V2M_SSH[2] = "" Then ; if no username found in INI or compiled then ...
								$V2M_EventDisplay = YTS_EventLog("SSH AUTH - asking for username ...", $V2M_EventDisplay, '6')
								$V2M_SSH[2] = V2MInBoxSTDINWrite($V2M_ProcessIDs[1], $V2M_SSH[2], _Translate($V2M_GUI_Language, "MSG_SSHUSER_TITLE", "SSH USERNAME"), _Translate($V2M_GUI_Language, "MSG_SSHUSER_TEXT", "ENTER SSH USERNAME"))
							Else
								$V2M_EventDisplay = YTS_EventLog("SSH AUTH - using username from INI file or compiled into app.", $V2M_EventDisplay, '6')
								V2MInBoxSTDINWrite($V2M_ProcessIDs[1], $V2M_SSH[2], _Translate($V2M_GUI_Language, "MSG_SSHUSER_TITLE", "SSH USERNAME"), _Translate($V2M_GUI_Language, "MSG_SSHUSER_TEXT", "ENTER SSH USERNAME"))
							EndIf
							ContinueLoop
						ElseIf $V2M_SSH[14] = 1 Then ; password found
							If _DateDiff('s', $sTimestamp[2], _NowCalc()) <= 0 Then
								YTS_EventLog(@HOUR & ":" & @MIN & ":" & @SEC & ":" & @MSEC & " - " & "$V2M_Status[1][3] = " & $V2M_Status[1][3] & ", _DateDiff('s', $sTimestamp[2], _NowCalc()) = " & _DateDiff('s', $sTimestamp[2], _NowCalc()), $V2M_EventDisplay, '9')
								If $V2M_Status[1][3] >= 3 Then ; if password has been asked for more than 2 times (3 or greater), then password is incorrect, reset it now
									$V2M_Status[1][3] = 0
									$V2M_EventDisplay = YTS_EventLog("SSH - authentication failure, too many password requests", $V2M_EventDisplay, '3')
									$V2M_EventDisplay = YTS_EventLog("SSH - auth password reset (too many password attempts in one minute)", $V2M_EventDisplay, '3')
									$V2M_SSH[3] = ""
									$sTimestamp[1] = _DateAdd('s', 2, _NowCalc())
									;				Sleep(500)
								Else ; else, add password count now
									$V2M_Status[1][3] = $V2M_Status[1][3] + 1 ; Amount of times Password has been used
								EndIf
							Else
								$sTimestamp[2] = _DateAdd('n', 1, _NowCalc()) ;Add 1 minute to password reset timer ... so we don't ask for a password again until 3 authentications have failed within a minute.
								$V2M_Status[1][3] = 1
							EndIf

							$V2M_EventDisplay = YTS_EventLog("SSH AUTH - 'password' detected", $V2M_EventDisplay, '2')
							If IniRead($AppINI, "V2M_Server", "PASSWORD", "") = "" Then
								$V2M_EventDisplay = YTS_EventLog("SSH AUTH - using compiled password, or asking for it.", $V2M_EventDisplay, '6')
								$V2M_SSH[3] = V2MInBoxSTDINWrite($V2M_ProcessIDs[1], $V2M_SSH[3], _Translate($V2M_GUI_Language, "MSG_SSHPASS_TITLE", "SSH PASSWORD"), _Translate($V2M_GUI_Language, "MSG_SSHPASS_TEXT", "ENTER SSH PASSWORD"), IniRead($AppINI, "V2M_Server", "PASSWORDHASH", "*"))
							Else
								$V2M_EventDisplay = YTS_EventLog("SSH AUTH - using password from INI file.", $V2M_EventDisplay, '6')
								$V2M_SSH[3] = V2MInBoxSTDINWrite($V2M_ProcessIDs[1], IniRead($AppINI, "V2M_Server", "PASSWORD", ""), _Translate($V2M_GUI_Language, "MSG_SSHPASS_TITLE", "SSH PASSWORD"), _Translate($V2M_GUI_Language, "MSG_SSHSVR_TITLE", "ENTER SSH PASSWORD"), IniRead($AppINI, "V2M_Server", "PASSWORDHASH", "*"))
							EndIf
							ContinueLoop
						EndIf
					EndIf
				Else ; there is no processID for plink, or no processexists for plink then ...
					$V2M_Status[3][2] = 0
				EndIf ; If Not $V2M_ProcessIDs[1] = '' And ProcessExists($V2M_SSH_APP) Then
				If $V2M_Status[3][3] Then ;ssh connected
					If $V2M_Status[3][5] <> 1 And $V2M_Status[3][7] <> 1 And $V2M_Status[3][10] <> 1 Then ; if not scstarted or not SVRstarted or not vwrstarted then ...
						If $V2M_Status[3][4] = 1 Or $V2M_Status[3][6] = 1 Or $V2M_Status[3][8] = 1 Or $V2M_Status[3][9] = 1 Then ; if scwanted or svrwanted or vwrscwanted or vwrsvrwanted then ...
							V2M_startvnc('ssh') ;start vnc using ssh encryption
							TraySetState(4) ;start icon flashing
							$sTimestamp[1] = _DateAdd('s', _IniReadWrite($AppINI, "Common", "AppReRunTimer", "30") - 1, $sTimestamp[1]) ;sleep for 29 more seconds (30 in total)
							_GUICtrlStatusBar_SetIcon($V2M_GUI[42], 1, _WinAPI_LoadShell32Icon(111)) ; Set icon in main window
							_GUICtrlStatusBar_SetTipText($V2M_GUI[42], 2, _Translate($V2M_GUI_Language, "TRAYTIP_SSH_CONNECTED_LINE1", "") & " - AES 256")
							_GUICtrlStatusBar_SetIcon($V2M_GUI[43], 2, _WinAPI_LoadShell32Icon(111)) ; Set icon in main window
						ElseIf $V2M_Status[3][8] Then ;vwrscwanted
							$V2M_EventDisplay = YTS_EventLog("vwrscwanted", $V2M_EventDisplay, '8')
							V2M_startvnc('ssh') ;start vnc using ssh encryption
						ElseIf $V2M_Status[3][9] Then ;vwrsvrwanted
							$V2M_EventDisplay = YTS_EventLog("vwrsvrwanted", $V2M_EventDisplay, '8')
							V2M_startvnc('ssh') ;start vnc using ssh encryption
						EndIf
						$V2M_EventDisplay = YTS_EventLog("Starting Secure VNC Connection", $V2M_EventDisplay, '3')
					ElseIf $V2M_Status[3][5] = 1 Then ; scstarted
						If Not ProcessExists($V2M_VNC_SC) Then
							$V2M_EventDisplay = YTS_EventLog("SCstarted =1, NOT processexists()", $V2M_EventDisplay, '9')
							$V2M_Status[3][5] = 0 ; scstarted
						EndIf
					ElseIf $V2M_Status[3][7] = 1 Then ; SVRstarted
						If Not ProcessExists($V2M_VNC_SVR) Then
							$V2M_EventDisplay = YTS_EventLog("SVRstarted =1, NOT processexists()", $V2M_EventDisplay, '9')
							$V2M_Status[3][7] = 0 ; scstarted
						EndIf
					ElseIf $V2M_Status[3][10] = 1 Then ; vwrstarted
						If Not ProcessExists($V2M_VNC_VWR) Then
							$V2M_EventDisplay = YTS_EventLog("VWRstarted =1, NOT processexists()", $V2M_EventDisplay, '9')
							$V2M_Status[3][10] = 0 ; scstarted
						EndIf
					EndIf
				EndIf ; --> ssh connected
			EndIf ; If Not $V2M_Status[3][2]
		Else ;SSH/UVNC not wanted
			TraySetState(8)
		EndIf ; If $V2M_Status[3][1]
		If $V2MGUITimer = 1 Then
			;update connection timer in statusbars
			_GUICtrlStatusBar_SetText($V2M_GUI[42], @TAB & V2M_Timer('Read'), 2)
			_GUICtrlStatusBar_SetText($V2M_GUI[43], @TAB & V2M_Timer('Read'), 2)
		ElseIf Not $V2M_Status[3][1] Then ; ssh wanted
			;update time in statusbars
			_GUICtrlStatusBar_SetText($V2M_GUI[42], @TAB & StringFormat("%02d:%02d:%02d", @HOUR, @MIN, @SEC), 2)
			_GUICtrlStatusBar_SetText($V2M_GUI[43], @TAB & StringFormat("%02d:%02d:%02d", @HOUR, @MIN, @SEC), 2)
		EndIf ; If $V2MGUITimer = 1


		;		If _DateDiff('s', $sTimestamp[2], _NowCalc()) >= 0 Then
		;			$sTimestamp[2] = _DateAdd('n', 1, _NowCalc()) ;Add 1 minute to time ... so it will not come back here for 1 minute
		;			YTS_EventLog("                    $V2M_Status[1][3] = " & $V2M_Status[1][3] & " - " & @HOUR & ":" & @MIN & ":" & @SEC & ":" & @MSEC, $V2M_EventDisplay, '9')
		;			If $V2M_Status[1][3] > 2 Then ; if password has been asked for more than 2 times (3 or greater), then password is incorrect, reset it now
		;				$V2M_Status[1][3] = 0
		;				$V2M_EventDisplay = YTS_EventLog("SSH - authentication failure, too many password requests", $V2M_EventDisplay, '3')
		;				$V2M_SSH[3] = ""
		;				$sTimestamp[1] = _DateAdd('s', 2, _NowCalc())
		;				;				Sleep(500)
		;			Else ; else, reset password count now
		;				$V2M_Status[1][3] = 0
		;			EndIf
		;		EndIf

	EndIf ; end delayed loop section (used only once per second)

	;=========================================================================================================================================================
	;=================== Get any messages from the GUI (every cycle)
	;=========================================================================================================================================================
	$V2M_GUI_Msg = GUIGetMsg()
	Switch $V2M_GUI_Msg
		;	GUI Window Events
		Case -3 ;Or -3
			; GUI Window Closed
			If $V2M_Status[2][3] = 'show' Then ;debug GUI
				$V2M_EventDisplay = YTS_EventLog(V2MGuiChangeState($V2M_GUI_Debug, $V2M_GUI_DebugTitle, 'hide'), $V2M_EventDisplay, '6')
				GUICtrlSetState($V2M_GUI[33], 4) ;uncheck the checkbox
				$V2M_Status[2][3] = 'hide'
			ElseIf $V2M_Status[2][1] = 'show' Then ;main GUI
				;				MsgBox(0, "Exit VNC2Me", "Do you wish to close VNC2Me ?", 30)
				$V2M_EventDisplay = YTS_EventLog(V2MGuiChangeState($V2M_GUI_Main, $V2M_GUI_MainTitle, 'hide'), $V2M_EventDisplay, '6')
				$V2M_EventDisplay = YTS_EventLog(V2MGuiChangeState($V2M_GUI_Mini, $V2M_GUI_MiniTitle, 'show'), $V2M_EventDisplay, '6')
				$V2M_Status[2][1] = 'hide'
				TrayTip(_Translate($V2M_GUI_Language, "TRAYTIP_APP_GUISWITCH_TITLE", "APP_GUISWITCH_TITLE"), _Translate($V2M_GUI_Language, "TRAYTIP_APP_GUISWITCH_LINE1", "") & @CR & _Translate($V2M_GUI_Language, "TRAYTIP_APP_GUISWITCH_LINE2", ""), 10)
				;				TrayTip("V2M Tip ", "To Exit VNC2Me" & @CR & "Right Click this Icon", 10)
			ElseIf $V2M_Status[2][2] = 'show' Then ;mini GUI
				$V2M_EventDisplay = YTS_EventLog(V2MGuiChangeState($V2M_GUI_Mini, $V2M_GUI_MiniTitle, 'hide'), $V2M_EventDisplay, '6')
				$V2M_EventDisplay = YTS_EventLog(V2MGuiChangeState($V2M_GUI_Main, $V2M_GUI_MainTitle, 'show'), $V2M_EventDisplay, '6')
				$V2M_Status[2][2] = 'hide'
				TrayTip(_Translate($V2M_GUI_Language, "TRAYTIP_APP_GUISWITCH_TITLE", "APP_GUISWITCH_TITLE"), _Translate($V2M_GUI_Language, "TRAYTIP_APP_GUISWITCH_LINE1", "") & @CR & _Translate($V2M_GUI_Language, "TRAYTIP_APP_GUISWITCH_LINE2", ""), 10)
				;				TrayTip("V2M Tip ", "To Exit VNC2Me" & @CR & "Right Click this Icon", 10)
			EndIf
		Case $V2M_GUI[17] ;Main exit button
			$V2M_EventDisplay = YTS_EventLog("GUI - Exiting (MainButtonExit)", $V2M_EventDisplay, '5')
			$V2M_EventDisplay = YTS_EventLog(V2MGuiChangeState($V2M_GUI_Disclaimer, $V2M_GUI_DisclaimerTitle, 'hide'), $V2M_EventDisplay, '6')
			$V2M_EventDisplay = YTS_EventLog(V2MGuiChangeState($V2M_GUI_Debug, $V2M_GUI_DebugTitle, 'hide'), $V2M_EventDisplay, '6')
			$V2M_EventDisplay = YTS_EventLog(V2MGuiChangeState($V2M_GUI_Main, $V2M_GUI_MainTitle, 'hide'), $V2M_EventDisplay, '6')
			$V2M_EventDisplay = YTS_EventLog(V2MGuiChangeState($V2M_GUI_Mini, $V2M_GUI_MiniTitle, 'hide'), $V2M_EventDisplay, '6')
			$V2M_Exit = 1
		Case $V2M_GUI[31] ;Mini exit button
			$V2M_EventDisplay = YTS_EventLog("GUI - Exiting (MiniButtonExit)", $V2M_EventDisplay, '5')
			$V2M_EventDisplay = YTS_EventLog(V2MGuiChangeState($V2M_GUI_Disclaimer, $V2M_GUI_DisclaimerTitle, 'hide'), $V2M_EventDisplay, '6')
			$V2M_EventDisplay = YTS_EventLog(V2MGuiChangeState($V2M_GUI_Debug, $V2M_GUI_DebugTitle, 'hide'), $V2M_EventDisplay, '6')
			$V2M_EventDisplay = YTS_EventLog(V2MGuiChangeState($V2M_GUI_Main, $V2M_GUI_MainTitle, 'hide'), $V2M_EventDisplay, '6')
			$V2M_EventDisplay = YTS_EventLog(V2MGuiChangeState($V2M_GUI_Mini, $V2M_GUI_MiniTitle, 'hide'), $V2M_EventDisplay, '6')
			$V2M_Exit = 1
		Case $V2M_GUI[32] ; MainGUI File > Exit Clicked
			$V2M_EventDisplay = YTS_EventLog("Exiting (MainMenuExit)", $V2M_EventDisplay, '5')
			$V2M_EventDisplay = YTS_EventLog(V2MGuiChangeState($V2M_GUI_Disclaimer, $V2M_GUI_DisclaimerTitle, 'hide'), $V2M_EventDisplay, '6')
			$V2M_EventDisplay = YTS_EventLog(V2MGuiChangeState($V2M_GUI_Debug, $V2M_GUI_DebugTitle, 'hide'), $V2M_EventDisplay, '6')
			$V2M_EventDisplay = YTS_EventLog(V2MGuiChangeState($V2M_GUI_Main, $V2M_GUI_MainTitle, 'hide'), $V2M_EventDisplay, '6')
			$V2M_EventDisplay = YTS_EventLog(V2MGuiChangeState($V2M_GUI_Mini, $V2M_GUI_MiniTitle, 'hide'), $V2M_EventDisplay, '6')
			$V2M_Exit = 1
		Case $V2M_GUI[30] ; debug copy > clipboard clicked
			$clipboard = GUICtrlRead($V2M_GUI_DebugOutputEdit)
			ClipPut($clipboard)
			TrayTip(_Translate($V2M_GUI_Language, "TRAYTIP_DEBUG_COPIED_TITLE", "DEBUG_COPIED_TITLE"), _Translate($V2M_GUI_Language, "TRAYTIP_DEBUG_COPIED_LINE1", "") & @CR & _Translate($V2M_GUI_Language, "TRAYTIP_DEBUG_COPIED_LINE2", ""), 10)
		Case $V2M_GUI[15] ; MainGUI Help > About Clicked
			$V2M_EventDisplay = YTS_EventLog("GUI - MainAbout", $V2M_EventDisplay, '5')
			V2MAboutBox()
			;	GUI Main Button's
		Case $V2M_GUI[20] ;Tab_SC_ButtonConnect
			$V2M_EventDisplay = YTS_EventLog("GUI - VNC SC ButtonConnect", $V2M_EventDisplay, '5')
			$V2M_EventDisplay = YTS_EventLog("VNC - Support Session Requested", $V2M_EventDisplay, '5')
			$V2M_Status[1][1] = 'SC' ;ConnectionType is SC
			$V2M_Status[3][1] = 1 ; ssh wanted
			$V2M_Status[3][2] = 0 ; ssh started
			$V2M_Status[3][3] = 0 ; ssh Connected
			$V2M_Status[3][4] = 1 ; SC wanted
			$V2M_Status[3][6] = 0 ; svrwanted
			$V2M_Status[3][8] = 0 ; vwrscwanted
			$V2M_Status[3][9] = 0 ; vwrsvrwanted
			;			$V2M_CompressSSH = GUICtrlRead($V2M_GUI[65])

		Case $V2M_GUI[36] ;GUI_SVR_ButtonConnect
			$V2M_EventDisplay = YTS_EventLog("GUI - VNC SVR ButtonConnect", $V2M_EventDisplay, '5')
			$V2M_EventDisplay = YTS_EventLog("VNC - Collaboration Session Requested", $V2M_EventDisplay, '3')
			$V2M_Status[1][1] = 'SVR' ;ConnectionType is Collaboration Server
			$V2M_Status[3][1] = 1 ; ssh wanted
			$V2M_Status[3][2] = 0 ; ssh started
			$V2M_Status[3][3] = 0 ; ssh Connected
			$V2M_Status[3][4] = 0 ; SC wanted
			$V2M_Status[3][6] = 1 ; svr wanted
			$V2M_Status[3][8] = 0 ; vwr scwanted
			$V2M_Status[3][9] = 0 ; vwr svrwanted
			$V2M_SessionCode = GUICtrlRead($V2M_GUI[35])
		Case $V2M_GUI[10] ;Tab_VWR_ButtonConnect clicked
			$V2M_EventDisplay = YTS_EventLog("GUI - VNC VWR ButtonConnect", $V2M_EventDisplay, '5')
			If $V2M_Status[3][8] = 1 Or GUICtrlRead($V2M_GUI[40]) = 1 Then ;vwrscwanted
				$V2M_EventDisplay = YTS_EventLog("VNC - Viewer for SC Session Requested", $V2M_EventDisplay, '3')
				TrayTip(_Translate($V2M_GUI_Language, "TRAYTIP_VWR_STARTSC_TITLE", "VWR_STARTSC_TITLE"), _Translate($V2M_GUI_Language, "TRAYTIP_VWR_STARTSC_LINE1", "") & @CR & _Translate($V2M_GUI_Language, "TRAYTIP_VWR_STARTSC_LINE2", ""), 30)
				$V2M_Status[3][8] = 1
			ElseIf $V2M_Status[3][9] = 1 Or GUICtrlRead($V2M_GUI[41]) = 1 Then ;vwrsvrwanted
				$V2M_EventDisplay = YTS_EventLog("VNC - Viewer for SVR Session Requested", $V2M_EventDisplay, '3')
				TrayTip(_Translate($V2M_GUI_Language, "TRAYTIP_VWR_STARTSVR_TITLE", "VWR_STARTSVR_TITLE"), _Translate($V2M_GUI_Language, "TRAYTIP_VWR_STARTSVR_LINE1", "") & @CR & _Translate($V2M_GUI_Language, "TRAYTIP_VWR_STARTSVR_LINE2", ""), 30)
				$V2M_Status[3][9] = 1
			EndIf
			$V2M_Status[1][1] = 'VWR' ;ConnectionType is viewer
			$V2M_Status[3][1] = 1 ; ssh wanted
			$V2M_Status[3][2] = 0 ; ssh started
			$V2M_Status[3][3] = 0 ; ssh Connected
			$V2M_Status[3][4] = 0 ; SC wanted
			$V2M_Status[3][6] = 0 ; svr wanted
			$V2M_SessionCode = GUICtrlRead($V2M_GUI[12])
		Case $V2M_GUI[21] ;Tab_SC_ButtonStop Clicked
			$V2M_EventDisplay = YTS_EventLog("GUI - VNC SC ButtonStop", $V2M_EventDisplay, '5')
			$V2M_Status[1][1] = '' ;ConnectionType
			$V2M_Status[3][4] = 0 ; SC wanted
			$V2M_Status[3][6] = 0 ; svrwanted
			$V2M_Status[3][8] = 0 ; vwrscwanted
			$V2M_Status[3][9] = 0 ; vwrsvrwanted
			V2MExitVNC()
			_RefreshSystemTray(50)
		Case $V2M_GUI[37] ;GUI_SVR_ButtonStop
			$V2M_EventDisplay = YTS_EventLog("GUI - VNC SVR ButtonStop", $V2M_EventDisplay, '5')
			$V2M_Status[1][1] = '' ;ConnectionType
			$V2M_Status[3][4] = 0 ; SC wanted
			$V2M_Status[3][6] = 0 ; svrwanted
			$V2M_Status[3][8] = 0 ; vwrscwanted
			$V2M_Status[3][9] = 0 ; vwrsvrwanted
			V2MExitVNC()
			_RefreshSystemTray(50)
		Case $V2M_GUI[11] ;Tab_VWR_ButtonStop clicked
			$V2M_EventDisplay = YTS_EventLog("GUI - VNC VWR ButtonStop", $V2M_EventDisplay, '5')
			$V2M_Status[1][1] = '' ;ConnectionType
			$V2M_Status[3][4] = 0 ; SC wanted
			$V2M_Status[3][6] = 0 ; svrwanted
			$V2M_Status[3][8] = 0 ; vwrscwanted
			$V2M_Status[3][9] = 0 ; vwrsvrwanted
			V2MExitVNC()
			_RefreshSystemTray(50)
			;	GUI Debug Buttons
		Case $V2M_GUI[28] ;DEBUG SSH button pressed
			$V2M_EventDisplay = YTS_EventLog("GUI - Debug SSH button pressed", $V2M_EventDisplay, '5')
			$V2M_Status[1][1] = 'SSH' ;ConnectionType is SSH ONLY
			$V2M_Status[3][1] = 1 ; SSH wanted
			$V2M_Status[3][4] = 0 ; SC wanted
			$V2M_Status[3][6] = 0 ; svrwanted
			$V2M_Status[3][8] = 0 ; vwrscwanted
			$V2M_Status[3][9] = 0 ; vwrsvrwanted
		Case $V2M_GUI[29] ;Debug SSH Stop button pressed
			$V2M_EventDisplay = YTS_EventLog("GUI - Debug SSH ButtonStop", $V2M_EventDisplay, '5')
			$V2M_Status[3][1] = 0
			$V2M_Status[3][2] = 0 ; SC started
			$V2M_Status[3][4] = 0 ; SC wanted
			$V2M_Status[3][6] = 0 ; svrwanted
			$V2M_Status[3][8] = 0 ; vwrscwanted
			$V2M_Status[3][9] = 0 ; vwrsvrwanted
			V2MExitSSH()
			_RefreshSystemTray(50)
		Case $V2M_GUI[38] ;GUI_VWR_SsnRndChbx
			If (IniRead($AppINI, "V2M_Server", "SESSION_CODE", "") = "") Then
				If GUICtrlRead($V2M_GUI[38]) = 1 Then
					$V2M_EventDisplay = YTS_EventLog("GUI - Random Session Code Generated", $V2M_EventDisplay, '5')
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
			If (IniRead($AppINI, "V2M_Server", "SESSION_CODE", "") = "") Then
				If GUICtrlRead($V2M_GUI[39]) = 1 Then
					$V2M_EventDisplay = YTS_EventLog("GUI - Random Session Code Generated", $V2M_EventDisplay, '5')
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
					$V2M_EventDisplay = YTS_EventLog(V2MGuiChangeState($V2M_GUI_Debug, $V2M_GUI_DebugTitle, 'show'), $V2M_EventDisplay, '5')
				EndIf
			Else
				$V2M_Status[2][3] = 'hide' ;debug window hide
				$V2M_EventDisplay = YTS_EventLog(V2MGuiChangeState($V2M_GUI_Debug, $V2M_GUI_DebugTitle, 'hide'), $V2M_EventDisplay, '5')
			EndIf
		Case $V2M_GUI[40] ;TAB VWR Radio Items
			$V2M_EventDisplay = YTS_EventLog("VWR - SC Connection", $V2M_EventDisplay, '3')
			GUICtrlSetState($V2M_GUI[38], $GUI_DISABLE) ;Disable the random session code checkbox
			;			$V2M_Status[3][8] = 1 ;vwrscwanted
			;			MsgBox(0, "", "SC", 1)
			;the following where a trial that didn't work
		Case $V2M_GUI[41] ;TAB VWR Radio Items
			$V2M_EventDisplay = YTS_EventLog("VWR - SVR Connection", $V2M_EventDisplay, '3')
			GUICtrlSetState($V2M_GUI[38], $GUI_ENABLE) ;Enable the random session code checkbox
			;			$V2M_Status[3][9] = 1 ;vwrSVRwanted
			;			MsgBox(0, "", "SVR", 1)
		Case $V2M_GUI[61] ;Disclaimer Accept Button
			GUISwitch($V2M_GUI_Disclaimer)
			GUISetState(@SW_HIDE, $V2M_GUI_DisclaimerTitle)
			GUIDelete($V2M_GUI_Disclaimer)
			GUISwitch($V2M_GUI_Main)
			GUISetState(@SW_SHOW, $V2M_GUI_Main)
			TrayItemSetState($V2M_Tray[3], $TRAY_CHECKED)
			TraySetState(1)
		Case $V2M_GUI[62] ;Disclaimer Reject Button
			$V2M_EventDisplay = YTS_EventLog(V2MGuiChangeState($V2M_GUI_Disclaimer, $V2M_GUI_DisclaimerTitle, 'hide'), $V2M_EventDisplay, '6')
			$V2M_EventDisplay = YTS_EventLog(V2MGuiChangeState($V2M_GUI_Debug, $V2M_GUI_DebugTitle, 'hide'), $V2M_EventDisplay, '6')
			$V2M_EventDisplay = YTS_EventLog(V2MGuiChangeState($V2M_GUI_Main, $V2M_GUI_MainTitle, 'hide'), $V2M_EventDisplay, '6')
			$V2M_EventDisplay = YTS_EventLog(V2MGuiChangeState($V2M_GUI_Mini, $V2M_GUI_MiniTitle, 'hide'), $V2M_EventDisplay, '6')
			$V2M_Exit = 1
		Case $V2M_GUI[63] ;Disclaimer Exit Button
			$V2M_EventDisplay = YTS_EventLog(V2MGuiChangeState($V2M_GUI_Disclaimer, $V2M_GUI_DisclaimerTitle, 'hide'), $V2M_EventDisplay, '6')
			$V2M_EventDisplay = YTS_EventLog(V2MGuiChangeState($V2M_GUI_Debug, $V2M_GUI_DebugTitle, 'hide'), $V2M_EventDisplay, '6')
			$V2M_EventDisplay = YTS_EventLog(V2MGuiChangeState($V2M_GUI_Main, $V2M_GUI_MainTitle, 'hide'), $V2M_EventDisplay, '6')
			$V2M_EventDisplay = YTS_EventLog(V2MGuiChangeState($V2M_GUI_Mini, $V2M_GUI_MiniTitle, 'hide'), $V2M_EventDisplay, '6')
			$V2M_Exit = 1

	EndSwitch
	;
	;=========================================================================================================================================================
	; Get any messages from the TrayIcon
	$V2M_TrayMsg = TrayGetMsg()
	Switch $V2M_TrayMsg
		Case $TRAY_EVENT_PRIMARYDOWN
			$V2M_EventDisplay = YTS_EventLog("GUI - Tray PrimaryClick", $V2M_EventDisplay, '5')
			V2MAboutBox()
		Case $V2M_Tray[1] ; Exit
			$V2M_EventDisplay = YTS_EventLog("GUI - Exiting (Tray)", $V2M_EventDisplay, '5')
			$V2M_EventDisplay = YTS_EventLog(V2MGuiChangeState($V2M_GUI_Disclaimer, $V2M_GUI_DisclaimerTitle, 'hide'), $V2M_EventDisplay, '6')
			$V2M_EventDisplay = YTS_EventLog(V2MGuiChangeState($V2M_GUI_Debug, $V2M_GUI_DebugTitle, 'hide'), $V2M_EventDisplay, '6')
			$V2M_EventDisplay = YTS_EventLog(V2MGuiChangeState($V2M_GUI_Main, $V2M_GUI_MainTitle, 'hide'), $V2M_EventDisplay, '6')
			$V2M_EventDisplay = YTS_EventLog(V2MGuiChangeState($V2M_GUI_Mini, $V2M_GUI_MiniTitle, 'hide'), $V2M_EventDisplay, '6')
			$V2M_Exit = 1
		Case $V2M_Tray[8] ; About
			$V2M_EventDisplay = YTS_EventLog("GUI - Tray About", $V2M_EventDisplay, '5')
			V2MAboutBox()
		Case $V2M_Tray[3] ;show > main
			TrayItemSetState($V2M_Tray[3], 1)
			$V2M_EventDisplay = YTS_EventLog(V2MGuiChangeState($V2M_GUI_Mini, $V2M_GUI_MiniTitle, 'hide'), $V2M_EventDisplay, '5')
			$V2M_Status[2][2] = 'hide'
			$V2M_EventDisplay = YTS_EventLog(V2MGuiChangeState($V2M_GUI_Main, $V2M_GUI_MainTitle, 'show'), $V2M_EventDisplay, '5')
			$V2M_Status[2][1] = 'show'
		Case $V2M_Tray[4] ;show > mini
			TrayItemSetState($V2M_Tray[4], 1)
			$V2M_EventDisplay = YTS_EventLog(V2MGuiChangeState($V2M_GUI_Main, $V2M_GUI_MainTitle, 'hide'), $V2M_EventDisplay, '5')
			$V2M_Status[2][1] = 'hide'
			$V2M_EventDisplay = YTS_EventLog(V2MGuiChangeState($V2M_GUI_Mini, $V2M_GUI_MiniTitle, 'show'), $V2M_EventDisplay, '5')
			$V2M_Status[2][2] = 'show'
		Case $V2M_Tray[6] ;show > debug
			TrayItemSetState($V2M_Tray[6], 1)
			GUICtrlSetState($V2M_GUI[33], 1)
			$V2M_EventDisplay = YTS_EventLog(V2MGuiChangeState($V2M_GUI_Debug, $V2M_GUI_DebugTitle, 'show'), $V2M_EventDisplay, '5')
		Case $V2M_Tray[7] ;show > none
			TrayItemSetState($V2M_Tray[7], 1)
			$V2M_EventDisplay = YTS_EventLog(V2MGuiChangeState($V2M_GUI_Main, $V2M_GUI_MainTitle, 'hide'), $V2M_EventDisplay, '5')
			$V2M_Status[2][1] = 'hide'
			$V2M_EventDisplay = YTS_EventLog(V2MGuiChangeState($V2M_GUI_Mini, $V2M_GUI_MiniTitle, 'hide'), $V2M_EventDisplay, '5')
			$V2M_Status[2][2] = 'hide'
			ToolTip("")
			;		Case $V2M_Tray[5]
			;			TrayItemSetState($V2M_Tray[5], 1)
			;			$V2M_Status[2][4] = 1
			;			;			ToolTip("Connected for : " & V2M_Timer('Read'), 10, 30)
	EndSwitch
WEnd
TraySetState(8)
OnAutoItExit()