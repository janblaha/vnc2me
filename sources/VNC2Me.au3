#RequireAdmin
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=..\compiled\v2m.ico
#AutoIt3Wrapper_Outfile=..\compiled\VNC2Me.exe
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_Res_Comment=Creates Secure SSH tunnel, VNC then tunnels through this, making VNC ALOT more secure.
#AutoIt3Wrapper_Res_Description=VNC2Me - Allows Remote Desktop sharing securely over the internet.
#AutoIt3Wrapper_Res_Fileversion=0.0.2.20
#AutoIt3Wrapper_Res_FileVersion_AutoIncrement=p
#AutoIt3Wrapper_Res_LegalCopyright=Sec IT (GPL) 2008
#AutoIt3Wrapper_res_requestedExecutionLevel=requireAdministrator
#AutoIt3Wrapper_Res_Field="Made By"|"Jim Dolby"
#AutoIt3Wrapper_Res_Icon_Add=v2m.ico
#AutoIt3Wrapper_Au3Check_Stop_OnWarning=y
#AutoIt3Wrapper_Run_Tidy=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****


#Region --- Script patched by FreeStyle code Start 20.07.2008 - 11:15:22

#EndRegion --- Script patched by FreeStyle code Start 20.07.2008 - 11:15:22


#Region --- Script patched by FreeStyle code Start 20.07.2008 - 11:12:49

#EndRegion --- Script patched by FreeStyle code Start 20.07.2008 - 11:12:49
;#AutoIt3Wrapper_res_File_Add=v2mplink.exe
;#AutoIt3Wrapper_res_File_Add=v2mvwr.exe
;#AutoIt3Wrapper_res_File_Add=vnc2me.ini
;#AutoIt3Wrapper_res_File_Add=VNCHooks.dll
; http://www.autoitscript.com/forum/index.php?s=&showtopic=12828&view=findpost&p=88305
;Opt("TrayAuto", 0)		;Pause Script pauses when click on tray icon.		0 = no pause	1 = pause (default). If there is no DefaultMenu no pause will occurs.
Opt("TrayIconDebug", 1) ;If enabled shows the current script line in the tray icon tip to help debugging.		0 = no debug information (default)	1 = show debug
Opt("TrayIconHide", 0) ;Hides the AutoIt tray icon. Note: The icon will still initially appear ~750 milliseconds.		0 = show icon (default)	1 = hide icon
Opt("TrayMenuMode", 1) ;Extend the behaviour of the script tray icon/menu. This can be done with a combination (adding) of the following values.		0 = default menu items (Script Paused/Exit) are appended to the usercreated menu; usercreated checked items will automatically unchecked; if you double click the tray icon then the controlid is returned which has the "Default"-style (default).		1 = no default menu		2 = user created checked items will not automatically unchecked if you click it		4 = don't return the menuitemID which has the "default"-style in the main contextmenu if you double click the tray icon		8 = turn off auto check of radio item groups
;Opt("ExpandEnvStrings", 1)
;Opt("ExpandVarStrings", 1)
Opt("MustDeclareVars", 0)
;Opt("RunErrorsFatal", 0)

#include "V2M_GlobalVars.au3"
#include "V2M_Functions.au3"
#include "V2M_TimerFunc.au3"
#include "Includes\_RefreshSystemTray.au3"
;#include "Includes\XSkin.au3"
;#include "Includes\XSkinTray.au3"
#include "V2M_GUI.au3"
#include <GuiConstants.au3>

;declare host, user & pass, if include is commented out, script asks for them.
Dim $V2M_SSH_Hostname = ""
Dim $V2M_SSH_Username = ""
Dim $V2M_SSH_Password = ""
;#include "V2M_Private_server_details.au3" ;comment out this line to ask for host, user & pass




;HotKeySet("{F1}", "StartTimer")
;HotKeySet("{F12}", $V2M_SSH_ProcessID = V2MSSHConnect($V2M_SSH_PortFwdDirection))
;If FileExists(@ScriptDir & "\V2Msc.exe") Then
Dim $V2M_VNC_SC = "V2Msc.exe"
;Else
;	$V2M_VNC_SC = "V2Msrv.exe"
;EndIf



If ProcessExists($V2M_VNC_SC) Then
	ProcessClose($V2M_VNC_SC)
EndIf
If ProcessExists("V2Msrv.exe") Then
	ProcessClose("V2Msrv.exe")
EndIf
If ProcessExists("v2mvwr.exe") Then
	ProcessClose("V2Mvwr.exe")
EndIf
If ProcessExists("v2mplink.exe") Then
	ProcessClose("v2mplink.exe")
EndIf





TraySetState()
TraySetIcon("v2m.ico")
$V2M_Tray_Exit = TrayCreateItem("Exit")
$V2M_Tray_GUISwap = TrayCreateItem("Swap")



;
;=========================================================================================================================================================
; If commandline arguments, what to do ...
;If $CmdLine[0] = 0 Then
;	V2M_EventLog("NO Cmdline Arguements found", $V2M_EventDisplay, 1)
;	;continue as normal
;
;ElseIf $CmdLine[1] = "connect" Or $CmdLine[1] = "-c" Or $CmdLine[1] = "-connect" Or $CmdLine[1] = "/c" Or $CmdLine[1] = "/connect" Then
;	V2M_EventLog("Cmdline Arguements found", $V2M_EventDisplay, 1)
;
;ElseIf $CmdLine[1] = "loopback" Or $CmdLine[1] = "LoopBack" Then
;	V2M_EventLog("LoopBack Cmdline Arguements found", $V2M_EventDisplay, 1)
;
;Else
;	V2M_EventLog("NO Cmdline Arguements found", $V2M_EventDisplay, 1)
;	TrayTip("VNC2Me Starting ... ", "VNC2Me GUI Started"& @CR & "NO Cmdline Arguements found", 10)
;EndIf

#Region Commandline lexing
; retrieve commandline parameters (not yet implemented)
;-------------------------------------------------------------------------------------------
$V_Arg = "Valid Arguments are:" & @CRLF
$V_Arg = $V_Arg & "    /connect  [future use with autostart after reboots, and in safemode]" & @CRLF
$V_Arg = $V_Arg & "    /nossh  [*posible* future use to allow bypass of SSH components]" & @CRLF
;
For $x = 1 To $CMDLINE[0]
	$T_Var = StringLower($CMDLINE[$x])
	;MsgBox( 1, "debug", "argument: " & $t_var,1)
	$Parameter_Mode = 1
	Select
		Case $T_Var = "/connect"
			; when launched with connect string, port setting (and if defined server, user & pass) are read from the INI file.
			V2M_EventLog("CONNECT Cmdline Arguements found", $V2M_EventDisplay, 1)
			;			$H_Cmp = $CMDLINE[$x + 1]
			;			$H_au3 = $CMDLINE[$x + 2]
		Case $T_Var = "/?" Or $T_Var = "/help"
			MsgBox(1, "VNC2Me", "VNC2Me has the following commandline arguments: " & $T_Var & @LF & $V_Arg)
			Exit
			;		Case $T_Var = "/in"
			;			$x = $x + 1
			;			$ScriptFile_In = $CMDLINE[$x]
			;		Case $T_Var = "/compress" Or $T_Var = "/comp" Or $T_Var = "/compression"
			;			$x = $x + 1
			;			$INP_Compression = Number($CMDLINE[$x])
		Case Else
			V2M_EventLog("NO Cmdline Arguements found", $V2M_EventDisplay, 1)
			TrayTip("VNC2Me Starting ... ", "VNC2Me GUI Started" & @CR & "NO Cmdline Arguements found", 10)
	EndSelect
Next
#EndRegion Commandline lexing













;
;=========================================================================================================================================================
; Vista Modifications to allow faster vista support
Dim $curVal = ""

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


;
;=========================================================================================================================================================
; Loop unitl we hit Exit (or get an error)
While 1
	If $V2M_LoopCount = 0 Then
		; We assign the process ID of plink to $V2M_SSH_ProcessID below...
		If ProcessExists("v2mplink.exe") Then
			; $V2M_GUI_MiniTitle is updated title name for timer GUI
			If $V2MGUITimer Then
				;Update the title bar (mostly just to have something to look at.)
				ReadTimer()
				If $V2M_GUI_MiniTitle = $V2M_Name & "         (Connected for : " & FMTMSec($elapsed) & ")" Then

				Else
					$V2M_GUI_MiniTitle = $V2M_Name & "         (Connected for : " & FMTMSec($elapsed) & ")"
					GUISwitch($V2M_GUI_Mini)
					WinSetTitle($V2M_Name, "", $V2M_GUI_MiniTitle)
					Sleep(100)
				EndIf

				; If Timer Windows Active
				If WinActive($V2M_GUI_MiniTitle) Then
					; Check if WinActive has been set before, if not, de-activate transparency, and set WinActive (saves refreshing GUI Transparency)
					If Not $V2M_GUI_MiniNoTransparency Then
						WinSetTrans($V2M_GUI_MiniTitle, "", 255)
						$V2M_GUI_MiniNoTransparency = 1
					EndIf

				Else
					WinSetTrans($V2M_GUI_MiniTitle, "", 180)
					$V2M_GUI_MiniNoTransparency = 0
				EndIf
			EndIf

			; Calling StdoutRead like this returns the characters waiting to be read, without removing them.
			$V2M_SSH_ReadCharsWaiting = StdoutRead($V2M_SSH_ProcessID, 0, 1)
			; If there was an error reading, the most likely cause us that the child process has quit...
			If @error = -1 Then
				$V2M_EventLog = "SSH - STDOUT unable to be read"
				$V2M_EventDisplay = V2M_EventLog($V2M_EventLog, $V2M_EventDisplay, 1)
				$V2M_SSH_ProcessID = '' ; Set $V2M_SSH_ProcessID to zero so we don't try to read anything further...
				If $V2M_SSHStarted = 1 Then
				Else
					;				Sleep(100)
				EndIf
			EndIf

			; Calling StdoutRead like this returns the characters waiting to be read, without removing them.
			$V2M_SSH_ErrCharsWaiting = StderrRead($V2M_SSH_ProcessID, 0, 1)
			If @error = -1 Then
				$V2M_EventLog = "SSH - STDERR unable to be read"
				$V2M_EventDisplay = V2M_EventLog($V2M_EventLog, $V2M_EventDisplay, 1)
				$V2M_SSH_ProcessID = 0
				If $V2M_SSHStarted = 1 Then
				Else
					;				Sleep(100)
				EndIf
			EndIf

			; no errors > is there STDOUT to be read ?
			If $V2M_SSH_ReadCharsWaiting Then
				; Read all available
				$currentRead = StdoutRead($V2M_SSH_ProcessID)
				;detect username and password in STDOUT
				$V2M_SSH_ReadUsername = StringRegExp($currentRead, $V2M_SSH_DetectUsername)
				$V2M_SSH_ReadPassword = StringRegExp($currentRead, $V2M_SSH_DetectPassword)

				; If Username has been detected, do the thing
				If $V2M_SSH_ReadUsername = 1 Then
					$V2M_EventLog = "SSH AUTH - 'login' detected"
					$V2M_EventDisplay = V2M_EventLog($V2M_EventLog, $V2M_EventDisplay, 1)
					TrayTip("Secure Connection Starting", "Sending Login Details to server", 10)
					If $V2M_SSH_Username = '' Then
						$V2M_SSH_Username = V2MInBoxSTDINWrite($V2M_SSH_ProcessID, '', "Username", "Enter Username")
					Else
						StdinWrite($V2M_SSH_ProcessID, $V2M_SSH_Username & " " & @CR)
					EndIf
				ElseIf $V2M_SSH_ReadPassword = 1 Then
					$V2M_EventLog = "SSH AUTH - 'password' detected"
					$V2M_EventDisplay = V2M_EventLog($V2M_EventLog, $V2M_EventDisplay, 1)
					TrayTip("Secure Connection Starting", "Sending Login Details to server", 10)
					If $V2M_SSH_Password = '' Then
						$V2M_SSH_Password = V2MInBoxSTDINWrite($V2M_SSH_ProcessID, '', "Password", "Enter Password", "*")
					Else
						StdinWrite($V2M_SSH_ProcessID, $V2M_SSH_Password & " " & @CR)
					EndIf
				Else
					; Add the rest of what is read from STDOUT to the editbox
					$V2M_EventLog = "SSH STDOUT updates fed to GUI"
					$V2M_EventDisplay = V2M_EventLog($V2M_EventLog, $V2M_EventDisplay, 1)
					GUICtrlSetData($V2M_GUI_DebugOutputEdit, @CRLF & $currentRead, 1)
				EndIf

				; no errors > is there STDOUT to be read ?
			ElseIf $V2M_SSH_ErrCharsWaiting Then
				; Read all available
				$currentErr = StderrRead($V2M_SSH_ProcessID)
				;detect "Host key not present"
				$V2M_SSH_ErrHostKey = StringRegExp($currentErr, $V2M_SSH_DetectNoHostKey)
				$V2M_SSH_PortRefused = StringRegExp($currentErr, $V2M_SSH_DetectPortRefused)
				$V2M_SSH_Connected = StringRegExp($currentErr, $V2M_SSH_DetectConnected)
				$V2M_SSH_VNCDisconnect = StringRegExp($currentErr, $V2M_SSH_DetectVNCDisconnect)
				If $V2M_SSH_ErrHostKey = 1 Then
					$V2M_EventLog = "SSH - Host Key Not Known"
					$V2M_EventDisplay = V2M_EventLog($V2M_EventLog, $V2M_EventDisplay)
					V2MAddHostKey()
					GUICtrlSetData($V2M_GUI_DebugOutputEdit, $currentErr, 1)
				ElseIf $V2M_SSH_PortRefused = 1 Then
					If $V2M_VNC_SCStart = 1 Then
						$V2M_EventLog = "VNC - Disconnected from viewer"
						$V2M_EventDisplay = V2M_EventLog($V2M_EventLog, $V2M_EventDisplay, 1)

						GUICtrlSetData($V2M_GUI_DebugOutputEdit, $currentErr, 1)
						$V2M_MsgBox = MsgBox(270373, "Error", "VNC Connection Not Established," & @CRLF & "Should I Retry same port ?", 60)
						If $V2M_MsgBox = 2 Then ;cancel pressed
							V2MExitSSH()
							V2MExitVNC()
							$V2M_AutoReconnect = 0
							GUISwitch($V2M_GUI_Mini)
							GUISetState(@SW_HIDE, $V2M_GUI_MiniTitle)
							GUISwitch($V2M_GUI_Main)
							GUISetState(@SW_SHOW, $V2M_GUI_MainTitle)
						Else ;retry pressed or timeout
							V2MExitSSH()
							V2MExitVNC()
							;						$V2M_SessionCode = V2MRandomPort()
							$V2M_SSH_ProcessID = V2MSSHConnect($V2M_SSH_PortFwdDirection)
						EndIf
					Else
						$V2M_EventLog = "SSH STDERR - Romote Port Refused"
						$V2M_EventDisplay = V2M_EventLog($V2M_EventLog, $V2M_EventDisplay, 1)

						GUICtrlSetData($V2M_GUI_DebugOutputEdit, $currentErr, 1)
						MsgBox(0, "Debug", "Remote Port(s) refused," & @CRLF & "Reconnecting", 5)
						V2MExitSSH()
						$V2M_SessionCode = V2MRandomPort()
						$V2M_SSH_ProcessID = V2MSSHConnect($V2M_SSH_PortFwdDirection)
					EndIf

				ElseIf $V2M_SSH_Connected = 1 Then ;we now have stable ssh connection
					$V2M_EventLog = "SSH - Stable Connection"
					$V2M_EventDisplay = V2M_EventLog($V2M_EventLog, $V2M_EventDisplay)
					TrayTip("Secure Connection Started", "Stable Connection to server established" & @LF & "Starting VNC", 10)

					GUICtrlSetData($V2M_GUI_DebugOutputEdit, $currentErr, 1)
					GUICtrlSetData($V2M_GUI_VWR_InputCode & @CRLF, $V2M_SessionCode)
					GUICtrlSetData($V2M_GUI_MiniSessionCode & @CRLF, $V2M_SessionCode)
					StartTimer()

					GUISwitch($V2M_GUI_Main)
					GUISetState(@SW_HIDE, $V2M_GUI_MainTitle)
					GUISwitch($V2M_GUI_Mini)
					GUISetState(@SW_SHOW, $V2M_GUI_MiniTitle)
					If $V2M_GUI_MainSwap = '' Then
						$V2M_GUI_MainSwap = GUICtrlCreateMenuItem("Show Minimal", $V2M_GUI_MainFileMenu)
					EndIf
					$V2MGUITimer = 1
					;	Start VNC Server
					If $V2M_ConnectType = 'VWR' Then
						; start VWR
						$V2M_VNC_ViewerProcessID = Run(@ScriptDir & "\V2Mvwr.exe -listen 15500 -8greycolours -autoscaling", @ScriptDir, @SW_HIDE, 7)
					ElseIf $V2M_ConnectType = 'SC' Then
						; start SC
						If $V2M_AutoReconnect = 1 Then
							Sleep(2000)
							Run($V2M_VNC_SC & " -connect 127.0.0.1:25400", @ScriptDir, @SW_HIDE, 7)
							$V2M_VNC_SCStart = 1
							$V2M_VNC_SCStarted = 1
						Else
							$V2M_VNC_SCStart = 0
						EndIf
					ElseIf $V2M_ConnectType = 'SRV' Then
						; start SRV
					Else
						; do nothing
					EndIf
				ElseIf $V2M_SSH_VNCDisconnect = 1 Then ;VNC App closed or disconnected
					If $V2M_AutoReconnect = 1 And $V2M_VNC_SCStart = 1 Then
						Sleep(2000)
						Run($V2M_VNC_SC & " -connect 127.0.0.1:25400", @ScriptDir, @SW_HIDE, 7)
						$V2M_EventLog = "VNC App Restarting"
						$V2M_EventDisplay = V2M_EventLog($V2M_EventLog & @CRLF, $V2M_EventDisplay)
					EndIf

				Else
					GUICtrlSetData($V2M_GUI_DebugOutputEdit, $currentErr, 1)
					$V2M_EventLog = "SSH STDERR updates fed to GUI"
					$V2M_EventDisplay = V2M_EventLog($V2M_EventLog, $V2M_EventDisplay, 1)
				EndIf
			EndIf ; => no program output waiting.
		Else
			If $V2M_AutoReconnect = 1 Then
				$V2M_EventLog = "SSH - Reconnecting"
				$V2M_EventDisplay = V2M_EventLog($V2M_EventLog, $V2M_EventDisplay)
				;		MsgBox(0, "Debug", "Reconnecting", 30)
				$V2M_SSH_ProcessID = V2MSSHConnect($V2M_SSH_PortFwdDirection)
				$V2M_EventLog = "$V2M_SSH_ProcessID = " & $V2M_SSH_ProcessID
				$V2M_EventDisplay = V2M_EventLog($V2M_EventLog, $V2M_EventDisplay, 1)
			EndIf
		EndIf
		
		If $V2M_VNC_SCStarted = 1 And $V2M_AutoReconnect = 1 Then
			If ProcessExists($V2M_VNC_SC) Then
				;			Sleep(300)
				;			msgbox(0, "Debug", "", 2)
			Else
				Sleep(2000)
				$V2M_VNC_ProcessID = Run($V2M_VNC_SC & " -connect 127.0.0.1:25400", @ScriptDir, @SW_HIDE, 7)
			EndIf
		EndIf

	EndIf

	;
	;=========================================================================================================================================================
	;=========================================================================================================================================================
	;=========================================================================================================================================================
	; Get any messages from the GUI
	$V2M_GUI_Msg = GUIGetMsg()
	Select
		;	GUI Window Events
		Case $V2M_GUI_Msg = -3
			If WinActive($V2M_GUI_DebugTitle) Then
				$V2M_EventDisplay = V2M_EventLog(V2MGuiChangeState($V2M_GUI_Debug, $V2M_GUI_DebugTitle, 'hide'), $V2M_EventDisplay, 1)
				;				GUISwitch($V2M_GUI_Debug)
				;				GUISetState(@SW_HIDE, $V2M_GUI_DebugTitle)
				;untick debug checkbox
				GUICtrlSetState($V2M_GUI_DebugCheckbox, 4)
				;				V2M_EventLog('GUI - Debug Window Closed', $V2M_EventDisplay, 1)
			ElseIf WinActive($V2M_GUI_MainTitle) Then
				;				V2MGuiSwap()
				$V2M_EventDisplay = V2M_EventLog(V2MGuiChangeState($V2M_GUI_Main, $V2M_GUI_MainTitle, 'hide'), $V2M_EventDisplay, 1)
				$V2M_EventDisplay = V2M_EventLog(V2MGuiChangeState($V2M_GUI_Mini, $V2M_GUI_MiniTitle, 'show'), $V2M_EventDisplay, 1)
				;				V2M_EventLog('GUI - Switch GUI (Main > Mini)', $V2M_EventDisplay, 1)
			Else
				;				V2MGuiSwap()
				$V2M_EventDisplay = V2M_EventLog(V2MGuiChangeState($V2M_GUI_Main, $V2M_GUI_MainTitle, 'show'), $V2M_EventDisplay, 1)
				$V2M_EventDisplay = V2M_EventLog(V2MGuiChangeState($V2M_GUI_Mini, $V2M_GUI_MiniTitle, 'hide'), $V2M_EventDisplay, 1)
				;				V2M_EventLog('GUI - Switch GUI (Mini > Main)', $V2M_EventDisplay, 1)
			EndIf
		Case $V2M_GUI_Msg = $V2M_GUI_MainButtonExit
			$V2M_EventLog = "GUI - Exiting (MainButtonExit)"
			$V2M_EventDisplay = V2M_EventLog($V2M_EventLog, $V2M_EventDisplay, 1)
			;			JDs_debug("GUI exiting (MainGUI exit button)")
			$V2M_Exit = 1
		Case $V2M_GUI_Msg = $V2M_GUI_MiniButtonExit
			$V2M_EventLog = "GUI - Exiting (MainButtonExit)"
			$V2M_EventDisplay = V2M_EventLog($V2M_EventLog, $V2M_EventDisplay, 1)
			;			JDs_debug("GUI exiting (MainGUI exit button)")
			$V2M_Exit = 1
		Case $V2M_GUI_Msg = $V2M_GUI_DebugButtonCopy
			$clipboard = GUICtrlRead($V2M_GUI_DebugOutputEdit)
			ClipPut($clipboard)

			;	GUI Main Menu's
		Case $V2M_GUI_Msg = $V2M_GUI_MainSwap
			$V2M_EventLog = V2MGuiSwap()
			$V2M_EventLog = $V2M_EventLog & "($V2M_GUI_MainSwap)"
			$V2M_EventDisplay = V2M_EventLog($V2M_EventLog, $V2M_EventDisplay, 1)
		Case $V2M_GUI_Msg = $V2M_GUI_MainAbout
			$V2M_EventLog = "GUI - MainAbout"
			$V2M_EventDisplay = V2M_EventLog($V2M_EventLog, $V2M_EventDisplay, 1)
			V2MAboutBox()
		Case $V2M_GUI_Msg = $V2M_GUI_MainMenuExit
			; MainGUI File > Exit Clicked
			$V2M_EventLog = "Exiting (MainMenuExit)"
			$V2M_EventDisplay = V2M_EventLog($V2M_EventLog, $V2M_EventDisplay, 1)
			$V2M_Exit = 1

			;	GUI Mini Menu's
			;		Case $V2M_GUI_Msg = $V2M_GUI_MiniSwap
			;			$V2M_EventLog = V2MGuiSwap()
			;			$V2M_EventLog = $V2M_EventLog & "($V2M_GUI_MiniSwap)"
			;			$V2M_EventDisplay = V2M_EventLog($V2M_EventLog, $V2M_EventDisplay, 1)
			;		Case $V2M_GUI_Msg = $V2M_GUI_MiniAbout
			;			$V2M_EventLog = "GUI - MiniAbout"
			;			$V2M_EventDisplay = V2M_EventLog($V2M_EventLog, $V2M_EventDisplay, 1)
			;			V2MAboutBox()

			;	GUI Tab Viewer Buttons
		Case $V2M_GUI_Msg = $V2M_GUI_VWR_ButtonConnect
			$V2M_EventLog = "GUI - Tab_VWR_ButtonConnect"
			$V2M_EventDisplay = V2M_EventLog($V2M_EventLog, $V2M_EventDisplay)
			$V2M_ConnectType = 'VWR'
			$V2M_SessionCode = GUICtrlRead($V2M_GUI_VWR_InputCode)
			$V2M_SSH_PortFwdDirection = "Remote"
			;			MsgBox(0, "Debug", "Pressed Tab_VWRButtonConnect", 2)
			;			MsgBox(0, "Debug", "$V2M_SC_SsnCodeRead = " & $V2M_SC_SsnCodeRead, 2)
			If $V2M_SSH_ProcessID = '' Then
				$V2M_SSH_ProcessID = V2MSSHConnect($V2M_SSH_PortFwdDirection)
			Else
				V2MExitSSH()
				V2MExitVNC()
			EndIf
			$V2M_VNC_SCStart = 0
			$V2M_SSHStarted = 1
			$V2M_AutoReconnect = 1
		Case $V2M_GUI_Msg = $V2M_GUI_VWR_ButtonStop
			V2MExitVNC()
			_RefreshSystemTray(50)
			$V2M_AutoReconnect = 0
			;			MsgBox(0, "Debug", "Pressed GUI_VWR_ButtonStop", 2)

			;	GUI Tab SC Buttons
		Case $V2M_GUI_Msg = $V2M_GUI_SC_ButtonConnect
			$V2M_EventLog = "GUI - Tab_SC_ButtonConnect"
			$V2M_EventDisplay = V2M_EventLog($V2M_EventLog, $V2M_EventDisplay, 1)
			$V2M_ConnectType = 'SC'

			$V2M_SC_SsnCodeRead = GUICtrlRead($V2M_GUI_SC_InputCode)
			If $V2M_SC_SsnCodeRead = '' Then
				MsgBox(0, "Error", "Please enter the Session Code and try again", 60)
				$V2M_EventLog = "GUI - Session Code was blank"
				$V2M_EventDisplay = V2M_EventLog($V2M_EventLog, $V2M_EventDisplay, 1)
				;Set focus to input, and set BGcolour to red (or something)
			Else
				$V2M_SessionCode = $V2M_SC_SsnCodeRead
				If $V2M_SSH_ProcessID = '' Then
					$V2M_SSH_PortFwdDirection = 'Local'
					$V2M_SSH_ProcessID = V2MSSHConnect($V2M_SSH_PortFwdDirection)
				Else
					If $V2M_SSH_PortFwdDirection = 'Remote' Then
						V2MExitSSH()
						$V2M_SSH_PortFwdDirection = 'Local'
						$V2M_SSH_ProcessID = V2MSSHConnect($V2M_SSH_PortFwdDirection)
						$V2M_EventLog = "VNC - Server started, connecting to viewer"
						$V2M_EventDisplay = V2M_EventLog($V2M_EventLog, $V2M_EventDisplay, 1)
					EndIf
					$V2M_SSHStarted = 1
				EndIf

				If ProcessExists($V2M_VNC_SC) Then
					V2MExitVNC()
				EndIf

				$V2M_VNC_SCStart = 1

				$V2M_EventLog = "VNC - Server located, connecting to viewer"
				$V2M_EventDisplay = V2M_EventLog($V2M_EventLog, $V2M_EventDisplay, 1)

				$V2M_AutoReconnect = 1
			EndIf
		Case $V2M_GUI_Msg = $V2M_GUI_SC_ButtonStop
			$V2M_EventLog = "GUI - Tab_SC_ButtonStop"
			$V2M_EventDisplay = V2M_EventLog($V2M_EventLog, $V2M_EventDisplay, 1)
			$V2M_AutoReconnect = 0
			V2MExitVNC()
			_RefreshSystemTray(50)

			;	GUI Debug Buttons
		Case $V2M_GUI_Msg = $V2M_GUI_DebugButtonConnect
			$V2M_EventLog = "GUI - Debug SSH button pressed"
			$V2M_EventDisplay = V2M_EventLog($V2M_EventLog, $V2M_EventDisplay, 1)
			$V2M_ConnectType = 'SSH'
			$V2M_SSH_PortFwdDirection = "Both"
			$V2M_SSHStarted = 1
			$V2M_AutoReconnect = 1
			$V2M_SessionCode = V2MRandomPort()
			$V2M_SSH_ProcessID = V2MSSHConnect($V2M_SSH_PortFwdDirection)
			;			Sleep(100)
		Case $V2M_GUI_Msg = $V2M_GUI_DebugButtonStop
			$V2M_EventLog = "GUI - Debug SSH ButtonStop"
			$V2M_EventDisplay = V2M_EventLog($V2M_EventLog, $V2M_EventDisplay, 1)
			$V2M_AutoReconnect = 0
			V2MExitSSH()
			$V2M_SSH_Hostname = ''
			$V2M_SSH_Username = ''
			$V2M_SSH_Password = ''
			_RefreshSystemTray(50)

		Case Else
			;;;
	EndSelect
	;
	;=========================================================================================================================================================
	; Get any messages from the TrayIcon
	$V2M_TrayMsg = TrayGetMsg()
	Select
		Case $V2M_TrayMsg = $V2M_Tray_Exit
			; Icon Exit clicked
			$V2M_EventLog = "GUI - Exiting (Tray_Exit)"
			$V2M_EventDisplay = V2M_EventLog($V2M_EventLog, $V2M_EventDisplay, 1)
			$V2M_Exit = 1
		Case $V2M_TrayMsg = $V2M_Tray_GUISwap
			$V2M_EventLog = V2MGuiSwap()
			$V2M_EventLog = $V2M_EventLog & "($V2M_Tray_GUISwap)"
			$V2M_EventDisplay = V2M_EventLog($V2M_EventLog, $V2M_EventDisplay, 1)
			;			MsgBox(0, "Debug", "GUI Swap", 2)
		Case Else
			;;;
	EndSelect

	If $V2M_Exit = 1 Then
		V2MExitSSH()
		V2MExitVNC()
		$V2M_EventDisplay = V2M_EventLog(' ', $V2M_EventDisplay)

		ProcessClose("aero_disable.exe") ; included here so that it closes before the temp folder it is located in gets deleted
		;		Sleep(200)
		Exit
	Else
		Sleep(100)
	EndIf


	If GUICtrlRead($V2M_GUI_DebugCheckbox) = 1 Then
		;		$V2M_GUI_DebugShow = 1
		GUISwitch($V2M_GUI_Debug)
		GUISetState(@SW_SHOW, $V2M_GUI_DebugTitle)
	ElseIf GUICtrlRead($V2M_GUI_DebugCheckbox) = 4 Then
		;		$V2M_GUI_DebugShow = 0
		GUISwitch($V2M_GUI_Debug)
		GUISetState(@SW_HIDE, $V2M_GUI_DebugTitle)
	EndIf
	;	If $V2M_GUI_DebugShow = 1 Then
	;	Else
	;	EndIf

	If GUICtrlRead($V2M_GUI_VWR_SsnRndChbx) = 1 Then
		If (IniRead(@ScriptDir & "\vnc2me.ini", "V2M_Server", "SESSION_CODE", "") = "") Then
			If $V2M_GUI_VWR_SsnRndChbx_PreviousState = 0 Then
				$V2M_SessionCode = V2MRandomPort()
				;			MsgBox(0, "Debug", "Random port = " & $V2M_SessionCode)
				GUICtrlSetData($V2M_GUI_VWR_InputCode & @CRLF, $V2M_SessionCode)
				;generate random code
				$V2M_GUI_VWR_SsnRndChbx_PreviousState = 1
			EndIf
		EndIf

		;		If $V2M_LoopCount = 1 Or $V2M_LoopCount = 100 Or $V2M_LoopCount = 200 Or $V2M_LoopCount = 300 Or $V2M_LoopCount = 400 Or $V2M_LoopCount = 500 Then
		;		EndIf
	Else
		$V2M_GUI_VWR_SsnRndChbx_PreviousState = 0
	EndIf

	$V2M_LoopCount = $V2M_LoopCount + 1
	If $V2M_LoopCount > 10 Then ;takes about 130 milliseconds per cycle (probably quicker on faster CPUs) + sleep value below
		;		MsgBox(0, "Debug", "$V2M_LoopCount = " & $V2M_LoopCount)
		$V2M_LoopCount = 0
	Else
		Sleep(10)
	EndIf
WEnd