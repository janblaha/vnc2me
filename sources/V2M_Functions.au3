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
	$V2M_EventDisplay=V2M_EventLog('STDERR found', $V2M_EventDisplay, 1)
;	JDs_debug("STDERR found")
	$msgbox = MsgBox(4, "The host is not cached", "This Host is not known, do you want to add it to known hosts ???")
	If $msgbox = 6 Then
		StdinWrite($V2M_ProcessIDs[1], "y " & @CR)
	ElseIf $msgbox = 7 Then
		StdinWrite($V2M_ProcessIDs[1], "n " & @CR)
	EndIf
EndFunc   ;==>V2MAddHostKey

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
	$V2M_EventDisplay=V2M_EventLog('VNC - Waiting to close cleanly', $V2M_EventDisplay, 0)
	ProcessWaitClose($V2M_VNC_SC, 5)
	ProcessWaitClose($V2M_VNC_VWR, 5)
	ProcessWaitClose($V2M_VNC_SVR, 5)
	If ProcessExists($V2M_VNC_VWR) Or ProcessExists($V2M_VNC_SC) Or ProcessExists($V2M_VNC_SVR) Then
		$V2M_EventDisplay=V2M_EventLog('VNC - Closed Forcibly', $V2M_EventDisplay, 0)
		ProcessClose($V2M_VNC_SC)
		ProcessClose($V2M_VNC_VWR)
		ProcessClose($V2M_VNC_SVR)
	Else
		$V2M_EventDisplay=V2M_EventLog('VNC - Closed Cleanly', $V2M_EventDisplay, 0)
	EndIf
EndFunc   ;==>V2MExit

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
	StdinWrite($V2M_ProcessIDs[1], " exit" & @CR)
	$V2M_EventDisplay=V2M_EventLog('SSH - Waiting to close cleanly', $V2M_EventDisplay, 0)
	ProcessWaitClose("v2mplink.exe", 3)
	If ProcessExists("v2mplink.exe") Then
		ProcessClose("v2mplink.exe")
		$V2M_EventDisplay=V2M_EventLog('SSH - Closed Forcibly', $V2M_EventDisplay, 0)
	Else
		$V2M_EventDisplay=V2M_EventLog('SSH - Closed Cleanly', $V2M_EventDisplay, 0)
	EndIf
EndFunc   ;==>V2MExit

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
	Return Random($V2MPortMin, $V2MPortMax, 1)
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
Func V2MAboutBox ()
	MsgBox(0, "About", $V2M_GUI_MainTitle & @CRLF & @CRLF & "© 2008 Sec IT.")
EndFunc

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
		GUISetState(@SW_SHOW, $GUI_title)
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
	$V2M_EventDisplay=V2M_EventLog("AUTH - Passing " & $InBoxTitle, $V2M_EventDisplay, 1)
;	JDs_debug("AUTH - Passing " & $InBoxTitle)
	StdinWrite($WriteWhere, $WriteWhat & " " & @CR)
	Return $WriteWhat
EndFunc   ;==>V2MInBoxSTDINWrite

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
	Local $Local_ConnectString
	$V2M_EventDisplay = V2M_EventLog("SSH - Starting at " & @HOUR & ":" & @MIN & ":" & @SEC & ", for "&$V2M_Status[1][1]&" Connections, (Session Code = " & $V2M_SessionCode & ")", $V2M_EventDisplay, 'Full')
	ProcessClose('v2mplink.exe')

	If $V2M_SessionCode = '' Then
		MsgBox(0, "Error", "Please enter the Session Code and try again", 60)
		$V2M_EventDisplay = V2M_EventLog("GUI - Session Code was blank", $V2M_EventDisplay, 'dll')
		$V2M_Status[3][1] = 0 ; SSH notwanted
	Else
		If $V2M_SSH[1] = "" Then
			$V2M_SSH[1] = InputBox("Host Server", "What server do i connect to ?")
			If @error = 1 Then
				$V2M_Status[3][1] = 0		;sshwanted = 0
			ElseIf $V2M_SSH[1] = "" Then
				$V2M_Status[3][1] = 0		;sshwanted = 0
			EndIf
		EndIf

		If $V2M_Status[1][1] = 'VWR' Then
			If IniRead(@ScriptDir & "\vnc2me_sc.ini", "V2M_GUI", "VNC_VWR_SC_ONLY", 0) = 1 Then
				TrayTip(IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "TRAYTIP_VWR_STARTSC_TITLE", "VWR_STARTSC_TITLE"), IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "TRAYTIP_VWR_STARTSC_LINE1", "") & @CR & IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "TRAYTIP_VWR_STARTSC_LINE2", ""), 30)
				$Local_ConnectString = @ScriptDir & '\v2mplink.exe -R ' & $V2M_SessionCode & ':127.0.0.1:15500 ' & $V2M_SSH[1] & ' -v -N'
				$V2M_Status[3][8] = 1
			ElseIf IniRead(@ScriptDir & "\vnc2me_sc.ini", "V2M_GUI", "VWR_VWR_SVR_ONLY", 0) = 1 Then
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
					MsgBox(1, "VWR for SC", "No Viewer connection type chosen"&@CRLF&"SC type will be selected" , 10)
					If @error=-1 Or @error=1 Then 
						GUICtrlSetState($V2M_GUI[40], 1)		;Check the SC vwr radio item.
						$V2M_Status[3][8] = 1 ;vwrSCwanted
					Else
						$V2M_Status[1][1] = ''
						$V2M_Status[3][1] = 0		;sshwanted = 0
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
		$V2M_ProcessIDs[1] = Run($Local_ConnectString, @ScriptDir, @SW_MINIMIZE, 7)
		$V2M_EventDisplay=V2M_EventLog("RUN - Starting SSH at " & @HOUR & ":" & @MIN & ":" & @SEC & " (remote port " & $V2M_SessionCode & ")" & @CRLF, $V2M_EventDisplay, 'dll')
		Return $V2M_ProcessIDs[1]
		$V2M_Status[3][2] = 1 ;ssh started
	EndIf
EndFunc   ;==>V2MSSHConnect
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
			$V2M_EventDisplay = V2M_EventLog("v2mplink.exe has Closed, Full reconnect", $V2M_EventDisplay, 'dll')
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
Func V2M_startvnc($how='ssh')
	$V2M_EventDisplay = V2M_EventLog("VNC - Starting VNC"&@CRLF&"$V2M_Status[3][4] = "&$V2M_Status[3][4]&@CRLF&"$V2M_Status[3][6] = "&$V2M_Status[3][6]&@CRLF&"$V2M_Status[3][8] = "&$V2M_Status[3][8]&@CRLF&"$V2M_Status[3][9] = "&$V2M_Status[3][9], $V2M_EventDisplay, 'dll')
	If $how = "ssh" Then
		If $V2M_Status[3][4] Then ;scwanted
			If Not $V2M_Status[3][5] Then
				$V2M_EventDisplay = V2M_EventLog("VNC - Starting SC via SSH", $V2M_EventDisplay, 'debug')
;				If ProcessExists($V2M_VNC_SC) Then ProcessClose($V2M_VNC_SC)
				$V2M_ProcessIDs[3] = Run($V2M_VNC_SC & " -connect 127.0.0.1:25400", @ScriptDir, @SW_HIDE, 7) ;run sc
				$V2M_Status[3][5] = 1		;flag As started
				Sleep(2000)
				Return("SCviaSSH")
			EndIf
		ElseIf $V2M_Status[3][6] Then ;svrwanted
			If Not $V2M_Status[3][7] Then
				$V2M_EventDisplay = V2M_EventLog("VNC - Starting SVR via SSH", $V2M_EventDisplay, 'debug')
;				If ProcessExists($V2M_VNC_SVR) Then ProcessClose($V2M_VNC_SVR)
				$V2M_ProcessIDs[4] = Run($V2M_VNC_SVR & " AcceptCutText=0 AcceptPointerEvents=0 AcceptKeyEvents=0 AlwaysShared=1 LocalHost=1 SecurityTypes=None PortNumber=25900", @ScriptDir, @SW_HIDE, 7) ;run svr
				$V2M_Status[3][7] = 1 ;	flag As started
				Sleep(2000)
				Return("SVRviaSSH")
			EndIf
		ElseIf $V2M_Status[3][8] Then ;vwrscwanted
			If $V2M_Status[3][10] <> 1 Then
				$V2M_EventDisplay = V2M_EventLog("VNC - Starting VWR for SC via SSH", $V2M_EventDisplay, 'debug')
				$V2M_ProcessIDs[2] = Run($V2M_VNC_VWR & " -listen 15500 -8greycolours -autoscaling", @ScriptDir, @SW_MINIMIZE, 7) ;run vwr For sc connection
;				MsgBox(0, 'Debug', '@error = '&@error&@CRLF&'$V2M_ProcessIDs[2] = '&$V2M_ProcessIDs[2],3)
;				If ProcessExists($V2M_VNC_VWR) Then ProcessClose($V2M_VNC_VWR)
				$V2M_Status[3][10] = 1 ;	flag As started
				Return("VWRSCviaSSH")
			EndIf
		ElseIf $V2M_Status[3][9] Then ;vwrsvrwanted
			If $V2M_Status[3][10] <> 1 Then
				$V2M_EventDisplay = V2M_EventLog("VNC - Starting VWR for SVR via SSH", $V2M_EventDisplay, 'debug')
				$V2M_ProcessIDs[2] = Run($V2M_VNC_VWR & " localhost::25900 /8greycolors/autoreconnect 1 /shared /belldeiconify /autoscaling", @ScriptDir, @SW_MINIMIZE, 7) ;run vwr For svr connection
;				MsgBox(0, 'Debug', '@error = '&@error&@CRLF&'$V2M_ProcessIDs[2] = '&$V2M_ProcessIDs[2],3)
;				If ProcessExists($V2M_VNC_VWR) Then ProcessClose($V2M_VNC_VWR)
				$V2M_Status[3][10] = 1 ;	flag As started
				Return("VWRSVRviaSSH")
			EndIf
		EndIf
	EndIf
EndFunc   ;==>startvnc

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
Func V2M_EventLog($V2M_EventLog='', $V2M_EventDisplay='', $JDs_debug_only='dll')
	If $V2M_EventLog = $V2M_EventDisplay Then
		;do nothing
	Else
		If $JDs_debug_only = '0' Or $JDs_debug_only = 'full' Then
;		MsgBox(0, "Debug", $JDs_debug_only, 2)
			;send to minigui event log
			GUICtrlSetData($V2M_GUI[8], @CRLF & $V2M_EventLog, 1)
			;send to maingui event log
			GUICtrlSetData($V2M_GUI[9], @CRLF & $V2M_EventLog, 1)
			;send to Tab3Debug event log
			GUICtrlSetData($V2M_GUI_DebugOutputEdit, @CRLF & $V2M_EventLog, 1)
		ElseIf $JDs_debug_only = '1' Or $JDs_debug_only = 'debug' Then
			;send to Tab3Debug event log
			GUICtrlSetData($V2M_GUI_DebugOutputEdit, @CRLF & $V2M_EventLog, 1)
		ElseIf $JDs_debug_only = 'dll' Then
			;do nothing
		EndIf
		; view the following output from sysinternals debuger "DebugView" or similar
		DllCall("kernel32.dll", "none", "OutputDebugString", "str", "V2M - " & $V2M_EventLog)
		$V2M_EventDisplay = $V2M_EventLog
;		Sleep(100)
	EndIf
	Return $V2M_EventDisplay
EndFunc

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
Func OnAutoItExit ( )
	Local $timer
	;exit ssh & vnc
	V2MExitSSH()
	V2MExitVNC()
	$V2M_EventDisplay = V2M_EventLog(' ', $V2M_EventDisplay)
	ProcessClose("aero_disable.exe") ; included here so that it closes before the temp folder it is located in gets deleted
	If IniRead(@ScriptDir & "\vnc2me_sc.ini", "V2M_GUI", "GUI_TIMER_SHOW", 1) = 1 Then
;		Local $timer
		$timer = V2M_Timer("Stop")
		If $timer <> "0:0:0" Then
			MsgBox(0,"Connection timer","Session Connected for: " & $timer, 60)
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
		ProcessClose("aero_disable.exe") ; included here a second time, just in case AutoIt is forcibly closed

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
;	If @Compiled Then _SelfDelete(5)
	Exit
EndFunc

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
		if $V2M_Timer[2] = 0 then
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
EndFunc

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
	$V2M_MsgBox = MsgBox(270373, "Error", "VNC Connection Not Established," & @CRLF & "Should I Retry same port ?", 60)
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
EndFunc
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
EndFunc

;=========================================================================================================================================================

;MsgBox(0, "Your OS Language:", _Language())
Func _Language()
Select
	Case StringInStr("0413,0813", @OSLang)
		Return "Dutch"
	Case StringInStr("0409,0809,0c09,1009,1409,1809,1c09,2009,2409,2809,2c09,3009,3409", @OSLang)
		Return "English"
	Case StringInStr("040c,080c,0c0c,100c,140c,180c", @OSLang)
		Return "French"
	Case StringInStr("0407,0807,0c07,1007,1407", @OSLang)
		Return "German"
	Case StringInStr("0410,0810", @OSLang)
		Return "Italian"
	Case StringInStr("0414,0814", @OSLang)
		Return "Norwegian"
	Case StringInStr("0415", @OSLang)
		Return "Polish"
	Case StringInStr("0416,0816", @OSLang)
		Return "Portuguese"
	Case StringInStr("040a,080a,0c0a,100a,140a,180a,1c0a,200a,240a,280a,2c0a,300a,340a,380a,3c0a,400a,440a,480a,4c0a,500a", @OSLang)
        Return "Spanish"
	Case StringInStr("041d,081d", @OSLang)
		Return "Swedish"
	Case Else
		Return ""
EndSelect
EndFunc

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
