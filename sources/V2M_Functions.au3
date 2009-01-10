

#Region --- Script analyzed by FreeStyle code Start 06.09.2008 - 20:04:12

#EndRegion --- Script analyzed by FreeStyle code End - no patching necessary


#Region --- Script analyzed by FreeStyle code Start 20.07.2008 - 11:14:56

#EndRegion --- Script analyzed by FreeStyle code End - no patching necessary
;
; Misc FUNCTIONS
;
Dim $V2M_GUI_Main
Dim $V2M_VNC_ProcessID
Dim $V2M_GUI_DebugOutputEdit
Dim $V2M_GUI_MiniTitle
Dim $V2M_GUI_Mini
Dim $V2M_SSH_Hostname


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
Func V2M_EventLog($V2M_EventLog='', $V2M_EventDisplay='', $JDs_debug_only='0')
	If $V2M_EventLog = $V2M_EventDisplay Then
		;do nothing
	Else
		If $JDs_debug_only = '0' Then
			;send to minigui event log
			GUICtrlSetData($V2M_GUI_MiniStatusBar, @CRLF & $V2M_EventLog, 1)
			;send to maingui event log
			GUICtrlSetData($V2M_GUI_MainStatusBar, @CRLF & $V2M_EventLog, 1)
			;send to Tab3Debug event log
			GUICtrlSetData($V2M_GUI_DebugOutputEdit, @CRLF & $V2M_EventLog, 1)
		ElseIf $JDs_debug_only = '1' Then
			;send to Tab3Debug event log
			GUICtrlSetData($V2M_GUI_DebugOutputEdit, @CRLF & $V2M_EventLog, 1)
		EndIf
		DllCall("kernel32.dll", "none", "OutputDebugString", "str", "V2M - " & $V2M_EventLog)
		$V2M_EventDisplay = $V2M_EventLog
		Sleep(100)
	EndIf
	Return $V2M_EventDisplay
EndFunc
;===============================================================================
;
; Description:		Ask if you want to add host key
; Parameter(s):		none
; Requirement(s):	$V2M_SSH_ProcessID needs to be gloabal, and hold controlID for plink.exe
; Return Value(s):	none
; Author(s):		Jim Dolby
; Note(s):			
;
;===============================================================================
Func V2MAddHostKey()
	Dim $msgbox
	;Add Host key to knownhosts
	$V2M_EventDisplay=V2M_EventLog('STDERR found', $V2M_EventDisplay, 1)
;	JDs_debug("STDERR found")
	$msgbox = MsgBox(4, "The host is not cached", "This Host is not known, do you want to add it to known hosts ???")
	If $msgbox = 6 Then
		StdinWrite($V2M_SSH_ProcessID, "y " & @CR)
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
	$V2M_EventDisplay=V2M_EventLog('Waiting for VNC to close cleanly', $V2M_EventDisplay, 0)
	ProcessWaitClose("v2msc.exe", 5)
	ProcessWaitClose("V2Mvwr.exe", 5)
	If ProcessExists("V2Mvwr.exe") Or ProcessExists("v2msc.exe") Then
		ProcessClose("v2msc.exe")
		ProcessClose("V2Mvwr.exe")
		$V2M_EventDisplay=V2M_EventLog('Forcing VNC Closed', $V2M_EventDisplay, 0)
	Else
		$V2M_EventDisplay=V2M_EventLog('VNC Closed Cleanly', $V2M_EventDisplay, 0)
	EndIf
EndFunc   ;==>V2MExit

;===============================================================================
;
; Description:		exits all v2m ssh apps
; Parameter(s):		none
; Requirement(s):	$V2M_SSH_ProcessID needs to be gloabal, and hold controlID for plink.exe
; Return Value(s):	none
; Author(s):		Jim Dolby
; Note(s):			
;
;===============================================================================
Func V2MExitSSH()
	StdinWrite($V2M_SSH_ProcessID, "exit" & @CR)
	$V2M_EventDisplay=V2M_EventLog('Waiting for SSH to close cleanly', $V2M_EventDisplay, 0)
	ProcessWaitClose("v2mplink.exe", 3)
	If ProcessExists("v2mplink.exe") Then
		ProcessClose("v2mplink.exe")
		$V2M_EventDisplay=V2M_EventLog('Forcing SSH Closed', $V2M_EventDisplay, 0)
	Else
		$V2M_EventDisplay=V2M_EventLog('SSH Closed Cleanly', $V2M_EventDisplay, 0)
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
; Parameter(s):		none
; Requirement(s):	$V2M_GUI_MainTitle, $V2M_GUI_MiniTitle, $V2M_GUI_Main and $V2M_GUI_Mini
;						GUI Titles, and control ID's from creating the GUI's
; Return Value(s):	"GUI - Swaping UI"
; Author(s):		Jim Dolby
; Note(s):			
;
;===============================================================================
Func V2MGuiSwap($GUI_title = '', $GUI_state = '')
	If $V2M_GUI_MiniTitle = "" Then
		; do nothing
	Else
		;		MsgBox(0, "Debug", $which, 2)
		If WinActive($V2M_GUI_MiniTitle) Then
			;			MsgBox(0, "Debug", $V2M_GUI_MiniTitle & " is active", 2)
			GUISwitch($V2M_GUI_Main)
			GUISetState(@SW_SHOW, $V2M_GUI_MainTitle)
			GUISwitch($V2M_GUI_Mini)
			GUISetState(@SW_HIDE, $V2M_GUI_MiniTitle)
			GUISwitch($V2M_GUI_Main)
		Else
			;			MsgBox(0, "Debug", $V2M_GUI_MiniTitle & " is not active", 2)
			GUISwitch($V2M_GUI_Mini)
			GUISetState(@SW_SHOW, $V2M_GUI_MiniTitle)
			GUISwitch($V2M_GUI_Main)
			GUISetState(@SW_HIDE, $V2M_GUI_MainTitle)
			GUISwitch($V2M_GUI_Mini)
		EndIf
		Return "GUI - Swaping UI"
	EndIf
EndFunc   ;==>V2MGuiSwap


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
			Exit
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
; Parameter(s):		$V2M_SSH_PortFwdDirection	= Port tunneling direction :Local;Remote;Both.
; Requirement(s):	$V2M_GUI_DebugOutputEdit, $V2M_SessionCode, $V2M_SSH_Hostname
; Return Value(s):	$V2M_SSH_ProcessID
; Author(s):		Jim Dolby
; Note(s):			
;
;===============================================================================
;Func V2MSSHConnect($V2M_SessionCode = '', $RunWhat = 'v2mplink', $StandardHost = '', $RunWhere = @ScriptDir)
Func V2MSSHConnect($V2M_SSH_PortFwdDirection = 'Both')
	Dim $Local_ConnectString
;	$V2M_AutoReconnect = 1
	$V2M_EventLog = "SSH - Starting at " & @HOUR & ":" & @MIN & ":" & @SEC & " (Port Dir = " & $V2M_SSH_PortFwdDirection & ", Port# = " & $V2M_SessionCode & ")"
	$V2M_EventDisplay = V2M_EventLog($V2M_EventLog, $V2M_EventDisplay, 0)

	ProcessClose('v2mplink.exe')

	If $V2M_SSH_Hostname = "" Then
		$V2M_SSH_Hostname = InputBox("Host Server", "What server do i connect to ?")
		If @error = 1 Then
			$V2M_AutoReconnect = 0
		ElseIf $V2M_SSH_Hostname = "" Then
			$V2M_AutoReconnect = 0
		EndIf
	EndIf

	If $V2M_AutoReconnect = 1 Then
		If $V2M_Status[0][0] = 'VWR' Then
			$Local_ConnectString = @ScriptDir & '\v2mplink.exe -R ' & $V2M_SessionCode & ':127.0.0.1:15500 ' & $V2M_SSH_Hostname & ' -v -P ' & $V2M_SSH_Port
		ElseIf $V2M_Status[0][0] = 'SC' Then
			$Local_ConnectString = @ScriptDir & '\v2mplink.exe -L 25400:127.0.0.1:' & $V2M_SessionCode & ' ' & $V2M_SSH_Hostname & ' -v -P ' & $V2M_SSH_Port
		Else
			$Local_ConnectString = @ScriptDir & '\v2mplink.exe -R ' & $V2M_SessionCode & ':127.0.0.1:15500 -L 25400:127.0.0.1:' & $V2M_SessionCode & ' ' & $V2M_SSH_Hostname & ' -v -P ' & $V2M_SSH_Port
		EndIf

;		If $V2M_SSH_PortFwdDirection = 'Local' Then
;			$Local_ConnectString = @ScriptDir & '\v2mplink.exe -L 25400:127.0.0.1:' & $V2M_SessionCode & ' ' & $V2M_SSH_Hostname & ' -v'
;		ElseIf $V2M_SSH_PortFwdDirection = 'Remote' Then
;			$Local_ConnectString = @ScriptDir & '\v2mplink.exe -R ' & $V2M_SessionCode & ':127.0.0.1:15500 ' & $V2M_SSH_Hostname & ' -v'
;		Else
;			$Local_ConnectString = @ScriptDir & '\v2mplink.exe -R ' & $V2M_SessionCode & ':127.0.0.1:15500 -L 25400:127.0.0.1:' & $V2M_SessionCode & ' ' & $V2M_SSH_Hostname & ' -v'
;		EndIf
;		;	Run child process and provide $VAR for console i/o.	1 (1) = Provide a handle to the child's STDIN stream	2 (2) = Provide a handle to the child's STDOUT stream	4 (4) = Provide a handle to the child's STDERR stream
		$V2M_SSH_ProcessID = Run($Local_ConnectString, @ScriptDir, @SW_HIDE, 7)
;		$V2M_EventDisplay=V2M_EventLog("RUN - Starting SSH at " & @HOUR & ":" & @MIN & ":" & @SEC & " (remote port " & $V2M_SessionCode & ")" & @CRLF, $V2M_EventDisplay, 0)
	
		Return $V2M_SSH_ProcessID
	EndIf
EndFunc   ;==>V2MSSHConnect

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
; Description:		This is executed when Autoit exits
; Parameter(s):		none
; Requirement(s):	none
; Return Value(s):	none
; Author(s):		Jim Dolby
; Note(s):			Function name can be renamed, but only if ;Opt("OnExitFunc", "OnAutoItExit") is set (and OnAutoItExit is changed to new name)
;
;===============================================================================
Func OnAutoItExit ( )
	If IniRead(@ScriptDir & "\vnc2me_sc.ini", "V2M_GUI", "GUI_TIMER_SHOW", 1) = 1 Then
		Local $timer
		$timer = V2M_Timer("Stop")
		If $timer <> "0:0:0" Then
			MsgBox(0,"Connection timer","Session Connected for: " & $timer, 60)
		EndIf
	EndIf
	Dim $curVal
	_RefreshSystemTray(50)
	If $V2M_VNC_PasswordRegAdded = 1 Then
		MsgBox(0, "Debug:", "I added Password, so Deleting it NOW", 2)
		RegDelete("HKEY_CURRENT_USER\Software\ORL\WinVNC3", "Password")
	EndIf
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
	ProcessClose('v2mplink.exe')
	ProcessClose('v2mvwr.exe')
	ProcessClose('v2msc.exe')
	Opt('WinTitleMatchMode', 4)
	ControlSend('classname=Progman', '', 'SysListView321', '{F5}')
EndFunc

;===============================================================================
;
; Description:		Sends Debug output to kernel32.dll (can be viewed using Dbgview.exe by sysinternals), and Sends to StatusBar's if requested
; Parameter(s):		$msg				= Debug / log message
;					$Local_DebugOnly	= 1 only sends to kernel32.dll, 0 sends to StatusBar's as well
; Requirement(s):	$V2M_GUI_MainStatusBar, $V2M_GUI_MiniStatusBar
; Return Value(s):	none
; Author(s):		Jim Dolby
; Note(s):			
;
;===============================================================================
Func JDs_debug($msg, $Local_DebugOnly = 1)
	If $Local_DebugOnly = 1 Then
		DllCall("kernel32.dll", "none", "OutputDebugString", "str", "V2M - " & $msg)
	Else
		DllCall("kernel32.dll", "none", "OutputDebugString", "str", "V2M - " & $msg)
		;send to minigui event log display
		GUICtrlSetData($V2M_GUI_MiniStatusBar, @CRLF & $msg, 1)
		;send to maingui event log display
		GUICtrlSetData($V2M_GUI_MainStatusBar, @CRLF & $msg, 1)
	EndIf
EndFunc   ;==>JDs_debug

;=========================================================================================================================================================
;=========================================================================================================================================================
;=========================================================================================================================================================


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
;	$V2MHost = IniRead($sIni, "$V2MServer", "Host", "aus.st")
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

Func CheckPort($CheckPortIP, $CheckPortPort)
	Dim $socket
	
	TCPStartUp()
	$socket = TCPConnect( $CheckPortIP, $CheckPortPort )
	Return $socket
	TCPShutdown ()

EndFunc

;=========================================================================================================================================================

Func CheckPortLoop($count1, $CheckPortLoopIP, $CheckPortLoopPort)
	Dim $loop, $Exit
	$loop = 1
	While $loop < $count1
		$Exit = CheckPort($CheckPortLoopIP, $CheckPortLoopPort)
		If $Exit = -1 Then
			$loop = $loop + 1
			Sleep (1000)
		Else
			$loop = $count1
		EndIf
		MsgBox(64, "CheckPort()", "checkport results: " & $Exit & @CRLF & "$loop: " & $loop)
	WEnd
EndFunc

;=========================================================================================================================================================

Func CloseFunc($prog)
	Dim $PID
	
	$PID = ProcessExists($prog)
	If $PID Then ProcessClose($PID)

EndFunc

;=========================================================================================================================================================

