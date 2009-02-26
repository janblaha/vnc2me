;
; Misc FUNCTIONS
;



;===============================================================================
;
; Description:		Ask if you want to add host key
; Parameter(s):		none
; Requirement(s):	$V2M_ProcessIDs[1] needs to be global, and hold controlID for plink.exe
; Return Value(s):	none
; Author(s):		Jim Dolby
; Note(s):
;
;===============================================================================
Func V2MAddHostKey()
	Local $msgbox
	;Add Host key to knownhosts
	$V2M_EventDisplay = V2M_EventLog('STDERR found', $V2M_EventDisplay, 1)
	;	JDs_debug("STDERR found")
	$msgbox = MsgBox(4, IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "MSG_HOST_TITLE", "HOST NOT CACHED"), IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "MSG_HOST_TEXT", "THIS HOST IS NOT KNOWN, DO YOU WANT TO ADD IT TO KNOWN HOSTS ???"))
	If $msgbox = 6 Then
		StdinWrite($V2M_ProcessIDs[1], "y " & @CR)
	ElseIf $msgbox = 7 Then
		StdinWrite($V2M_ProcessIDs[1], "n " & @CR)
	EndIf
EndFunc   ;==>V2MAddHostKey

;===============================================================================
;
; Description:		Creates a random number between $V2MPortMin & $V2MPortMax
; Parameter(s):		none
; Requirement(s):	$V2MPortMin & $V2MPortMax.
; Return Value(s):	$V2M_RandomPort
; Author(s):		Jim Dolby
; Note(s):
;
;===============================================================================
Func V2MRandomPort()
	Local $RandomNumber
	$RandomNumber = Random($V2MPortMin, $V2MPortMax, 1)
	If Mod($RandomNumber, 2) > 0 Then
		$RandomNumber = $RandomNumber + 1
	EndIf
	Return $RandomNumber
EndFunc   ;==>V2MRandomPort

;===============================================================================
;
; Description:		Creates a short message about the application
; Parameter(s):		none
; Requirement(s):
; Return Value(s):	none
; Author(s):		Jim Dolby
; Note(s):
;
;===============================================================================
Func V2MAboutBox()
	MsgBox(0, "About", $V2M_GUI_MainTitle & @CRLF & "Creates a secure Tunnel (via SSH)," & @CRLF & "and starts VNC through this tunnel (thereby securing it)" & @CRLF & @CRLF & "visit: www.vnc2me.org for further details" & @CRLF & @CRLF & "© 2008 Sec IT.")
EndFunc   ;==>V2MAboutBox

;===============================================================================
;
; Description:		Swaps between the GUI's
; Parameter(s):		$GUI_title = Title of window to change
;					$GUI_state = hide / show for hiding or showing respectively
; Requirement(s):	GUI Titles, and control ID's from creating the GUI's
; Return Value(s):	"GUI - Changing " & $GUI_title & " to " & $GUI_state
; Author(s):		Jim Dolby
; Note(s):			modified version of V2MGuiSwap, simplified somewhat
;
;===============================================================================
Func V2MGuiChangeState($GUI_id, $GUI_title, $GUI_state)
	GUISwitch($GUI_id)
	If $GUI_state = 'hide' Then
		GUISetState(@SW_HIDE, $GUI_title)
	ElseIf $GUI_state = 'show' Then
		GUISetState(@SW_SHOWNOACTIVATE, $GUI_title)
	EndIf
	Return "GUI - Changing " & $GUI_title & " to " & $GUI_state
EndFunc   ;==>V2MGuiChangeState

;===============================================================================
;
; Description:		Creates an input box for passing of Username or Password to stdin
; Parameter(s):		$WriteWhere		= ProcessID to write to
;					$WriteWhat		= Not Currently Used
;					$InBoxTitle		= Title of Displayed Input Box
;					$InBoxText		= Text of Displayed Input Box
;					$InBoxPassHash	= If not blank, inputs are hashed out using this (eg $InBoxPassHash = "*")
; Requirement(s):	none
; Return Value(s):	none
; Author(s):		Jim Dolby
; Note(s):			Replaces both V2MSSHUser() & V2MSSHPass()
;
;===============================================================================
Func V2MInBoxSTDINWrite($WriteWhere, $WriteWhat = "", $InBoxTitle = "Password", $InBoxText = "Enter Password", $InBoxPassHash = "")
	;if $write not passed in func call, ask for it.
	If $WriteWhat = "" Then
		$WriteWhat = InputBox($InBoxTitle, $InBoxText, "", $InBoxPassHash)
		If @error = 1 Then
			$V2M_Exit = 1
		EndIf
	EndIf
	;writes "password"
	$V2M_EventDisplay = V2M_EventLog("AUTH - Passing " & $InBoxTitle, $V2M_EventDisplay, 1)
	;	JDs_debug("AUTH - Passing " & $InBoxTitle)
	StdinWrite($WriteWhere, $WriteWhat & " " & @CR)
	Return $WriteWhat
EndFunc   ;==>V2MInBoxSTDINWrite

;===============================================================================
;
; Description:		Checks if appropriate processes running, and if not, turns that flag off
; Parameter(s):		None
; Requirement(s):	$V2M_Status[3][X]
; Return Value(s):	Nill
; Author(s):		Jim Dolby
; Note(s):			Only checked every 100 cycles of the While loop.
;
;===============================================================================

Func V2M_CheckRunning()
	If $V2M_Status[3][5] Then ;scstarted
		If Not ProcessExists($V2M_VNC_SC) Then
			$V2M_Status[3][5] = 0
			$V2M_EventDisplay = V2M_EventLog($V2M_VNC_SC & " has Closed", $V2M_EventDisplay, 'dll')
		EndIf
	EndIf
	If $V2M_Status[3][7] Then ;SVRstarted
		If Not ProcessExists($V2M_VNC_SVR) Then
			$V2M_Status[3][7] = 0
			$V2M_EventDisplay = V2M_EventLog($V2M_VNC_SVR & " has Closed", $V2M_EventDisplay, 'dll')
		EndIf
	EndIf
	If $V2M_Status[3][10] Then ;vwrstarted
		If Not ProcessExists($V2M_VNC_VWR) Then
			$V2M_Status[3][10] = 0
			$V2M_EventDisplay = V2M_EventLog($V2M_VNC_VWR & " has Closed", $V2M_EventDisplay, 'dll')
		EndIf
	EndIf
	If $V2M_Status[3][2] Then ;sshstarted
		If Not ProcessExists("v2mplink.exe") Then
			V2M_startvnc()
			$V2M_Status[3][2] = 0
			$V2M_Status[3][3] = 0
			$V2M_Status[3][5] = 0
			$V2M_Status[3][7] = 0
			$V2M_Status[3][10] = 0
			V2M_Timer("Stop")
			$V2M_EventDisplay = V2M_EventLog("v2mplink.exe has Closed after: " & (V2M_Timer("Stop")), $V2M_EventDisplay, 'dll')
		EndIf
	EndIf
	If $V2M_Status[3][12] Then ;uvncstarted
		If Not ProcessExists($V2M_VNC_UVNC) Then
			$V2M_Status[3][12] = 0
			$V2M_EventDisplay = V2M_EventLog($V2M_VNC_UVNC & " has Closed", $V2M_EventDisplay, 'dll')
		EndIf
	EndIf
EndFunc   ;==>V2M_CheckRunning

;===============================================================================
;
; Description:		Starts the Appropriate VNC Application
; Parameter(s):		Nill
; Requirement(s):	$V2M_Status[3][X]
; Return Value(s):	Nill
; Author(s):		Jim Dolby
; Note(s):			Only checked every 100 cycles of the While loop.
;
;===============================================================================

Func V2M_startvnc($how = 'ssh')
	$V2M_EventDisplay = V2M_EventLog("VNC - Starting VNC" & @CRLF & "$V2M_Status[3][4] = " & $V2M_Status[3][4] & @CRLF & "$V2M_Status[3][6] = " & $V2M_Status[3][6] & @CRLF & "$V2M_Status[3][8] = " & $V2M_Status[3][8] & @CRLF & "$V2M_Status[3][9] = " & $V2M_Status[3][9], $V2M_EventDisplay, 'dll')
	If $how = "ssh" Then
		If $V2M_Status[3][4] Then ;scwanted
			If Not $V2M_Status[3][5] Then
				$V2M_EventDisplay = V2M_EventLog("VNC - Starting SC via SSH", $V2M_EventDisplay, 'debug')
				;				If ProcessExists($V2M_VNC_SC) Then ProcessClose($V2M_VNC_SC)
				$V2M_ProcessIDs[3] = Run($V2M_VNC_SC & " -connect 127.0.0.1:25400", @ScriptDir, @SW_HIDE, 7) ;run sc
				$V2M_Status[3][5] = 1 ;flag As started
				Sleep(2000)
				Return ("SCviaSSH")
			EndIf
		ElseIf $V2M_Status[3][6] Then ;svrwanted
			If Not $V2M_Status[3][7] Then
				$V2M_EventDisplay = V2M_EventLog("VNC - Starting SVR via SSH", $V2M_EventDisplay, 'debug')
				;				If ProcessExists($V2M_VNC_SVR) Then ProcessClose($V2M_VNC_SVR)
				$V2M_ProcessIDs[4] = Run(@ScriptDir & "\" & $V2M_VNC_SVR & " AcceptCutText=0 AcceptPointerEvents=0 AcceptKeyEvents=0 AlwaysShared=1 LocalHost=1 SecurityTypes=None PortNumber=25900", @ScriptDir, @SW_MINIMIZE, 7) ;run svr
				$V2M_Status[3][7] = 1 ;	flag As started
				Sleep(2000)
				Return ("SVRviaSSH")
			EndIf
		ElseIf $V2M_Status[3][8] Then ;vwrscwanted
			If $V2M_Status[3][10] <> 1 Then
				$V2M_EventDisplay = V2M_EventLog("VNC - Starting VWR for SC via SSH", $V2M_EventDisplay, 'debug')
				$V2M_ProcessIDs[2] = Run($V2M_VNC_VWR & " -listen 15500 -8greycolours -autoscaling", @ScriptDir, @SW_HIDE, 7) ;run vwr For sc connection
				;				MsgBox(0, 'Debug', '@error = '&@error&@CRLF&'$V2M_ProcessIDs[2] = '&$V2M_ProcessIDs[2],3)
				;				If ProcessExists($V2M_VNC_VWR) Then ProcessClose($V2M_VNC_VWR)
				$V2M_Status[3][10] = 1 ;	flag As started
				Return ("VWRSCviaSSH")
			EndIf
		ElseIf $V2M_Status[3][9] Then ;vwrsvrwanted
			If $V2M_Status[3][10] <> 1 Then
				$V2M_EventDisplay = V2M_EventLog("VNC - Starting VWR for SVR via SSH", $V2M_EventDisplay, 'debug')
				$V2M_ProcessIDs[2] = Run($V2M_VNC_VWR & " localhost::25900 /8greycolors/autoreconnect 1 /shared /belldeiconify /autoscaling", @ScriptDir, @SW_HIDE, 7) ;run vwr For svr connection
				;				MsgBox(0, 'Debug', '@error = '&@error&@CRLF&'$V2M_ProcessIDs[2] = '&$V2M_ProcessIDs[2],3)
				;				If ProcessExists($V2M_VNC_VWR) Then ProcessClose($V2M_VNC_VWR)
				$V2M_Status[3][10] = 1 ;	flag As started
				Return ("VWRSVRviaSSH")
			EndIf
		EndIf
	EndIf
EndFunc   ;==>V2M_startvnc

;===============================================================================
;
; Description:		Exits all v2m vnc apps, and updates log
; Parameter(s):		none
; Requirement(s):	none
; Return Value(s):	none
; Author(s):		Jim Dolby
; Note(s):			none
;
;===============================================================================
Func V2MExitVNC()
	$V2M_EventDisplay = V2M_EventLog('VNC - Waiting to close all VNCs cleanly', $V2M_EventDisplay, 'dll')
	While ProcessExists($V2M_VNC_VWR)
		ProcessWaitClose($V2M_VNC_VWR, 3)
		If ProcessExists($V2M_VNC_VWR) Then
			ProcessClose($V2M_VNC_VWR)
			$V2M_EventDisplay = V2M_EventLog('VNC - ' & $V2M_VNC_VWR & ' Closed Forcibly', $V2M_EventDisplay, 'dll')
		Else
			$V2M_EventDisplay = V2M_EventLog('VNC - ' & $V2M_VNC_VWR & ' Closed Cleanly', $V2M_EventDisplay, 'dll')
		EndIf
	WEnd
	While ProcessExists($V2M_VNC_SC)
		ProcessWaitClose($V2M_VNC_SC, 3)
		If ProcessExists($V2M_VNC_SC) Then
			ProcessClose($V2M_VNC_SC)
			$V2M_EventDisplay = V2M_EventLog('VNC - ' & $V2M_VNC_SC & ' Closed Forcibly', $V2M_EventDisplay, 'dll')
		Else
			$V2M_EventDisplay = V2M_EventLog('VNC - ' & $V2M_VNC_SC & ' Closed Cleanly', $V2M_EventDisplay, 'dll')
		EndIf
	WEnd
	While ProcessExists($V2M_VNC_SVR)
		ProcessWaitClose($V2M_VNC_SVR, 3)
		If ProcessExists($V2M_VNC_SVR) Then
			ProcessClose($V2M_VNC_SVR)
			$V2M_EventDisplay = V2M_EventLog('VNC - ' & $V2M_VNC_SVR & ' Closed Forcibly', $V2M_EventDisplay, 'dll')
		Else
			$V2M_EventDisplay = V2M_EventLog('VNC - ' & $V2M_VNC_SVR & ' Closed Cleanly', $V2M_EventDisplay, 'dll')
		EndIf
	WEnd
	While ProcessExists($V2M_VNC_UVNC)
		ProcessWaitClose($V2M_VNC_UVNC, 3)
		If ProcessExists($V2M_VNC_UVNC) Then
			ProcessClose($V2M_VNC_UVNC)
			$V2M_EventDisplay = V2M_EventLog('VNC - ' & $V2M_VNC_UVNC & ' Closed Forcibly', $V2M_EventDisplay, 'dll')
		Else
			$V2M_EventDisplay = V2M_EventLog('VNC - ' & $V2M_VNC_UVNC & ' Closed Cleanly', $V2M_EventDisplay, 'dll')
		EndIf
	WEnd
	$V2M_EventDisplay = V2M_EventLog('VNC - All VNCs closed', $V2M_EventDisplay, 'dll')
	_RefreshSystemTray(50)
EndFunc   ;==>V2MExitVNC

;===============================================================================
;
; Description:		Creates the SSH tunnel
; Parameter(s):
; Requirement(s):	$V2M_GUI_DebugOutputEdit, $V2M_SessionCode, $V2M_SSH[1]
; Return Value(s):	$V2M_ProcessIDs[1]
; Author(s):		Jim Dolby
; Note(s):
;
;===============================================================================
;Func V2MSSHConnect($V2M_SessionCode = '', $RunWhat = 'v2mplink', $StandardHost = '', $RunWhere = @ScriptDir)
Func V2MSSHConnect()
	Local $Local_ConnectString, $local_return
	ProcessClose('v2mplink.exe')

	If $V2M_SessionCode = '' Then
		MsgBox(0, IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "MSG_SSN_TITLE", "BLANK SESSION CODE"), IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "MSG_SSN_TEXT", "PLEASE ENTER THE SESSION CODE AND TRY AGAIN"), 20)
		$V2M_EventDisplay = V2M_EventLog("GUI - Session Code was blank", $V2M_EventDisplay, 'dll')
		$V2M_Status[3][1] = 0 ; SSH notwanted
	Else
		$V2M_EventDisplay = V2M_EventLog("SSH - Starting at " & @HOUR & ":" & @MIN & ":" & @SEC & ", for " & $V2M_Status[1][1] & " Connections, (Session Code = " & $V2M_SessionCode & ")", $V2M_EventDisplay, 'Full')
		If $V2M_SSH[1] = "" Then
			$V2M_EventDisplay = V2M_EventLog("SSH - No Hostname set", $V2M_EventDisplay, 'Full')
			$V2M_SSH[1] = InputBox(IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "MSG_SSHSVR_TITLE", "HOST SERVER"), IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "MSG_SSHSVR_TEXT", "CONNECT TO WHICH SSH SERVER ?"))
			If @error = 1 Then
				$V2M_Status[3][1] = 0 ;sshwanted = 0
				$V2M_Status[1][1] = ''
			ElseIf $V2M_SSH[1] = "" Then
				$V2M_Status[3][1] = 0 ;sshwanted = 0
			EndIf
		EndIf

		If $V2M_Status[1][1] = 'VWR' Then
			If IniRead(@ScriptDir & "\vnc2me_sc.ini", "V2M_GUI", "VNC_VWR_SC_ONLY", 0) = 1 Then
				TrayTip(IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "TRAYTIP_VWR_STARTSC_TITLE", "VWR_STARTSC_TITLE"), IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "TRAYTIP_VWR_STARTSC_LINE1", "") & @CR & IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "TRAYTIP_VWR_STARTSC_LINE2", ""), 30)
				$Local_ConnectString = @ScriptDir & '\v2mplink.exe -R ' & $V2M_SessionCode & ':127.0.0.1:15500 ' & $V2M_SSH[1] & ' -v -N'
				$V2M_Status[3][8] = 1
			ElseIf IniRead(@ScriptDir & "\vnc2me_sc.ini", "V2M_GUI", "VNC_VWR_SVR_ONLY", 0) = 1 Then
				TrayTip(IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "TRAYTIP_VWR_STARTSVR_TITLE", "VWR_STARTSVR_TITLE"), IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "TRAYTIP_VWR_STARTSVR_LINE1", "") & @CR & IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "TRAYTIP_VWR_STARTSVR_LINE2", ""), 30)
				$Local_ConnectString = @ScriptDir & '\v2mplink.exe -L 25900:127.0.0.1:' & $V2M_SessionCode & ' ' & $V2M_SSH[1] & ' -v -N'
				$V2M_Status[3][9] = 1
			Else
				If $V2M_Status[3][8] = 1 Or GUICtrlRead($V2M_GUI[40]) = 1 Then ;vwrscwanted
					TrayTip(IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "TRAYTIP_VWR_STARTSC_TITLE", "VWR_STARTSC_TITLE"), IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "TRAYTIP_VWR_STARTSC_LINE1", "") & @CR & IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "TRAYTIP_VWR_STARTSC_LINE2", ""), 30)
					$Local_ConnectString = @ScriptDir & '\v2mplink.exe -R ' & $V2M_SessionCode & ':127.0.0.1:15500 ' & $V2M_SSH[1] & ' -v -N'
					$V2M_Status[3][8] = 1
				ElseIf $V2M_Status[3][9] = 1 Or GUICtrlRead($V2M_GUI[41]) = 1 Then ;vwrsvrwanted
					TrayTip(IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "TRAYTIP_VWR_STARTSVR_TITLE", "VWR_STARTSVR_TITLE"), IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "TRAYTIP_VWR_STARTSVR_LINE1", "") & @CR & IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "TRAYTIP_VWR_STARTSVR_LINE2", ""), 30)
					$Local_ConnectString = @ScriptDir & '\v2mplink.exe -L 25900:127.0.0.1:' & $V2M_SessionCode & ' ' & $V2M_SSH[1] & ' -v -N'
					$V2M_Status[3][9] = 1
				Else
					$local_return = MsgBox(1, IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "MSG_VWR_TITLE", "VIEWER"), IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "MSG_VWR_TEXT", "NO VIEWER CONNECTION TYPE CHOSEN" & @CRLF & "DEFAULTED TO SC"), 10)
					If $local_return = -1 Or $local_return = 1 Then
						GUICtrlSetState($V2M_GUI[40], 1) ;Check the SC vwr radio item.
						$V2M_Status[3][8] = 1 ;vwrSCwanted
					Else
						$V2M_Status[1][1] = ''
						$V2M_Status[3][1] = 0 ;sshwanted = 0
					EndIf
				EndIf
			EndIf

			;			If ($V2M_Status[3][9] = 1) Or (IniRead(@ScriptDir & "\vnc2me_sc.ini", "V2M_GUI", "VWR_VWR_SVR_ONLY", 0) = 1) Then		;vwrSVRwanted
			;				$Local_ConnectString = @ScriptDir & '\v2mplink.exe -L 25900:127.0.0.1:' & $V2M_SessionCode & ' ' & $V2M_SSH[1] & ' -v -N'
			;			Else
			;				$Local_ConnectString = @ScriptDir & '\v2mplink.exe -R ' & $V2M_SessionCode & ':127.0.0.1:15500 ' & $V2M_SSH[1] & ' -v -N'
			;			EndIf
		ElseIf $V2M_Status[1][1] = 'SVR' Then
			$Local_ConnectString = @ScriptDir & '\v2mplink.exe -R ' & $V2M_SessionCode & ':127.0.0.1:15500 ' & $V2M_SSH[1] & ' -v -N'
		ElseIf $V2M_Status[1][1] = 'SC' Then
			$Local_ConnectString = @ScriptDir & '\v2mplink.exe -L 25400:127.0.0.1:' & $V2M_SessionCode & ' ' & $V2M_SSH[1] & ' -v -N'
		Else
			$Local_ConnectString = @ScriptDir & '\v2mplink.exe -R ' & $V2M_SessionCode & ':127.0.0.1:15500 -L 25400:127.0.0.1:' & $V2M_SessionCode & ' ' & $V2M_SSH[1] & ' -v -N'
		EndIf
		If $V2M_Status[3][1] = 0 Then
			$V2M_EventDisplay = V2M_EventLog("RUN - NOT Starting SSH at " & @HOUR & ":" & @MIN & ":" & @SEC & " <due to error in V2MSSHConnect()>", $V2M_EventDisplay, 'dll')
			$V2M_Status[3][2] = 0 ;ssh started
			$V2M_Status[3][4] = 0
			$V2M_Status[3][6] = 0
			$V2M_Status[3][8] = 0
			$V2M_Status[3][9] = 0

		Else
			$V2M_ProcessIDs[1] = Run($Local_ConnectString, @ScriptDir, @SW_HIDE, 7)
			$V2M_EventDisplay = V2M_EventLog("RUN - Starting SSH at " & @HOUR & ":" & @MIN & ":" & @SEC & " (remote port " & $V2M_SessionCode & ")", $V2M_EventDisplay, 'dll')
			Return $V2M_ProcessIDs[1]
			$V2M_Status[3][2] = 1 ;ssh started
		EndIf
	EndIf
EndFunc   ;==>V2MSSHConnect

;===============================================================================
;
; Description:		exits all v2m ssh apps
; Parameter(s):		none
; Requirement(s):	$V2M_ProcessIDs[1] needs to be gloabal, and hold controlID for plink.exe
; Return Value(s):	none
; Author(s):		Jim Dolby
; Note(s):
;
;===============================================================================
Func V2MExitSSH()
	StdinWrite($V2M_ProcessIDs[1], "exit " & @CRLF)
	While ProcessExists("v2mplink.exe")
		$V2M_EventDisplay = V2M_EventLog('SSH - Waiting to close cleanly', $V2M_EventDisplay, 'dll')
		ProcessWaitClose("v2mplink.exe", 4)
		If ProcessExists("v2mplink.exe") Then
			ProcessClose("v2mplink.exe")
			$V2M_EventDisplay = V2M_EventLog('SSH - Closed Forcibly', $V2M_EventDisplay, 'dll')
		Else
			;			$V2M_EventDisplay=V2M_EventLog('SSH - Closed Cleanly', $V2M_EventDisplay, 'dll')
		EndIf
	WEnd
	$V2M_EventDisplay = V2M_EventLog('SSH - All SSHs Closed', $V2M_EventDisplay, 'dll')
	_RefreshSystemTray(50)
EndFunc   ;==>V2MExitSSH

;===============================================================================
;
; Description:		Sets GUI Control data
; Parameter(s):		$ControlID	= GUI ControlID to set data to
;					$data		= Data to set to the GUI
;					$default	= 0 overwrites existing data, 1 inserts at carot
; Requirement(s):	none
; Return Value(s):	none
; Author(s):		Jim Dolby
; Note(s):
;
;===============================================================================
Func V2MGUICtrlSetData($ControlID, $data, $default = 0)
	GUICtrlSetData($ControlID, $data, $default)
EndFunc   ;==>V2MGUICtrlSetData

;===============================================================================
;
; Description:		Eventlog handler, sends logs to std windows debug (via dll)
;					and GUI Statusbars
; Parameter(s):		$V2M_EventLog	=	Text string to send to log
;					$JDs_debug_only	=	0, text is display in statusbar. else, only sent to debug dll
; Requirement(s):
; Return Value(s):	$V2M_EventDisplay
; Author(s):		Jim Dolby
; Note(s):
;
;===============================================================================
Func V2M_EventLog($V2M_EventLog = '', $V2M_EventDisplay = '', $JDs_debug_only = 'dll')
	If $V2M_EventLog = $V2M_EventDisplay Then
		;do nothing
	Else
		If $JDs_debug_only = '0' Or $JDs_debug_only = 'full' Then
			;		MsgBox(0, "Debug", $JDs_debug_only, 2)
			;send to minigui event log
			;			GUICtrlSetData($V2M_GUI[8], $V2M_EventLog, 1)
			_GUICtrlStatusBar_SetText($V2M_GUI[42], $V2M_EventLog) ;send to minigui event log
			_GUICtrlStatusBar_SetText($V2M_GUI[43], $V2M_EventLog) ;send to maingui event log
			;			GUICtrlSetData($V2M_GUI[9], $V2M_EventLog & @CRLF, 1)
			;send to Tab3Debug event log
			GUICtrlSetData($V2M_GUI_DebugOutputEdit, $V2M_EventLog & @CRLF, 1)
			ConsoleWrite($V2M_EventLog & @CRLF)
		ElseIf $JDs_debug_only = '1' Or $JDs_debug_only = 'debug' Then
			;send to Tab3Debug event log
			If $V2M_Status[1][2] = 1 Then GUICtrlSetData($V2M_GUI_DebugOutputEdit, $V2M_EventLog & @CRLF, 1)
		ElseIf $JDs_debug_only = 'dll' Then
			;do nothing
		EndIf
		; view the following output from sysinternals debuger "DebugView" or similar
		If $V2M_Status[1][2] = 1 Then DllCall("kernel32.dll", "none", "OutputDebugString", "str", "V2M - " & $V2M_EventLog)
		$V2M_EventDisplay = $V2M_EventLog
		;		Sleep(100)
	EndIf
	Return $V2M_EventDisplay
EndFunc   ;==>V2M_EventLog

;===============================================================================
;
; Description:		This is executed when Autoit exits
; Parameter(s):		none
; Requirement(s):	none
; Return Value(s):	none
; Author(s):		Jim Dolby
; Note(s):			Function name can be renamed, but only if ;Opt("OnExitFunc", "OnAutoItExit") is set (and OnAutoItExit is changed to new name)
;
;===============================================================================
Func OnAutoItExit()
	Local $timer
	TrayTip(IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "TRAYTIP_APP_EXITING_TITLE", "APP_EXITING_TITLE"), IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "TRAYTIP_APP_EXITING_LINE1", "") & @CR & IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "TRAYTIP_APP_EXITING_LINE2", ""), 30)
	;exit ssh & vnc
	V2MExitSSH()
	V2MExitVNC()
	ProcessClose("Aero_disable.exe") ; included here so that it closes before the temp folder it is located in gets deleted
	If IniRead(@ScriptDir & "\vnc2me_sc.ini", "V2M_GUI", "GUI_TIMER_SHOW", 1) = 1 Then
		;		Local $timer
		$timer = V2M_Timer("Stop")
		If $timer <> "0:0:0" Then
			MsgBox(0, IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "MSG_TIMER_TITLE", "CONNECTION TIMER"), IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "MSG_TIMER_TEXT", "SESSION CONNECTED FOR: ") & " " & $timer, 60)
		EndIf
	EndIf
	Local $curVal
	_RefreshSystemTray(50)
	;	If $V2M_VNC_PasswordRegAdded = 1 Then
	;		MsgBox(0, "Debug:", "I added Password, so Deleting it NOW", 2)
	;		RegDelete("HKEY_CURRENT_USER\Software\ORL\WinVNC3", "Password")
	;	EndIf
	;	If $Debug = 1 Then MsgBox(0,"Debug - OnAutoItExit()","Program has finished " & @EXITMETHOD)
	If @OSVersion = "WIN_VISTA" Then
		V2M_EventLog("EXIT - @OSVersion = WIN_VISTA ", $V2M_EventDisplay, 'dll')
		ProcessClose("aero_disable.exe") ; included here a second time, just in case AutoIt is forcibly closed
		RunWait(@ComSpec & " /c sc start uxsms", @SystemDir, @SW_HIDE)
		$curVal = RegRead("HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System", "PromptOnSecureDesktop_VNC")
		If $curVal = 0 Or $curVal = 1 Then
			RegWrite("HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System", "PromptOnSecureDesktop", "REG_DWORD", $curVal)
		EndIf
		RegDelete("HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System", "PromptOnSecureDesktop_VNC")

		$curVal = RegRead("HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System", "ConsentPromptBehaviorAdmin_VNC")
		If $curVal = 0 Or $curVal = 1 Or $curVal = 2 Then
			RegWrite("HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System", "ConsentPromptBehaviorAdmin", "REG_DWORD", $curVal)
		EndIf
		RegDelete("HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System", "ConsentPromptBehaviorAdmin_VNC")
	EndIf
	;	ProcessClose('v2mplink.exe')
	;	ProcessClose('v2mvwr.exe')
	;	ProcessClose('v2msc.exe')
	;	Opt('WinTitleMatchMode', 4)
	;	ControlSend('classname=Progman', '', 'SysListView321', '{F5}')
	;turn the wallpaper back on ...
	DllCall("user32.dll", "int", "SystemParametersInfo", "int", 20, "int", 0, "str", RegRead("HKEY_CURRENT_USER\Control Panel\Desktop", "Wallpaper"), "int", 3)
	;turn AERO back on
	RunWait(@ComSpec & ' /c Rundll32.exe dwmApi #102', @SystemDir, @SW_SHOWNOACTIVATE) ;enables aero
	If StringInStr(@ScriptFullPath, "\7z") Then
		V2M_EventLog("RUN - : Path contains '\7z', all files will now be deleted", $V2M_EventDisplay, 'dll')
		If @Compiled Then _SelfDelete(5)
	Else
		V2M_EventLog("EXIT - Path NOT contain '\7z', VNC2Me must be installed or not using 7z packaging, not deleting files", $V2M_EventDisplay, 'dll')
	EndIf
	$V2M_EventDisplay = V2M_EventLog(' ', $V2M_EventDisplay, 'full')
	Exit
EndFunc   ;==>OnAutoItExit

;===============================================================================
;
; Description:		Session Timer Handling Function
; Parameter(s):		$TimerAction	=	Start	=	Start or INIT the timer functions
;														Loading Global $V2M_Timer[3] with hours:mins:sec of call
;										Stop	=	Stop the timer function
;														Loading Global $V2M_Timer[4] with hours:mins:sec of call
;										Read	=	Reads the Session Times and returns
; Requirement(s):
; Return Value(s):	$V2M_EventDisplay
; Author(s):		Jim Dolby
; Note(s):
;
;===============================================================================

Func V2M_Timer($TimerAction = 'Start')
	Local $iSec, $iMin, $iHour, $ReadTicks, $V2M_TotalTicks
	If $TimerAction = "Start" Then
		If $V2M_Timer[2] = 0 Then
			$V2M_Timer[5] = TimerInit()
			$V2M_Timer[3] = @HOUR & ":" & @MIN & ":" & @SEC
			$V2M_Timer[2] = 1
			Return $V2M_Timer[3]
		EndIf
	ElseIf $TimerAction = "Stop" And $V2M_Timer[2] = 0 Then
		Return 0
	ElseIf $TimerAction = "Stop" And $V2M_Timer[2] = 1 Then
		$V2M_TotalTicks = TimerDiff($V2M_Timer[5])
		_TicksToTime(Int($V2M_TotalTicks), $iHour, $iMin, $iSec)
		$V2M_Timer[1] = StringFormat("%02i:%02i:%02i", $iHour, $iMin, $iSec)
		$V2M_Timer[4] = @HOUR & ":" & @MIN & ":" & @SEC
		Return $V2M_Timer[1]
	ElseIf $TimerAction = "Read" Then
		_TicksToTime(Int(TimerDiff($V2M_Timer[5])), $iHour, $iMin, $iSec)
		$ReadTicks = StringFormat("%02i:%02i:%02i", $iHour, $iMin, $iSec)
		Return $ReadTicks
	EndIf
EndFunc   ;==>V2M_Timer

;
;=========================================================================================================================================================
;

;
;=========================================================================================================================================================
;

;
;=========================================================================================================================================================
;
Func V2MPortRefused()
	$V2M_MsgBox = MsgBox(270373, IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "MSG_PORTC_TITLE", "ERROR - SESSION REFUSED"), IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "MSG_PORTC_TEXT", "SSH SESSION TUNNEL REFUSED, RETRY SAME SETTINGS ???"), 60)
	If $V2M_MsgBox = 2 Then ;cancel pressed
		V2MExitSSH()
		V2MExitVNC()
		$V2M_Status[3][1] = 0 ;sshwanted
		$V2M_EventDisplay = V2M_EventLog(V2MGuiChangeState($V2M_GUI_Mini, $V2M_GUI_MiniTitle, 'hide'), $V2M_EventDisplay, 1)
		$V2M_Status[2][2] = 'hide'
		$V2M_EventDisplay = V2M_EventLog(V2MGuiChangeState($V2M_GUI_Main, $V2M_GUI_MainTitle, 'show'), $V2M_EventDisplay, 1)
		$V2M_Status[2][1] = 'show'
	Else ;retry pressed or timeout
		V2MExitSSH()
		V2MExitVNC()
		$V2M_ProcessIDs[1] = V2MSSHConnect()
	EndIf
EndFunc   ;==>V2MPortRefused
;
;=========================================================================================================================================================
;

Func _TicksToTime($iTicks, ByRef $iHours, ByRef $iMins, ByRef $iSecs)
	If Number($iTicks) > 0 Then
		$iTicks = Round($iTicks / 1000)
		$iHours = Int($iTicks / 3600)
		$iTicks = Mod($iTicks, 3600)
		$iMins = Int($iTicks / 60)
		$iSecs = Round(Mod($iTicks, 60))
		; If $iHours = 0 then $iHours = 24
		Return 1
	ElseIf Number($iTicks) = 0 Then
		$iHours = 0
		$iTicks = 0
		$iMins = 0
		$iSecs = 0
		Return 1
	Else
		SetError(1)
		Return 0
	EndIf
EndFunc   ;==>_TicksToTime


;=========================================================================================================================================================

Func _SelfDelete($iDelay = 4)
	If @Compiled Then
		Local $sCmdFile
		FileDelete(@TempDir & "\scratch.bat")
		$sCmdFile = 'ping -n ' & $iDelay & '127.0.0.1 > nul' & @CRLF _
				 & ':loop' & @CRLF _
				 & 'del "' & @ScriptFullPath & '"' & @CRLF _
				 & 'if exist "' & @ScriptFullPath & '" goto loop' & @CRLF _
				 & 'del ' & @TempDir & '\scratch.bat'
		FileWrite(@TempDir & "\scratch.bat", $sCmdFile)
		Run(@TempDir & "\scratch.bat", @TempDir, @SW_HIDE)
	EndIf
EndFunc   ;==>_SelfDelete

Func V2M_UVNC_ConnectNames()
	Local $return = '', $iniCount, $loopcount = 0, $V2M_UVNC_ConnectNames = ''
	$iniCount = IniRead(@ScriptDir & "\ultravnc.ini", "SC", "SCNumberConnections", 0)
	While $loopcount < $iniCount
		V2M_EventLog('UVNC Connections loopcount = ' & $loopcount, $V2M_EventDisplay, 'dll')
		If $V2M_UVNC_ConnectNames = "" Then
			$V2M_UVNC_ConnectNames = IniRead(@ScriptDir & "\ultravnc.ini", "SC", "SCName_" & $loopcount, "")
		Else
			$V2M_UVNC_ConnectNames = $V2M_UVNC_ConnectNames & "|" & IniRead(@ScriptDir & "\ultravnc.ini", "SC", "SCName_" & $loopcount, "")
		EndIf
		$loopcount = $loopcount + 1 ; increment loopcount
	WEnd
	;	$V2M_UVNC_ConnectNames = $V2M_UVNC_ConnectNames & ""
	$return = $V2M_UVNC_ConnectNames
	Return $return
EndFunc   ;==>V2M_UVNC_ConnectNames

Func V2M_UVNC_NamesNumber($name)
	Local $return = '', $iniCount, $loopcount = 0
	$iniCount = IniRead(@ScriptDir & "\ultravnc.ini", "SC", "SCNumberConnections", 0)
	While $loopcount < $iniCount
		V2M_EventLog('UVNC Names loopcount = ' & $loopcount, $V2M_EventDisplay, 'dll')
		If $name = IniRead(@ScriptDir & "\ultravnc.ini", "SC", "SCName_" & $loopcount, "") Then
			$return = $loopcount
		Else
		EndIf
		$loopcount = $loopcount + 1 ; increment loopcount
	WEnd
	;	$V2M_UVNC_ConnectNames = $V2M_UVNC_ConnectNames & ""
	;	$return = $V2M_UVNC_ConnectNames
	Return $return
EndFunc   ;==>V2M_UVNC_NamesNumber
;=========================================================================================================================================================

;MsgBox(0, "Your OS Language:", _Language())
Func _Language()
	Local $return = '', $iniCount, $loopcount = 0
	$iniCount = IniRead(@ScriptDir & "\vnc2me_sc.ini", "LANGUAGES", "LANG_COUNT", 1)
	While $loopcount < $iniCount
		;		V2M_EventLog('Language loopcount = ' & $loopcount & " & " & @OSLang & " <> LANG_IDENT_"&$loopcount, $V2M_EventDisplay, 'dll')
		If StringInStr(IniRead(@ScriptDir & "\vnc2me_sc.ini", "LANGUAGES", "LANG_IDENT_" & $loopcount, ""), @OSLang) Then
			V2M_EventLog('Language loopcount=' & $loopcount & " & Lang Ident " & @OSLang & " was found in LANG_IDENT_" & $loopcount, $V2M_EventDisplay, 'dll')
			$return = IniRead(@ScriptDir & "\vnc2me_sc.ini", "LANGUAGES", "LANG_NAME_" & $loopcount, "English")
			$loopcount = $iniCount + 1
		Else
			V2M_EventLog('Language loopcount=' & $loopcount & " & Lang Ident " & @OSLang & " was found in LANG_IDENT_" & $loopcount, $V2M_EventDisplay, 'dll')
			V2M_EventLog('Language loopcount=' & $loopcount & " & Lang Ident " & @OSLang & " NOT found in LANG_IDENT_" & $loopcount, $V2M_EventDisplay, 'dll')
		EndIf
		$loopcount = $loopcount + 1 ; increment loopcount
	WEnd
	If $return = '' Then
		$V2M_EventDisplay = V2M_EventLog("Language - Current language not detected, defaulting to english <@OSLang = " & @OSLang & ">", $V2M_EventDisplay, 'dll')
		Return "English"
	Else
		$V2M_EventDisplay = V2M_EventLog("Language - Auto detected language: " & $return & " <@OSLang = " & @OSLang & ">", $V2M_EventDisplay, 'dll')
		Return $return
	EndIf
	V2M_EventLog('Language loopcount = ' & $loopcount & @CRLF & 'inicount = ' & $iniCount & @CRLF & '@OSLang = ' & @CRLF & @OSLang & " = LANG_IDENT_" & $loopcount, $V2M_EventDisplay, 'dll')
EndFunc   ;==>_Language

;=========================================================================================================================================================
;=========================================================================================================================================================
;=========================================================================================================================================================

;Func CheckPort($CheckPortIP, $CheckPortPort)
;	Local $socket
;
;	TCPStartUp()
;	$socket = TCPConnect( $CheckPortIP, $CheckPortPort )
;	Return $socket
;	TCPShutdown ()
;
;EndFunc

;=========================================================================================================================================================

;Func CheckPortLoop($count1, $CheckPortLoopIP, $CheckPortLoopPort)
;	Local $loop, $Exit
;	$loop = 1
;	TCPStartup()
;	While $loop < $count1
;		$Exit = TCPConnect($CheckPortLoopIP, $CheckPortLoopPort)
;;		$Exit = CheckPort($CheckPortLoopIP, $CheckPortLoopPort)
;		If $Exit = -1 Then
;			$loop = $loop + 1
;			Sleep (1000)
;		Else
;			$loop = $count1
;		EndIf
;		MsgBox(64, "CheckPort()", "checkport results: " & $Exit & @CRLF & "$loop: " & $loop)
;	WEnd
;	TCPShutdown()
;EndFunc

;=========================================================================================================================================================

;Func CloseFunc($prog)
;	Local $PID
;
;	$PID = ProcessExists($prog)
;	If $PID Then ProcessClose($PID)
;
;EndFunc

;===============================================================================
;
; Description:		the following are experimentations and not used in the production release (yet)
; Parameter(s):
; Requirement(s):
; Return Value(s):
; Author(s):
; Note(s):
;
;===============================================================================
;Func BrowseForConfig()
;	$sFile = FileOpenDialog("Select config file", @ScriptDir, "INI files (*.ini)", 1)
;	If @error Or StringRight($sFile, 4) <> ".ini" Then Return ""
;	Return $sFile
;EndFunc   ;==>BrowseForConfig

;=========================================================================================================================================================

;Func LoadSettings($sIni = "vnc2me_sc.ini")
;	$sIni = @ScriptDir & "\vnc2me_sc.ini"
;	$V2M_INI_GUIName = IniRead($sIni, "V2MGUI", "GUIName", "V2M")
;	$V2MHost = IniRead($sIni, "$V2MServer", "Host", "nowhere.nohost")
;	$V2M = IniRead($sIni, "MAP", "User", "User")
;EndFunc   ;==>LoadSettings

;=========================================================================================================================================================

;Func SaveSettings($sIni = "vnc2me_sc.ini")
;	$sIni = @ScriptDir & "\vnc2me_sc.ini"
;	IniWrite($sIni, "MAP", "Letter", GUICtrlRead($hMapLetter))
;EndFunc   ;==>SaveSettings

;=========================================================================================================================================================

;Func SettingsToGUI()
;	GUICtrlSetData($hMapLetter, $gMapLetter)
;	GUICtrlSetData($hMapPasswordEdit, $gMapPassword)
;EndFunc   ;==>SettingsToGUI

;=========================================================================================================================================================