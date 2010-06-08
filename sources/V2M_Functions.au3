;
; Misc FUNCTIONS
;



;===============================================================================
;
; Description:		Ask if you want to add host key
; Parameter(s):		none
; Requirement(s):	$V2M_ProcessIDs[1] needs to be global, and hold controlID for plink.exe
; Return Value(s):	none
; Author(s):		YTS_Jim
; Note(s):
;
;===============================================================================
Func V2MAddHostKey($hostkey = '')
	$V2M_EventDisplay = YTS_EventLog("FUNC - V2MAddHostKey($hostkey = '')", $V2M_EventDisplay, "9")
	Local $msgbox
	;Add Host key to knownhosts
	$V2M_EventDisplay = YTS_EventLog('Host key not cached', $V2M_EventDisplay, '5')
	;	JDs_debug("STDERR found")
	$msgbox = MsgBox(4, _Translate($V2M_GUI_Language, "MSG_HOST_TITLE", "HOST NOT CACHED"), _Translate($V2M_GUI_Language, "MSG_HOST_TEXT", "THIS HOST IS NOT KNOWN, DO YOU WANT TO ADD IT TO KNOWN HOSTS ???") & @CRLF & "$hostkey = " & $hostkey)
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
; Author(s):		YTS_Jim
; Note(s):
;
;===============================================================================
Func V2MRandomPort()
	$V2M_EventDisplay = YTS_EventLog("FUNC - V2MRandomPort()", $V2M_EventDisplay, "9")
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
; Author(s):		YTS_Jim
; Note(s):
;
;===============================================================================
Func V2MAboutBox()
	$V2M_EventDisplay = YTS_EventLog("FUNC - V2MAboutBox()", $V2M_EventDisplay, "9")
	MsgBox(0, "About", $V2M_GUI_MainTitle & @CRLF & "Creates a secure Tunnel (via SSH)," & @CRLF & "and starts VNC through this tunnel (thereby securing it)" & @CRLF & @CRLF & "visit: www.vnc2me.org for further details" & @CRLF & @CRLF & "© 2008-2010 Secure Technology Group Pty Ltd (AUS).")
EndFunc   ;==>V2MAboutBox

;===============================================================================
;
; Description:		Swaps between the GUI's
; Parameter(s):		$GUI_title = Title of window to change
;					$GUI_state = hide / show for hiding or showing respectively
; Requirement(s):	GUI Titles, and control ID's from creating the GUI's
; Return Value(s):	"GUI - Changing " & $GUI_title & " to " & $GUI_state
; Author(s):		YTS_Jim
; Note(s):			modified version of V2MGuiSwap, simplified somewhat
;
;===============================================================================
Func V2MGuiChangeState($GUI_id, $GUI_title, $GUI_state)
	$V2M_EventDisplay = YTS_EventLog("FUNC - V2MGuiChangeState($GUI_id = " & $GUI_id & ", $GUI_title = " & $GUI_title & ", $GUI_state = " & $GUI_state & ")", $V2M_EventDisplay, "9")
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
; Author(s):		YTS_Jim
; Note(s):			Replaces both V2MSSHUser() & V2MSSHPass()
;
;===============================================================================
Func V2MInBoxSTDINWrite($WriteWhere, $WriteWhat = "", $InBoxTitle = "Password", $InBoxText = "Enter Password", $InBoxPassHash = "")
	$V2M_EventDisplay = YTS_EventLog("FUNC - V2MInBoxSTDINWrite($WriteWhere = " & $WriteWhere & ", $WriteWhat = " & $WriteWhat & ", $InBoxTitle = " & $InBoxTitle & ", $InBoxText = " & $InBoxText & ", $InBoxPassHash = " & $InBoxPassHash & ")", $V2M_EventDisplay, "9")
	;if $write not passed in func call, ask for it.
	If $WriteWhat = "" Then
		$WriteWhat = InputBox($InBoxTitle, $InBoxText, "", $InBoxPassHash, 300, 100, (@DesktopWidth / 2) - 150, (@DesktopHeight / 2) - 50, 0, $V2M_GUI_Main)
		If @error = 1 Then
			$V2M_Exit = 1
		EndIf
	EndIf
	;writes "password"
	$V2M_EventDisplay = YTS_EventLog("AUTH - Passing " & $InBoxTitle, $V2M_EventDisplay, '5')
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
; Author(s):		YTS_Jim
; Note(s):			Only checked every 100 cycles of the While loop.
;
;===============================================================================

Func V2M_CheckRunning()
	;	$V2M_EventDisplay = YTS_EventLog("FUNC - V2M_CheckRunning()", $V2M_EventDisplay, "9")
	If $V2M_Status[3][5] Then ;scstarted
		If Not ProcessExists($V2M_VNC_SC) Then
			$V2M_Status[3][5] = 0
			$V2M_EventDisplay = YTS_EventLog($V2M_VNC_SC & " has Closed", $V2M_EventDisplay, '8')
		EndIf
	EndIf
	If $V2M_Status[3][7] Then ;SVRstarted
		If Not ProcessExists($V2M_VNC_SVR) Then
			$V2M_Status[3][7] = 0
			$V2M_EventDisplay = YTS_EventLog($V2M_VNC_SVR & " has Closed", $V2M_EventDisplay, '8')
		EndIf
	EndIf
	If $V2M_Status[3][10] Then ;vwrstarted
		If Not ProcessExists($V2M_VNC_VWR) Then
			$V2M_Status[3][10] = 0
			$V2M_EventDisplay = YTS_EventLog($V2M_VNC_VWR & " has Closed", $V2M_EventDisplay, '8')
		EndIf
	EndIf
	If $V2M_Status[3][2] Then ;sshstarted
		If Not ProcessExists($V2M_SSH_APP) Then
			V2M_startvnc("ssh")
			$V2M_Status[3][2] = 0
			$V2M_Status[3][3] = 0
			$V2M_Status[3][5] = 0
			$V2M_Status[3][7] = 0
			$V2M_Status[3][10] = 0
			;			V2M_Timer("Stop")
			$V2M_EventDisplay = YTS_EventLog($V2M_SSH_APP & " has Closed after: " & (V2M_Timer("Read")), $V2M_EventDisplay, '8')
		EndIf
	EndIf
	If $V2M_Status[3][12] Then ;uvncstarted
		If Not ProcessExists($V2M_VNC_UVNC) Then
			$V2M_Status[3][12] = 0
			$V2M_EventDisplay = YTS_EventLog($V2M_VNC_UVNC & " has Closed", $V2M_EventDisplay, '8')
		EndIf
	EndIf
EndFunc   ;==>V2M_CheckRunning

;===============================================================================
;
; Description:		Starts the Appropriate VNC Application
; Parameter(s):		Nill
; Requirement(s):	$V2M_Status[3][X]
; Return Value(s):	Nill
; Author(s):		YTS_Jim
; Note(s):			Only checked every 100 cycles of the While loop.
;
;===============================================================================

Func V2M_startvnc($how = 'ssh')
	$V2M_EventDisplay = YTS_EventLog("FUNC - V2M_startvnc($how = " & $how & ")", $V2M_EventDisplay, "9")
	$V2M_EventDisplay = YTS_EventLog("VNC - Starting VNC using '" & $how & "' Connection type" & @CRLF & "$V2M_Status[3][4] = " & $V2M_Status[3][4] & @CRLF & "$V2M_Status[3][6] = " & $V2M_Status[3][6] & @CRLF & "$V2M_Status[3][8] = " & $V2M_Status[3][8] & @CRLF & "$V2M_Status[3][9] = " & $V2M_Status[3][9] & @CRLF & "$V2M_Status[3][11] = " & $V2M_Status[3][11], $V2M_EventDisplay, '7')
	V2M_CheckRunning()
	If $how = "ssh" Then
		If $V2M_Status[3][4] Then ;scwanted
			If Not $V2M_Status[3][5] Then
				$V2M_EventDisplay = YTS_EventLog("VNC - Starting SC via SSH", $V2M_EventDisplay, '5')
				;				If ProcessExists($V2M_VNC_SC) Then ProcessClose($V2M_VNC_SC)
				$V2M_ProcessIDs[3] = Run($V2M_VNC_SC & " -connect 127.0.0.1:25400", @ScriptDir, @SW_HIDE, 7) ;run sc
				$V2M_Status[3][5] = 1 ;flag As started
				Sleep(2000)
				Return ("SCviaSSH")
			EndIf
		ElseIf $V2M_Status[3][6] Then ;svrwanted
			If Not $V2M_Status[3][7] Then
				$V2M_EventDisplay = YTS_EventLog("VNC - Starting SVR via SSH", $V2M_EventDisplay, '5')
				;				If ProcessExists($V2M_VNC_SVR) Then ProcessClose($V2M_VNC_SVR)
				$V2M_ProcessIDs[4] = Run(@ScriptDir & "\" & $V2M_VNC_SVR & " AcceptCutText=0 AcceptPointerEvents=0 AcceptKeyEvents=0 AlwaysShared=1 LocalHost=1 SecurityTypes=None PortNumber=25900", @ScriptDir, @SW_HIDE, 7) ;run svr
				$V2M_Status[3][7] = 1 ;	flag As started
				Sleep(2000)
				Return ("SVRviaSSH")
			EndIf
		ElseIf $V2M_Status[3][8] Then ;vwrscwanted
			If $V2M_Status[3][10] <> 1 Then
				$V2M_EventDisplay = YTS_EventLog("VNC - Starting VWR for SC via SSH", $V2M_EventDisplay, '9')
				$V2M_ProcessIDs[2] = Run($V2M_VNC_VWR & " -listen 15500 -8greycolours -autoscaling", @ScriptDir, @SW_HIDE, 7) ;run vwr For sc connection
				;				MsgBox(0, 'Debug', '@error = '&@error&@CRLF&'$V2M_ProcessIDs[2] = '&$V2M_ProcessIDs[2],3)
				;				If ProcessExists($V2M_VNC_VWR) Then ProcessClose($V2M_VNC_VWR)
				$V2M_Status[3][10] = 1 ;	flag As started
				Return ("VWRSCviaSSH")
			EndIf
		ElseIf $V2M_Status[3][9] Then ;vwrsvrwanted
			If $V2M_Status[3][10] <> 1 Then
				$V2M_EventDisplay = YTS_EventLog("VNC - Starting VWR for SVR via SSH", $V2M_EventDisplay, '5')
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
; Author(s):		YTS_Jim
; Note(s):			none
;
;===============================================================================
Func V2MExitVNC()
	$V2M_EventDisplay = YTS_EventLog("FUNC - V2MExitVNC()", $V2M_EventDisplay, "9")
	$V2M_EventDisplay = YTS_EventLog('VNC - Waiting to close all VNCs cleanly', $V2M_EventDisplay, '7')
	While ProcessExists($V2M_VNC_VWR)
		ProcessWaitClose($V2M_VNC_VWR, 3)
		If ProcessExists($V2M_VNC_VWR) Then
			ProcessClose($V2M_VNC_VWR)
			$V2M_EventDisplay = YTS_EventLog('VNC - ' & $V2M_VNC_VWR & ' Closed Forcibly', $V2M_EventDisplay, '8')
		Else
			$V2M_EventDisplay = YTS_EventLog('VNC - ' & $V2M_VNC_VWR & ' Closed Cleanly', $V2M_EventDisplay, '8')
		EndIf
	WEnd
	While ProcessExists($V2M_VNC_SC)
		ProcessWaitClose($V2M_VNC_SC, 3)
		If ProcessExists($V2M_VNC_SC) Then
			ProcessClose($V2M_VNC_SC)
			$V2M_EventDisplay = YTS_EventLog('VNC - ' & $V2M_VNC_SC & ' Closed Forcibly', $V2M_EventDisplay, '8')
		Else
			$V2M_EventDisplay = YTS_EventLog('VNC - ' & $V2M_VNC_SC & ' Closed Cleanly', $V2M_EventDisplay, '8')
		EndIf
	WEnd
	While ProcessExists($V2M_VNC_SVR)
		ProcessWaitClose($V2M_VNC_SVR, 3)
		If ProcessExists($V2M_VNC_SVR) Then
			ProcessClose($V2M_VNC_SVR)
			$V2M_EventDisplay = YTS_EventLog('VNC - ' & $V2M_VNC_SVR & ' Closed Forcibly', $V2M_EventDisplay, '8')
		Else
			$V2M_EventDisplay = YTS_EventLog('VNC - ' & $V2M_VNC_SVR & ' Closed Cleanly', $V2M_EventDisplay, '8')
		EndIf
	WEnd
	While ProcessExists($V2M_VNC_UVNC)
		ProcessWaitClose($V2M_VNC_UVNC, 3)
		If ProcessExists($V2M_VNC_UVNC) Then
			ProcessClose($V2M_VNC_UVNC)
			$V2M_EventDisplay = YTS_EventLog('VNC - ' & $V2M_VNC_UVNC & ' Closed Forcibly', $V2M_EventDisplay, '8')
		Else
			$V2M_EventDisplay = YTS_EventLog('VNC - ' & $V2M_VNC_UVNC & ' Closed Cleanly', $V2M_EventDisplay, '8')
		EndIf
	WEnd
	ProcessClose($V2M_VNC_VWR)
	ProcessClose($V2M_VNC_SC)
	ProcessClose($V2M_VNC_SVR)
	$V2M_EventDisplay = YTS_EventLog('VNC - All VNCs closed', $V2M_EventDisplay, '8')
	_RefreshSystemTray(50)
EndFunc   ;==>V2MExitVNC

;===============================================================================
;
; Description:		Creates the SSH tunnel
; Parameter(s):
; Requirement(s):	$V2M_GUI_DebugOutputEdit, $V2M_SessionCode, $V2M_SSH[1]
; Return Value(s):	$V2M_ProcessIDs[1]
; Author(s):		YTS_Jim
; Note(s):
;
;===============================================================================
;Func V2MSSHConnect($V2M_SessionCode = '', $RunWhat = 'v2mplink', $StandardHost = '', $RunWhere = @ScriptDir)
Func V2MSSHConnect()
	$V2M_EventDisplay = YTS_EventLog("FUNC - V2MSSHConnect()", $V2M_EventDisplay, "9")
	Local $Local_ConnectString, $local_return
	ProcessClose($V2M_SSH_APP)
	If FileExists(@ScriptDir & "\sshhostkeys") Then
		If Not FileExists(@ScriptDir & "\.putty\sshhostkeys") Then
			FileMove(@ScriptDir & "\sshhostkeys", @ScriptDir & "\.putty\sshhostkeys", 8)
		EndIf
	EndIf

	If $V2M_Status[3][4] = 1 Then ; SC wanted
		$V2M_SessionCode = GUICtrlRead($V2M_GUI[19])
	ElseIf $V2M_Status[3][6] = 1 Then ; svr wanted
		$V2M_SessionCode = GUICtrlRead($V2M_GUI[35])
	ElseIf $V2M_Status[3][8] = 1 Or $V2M_Status[3][9] = 1 Then ; vwr scwanted, vwr svrwanted
		$V2M_SessionCode = GUICtrlRead($V2M_GUI[12])
	Else
		;		$V2M_SessionCode = ""
	EndIf

	If $V2M_SessionCode = '' Then
		MsgBox(0, _Translate($V2M_GUI_Language, "MSG_SSN_TITLE", "BLANK SESSION CODE"), _Translate($V2M_GUI_Language, "MSG_SSN_TEXT", "PLEASE ENTER THE SESSION CODE AND TRY AGAIN"), 20, $V2M_GUI_Main)
		$V2M_EventDisplay = YTS_EventLog("GUI - Session Code was blank", $V2M_EventDisplay, '8')
		$V2M_Status[1][1] = '' ;ConnectionType
		$V2M_Status[3][1] = 0 ; ssh wanted
		$V2M_Status[3][2] = 0 ; ssh started
		$V2M_Status[3][3] = 0 ; ssh Connected
		$V2M_Status[3][4] = 0 ; SC wanted
		$V2M_Status[3][6] = 0 ; svr wanted
		$V2M_Status[3][8] = 0 ; vwr scwanted
		$V2M_Status[3][9] = 0 ; vwr svrwanted
	Else
		If (GUICtrlRead($V2M_GUI[65]) = 1) Then
			$V2M_CompressSSH = " -C"
		EndIf
		$V2M_EventDisplay = YTS_EventLog("SSH - Starting at " & @HOUR & ":" & @MIN & ":" & @SEC & ", for " & $V2M_Status[1][1] & " Connections, (Session Code = " & $V2M_SessionCode & ")", $V2M_EventDisplay, '2')
		If $V2M_SSH[1] = "" Then
			$V2M_EventDisplay = YTS_EventLog("SSH - No Hostname set", $V2M_EventDisplay, '2')
			$V2M_SSH[1] = InputBox(_Translate($V2M_GUI_Language, "MSG_SSHSVR_TITLE", "HOST SERVER"), _Translate($V2M_GUI_Language, "MSG_SSHSVR_TEXT", "CONNECT TO WHICH SSH SERVER ?"), "", "", 300, 100, (@DesktopWidth / 2) - 150, (@DesktopHeight / 2) - 50, 240, $V2M_GUI_Main)
			If @error = 1 Then
				$V2M_Status[3][1] = 0 ;sshwanted = 0
				$V2M_Status[1][1] = '' ;ConnectionType
			ElseIf $V2M_SSH[1] = "" Then
				$V2M_Status[3][1] = 0 ;sshwanted = 0
			EndIf
		EndIf

		If $V2M_Status[1][1] = 'VWR' Then ;ConnectionType is viewer
			If IniRead($AppINI, "V2M_GUI", "VNC_VWR_SC_ONLY", 0) = 1 Then
				TrayTip(_Translate($V2M_GUI_Language, "TRAYTIP_VWR_STARTSC_TITLE", "VWR_STARTSC_TITLE"), _Translate($V2M_GUI_Language, "TRAYTIP_VWR_STARTSC_LINE1", "") & @CR & _Translate($V2M_GUI_Language, "TRAYTIP_VWR_STARTSC_LINE2", ""), 30)
				$Local_ConnectString = @ScriptDir & '\v2mplink.exe -R ' & $V2M_SessionCode & ':127.0.0.1:15500 -R ' & $V2M_SessionCode + 1 & ':127.0.0.1:15501 ' & $V2M_SSH[1] & ' -v -N' & $V2M_CompressSSH
				$V2M_Status[3][8] = 1
			ElseIf IniRead($AppINI, "V2M_GUI", "VNC_VWR_SVR_ONLY", 0) = 1 Then
				TrayTip(_Translate($V2M_GUI_Language, "TRAYTIP_VWR_STARTSVR_TITLE", "VWR_STARTSVR_TITLE"), _Translate($V2M_GUI_Language, "TRAYTIP_VWR_STARTSVR_LINE1", "") & @CR & _Translate($V2M_GUI_Language, "TRAYTIP_VWR_STARTSVR_LINE2", ""), 30)
				$Local_ConnectString = @ScriptDir & '\v2mplink.exe -L 25900:127.0.0.1:' & $V2M_SessionCode & ' -R ' & $V2M_SessionCode + 1 & ':127.0.0.1:15501 ' & $V2M_SSH[1] & ' -v -N' & $V2M_CompressSSH
				$V2M_Status[3][9] = 1
			Else
				If $V2M_Status[3][8] = 1 Or GUICtrlRead($V2M_GUI[40]) = 1 Then ;vwrscwanted
					TrayTip(_Translate($V2M_GUI_Language, "TRAYTIP_VWR_STARTSC_TITLE", "VWR_STARTSC_TITLE"), _Translate($V2M_GUI_Language, "TRAYTIP_VWR_STARTSC_LINE1", "") & @CR & _Translate($V2M_GUI_Language, "TRAYTIP_VWR_STARTSC_LINE2", ""), 30)
					$Local_ConnectString = @ScriptDir & '\v2mplink.exe -R ' & $V2M_SessionCode & ':127.0.0.1:15500 -R ' & $V2M_SessionCode + 1 & ':127.0.0.1:15501 ' & $V2M_SSH[1] & ' -v -N' & $V2M_CompressSSH
					$V2M_Status[3][8] = 1
				ElseIf $V2M_Status[3][9] = 1 Or GUICtrlRead($V2M_GUI[41]) = 1 Then ;vwrsvrwanted
					TrayTip(_Translate($V2M_GUI_Language, "TRAYTIP_VWR_STARTSVR_TITLE", "VWR_STARTSVR_TITLE"), _Translate($V2M_GUI_Language, "TRAYTIP_VWR_STARTSVR_LINE1", "") & @CR & _Translate($V2M_GUI_Language, "TRAYTIP_VWR_STARTSVR_LINE2", ""), 30)
					$Local_ConnectString = @ScriptDir & '\v2mplink.exe -L 25900:127.0.0.1:' & $V2M_SessionCode & ' -R ' & $V2M_SessionCode + 1 & ':127.0.0.1:15501 ' & $V2M_SSH[1] & ' -v -N' & $V2M_CompressSSH
					$V2M_Status[3][9] = 1
				Else
					$local_return = MsgBox(1, _Translate($V2M_GUI_Language, "MSG_VWR_TITLE", "VIEWER"), _Translate($V2M_GUI_Language, "MSG_VWR_TEXT", "NO VIEWER CONNECTION TYPE CHOSEN" & @CRLF & "DEFAULTED TO SC"), 10)
					If $local_return = -1 Or $local_return = 1 Then
						GUICtrlSetState($V2M_GUI[40], 1) ;Check the SC vwr radio item.
						$V2M_Status[3][8] = 1 ;vwrSCwanted
					Else
						$V2M_Status[1][1] = '' ;ConnectionType
						$V2M_Status[3][1] = 0 ;sshwanted = 0
					EndIf
				EndIf
			EndIf

			;			If ($V2M_Status[3][9] = 1) Or (IniRead($AppINI, "V2M_GUI", "VWR_VWR_SVR_ONLY", 0) = 1) Then		;vwrSVRwanted
			;				$Local_ConnectString = @ScriptDir & '\v2mplink.exe -L 25900:127.0.0.1:' & $V2M_SessionCode & ' ' & $V2M_SSH[1] & ' -v -N' & $V2M_CompressSSH
			;			Else
			;				$Local_ConnectString = @ScriptDir & '\v2mplink.exe -R ' & $V2M_SessionCode & ':127.0.0.1:15500 ' & $V2M_SSH[1] & ' -v -N' & $V2M_CompressSSH
			;			EndIf
		ElseIf $V2M_Status[1][1] = 'SVR' Then ;ConnectionType is Collaboration Server
			$Local_ConnectString = @ScriptDir & '\v2mplink.exe -R ' & $V2M_SessionCode & ':127.0.0.1:15500 -L 15501:127.0.0.1:' & $V2M_SessionCode + 1 & ' ' & $V2M_SSH[1] & ' -v -N' & $V2M_CompressSSH
		ElseIf $V2M_Status[1][1] = 'SC' Then ;ConnectionType is SC
			$Local_ConnectString = @ScriptDir & '\v2mplink.exe -L 25400:127.0.0.1:' & $V2M_SessionCode & ' -L 15501:127.0.0.1:' & $V2M_SessionCode + 1 & ' ' & $V2M_SSH[1] & ' -v -N' & $V2M_CompressSSH
		Else
			$Local_ConnectString = @ScriptDir & '\v2mplink.exe -R ' & $V2M_SessionCode & ':127.0.0.1:15500 -L 25400:127.0.0.1:' & $V2M_SessionCode & ' -L 15501:127.0.0.1:' & $V2M_SessionCode + 1 & ' ' & $V2M_SSH[1] & ' -v -N' & $V2M_CompressSSH
		EndIf
		If $V2M_Status[3][1] = 0 Then ;sshwanted
			$V2M_EventDisplay = YTS_EventLog("RUN - NOT Starting SSH at " & @HOUR & ":" & @MIN & ":" & @SEC & " <due to error in V2MSSHConnect()>", $V2M_EventDisplay, '8')
			$V2M_Status[3][2] = 0 ;ssh started
			$V2M_Status[3][4] = 0
			$V2M_Status[3][6] = 0
			$V2M_Status[3][8] = 0
			$V2M_Status[3][9] = 0

		Else ;sshwanted
			$V2M_ProcessIDs[1] = Run($Local_ConnectString, @ScriptDir, @SW_HIDE, 7)
			$V2M_EventDisplay = YTS_EventLog("RUN - Starting SSH at " & @HOUR & ":" & @MIN & ":" & @SEC & " (remote port " & $V2M_SessionCode & ")", $V2M_EventDisplay, '8')
			$V2M_EventDisplay = YTS_EventLog("RUN - Run($Local_ConnectString, @ScriptDir, @SW_HIDE, 7)", $V2M_EventDisplay, '9')
			$V2M_EventDisplay = YTS_EventLog("RUN - Run(" & $Local_ConnectString & ", " & @ScriptDir & ", " & @SW_HIDE & ", 7)", $V2M_EventDisplay, '9')
			$V2M_Status[3][2] = 1 ;ssh started
			Return $V2M_ProcessIDs[1]
		EndIf
	EndIf
EndFunc   ;==>V2MSSHConnect

;===============================================================================
;
; Description:		exits all v2m ssh apps
; Parameter(s):		none
; Requirement(s):	$V2M_ProcessIDs[1] needs to be gloabal, and hold controlID for plink.exe
; Return Value(s):	none
; Author(s):		YTS_Jim
; Note(s):
;
;===============================================================================
Func V2MExitSSH()
	$V2M_EventDisplay = YTS_EventLog("FUNC - V2MExitSSH()", $V2M_EventDisplay, "9")
	StdinWrite($V2M_ProcessIDs[1], "exit " & @CR)
	While ProcessExists("v2mplink.exe")
		$V2M_EventDisplay = YTS_EventLog('SSH - Waiting to close cleanly', $V2M_EventDisplay, '9')
		ProcessWaitClose("v2mplink.exe", 6)
		If ProcessExists("v2mplink.exe") Then
			ProcessClose("v2mplink.exe")
			$V2M_EventDisplay = YTS_EventLog('SSH - Closed Forcibly', $V2M_EventDisplay, '9')
		Else
			;			$V2M_EventDisplay=YTS_EventLog('SSH - Closed Cleanly', $V2M_EventDisplay, '8')
		EndIf
	WEnd
	$V2M_EventDisplay = YTS_EventLog('SSH - All SSHs Closed', $V2M_EventDisplay, '4')
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
; Author(s):		YTS_Jim
; Note(s):
;
;===============================================================================
Func V2MGUICtrlSetData($ControlID, $data, $default = 0)
	$V2M_EventDisplay = YTS_EventLog("FUNC - V2MGUICtrlSetData($ControlID = " & $ControlID & ", $data = " & $data & ", $default = " & $default & ")", $V2M_EventDisplay, "9")
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
; Author(s):		YTS_Jim
; Note(s):
;
;===============================================================================
Func V2M_EventLog($V2M_EventLog = '', $V2M_EventDisplay = '', $JDs_debug_only = '8')
	;	$V2M_EventDisplay = YTS_EventLog("FUNC - V2M_EventLog($V2M_EventLog = " & $V2M_EventLog & ", $V2M_EventDisplay = " & $V2M_EventDisplay & ", $JDs_debug_only = " & $JDs_debug_only & ")", $V2M_EventDisplay, "9")
	;	If $V2M_EventLog = $V2M_EventDisplay Then
	;		;do nothing
	;	Else
	If $V2M_EventLog <> $V2M_EventDisplay Then
		If $JDs_debug_only = '0' Or $JDs_debug_only = 'full' Then
			;		MsgBox(0, "Debug", $JDs_debug_only, 2)
			;send to minigui event log
			;			GUICtrlSetData($V2M_GUI[8], $V2M_EventLog, 1)
			_GUICtrlStatusBar_SetText($V2M_GUI[42], $V2M_EventLog, 1) ;send to minigui event log
			_GUICtrlStatusBar_SetText($V2M_GUI[43], $V2M_EventLog, 1) ;send to maingui event log
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
; Description:		Eventlog handler, sends logs to std windows debug (via dll)
;					and GUI Statusbars
; Parameter(s):		$V2M_EventLog	=	Text string to send to log
;					$JDs_debug_level	=	0, text is display in statusbar. else, only sent to debug dll
; Requirement(s):
; Return Value(s):	$V2M_EventDisplay
; Author(s):		YTS_Jim
; Note(s):
;
;===============================================================================
Func YTS_EventLog($V2M_EventLog = '', $V2M_EventDisplay = '', $Local_debug_level = '6')
	If $V2M_EventDisplay <> $V2M_EventLog Then
		If $Local_debug_level <= $DebugLevel Then
			If $Local_debug_level > 6 Then
				;print to debugviewer only
				; view the following output from sysinternals debuger "DebugView" or similar
				DllCall("kernel32.dll", "none", "OutputDebugString", "str", "V2M - " & $V2M_EventLog)
			ElseIf $Local_debug_level > 3 Then
				;print to debug, debugview
				; view the following output from sysinternals debuger "DebugView" or similar
				DllCall("kernel32.dll", "none", "OutputDebugString", "str", "V2M - " & $V2M_EventLog)
				If $V2M_Status[1][2] = 1 Then GUICtrlSetData($V2M_GUI_DebugOutputEdit, $V2M_EventLog & @CRLF, 1)
			Else ; $Local_debug_level <= 3 Then
				;print to tray, debug, debugview
				; view the following output from sysinternals debuger "DebugView" or similar
				DllCall("kernel32.dll", "none", "OutputDebugString", "str", "V2M - " & $V2M_EventLog)
				If $V2M_Status[1][2] = 1 Then GUICtrlSetData($V2M_GUI_DebugOutputEdit, $V2M_EventLog & @CRLF, 1)
				_GUICtrlStatusBar_SetText($V2M_GUI[42], $V2M_EventLog, 1) ;send to minigui statusbar
				_GUICtrlStatusBar_SetText($V2M_GUI[43], $V2M_EventLog, 1) ;send to maingui statusbar
			EndIf
			$V2M_EventDisplay = $V2M_EventLog
		EndIf
	EndIf
	Return $V2M_EventDisplay
EndFunc   ;==>YTS_EventLog

;===============================================================================
;
; Description:		This is executed when Autoit exits
; Parameter(s):		none
; Requirement(s):	none
; Return Value(s):	none
; Author(s):		YTS_Jim
; Note(s):			Function name can be renamed, but only if ;Opt("OnExitFunc", "OnAutoItExit") is set (and OnAutoItExit is changed to new name)
;
;===============================================================================
Func OnAutoItExit()
	$V2M_EventDisplay = YTS_EventLog("FUNC - OnAutoItExit()", $V2M_EventDisplay, "9")
	Local $timer
	TrayTip(_Translate($V2M_GUI_Language, "TRAYTIP_APP_EXITING_TITLE", "APP_EXITING_TITLE"), _Translate($V2M_GUI_Language, "TRAYTIP_APP_EXITING_LINE1", "") & @CR & _Translate($V2M_GUI_Language, "TRAYTIP_APP_EXITING_LINE2", ""), 30)
	;exit ssh & vnc
	V2MExitSSH()
	V2MExitVNC()
	;	ProcessClose("Aero_disable.exe") ; included here so that it closes before the temp folder it is located in gets deleted
	If IniRead($AppINI, "V2M_GUI", "GUI_TIMER_SHOW", 1) = 1 Then
		;		Local $timer
		$timer = V2M_Timer("Stop")
		If $timer <> "0:0:0" Then
			MsgBox(0, _Translate($V2M_GUI_Language, "MSG_TIMER_TITLE", "CONNECTION TIMER"), _Translate($V2M_GUI_Language, "MSG_TIMER_TEXT", "SESSION CONNECTED FOR: ") & " " & $timer, 60)
		EndIf
	EndIf
	If @OSVersion = "WIN_VISTA" Then
		YTS_EventLog("EXIT - @OSVersion = WIN_VISTA ", $V2M_EventDisplay, '8')
		;Enable UAC
		Vista_ControlUAC("Enable")
		;Enable Aero
		Vista_ControlAero("Enable")
	ElseIf @OSVersion = "WIN_7" Or @OSVersion = "WIN_2008" Or @OSVersion = "WIN_2008R2" Then
		YTS_EventLog("EXIT - @OSVersion = WIN_VISTA ", $V2M_EventDisplay, '8')
		;Enable UAC
		Vista_ControlUAC("Enable")
		;Enable Aero
		WIN7_ControlAero("Enable")
	EndIf
	;turn the wallpaper back on ...
	DllCall("user32.dll", "int", "SystemParametersInfo", "int", 20, "int", 0, "str", RegRead("HKEY_CURRENT_USER\Control Panel\Desktop", "Wallpaper"), "int", 3)
	If StringInStr(@ScriptDir, FileGetLongName(@TempDir)) Then
		YTS_EventLog("EXIT - Path is in the %temp% directory", $V2M_EventDisplay, "4")
		If @Compiled Then
			YTS_EventLog("EXIT - Application is Compiled, the whole directory (and sub-directories) will now be deleted", $V2M_EventDisplay, "4")
			_SelfDelete(5)
		EndIf
	Else
		YTS_EventLog("EXIT - Path is NOT in the %temp% directory, VNC2Me must be installed or not using 7z packaging, will NOT be deleting files", $V2M_EventDisplay, "4")
		YTS_EventLog("DEBUG - @ScriptDir = " & @ScriptDir & ", FileGetLongName(@TempDir) = " & FileGetLongName(@TempDir), $V2M_EventDisplay, "7")
	EndIf
	$V2M_EventDisplay = YTS_EventLog(' ', $V2M_EventDisplay, '7')
	;	Exit
	;	If $Debug = 1 Then MsgBox(0,"Debug - OnAutoItExit()","Program has finished " & @EXITMETHOD)
	_RefreshSystemTray(50)
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
; Author(s):		YTS_Jim
; Note(s):
;
;===============================================================================

Func V2M_Timer($TimerAction = 'Start')
	$V2M_EventDisplay = YTS_EventLog("FUNC - V2M_Timer($TimerAction = " & $TimerAction & ")", $V2M_EventDisplay, "9")
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


;===============================================================================
;
; Description:
; Parameter(s):
;
;
;
;
; Requirement(s):
; Return Value(s):
; Author(s):		YTS_Jim
; Note(s):
;
;===============================================================================

Func V2MPortRefused()
	$V2M_EventDisplay = YTS_EventLog("FUNC - V2MPortRefused()", $V2M_EventDisplay, "9")
	$V2M_MsgBox = MsgBox(270373, _Translate($V2M_GUI_Language, "MSG_PORTC_TITLE", "ERROR - SESSION REFUSED"), _Translate($V2M_GUI_Language, "MSG_PORTC_TEXT", "SSH SESSION TUNNEL REFUSED, RETRY SAME SETTINGS ???"), 60)
	If $V2M_MsgBox = 2 Then ;cancel pressed
		V2MExitSSH()
		V2MExitVNC()
		$V2M_Status[3][1] = 0 ;sshwanted
		$V2M_EventDisplay = YTS_EventLog(V2MGuiChangeState($V2M_GUI_Mini, $V2M_GUI_MiniTitle, 'hide'), $V2M_EventDisplay, 5)
		$V2M_Status[2][2] = 'hide'
		$V2M_EventDisplay = YTS_EventLog(V2MGuiChangeState($V2M_GUI_Main, $V2M_GUI_MainTitle, 'show'), $V2M_EventDisplay, 5)
		$V2M_Status[2][1] = 'show'
		$V2M_Exit = 1
	Else ;retry pressed or timeout
		V2MExitSSH()
		V2MExitVNC()
		$V2M_ProcessIDs[1] = V2MSSHConnect()
		V2M_Timer("Start")
	EndIf
EndFunc   ;==>V2MPortRefused


;===============================================================================
;
; Description:
; Parameter(s):
;
;
;
;
; Requirement(s):
; Return Value(s):
; Author(s):		YTS_Jim
; Note(s):
;
;===============================================================================

;Func _TicksToTime($iTicks, ByRef $iHours, ByRef $iMins, ByRef $iSecs)
;	If Number($iTicks) > 0 Then
;		$iTicks = Round($iTicks / 1000)
;		$iHours = Int($iTicks / 3600)
;		$iTicks = Mod($iTicks, 3600)
;		$iMins = Int($iTicks / 60)
;		$iSecs = Round(Mod($iTicks, 60))
;		; If $iHours = 0 then $iHours = 24
;		Return 1
;	ElseIf Number($iTicks) = 0 Then
;		$iHours = 0
;		$iTicks = 0
;		$iMins = 0
;		$iSecs = 0
;		Return 1
;	Else
;		SetError(1)
;		Return 0
;	EndIf
;EndFunc   ;==>_TicksToTime


;===============================================================================
;
; Description:		deletes the running script (if its compiled)
; Parameter(s):		$idelay - the amount of seconds to wait for initial, and between retry deletes
; Requirement(s):
; Return Value(s):
; Author(s):		YTS_Jim
; Note(s):
;
;===============================================================================

Func _SelfDelete($iDelay = 4)
	$V2M_EventDisplay = YTS_EventLog("FUNC - _SelfDelete($iDelay = " & $iDelay & ")", $V2M_EventDisplay, "9")
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


; #FUNCTION# ====================================================================================================================
; Name...........: _IniReadWrite
; Description ...: Reads a value from a standard format .ini file. If returned value = "" it writes default value to INI.
;               If no default given, it writes a space (which should mean it doesn't return back
; Syntax.........: _IniReadWrite ($LocalFilename, $LocalSection, $LocalKey, $LocalDefault = ' ')
;
; Parameters ....:      $LocalFilename -        The filename of the .ini file.
;                                       $LocalSection -         The section name in the .ini file.
;                                       $LocalKey -                     The key name in the in the .ini file.
;                                       $LocalDefault -         The default value to return (and write to INI) if the requested key is not found.
;
; Return values .:      Success -                       Returns the requested key value read from INI. ($LocalRead)
;                                       Failure -                       Returns the default string if requested key not found. ($LocalDefault)
;                                                                               Writes the $LocalDefault
; Author ........:      JDaus
; ===============================================================================================================================
Func _IniReadWrite($LocalFilename, $LocalSection, $LocalKey, $LocalDefault = ' ')
	$V2M_EventDisplay = YTS_EventLog("FUNC - _IniReadWrite($LocalFilename = " & $LocalFilename & ", $LocalSection = " & $LocalSection & ", $LocalKey = " & $LocalKey & ", $LocalDefault = " & $LocalDefault & ")", $V2M_EventDisplay, "9")
	Local $LocalRead, $LocalWrite, $return
	$LocalRead = IniRead($LocalFilename, $LocalSection, $LocalKey, '')
	If $LocalRead = '' Then
		SetError(1)
		$LocalWrite = IniWrite($LocalFilename, $LocalSection, $LocalKey, $LocalDefault)
		If $LocalWrite = 0 Then
			$return = 0
		Else
			$return = $LocalDefault
		EndIf
	Else
		$return = $LocalRead
	EndIf
	Return $return
EndFunc   ;==>_IniReadWrite

;===============================================================================
;
; Description:		Reads the v2m_lang.INI for a matching "LANG_IDENT" to the @OSLang
;					then reads the LANG_NAME and returns that name
; Parameter(s): 	Nill
;
;
;
;
; Requirement(s):	vm2_lang.ini needs to exist, otherwise defaults to english
; Return Value(s):	Language Name for use in translations
; Author(s):		YTS_Jim
; Note(s):
;
;===============================================================================

;MsgBox(0, "Your OS Language:", _Language())
;Func _Language()
;	$V2M_EventDisplay = YTS_EventLog("FUNC - _Language()", $V2M_EventDisplay, "9")
;	Local $return = '', $iniCount, $loopcount = 0
;	$iniCount = IniRead($AppINI, "LANGUAGES", "LANG_COUNT", 1)
;	While $loopcount < $iniCount
;		;		YTS_EventLog('Language loopcount = ' & $loopcount & " & " & @OSLang & " <> LANG_IDENT_"&$loopcount, $V2M_EventDisplay, '9')
;		If StringInStr(IniRead($AppINI, "LANGUAGES", "LANG_IDENT_" & $loopcount, ""), @OSLang) Then
;			YTS_EventLog('Language loopcount=' & $loopcount & " & Lang Ident " & @OSLang & " was found in LANG_IDENT_" & $loopcount, $V2M_EventDisplay, '8')
;			$return = IniRead($AppINI, "LANGUAGES", "LANG_NAME_" & $loopcount, "English")
;			$loopcount = $iniCount + 1
;		Else
;			YTS_EventLog('Language loopcount=' & $loopcount & " & Lang Ident " & @OSLang & " NOT found in LANG_IDENT_" & $loopcount, $V2M_EventDisplay, '8')
;		EndIf
;		$loopcount = $loopcount + 1 ; increment loopcount
;	WEnd
;	If $return = '' Then
;		$V2M_EventDisplay = YTS_EventLog("Language - Current language not detected, defaulting to english <@OSLang = " & @OSLang & ">", $V2M_EventDisplay, '8')
;		Return "English"
;	Else
;		$V2M_EventDisplay = YTS_EventLog("Language - Auto detected language: " & $return & " <@OSLang = " & @OSLang & ">", $V2M_EventDisplay, '8')
;		Return $return
;	EndIf
;	YTS_EventLog('Language loopcount = ' & $loopcount & @CRLF & 'inicount = ' & $iniCount & @CRLF & '@OSLang = ' & @CRLF & @OSLang & " = LANG_IDENT_" & $loopcount, $V2M_EventDisplay, '8')
;EndFunc   ;==>_Language


Func _Language()
	$V2M_EventDisplay = YTS_EventLog("FUNC - _Language()", $V2M_EventDisplay, "9")
	Local $return = '', $loopcount = 0, $Local_ExitLoop
	;       $iniCount = 1
	If IniRead($AppINI, "Common", "LANGUAGE", "") = "" Then
		;		YTS_EventLog('LANG - overide not found in $AppINI', $V2M_EventDisplay, "8")
		Do
			;			YTS_EventLog('LANG - @OSLang = ' & @OSLang & ' _Translate("LANGUAGES", "LANG_IDENT_" & $loopcount, "") = ' & _Translate("LANGUAGES", "LANG_IDENT_" & $loopcount+1, ""), $V2M_EventDisplay, "6")
			If StringInStr(_Translate("LANGUAGES", "LANG_IDENT_" & $loopcount, ""), @OSLang) Then
				YTS_EventLog('Language loopcount=' & $loopcount & " & Lang Ident " & @OSLang & " was found in LANG_IDENT_" & $loopcount, $V2M_EventDisplay, "6")
				$return = _Translate("LANGUAGES", "LANG_NAME_" & $loopcount, IniRead($AppINI, "Common", "LANGUAGE", "English"))
				$Local_ExitLoop = 1
				;                       $loopcount = $iniCount + 1
			Else
				;                       YTS_EventLog('Language loopcount=' & $loopcount & " & Lang Ident " & @OSLang & " was found in LANG_IDENT_" & $loopcount)
				YTS_EventLog('Language loopcount=' & $loopcount & " & Lang Ident " & @OSLang & " NOT found in LANG_IDENT_" & $loopcount, $V2M_EventDisplay, "6")
			EndIf
			$loopcount = $loopcount + 1 ; increment loopcount
		Until (_Translate("LANGUAGES", "LANG_IDENT_" & $loopcount, "") = "") Or $Local_ExitLoop = 1
	Else
		$return = IniRead($AppINI, "Common", "LANGUAGE", "English")
	EndIf
	If $return = '' Then
		$V2M_EventDisplay = YTS_EventLog("Language - Current language not detected, defaulting to english <@OSLang = " & @OSLang & ">", $V2M_EventDisplay, "4")
		IniWrite(@ScriptDir & "\v2m_lang.ini", "LANGUAGES", "LANG_NAME_" & $loopcount, "New_Language")
		IniWrite(@ScriptDir & "\v2m_lang.ini", "LANGUAGES", "LANG_IDENT_" & $loopcount, @OSLang)
		Return "English"
	Else
		$V2M_EventDisplay = YTS_EventLog("Language - Auto detected language: " & $return & " <@OSLang = " & @OSLang & ">", $V2M_EventDisplay, "4")
		If $return = "New_Language" Then $return = "English"
		Return $return
	EndIf
	;	YTS_EventLog('Language loopcount = ' & $loopcount & @CRLF & '@OSLang = ' & @OSLang & " = LANG_IDENT_" & $loopcount, $V2M_EventDisplay, "7")
EndFunc   ;==>_Language


Func _Translate($Local_Language = $V2M_GUI_Language, $TL_Parameter = "", $TL_Default = "")
	Local $local_return
	If FileExists(@ScriptDir & "\Lang\" & $Local_Language & ".ini") Then
		$local_return = IniRead(@ScriptDir & "\Lang\" & $Local_Language & ".ini", $V2M_GUI_Language, $TL_Parameter, $TL_Default)
	Else
		$local_return = IniRead(@ScriptDir & "\v2m_lang.ini", $V2M_GUI_Language, $TL_Parameter, $TL_Default)
	EndIf
	Return $local_return
EndFunc   ;==>_Translate


;===============================================================================
;
; Description:
; Parameter(s):
;
;
;
;
; Requirement(s):
; Return Value(s):
; Author(s):		YTS_Jim
; Note(s):
;
;===============================================================================

Func V2M_Update()
	$V2M_EventDisplay = YTS_EventLog("FUNC - V2M_Update()", $V2M_EventDisplay, "9")
	Local $s_GetVersFile, $local_loop, $local_loop_count
	If IniRead($AppINI, "Common", "INETUPDATE", 1) = 1 Or IniRead($AppINI, "Common", "TESTUPDATE", 0) = 1 Then
		$V2M_EventDisplay = YTS_EventLog("Updates - Checking for updates from vnc2me.org", $V2M_EventDisplay, '7')
		;#######################################################################################
		; check for old version control file and delete it
		;#######################################################################################
		If FileExists(@TempDir & "\v2m_latestversion.ini") Then
			If Not FileDelete(@TempDir & "\v2m_latestversion.ini") Then ; problem deleting old version control file
				$V2M_EventDisplay = YTS_EventLog("Updates - Cannot delete '" & @TempDir & "\v2m_latestversion.ini'", $V2M_EventDisplay, '8')
				MsgBox(262160, StringTrimRight(@ScriptName, 4) & " ERROR", "UPDATE CHECK FAILED" & @CRLF & @CRLF & "Possible cause: Old VCF file cannot be overwritten (may be read only).")
				Return SetError(3, 0, "262160|" & StringTrimRight(@ScriptName, 4) & " ERROR|UPDATE CHECK FAILED|Possible cause: Old VCF file cannot be overwritten (may be read only).")
			Else
				$V2M_EventDisplay = YTS_EventLog("Updates - Deleted '" & @TempDir & "\v2m_latestversion.ini'", $V2M_EventDisplay, '8')
			EndIf
		Else
			$V2M_EventDisplay = YTS_EventLog("Updates - VNC2Me update has not been run before on this computer", $V2M_EventDisplay, '8')
		EndIf
		;#######################################################################################
		; download version control file from web to temp dir
		;#######################################################################################
		$s_GetVersFile = InetGet("http://www.vnc2me.org/files/latestversion.ini", @TempDir & "\v2m_latestversion.ini", 1)
		If $s_GetVersFile = 0 Then ; version file or internet not available
			$V2M_EventDisplay = YTS_EventLog("Updates - Unable to get the version information from the internet", $V2M_EventDisplay, '8')
			MsgBox(262160, StringTrimRight(@ScriptName, 4) & " ERROR", "UPDATE CHECK FAILED" & @CRLF & @CRLF & "Possible cause: Connection issues / website offline or version file not found.  Try again later.")
			Return SetError(4, 0, "262160|" & StringTrimRight(@ScriptName, 4) & " ERROR|UPDATE CHECK FAILED|Possible cause: Connection issues / website offline or version file not found.  Try again later.")
		Else
			$V2M_EventDisplay = YTS_EventLog("Updates - Downloaded latest version information to '" & @TempDir & "\v2m_latestversion.ini'", $V2M_EventDisplay, '8')
		EndIf
		While $local_loop = 0
			Sleep(250) ; create a delay loop to ensure that file has been downloaded and saved before continuing
			If FileExists(@TempDir & "\v2m_latestversion.ini") Then $local_loop = 1 ; keep looping until file exists
			$local_loop_count = $local_loop_count + 1
			If $local_loop_count > 20 Then $local_loop = 1
		WEnd

		;#######################################################################################
		; Check for latest release
		;#######################################################################################
		If IniRead($AppINI, "Common", "INETUPDATE", 1) = 1 Then
			$V2M_EventDisplay = YTS_EventLog("Updates - checking the downloaded version file, and comparing version numbers", $V2M_EventDisplay, '8')
			If IniRead(@TempDir & "\v2m_latestversion.ini", "VNC2Me", "LatestBeta", FileGetVersion(@ScriptFullPath)) <> FileGetVersion(@ScriptFullPath) Then
				$V2M_EventDisplay = YTS_EventLog("Updates - Version of App and version in file differ, this (usually) means an update is available.", $V2M_EventDisplay, '8')
				MsgBox(0, "VNC2Me Updates", "Later release available on the website" & @CRLF & @CRLF & "http://vnc2me.org/" & @CRLF & @CRLF & "Thankyou for using VNC2Me products, please give feedback on the forum")
			Else
				$V2M_EventDisplay = YTS_EventLog("Updates - Latest Version of App.", $V2M_EventDisplay, '8')
			EndIf
		EndIf

		;#######################################################################################
		; check for testing release
		;#######################################################################################
		If IniRead($AppINI, "Common", "TESTUPDATE", 0) = 1 Then
			$V2M_EventDisplay = YTS_EventLog("Updates - TEST - checking the downloaded version file, and comparing version numbers.", $V2M_EventDisplay, '8')
			If IniRead(@TempDir & "\v2m_latestversion.ini", "VNC2Me", "LatestTesting", FileGetVersion(@ScriptFullPath)) <> FileGetVersion(@ScriptFullPath) Then
				$V2M_EventDisplay = YTS_EventLog("Updates - TEST - Version of App and version in file differ, this (usually) means an update is available.", $V2M_EventDisplay, '8')
				MsgBox(0, "VNC2Me Updates", "There is an updated Testing version available" & @CRLF & @CRLF & "Contact JDaus for update URL..." & @CRLF & @CRLF & "Thankyou for helping test VNC2Me products", 10)
			Else
				$V2M_EventDisplay = YTS_EventLog("Updates - TEST - Latest Version of App.", $V2M_EventDisplay, '8')
				MsgBox(0, "VNC2Me Updates", "You are using the latest TESTING version", 10)
			EndIf
		EndIf
	EndIf
EndFunc   ;==>V2M_Update

;=========================================================================================================================================================
;============================================================== Vista Functions ==========================================================================
;=========================================================================================================================================================

;===============================================================================
;
; Description:		Turns Vistas AERO on and off
; Parameter(s):		$control
;							if $control = "Enable" then turn AERO on
;							if $control <> "Disable" then turn AERO off
; Requirement(s):	Needs vista to work (not checked for in function)
; Return Value(s):	nill
; Author(s):		YTS_Jim
; Note(s):
;
;===============================================================================

Func Vista_ControlAero($control = "Enable")
	$V2M_EventDisplay = YTS_EventLog("FUNC - Vista_ControlAero($control = " & $control & ")", $V2M_EventDisplay, "9")
	Local $DWMdll = DllOpen("dwmapi.dll")
	If $control = "Disable" Then
		DllCall($DWMdll, "int", "DwmEnableComposition", "uint", $DWM_EC_ENABLECOMPOSITION)
	ElseIf $control = "Enable" Then
		DllCall($DWMdll, "int", "DwmEnableComposition", "uint", $DWM_EC_DISABLECOMPOSITION)
	EndIf
EndFunc   ;==>Vista_ControlAero

Func WIN7_ControlAero($control = "Enable")
	;	Local $DWMdll = DllOpen("dwmapi.dll")
	If $control = "Disable" Then
		DllCall("dwmapi.dll", "hwnd", "DwmEnableComposition", "uint", $DWM_EC_DISABLECOMPOSITION)
	Else
		DllCall("dwmapi.dll", "hwnd", "DwmEnableComposition", "uint", $DWM_EC_ENABLECOMPOSITION)
	EndIf
EndFunc   ;==>WIN7_ControlAero

;===============================================================================
;
; Description:		Returns whether AERO is on or off
; Parameter(s):		nill
; Requirement(s):	Needs vista to work (not checked for in function)
; Return Value(s):	$status[1] which (should) contain information about the state of AERO
; Author(s):		YTS_Jim
; Note(s):
;
;===============================================================================

Func Vista_GetComposition()
	$V2M_EventDisplay = YTS_EventLog("FUNC - Vista_GetComposition()", $V2M_EventDisplay, "9")
	Local $DWMdll = DllOpen("dwmapi.dll")
	Local $status[10]
	$status = DllCall($DWMdll, "int", "DwmIsCompositionEnabled", "int*", "")
	Return $status[1]
EndFunc   ;==>Vista_GetComposition

;===============================================================================
;
; Description:		Turns Vistas UAC on and off instantly (no reboot needed)
; Parameter(s):		$control
;							if $control = "Enable" then turn UAC on
;							if $control <> "Disable" then turn UAC off
; Requirement(s):	Admin Priviledges
; Return Value(s):	nill
; Author(s):		YTS_Jim
; Note(s):
;
;===============================================================================

Func Vista_ControlUAC($control = "Enable")
	$V2M_EventDisplay = YTS_EventLog("FUNC - Vista_ControlUAC($control = " & $control & ")", $V2M_EventDisplay, "9")
	Local $curVal
	If $control = "Disable" Then
		If RegRead("HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System", "PromptOnSecureDesktop_V2M") = "" Then ; if the value doesn't exist
			$curVal = RegRead("HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System", "PromptOnSecureDesktop")
			RegWrite("HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System", "PromptOnSecureDesktop_V2M", "REG_DWORD", $curVal)
			$V2M_EventDisplay = YTS_EventLog("VISTA - PromptOnSecureDesktop", $V2M_EventDisplay, '8')
			RegWrite("HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System", "PromptOnSecureDesktop", "REG_DWORD", 0)
		EndIf
		If RegRead("HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System", "ConsentPromptBehaviorAdmin_V2M") = "" Then ; if the value doesn't exist
			$curVal = RegRead("HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System", "ConsentPromptBehaviorAdmin")
			RegWrite("HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System", "ConsentPromptBehaviorAdmin_V2M", "REG_DWORD", $curVal)
			$V2M_EventDisplay = YTS_EventLog("VISTA - ConsentPromptBehaviorAdmin", $V2M_EventDisplay, '8')
			RegWrite("HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System", "ConsentPromptBehaviorAdmin", "REG_DWORD", 0)
		EndIf
	ElseIf $control = "Enable" Then
		$curVal = RegRead("HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System", "PromptOnSecureDesktop_V2M")
		If $curVal <> "" Then
			RegWrite("HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System", "PromptOnSecureDesktop", "REG_DWORD", $curVal)
			RegDelete("HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System", "PromptOnSecureDesktop_V2M")
		EndIf

		$curVal = RegRead("HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System", "ConsentPromptBehaviorAdmin_V2M")
		If $curVal <> "" Then
			RegWrite("HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System", "ConsentPromptBehaviorAdmin", "REG_DWORD", $curVal)
			RegDelete("HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System", "ConsentPromptBehaviorAdmin_V2M")
		EndIf
	EndIf
EndFunc   ;==>Vista_ControlUAC

Func _cmdline()
	$V2M_EventDisplay = YTS_EventLog("FUNC - _cmdline()", $V2M_EventDisplay, "9")
	Local $local_loop = 0
	Do
		ConsoleWrite("$cmdline[0] = " & $cmdline[0] & "$local_loop = " & $local_loop & @CRLF)
		YTS_EventLog("$cmdline[0] = " & $cmdline[0] & "$local_loop = " & $local_loop, $V2M_EventDisplay, '8')
		$local_loop = $local_loop + 1
		;	$V2M_cmdline[1] = StringLower($cmdline[1])
		$V2M_EventDisplay = YTS_EventLog("$cmdline[1] = " & $cmdline[1], $V2M_EventDisplay, '8')
		Switch StringLower($cmdline[$local_loop])
			Case "install", "-i", "/i"
				YTS_EventLog("INSTALL Cmdline Arguement found", $V2M_EventDisplay, '5')
				;			InstallService()
				;			$V2M_Exit = 1
				;			$V2M_NoGUI = 1
			Case "remove", "-u", "/u", "uninstall"
				YTS_EventLog("REMOVE Cmdline Arguement found", $V2M_EventDisplay, '5')
				;			RemoveService()
				;			$V2M_Exit = 1
				;			$V2M_NoGUI = 1
			Case "/connect", "-c", "/c", "-connect"
				YTS_EventLog("CONNECT Cmdline Arguement found", $V2M_EventDisplay, '5')
				;				TrayTip(_Translate($V2M_GUI_Language, "TRAYTIP_SC_START_TITLE", ""), _Translate($V2M_GUI_Language, "TRAYTIP_SC_START_LINE1", "") & @CR & _Translate($V2M_GUI_Language, "TRAYTIP_SC_START_LINE2", ""), 10)
				; when launched with connect string, port setting (and if defined server, user & pass) are read from the INI file.
				;			$V2M_Exit = 1
				;			$V2M_NoGUI = 1
				;						$test = LoadApp($V2M_Status[2])
				;						If $test <> 1 Then
				;							MsgBox(0, "Error", "User canceled")
				;							$V2M_NoGUI = 0
				;							$V2M_Exit = 0
				;						Else
				;							$V2M_NoGUI = 1
				;							$V2M_Status[11] = 1
				;							$V2M_Exit = 0
				;						EndIf
			Case "/?", "-help", "-h"
				YTS_EventLog("HELP Cmdline Arguement found", $V2M_EventDisplay, 5)
				ConsoleWrite(" - - - Help - - - " & @CRLF)
				ConsoleWrite("params : " & @CRLF)
				ConsoleWrite("  -c : Automatically connect after [X] seconds (to the session code and server defined in the INI)" & @CRLF)
				ConsoleWrite("  -h : Show this help" & @CRLF)
				;			ConsoleWrite("  -i : install service" & @CRLF)
				;			ConsoleWrite("  -u : remove service" & @CRLF)
				ConsoleWrite(" - - - - - - - - " & @CRLF)
			Case Else
				$V2M_EventDisplay = YTS_EventLog("Cmdline Arguements not recognised", $V2M_EventDisplay, '8')
				;				TrayTip(_Translate($V2M_GUI_Language, "TRAYTIP_APP_START_TITLE", "APP_START_TITLE"), _Translate($V2M_GUI_Language, "TRAYTIP_APP_START_LINE1", "") & @CR & _Translate($V2M_GUI_Language, "TRAYTIP_APP_START_LINE2", ""), 10)
		EndSwitch
		Sleep(100)
	Until $local_loop = $cmdline[0]
EndFunc   ;==>_cmdline

Global $sServiceToCheck = "uvnc_service"
;MsgBox(0, $sServiceToCheck, _GetServiceState($sServiceToCheck))


Func _GetServiceState($sServiceName)
	Local $aTemp, $a_services
	$a_services = _RetrieveServices(@ComputerName)
	If Not @error And IsArray($a_services) Then
		For $x = 1 To $a_services[0]
			$aTemp = StringSplit($a_services[$x], "|")
			If $aTemp[1] = $sServiceName Then
				Return $aTemp[2]
			EndIf
		Next
		Return "Service not found"
	EndIf
EndFunc   ;==>_GetServiceState

Func _RetrieveServices($s_Machine)
	Local Const $wbemFlagReturnImmediately = 0x10
	Local Const $wbemFlagForwardOnly = 0x20
	Local $colItems = "", $objItem, $services
	Local $objWMIService = ObjGet("winmgmts:\\" & $s_Machine & "\root\CIMV2")
	If @error Then
		MsgBox(16, "_RetrieveServices", "ObjGet Error: winmgmts")
		Return
	EndIf
	$colItems = $objWMIService.ExecQuery("SELECT * FROM Win32_Service", "WQL", _
			$wbemFlagReturnImmediately + $wbemFlagForwardOnly)
	If @error Then
		MsgBox(16, "_RetrieveServices", "ExecQuery Error: SELECT * FROM Win32_Service")
		Return
	EndIf
	If IsObj($colItems) Then
		For $objItem In $colItems
			If IsArray($services) Then
				ReDim $services[UBound($services) + 1]
			Else
				Dim $services[2]
			EndIf
			$services[0] = UBound($services) - 1
;~             $services[UBound($services) - 1] = $objItem.Name
			$services[UBound($services) - 1] = $objItem.Name & "|" & $objItem.State
		Next
		Return $services
	EndIf
EndFunc   ;==>_RetrieveServices



;Global $GUI_Layered, $controlGui
;Func LoadApp($LocalName = "Test")
;	Local $sTimestamp, $sCountDown = 5, $return, $pngSrc, $hImage, $width, $height, $GUI_Label, $StopButton, $ExitApp
;
;	; Load PNG file as GDI bitmap
;	_GDIPlus_Startup()
;	$pngSrc = @ScriptDir & "\Skin_Grey.png"
;	$hImage = _GDIPlus_ImageLoadFromFile($pngSrc)
;
;	; Extract image width and height from PNG
;	$width = _GDIPlus_ImageGetWidth($hImage)
;	$height = _GDIPlus_ImageGetHeight($hImage)
;
;	; Create layered window
;	$GUI_Layered = GUICreate("SC Prompt", $width, $height, -1, -1, $WS_POPUP, $WS_EX_LAYERED)
;	SetBitmap($GUI_Layered, $hImage, 0)
;	; Register notification messages
;	GUIRegisterMsg($WM_NCHITTEST, "WM_NCHITTEST")
;	GUISetState()
;	WinSetOnTop($GUI_Layered, "", 1)
;	;fade in png background
;	For $i = 0 To 255 Step 5
;		SetBitmap($GUI_Layered, $hImage, $i)
;	Next
;
;
;	; create child MDI gui window to hold controls
;	; this part could use some work - there is some flicker sometimes...
;	$controlGui = GUICreate("ControlGUI", $width, $height, 0, 0, $WS_POPUP, BitOR($WS_EX_LAYERED, $WS_EX_MDICHILD), $GUI_Layered)
;
;	; child window transparency is required to accomplish the full effect, so $WS_EX_LAYERED above, and
;	; I think the way this works is the transparent window color is based on the image you set here:
;	GUICtrlCreatePic(@ScriptDir & "\BG_Grey.gif", 0, 0, $width, $height)
;	GUICtrlSetState(-1, $GUI_DISABLE)
;
;	; just a text label
;	$GUI_Label = GUICtrlCreateLabel("Starting Connection to " & $LocalName & " in 5 Seconds", 50, 30, 140, 50)
;	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
;	GUICtrlSetColor(-1, 0xFFFFFF)
;
;	; set default button for Enter key activation - renders outside GUI window
;	$StopButton = GUICtrlCreateButton("Stop", 210, 34, 250, -1, $BS_DEFPUSHBUTTON)
;
;	GUISetState()
;
;	$sTimestamp = _NowCalc()
;	While $ExitApp = 0
;		;		$msg = GUIGetMsg()
;		Switch GUIGetMsg()
;			Case $GUI_EVENT_CLOSE
;				$return = 0
;				ExitLoop
;			Case $StopButton
;				$return = 0
;				ExitLoop
;		EndSwitch
;		If _DateDiff('s', $sTimestamp, _NowCalc()) >= 1 Then
;			$sTimestamp = _NowCalc()
;			$sCountDown = $sCountDown - 1
;			Beep(1000, 50)
;			Beep(2000, 50)
;			GUICtrlSetData($GUI_Label, "Starting Connection to " & $LocalName & " in " & $sCountDown & " Seconds")
;			If $sCountDown < 0 Then
;				$return = 1
;				ExitLoop
;			EndIf
;		EndIf
;	WEnd
;
;	;	If $runthis <> "" Then
;	;		If FileExists($launchDir & "\" & $runthis) Then
;	;			Beep(1000, 50)
;	;			Beep(2000, 50)
;	;			_ShellExecute($runthis, "", $launchDir)
;	;		EndIf
;	;	EndIf
;
;;	GUIDelete($controlGui)
;;	;fade out png background
;;	For $i = 255 To 0 Step -5
;;		SetBitmap($GUI_Layered, $hImage, $i)
;;	Next
;;
;;	; Release resources
;;	_WinAPI_DeleteObject($hImage)
;;	_GDIPlus_Shutdown()
;;	GUIDelete($GUI_Layered)
;	Return $return
;EndFunc   ;==>LoadApp
;
;
;;Func GoAutoComplete()
;;    _GUICtrlComboBox_AutoComplete($Combo)
;;EndFunc   ;==>GoAutoComplete
;
;; ====================================================================================================
;
;; Handle the WM_NCHITTEST for the layered window so it can be dragged by clicking anywhere on the image.
;; ====================================================================================================
;
;Func WM_NCHITTEST($hWnd, $iMsg, $iwParam)
;	If ($hWnd = $GUI_Layered) And ($iMsg = $WM_NCHITTEST) Then Return $HTCAPTION
;EndFunc   ;==>WM_NCHITTEST
;
;; ====================================================================================================
;
;; SetBitMap
;; ====================================================================================================
;
;Func SetBitmap($hGUI, $hImage, $iOpacity)
;	Local $hScrDC, $hMemDC, $hBitmap, $hOld, $pSize, $tSize, $pSource, $tSource, $pBlend, $tBlend
;
;	$hScrDC = _WinAPI_GetDC(0)
;	$hMemDC = _WinAPI_CreateCompatibleDC($hScrDC)
;	$hBitmap = _GDIPlus_BitmapCreateHBITMAPFromBitmap($hImage)
;	$hOld = _WinAPI_SelectObject($hMemDC, $hBitmap)
;	$tSize = DllStructCreate($tagSIZE)
;	$pSize = DllStructGetPtr($tSize)
;	DllStructSetData($tSize, "X", _GDIPlus_ImageGetWidth($hImage))
;	DllStructSetData($tSize, "Y", _GDIPlus_ImageGetHeight($hImage))
;	$tSource = DllStructCreate($tagPOINT)
;	$pSource = DllStructGetPtr($tSource)
;	$tBlend = DllStructCreate($tagBLENDFUNCTION)
;	$pBlend = DllStructGetPtr($tBlend)
;	DllStructSetData($tBlend, "Alpha", $iOpacity)
;	DllStructSetData($tBlend, "Format", $AC_SRC_ALPHA)
;	_WinAPI_UpdateLayeredWindow($hGUI, $hScrDC, 0, $pSize, $hMemDC, $pSource, 0, $pBlend, $ULW_ALPHA)
;	_WinAPI_ReleaseDC(0, $hScrDC)
;	_WinAPI_SelectObject($hMemDC, $hOld)
;	_WinAPI_DeleteObject($hBitmap)
;	_WinAPI_DeleteDC($hMemDC)
;EndFunc   ;==>SetBitmap



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

;Func LoadSettings($sIni = $AppINI)
;	$sIni = $AppINI
;	$V2M_INI_GUIName = IniRead($sIni, "V2MGUI", "GUIName", "V2M")
;	$V2MHost = IniRead($sIni, "$V2MServer", "Host", "nowhere.nohost")
;	$V2M = IniRead($sIni, "MAP", "User", "User")
;EndFunc   ;==>LoadSettings

;=========================================================================================================================================================

;Func SaveSettings($sIni = $AppINI)
;	$sIni = $AppINI
;	IniWrite($sIni, "MAP", "Letter", GUICtrlRead($hMapLetter))
;EndFunc   ;==>SaveSettings

;=========================================================================================================================================================

;Func SettingsToGUI()
;	GUICtrlSetData($hMapLetter, $gMapLetter)
;	GUICtrlSetData($hMapPasswordEdit, $gMapPassword)
;EndFunc   ;==>SettingsToGUI