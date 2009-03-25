#cs ----------------------------------------------------------------------------
	
	AutoIt Version: 3.2.10.0
	Author:         myName
	
	Script Function:
	Template AutoIt script.
	
#ce ----------------------------------------------------------------------------

; Script Start - Add your code below here

;
;=========================================================================================================================================================
; Create the main GUI

$V2M_GUI_Main = GUICreate($V2M_GUI_MainTitle, $V2M_GUI[1], $V2M_GUI[2], (@DesktopWidth - $V2M_GUI[1]) / 2, (@DesktopHeight - $V2M_GUI[2]) / 2)

GUISetIcon("v2m.ico")
$V2M_GUI[7] = GUICtrlCreateMenu(IniRead(@ScriptDir & "\v2m_lang.ini", $V2M_GUI_Language, "GUI_MNU_FILE", "FILE"))
$V2M_GUI[32] = GUICtrlCreateMenuItem(IniRead(@ScriptDir & "\v2m_lang.ini", $V2M_GUI_Language, "GUI_MNU_EXIT", "EXIT"), $V2M_GUI[7])

$V2M_GUI[14] = GUICtrlCreateMenu(IniRead(@ScriptDir & "\v2m_lang.ini", $V2M_GUI_Language, "GUI_MNU_HELP", "HELP"))
$V2M_GUI[15] = GUICtrlCreateMenuItem(IniRead(@ScriptDir & "\v2m_lang.ini", $V2M_GUI_Language, "GUI_MNU_ABOUT", "ABOUT"), $V2M_GUI[14])

$V2M_GUI[16] = GUICtrlCreateTab(10, 0, $V2M_GUI[3], $V2M_GUI[4])

$BaseLeft = 20
$BaseTop = 35

$V2M_GUI[17] = GUICtrlCreateButton(IniRead(@ScriptDir & "\v2m_lang.ini", $V2M_GUI_Language, "MAIN_BTN_EXIT", "EXIT"), $BaseLeft, $V2M_GUI[2] - 70, 60, 20)
GUICtrlSetTip(-1, IniRead(@ScriptDir & "\v2m_lang.ini", $V2M_GUI_Language, "MAIN_BTN_EXIT_TIP", "EXIT THE APP"))
$CurLeft = $BaseLeft + 80
If $V2M_Status[1][2] = 1 Then
	$V2M_GUI[33] = GUICtrlCreateCheckbox(IniRead(@ScriptDir & "\v2m_lang.ini", $V2M_GUI_Language, "MAIN_DbgBox", "DEBUG"), $CurLeft, $V2M_GUI[2] - 70)
	GUICtrlSetTip(-1, IniRead(@ScriptDir & "\v2m_lang.ini", $V2M_GUI_Language, "MAIN_DBGBOX_TIP", "DISPLAY DEBUG WINDOW"))
Else
	$V2M_GUI[33] = 1
EndIf
Global $bParts[3] = [$V2M_GUI[1] - 75, 60, 15]
$V2M_GUI[43] = _GUICtrlStatusBar_Create($V2M_GUI_Main, $bParts, "", $SBARS_TOOLTIPS)

; Set parts
;_GUICtrlStatusBar_SetParts ($V2M_GUI[43], $bParts)
;_GUICtrlStatusBar_SetText ($V2M_GUI[43], $V2M_Name & " " & $V2M_Version & " - " & StringFormat("%02d:%02d:%02d", @HOUR, @MIN, @SEC), 1)
_GUICtrlStatusBar_SetText($V2M_GUI[43], @TAB & StringFormat("%02d:%02d:%02d", @HOUR, @MIN, @SEC), 2)
; Set icon
;	_GUICtrlStatusBar_SetIcon ($V2M_GUI[43], 2, _WinAPI_LoadShell32Icon (111))
;_GUICtrlStatusBar_SetBkColor($V2M_GUI[43], 0xFFFFFF)
;_GUICtrlStatusBar_SetText ($V2M_GUI[43], @TAB & , 1)
;$V2M_GUI[9] = GUICtrlCreateEdit("", $BaseLeft - 20, $V2M_GUI[2] - 40, $V2M_GUI[1], 21, BitOR(4096, 64, 2048))
;GUICtrlSetTip(-1,IniRead(@ScriptDir & "\v2m_lang.ini", $V2M_GUI_Language, "MAIN_STATUS_TIP", "CURRENT STATUS"))

;
; Tab SC sharing
;
If FileExists(@ScriptDir & "\V2Msc.exe") And (IniRead(@ScriptDir & "\vnc2me_sc.ini", "V2M_GUI", "MAIN_HIDE_SC", 0) = 0) Then
	$V2M_EventDisplay = V2M_EventLog("GUI - Creating SC tab", $V2M_EventDisplay, 'dll')
	$V2M_GUI[18] = GUICtrlCreateTabItem("  " & IniRead(@ScriptDir & "\v2m_lang.ini", $V2M_GUI_Language, "MAIN_TAB_SC", "SHARE DESKTOP") & "  ")
	$CurLeft = $BaseLeft
	$CurTop = $BaseTop

	$CurLeft = $CurLeft + 10

	GUICtrlCreateLabel(IniRead(@ScriptDir & "\v2m_lang.ini", $V2M_GUI_Language, "MAIN_SC_SSN", "SESSION CODE"), $CurLeft, $CurTop + 3)
	$V2M_GUI[19] = GUICtrlCreateInput("", $CurLeft + 80, $CurTop, 200)
	GUICtrlSetTip(-1, IniRead(@ScriptDir & "\v2m_lang.ini", $V2M_GUI_Language, "MAIN_SC_SSN_TIP", "INPUT SESSION CODE TO CONNECT"))
	$CurTop = $CurTop + 30
	$CurLeft = $CurLeft + 20
	$V2M_GUI[20] = GUICtrlCreateButton(IniRead(@ScriptDir & "\v2m_lang.ini", $V2M_GUI_Language, "MAIN_SC_BTN_START", "SHARE DESKTOP"), $CurLeft, $V2M_GUI[4] - 40, 140, 20) ; VNC SC spawn button
	$CurLeft = $CurLeft + 160
	$V2M_GUI[21] = GUICtrlCreateButton(IniRead(@ScriptDir & "\v2m_lang.ini", $V2M_GUI_Language, "MAIN_SC_BTN_STOP", "STOP SHARING"), $CurLeft, $V2M_GUI[4] - 40, 140, 20)
	If (IniRead(@ScriptDir & "\vnc2me_sc.ini", "V2M_Server", "SESSION_CODE", "") <> "") Then
		$V2M_EventDisplay = V2M_EventLog("GUI - Session Code found in INI, loading it into GUI", $V2M_EventDisplay, 'dll')
		GUICtrlSetData($V2M_GUI[19] & @CRLF, IniRead(@ScriptDir & "\vnc2me_sc.ini", "V2M_Server", "SESSION_CODE", ""))
		GUICtrlSetState($V2M_GUI[19], $GUI_DISABLE) ;disable the session code box after setting from INI
		;	Else
		;		GUICtrlSetData($V2M_GUI[19] & @CRLF, V2MRandomPort())
	EndIf
	$V2M_Status[5][1] = 1
Else
	$V2M_GUI[18] = 1
	$V2M_GUI[19] = 1
	$V2M_GUI[20] = 1
	$V2M_GUI[21] = 1
	$V2M_Status[5][1] = 0
EndIf
;
; Tab Collaboration
;
If FileExists(@ScriptDir & "\V2MSVR.exe") And (IniRead(@ScriptDir & "\vnc2me_sc.ini", "V2M_GUI", "MAIN_HIDE_SVR", 0) = 0) Then
	$V2M_EventDisplay = V2M_EventLog("GUI - Creating SVR tab", $V2M_EventDisplay, 'dll')
	$V2M_GUI[34] = GUICtrlCreateTabItem("  " & IniRead(@ScriptDir & "\v2m_lang.ini", $V2M_GUI_Language, "MAIN_TAB_SVR", "START COLLABORATION") & "  ")
	$CurLeft = $BaseLeft
	$CurTop = $BaseTop

	$CurLeft = $CurLeft + 10
	GUICtrlCreateLabel(IniRead(@ScriptDir & "\v2m_lang.ini", $V2M_GUI_Language, "MAIN_SVR_SSN", "SESSION CODE"), $CurLeft, $CurTop + 3)
	$CurLeft = $CurLeft + 80
	$V2M_GUI[35] = GUICtrlCreateInput("", $CurLeft, $CurTop, 200, '', BitOR(4096, 64))
	GUICtrlSetTip(-1, IniRead(@ScriptDir & "\v2m_lang.ini", $V2M_GUI_Language, "MAIN_SVR_SSN_TIP", "INPUT SEESION CODE TO START"))
	$CurLeft = $CurLeft + 220
	$V2M_GUI[39] = GUICtrlCreateCheckbox(IniRead(@ScriptDir & "\v2m_lang.ini", $V2M_GUI_Language, "MAIN_VWR_RND", "RANDOM"), $CurLeft, $CurTop, $V2M_GUI[3] - $CurLeft)
	GUICtrlSetTip(-1, IniRead(@ScriptDir & "\v2m_lang.ini", $V2M_GUI_Language, "MAIN_VWR_RND_TIP", "GENERATE RANDOM SESSION CODE"))
	$CurTop = $CurTop + 30
	$CurLeft = $BaseLeft + 30
	$V2M_GUI[36] = GUICtrlCreateButton(IniRead(@ScriptDir & "\v2m_lang.ini", $V2M_GUI_Language, "MAIN_SVR_BTN_START", "START COLLAB"), $CurLeft, $V2M_GUI[4] - 40, 140, 20)
	$CurLeft = $CurLeft + 160
	$V2M_GUI[37] = GUICtrlCreateButton(IniRead(@ScriptDir & "\v2m_lang.ini", $V2M_GUI_Language, "MAIN_SVR_BTN_STOP", "STOP COLLAB"), $CurLeft, $V2M_GUI[4] - 40, 140, 20)
	If (IniRead(@ScriptDir & "\vnc2me_sc.ini", "V2M_Server", "SESSION_CODE", "") <> "") Then
		$V2M_EventDisplay = V2M_EventLog("GUI - Session Code found in INI, loading it into GUI", $V2M_EventDisplay, 'dll')
		GUICtrlSetData($V2M_GUI[35] & @CRLF, IniRead(@ScriptDir & "\vnc2me_sc.ini", "V2M_Server", "SESSION_CODE", ""))
		GUICtrlSetState($V2M_GUI[35], $GUI_DISABLE) ;disable the session code box after setting from INI
		GUICtrlSetState($V2M_GUI[39], $GUI_DISABLE) ;disable the random session code checkbox
	Else
		$V2M_EventDisplay = V2M_EventLog("GUI - Session Code NOT found in INI, generating random code", $V2M_EventDisplay, 'dll')
		GUICtrlSetData($V2M_GUI[35] & @CRLF, V2MRandomPort())
		GUICtrlSetState($V2M_GUI[35], $GUI_DISABLE) ;Disable the session code box after Setting session code
		GUICtrlSetState($V2M_GUI[39], 1) ;set SVR tab random checkbox
	EndIf
	$V2M_Status[5][2] = 1
Else
	$V2M_GUI[34] = 1
	$V2M_GUI[35] = 1
	$V2M_GUI[39] = 1
	$V2M_GUI[36] = 1
	$V2M_GUI[37] = 1
	$V2M_Status[5][2] = 0
EndIf

;
; Tab viewing
;
If FileExists(@ScriptDir & "\V2Mvwr.exe") And (IniRead(@ScriptDir & "\vnc2me_sc.ini", "V2M_GUI", "MAIN_HIDE_VWR", 0) = 0) Then
	$V2M_EventDisplay = V2M_EventLog("GUI - Creating VWR tab", $V2M_EventDisplay, 'dll')
	$V2M_GUI[13] = GUICtrlCreateTabItem("  " & IniRead(@ScriptDir & "\v2m_lang.ini", $V2M_GUI_Language, "MAIN_TAB_VIEW", "VIEW DESKTOP") & "  ")
	$CurLeft = $BaseLeft
	$CurTop = $BaseTop

	$CurLeft = $CurLeft + 10
	GUICtrlCreateLabel(IniRead(@ScriptDir & "\v2m_lang.ini", $V2M_GUI_Language, "MAIN_VWR_SSN", "SESSION CODE"), $CurLeft, $CurTop + 3)
	$CurLeft = $CurLeft + 80
	$V2M_GUI[12] = GUICtrlCreateInput("", $CurLeft, $CurTop, 200, '', BitOR(4096, 64)) ;session code
	GUICtrlSetTip(-1, IniRead(@ScriptDir & "\v2m_lang.ini", $V2M_GUI_Language, "MAIN_VWR_SSN_TIP", "INPUT SESSION CODE TO CONNECT"))
	$CurLeft = $CurLeft + 220
	$V2M_GUI[38] = GUICtrlCreateCheckbox(IniRead(@ScriptDir & "\v2m_lang.ini", $V2M_GUI_Language, "MAIN_VWR_RND", "RANDOM"), $CurLeft, $CurTop, $V2M_GUI[3] - $CurLeft)
	GUICtrlSetTip(-1, IniRead(@ScriptDir & "\v2m_lang.ini", $V2M_GUI_Language, "MAIN_VWR_RND_TIP", "GENERATE RANDOM SESSION CODE"))
	$CurLeft = $BaseLeft + 30
	$CurTop = $CurTop + 25
	If (IniRead(@ScriptDir & "\vnc2me_sc.ini", "V2M_GUI", "VNC_VWR_SC_ONLY", 0) = 1) Then ;VWR_SC_WANTED
		$V2M_EventDisplay = V2M_EventLog("VWR - SC VWR Only", $V2M_EventDisplay, 'dll')
		$V2M_Status[3][8] = 1 ;vwrSCwanted
	ElseIf (IniRead(@ScriptDir & "\vnc2me_sc.ini", "V2M_GUI", "VNC_VWR_SVR_ONLY", 0) = 1) Then ;VWR_SVR_WANTED
		$V2M_EventDisplay = V2M_EventLog("VWR - SVR VWR Only", $V2M_EventDisplay, 'dll')
		$V2M_Status[3][9] = 1 ;vwrSVRwanted
	Else ;ASK user what to connect to ...
		$V2M_EventDisplay = V2M_EventLog("VWR - Ask for connection type", $V2M_EventDisplay, 'dll')
		GUIStartGroup()
		$V2M_GUI[40] = GUICtrlCreateRadio(IniRead(@ScriptDir & "\v2m_lang.ini", $V2M_GUI_Language, "MAIN_VWR_RADIO_SC", "CONNECT TO SC"), $CurLeft, $CurTop, 100, 20, $GUI_SS_DEFAULT_RADIO)
		$CurLeft = ($V2M_GUI[3] / 2) + 10
		$V2M_GUI[41] = GUICtrlCreateRadio(IniRead(@ScriptDir & "\v2m_lang.ini", $V2M_GUI_Language, "MAIN_VWR_RADIO_SVR", "CONNECT TO SVR"), $CurLeft, $CurTop, 100, 20)
		GUICtrlSetState($V2M_GUI[40], 1) ;Check the SC vwr radio item.
		$V2M_Status[3][8] = 1 ;vwrSCwanted
	EndIf
	$CurTop = $CurTop + 10
	$CurLeft = $BaseLeft + 30
	$V2M_GUI[10] = GUICtrlCreateButton(IniRead(@ScriptDir & "\v2m_lang.ini", $V2M_GUI_Language, "MAIN_VWR_BTN_START", "START VIEWING"), $CurLeft, $V2M_GUI[4] - 40, 140, 20)
	$CurLeft = $CurLeft + 160
	$V2M_GUI[11] = GUICtrlCreateButton(IniRead(@ScriptDir & "\v2m_lang.ini", $V2M_GUI_Language, "MAIN_VWR_BTN_STOP", "STOP VIEWING"), $CurLeft, $V2M_GUI[4] - 40, 140, 20)
	If (IniRead(@ScriptDir & "\vnc2me_sc.ini", "V2M_Server", "SESSION_CODE", "") <> "") Then
		$V2M_EventDisplay = V2M_EventLog("GUI - Session Code found in INI, loading it into GUI", $V2M_EventDisplay, 'dll')
		GUICtrlSetData($V2M_GUI[12] & @CRLF, IniRead(@ScriptDir & "\vnc2me_sc.ini", "V2M_Server", "SESSION_CODE", ""))
		GUICtrlSetState($V2M_GUI[12], $GUI_DISABLE) ;disable the session code box after setting from INI
		GUICtrlSetState($V2M_GUI[38], $GUI_DISABLE) ;disable the random session code checkbox
	Else
		$V2M_EventDisplay = V2M_EventLog("GUI - Session Code NOT found in INI, generating random code", $V2M_EventDisplay, 'dll')
		GUICtrlSetData($V2M_GUI[12] & @CRLF, V2MRandomPort())
		GUICtrlSetState($V2M_GUI[12], $GUI_DISABLE) ;Disable the session code box after Setting session code
		GUICtrlSetState($V2M_GUI[38], 1) ;set VWR tab random checkbox
	EndIf
	$V2M_Status[5][3] = 1
Else
	$V2M_GUI[13] = 1
	$V2M_GUI[12] = 1
	$V2M_GUI[38] = 1
	$V2M_GUI[10] = 1
	$V2M_GUI[11] = 1
	$V2M_Status[5][3] = 0
EndIf
;
; Tab UVNC sharing
;
If FileExists(@ScriptDir & "\uvnc.exe") And (IniRead(@ScriptDir & "\vnc2me_sc.ini", "V2M_GUI", "MAIN_HIDE_UVNC", 0) = 0) Then
	$V2M_EventDisplay = V2M_EventLog("GUI - Creating UVNC tab", $V2M_EventDisplay, 'dll')
	$V2M_GUI[50] = GUICtrlCreateTabItem("  " & IniRead(@ScriptDir & "\v2m_lang.ini", $V2M_GUI_Language, "MAIN_TAB_UVNC", "UVNC") & "  ")
	$CurTop = $BaseTop
	$CurLeft = $BaseLeft + 10
	If (IniRead(@ScriptDir & "\ultravnc.ini", "SC", "SCNUMBERCONNECTIONS", 0)) > 0 Then
		V2M_EventLog("UVNC, SCNUMBERCONNECTIONS > 0", $V2M_EventDisplay, 'dll')
		$V2M_GUI[55] = GUICtrlCreateCombo("Manual", $CurLeft, $CurTop, 180, 90)
		GUICtrlSetData($V2M_GUI[55], V2M_UVNC_ConnectNames(), '')
	Else
		V2M_EventLog("UVNC, SCNUMBERCONNECTIONS = 0", $V2M_EventDisplay, 'dll')
		GUICtrlCreateLabel(IniRead(@ScriptDir & "\v2m_lang.ini", $V2M_GUI_Language, "MAIN_UVNC_ADD", "ADDRESS"), $CurLeft, $CurTop + 3)
		$V2M_GUI[51] = GUICtrlCreateInput("", $CurLeft + 80, $CurTop, 200)
		GUICtrlSetTip(-1, IniRead(@ScriptDir & "\v2m_lang.ini", $V2M_GUI_Language, "MAIN_UVNC_ADD_TIP", "INPUT SUPPORT ADDRESS TO CONNECT"))
		$CurTop = $CurTop + 20
		$CurLeft = $BaseLeft + 10
		GUICtrlCreateLabel(IniRead(@ScriptDir & "\v2m_lang.ini", $V2M_GUI_Language, "MAIN_UVNC_PORT", "PORT"), $CurLeft, $CurTop + 3)
		$V2M_GUI[52] = GUICtrlCreateInput("", $CurLeft + 80, $CurTop, 200)
		GUICtrlSetTip(-1, IniRead(@ScriptDir & "\v2m_lang.ini", $V2M_GUI_Language, "MAIN_UVNC_PORT_TIP", "INPUT SUPPORT PORT"))
	EndIf
	$CurTop = $CurTop + 10
	$CurLeft = $CurLeft + 20
	$V2M_GUI[53] = GUICtrlCreateButton(IniRead(@ScriptDir & "\v2m_lang.ini", $V2M_GUI_Language, "MAIN_UVNC_BTN_START", "SHARE DESKTOP"), $CurLeft, $V2M_GUI[4] - 40, 140, 20, 0, $GUI_FOCUS) ; VNC SC spawn button
	$CurLeft = $CurLeft + 160
	$V2M_GUI[54] = GUICtrlCreateButton(IniRead(@ScriptDir & "\v2m_lang.ini", $V2M_GUI_Language, "MAIN_UVNC_BTN_STOP", "STOP SHARING"), $CurLeft, $V2M_GUI[4] - 40, 140, 20)
	If (IniRead(@ScriptDir & "\vnc2me_sc.ini", "V2M_Server", "SESSION_CODE", "") <> "") Then
		GUICtrlSetData($V2M_GUI[53] & @CRLF, IniRead(@ScriptDir & "\vnc2me_sc.ini", "V2M_Server", "SESSION_CODE", ""))
		;		GUICtrlSetState($V2M_GUI[53], $GUI_DISABLE)		;disable the session code box after setting from INI
		;	Else
		;		GUICtrlSetData($V2M_GUI[19] & @CRLF, V2MRandomPort())
	EndIf
	$V2M_Status[5][4] = 1
Else
	$V2M_GUI[50] = 1
	$V2M_GUI[51] = 1
	$V2M_GUI[52] = 1
	$V2M_GUI[53] = 1
	$V2M_GUI[54] = 1
	$V2M_Status[5][4] = 0
EndIf

; Show the GUI window
If ($V2M_Status[5][1] + $V2M_Status[5][2] + $V2M_Status[5][3] + $V2M_Status[5][4]) > 0 Then
	$V2M_EventDisplay = V2M_EventLog("GUI - Showing the main window (more than one tab visable)", $V2M_EventDisplay, 'dll')
	GUISetState(@SW_SHOW, $V2M_GUI_MainTitle)
	TrayItemSetState($V2M_Tray[3], $TRAY_CHECKED)
Else
	$V2M_EventDisplay = V2M_EventLog("GUI - No Tabs visable in the main GUI, VNC2Me will now exit", $V2M_EventDisplay, 'dll')
	TrayTip(IniRead(@ScriptDir & "\v2m_lang.ini", $V2M_GUI_Language, "TRAYTIP_APP_EXITING_TITLE", "APP_EXITING_TITLE"), IniRead(@ScriptDir & "\v2m_lang.ini", $V2M_GUI_Language, "TRAYTIP_APP_EXITING_LINE1", "") & @CR & IniRead(@ScriptDir & "\v2m_lang.ini", $V2M_GUI_Language, "TRAYTIP_APP_EXITING_LINE2", ""), 30)
	MsgBox(0, "What ?", "No VNC files found, exiting", 10)
	$V2M_Exit = 1
EndIf
$V2M_Status[2][1] = 'show'

;
;=========================================================================================================================================================
; Create the mini GUI
$V2M_GUI_Mini = GUICreate($V2M_GUI_MiniTitle, $V2M_GUI[5], $V2M_GUI[6], ((@DesktopWidth - $V2M_GUI[5]) / 2), 0, 2147483648, BitOR(128, 8))

;$V2M_GUI[22] = GUICtrlCreateMenu(IniRead(@ScriptDir & "\v2m_lang.ini", $V2M_GUI_Language, "GUI_MNU_FILE", "File"))
;$V2M_GUI[23] = GUICtrlCreateMenuItem(IniRead(@ScriptDir & "\v2m_lang.ini", $V2M_GUI_Language, "GUI_MNU_SWAP", "Show Main Window"), $V2M_GUI[22])
;
;$V2M_GUI[24] = GUICtrlCreateMenu(IniRead(@ScriptDir & "\v2m_lang.ini", $V2M_GUI_Language, "GUI_MNU_HELP", "Help"))
;$V2M_GUI[25] = GUICtrlCreateMenuItem(IniRead(@ScriptDir & "\v2m_lang.ini", $V2M_GUI_Language, "GUI_MNU_ABOUT", "About"), $V2M_GUI[24])

;$V2M_GUI[22] = GUICtrlCreateMenu("File")
;$V2M_GUI[23] = GUICtrlCreateMenuItem("Show Main Window", $V2M_GUI[22])

;$V2M_GUI[24] = GUICtrlCreateMenu("Help")
;$V2M_GUI[25] = GUICtrlCreateMenuItem("About", $V2M_GUI[24])

$V2M_GUI[31] = GUICtrlCreateButton(IniRead(@ScriptDir & "\v2m_lang.ini", $V2M_GUI_Language, "MINI_BTN_EXIT", " C L O S E   R E M O T E   S E S S I O N "), 0, 0, $V2M_GUI[5], 20)
GUICtrlSetTip(-1, IniRead(@ScriptDir & "\v2m_lang.ini", $V2M_GUI_Language, "MINI_BTN_EXIT_TIP", "EXIT VNC2ME"))
;$V2M_GUI[8] = GUICtrlCreateEdit("", 0, 20, $V2M_GUI[5] - 50, 21, BitOR(4096, 64, 2048))
;GUICtrlSetTip(-1,IniRead(@ScriptDir & "\v2m_lang.ini", $V2M_GUI_Language, "MINI_STATUS_TIP", "STATUS & EVENTS"))
;$V2M_GUI[26] = GUICtrlCreateEdit("", $V2M_GUI[5] - 50, 20, 50, 21, BitOR(4096, 64, 2048))
;GUICtrlSetTip(-1, IniRead(@ScriptDir & "\v2m_lang.ini", $V2M_GUI_Language, "MINI_SESSION_TIP", "VNC2Me SESSION CODE"))
Global $aParts[4] = [200, 75, 50, 50]
Global $aText[3] = ["Left Justified", @TAB & "Centered", @TAB & @TAB & "Right"]
$V2M_GUI[42] = _GUICtrlStatusBar_Create($V2M_GUI_Mini, $aParts, $aText)

; Set parts
;_GUICtrlStatusBar_SetParts ($V2M_GUI[42], $aParts)
_GUICtrlStatusBar_SetText($V2M_GUI[42], "Status")
_GUICtrlStatusBar_SetText($V2M_GUI[42], @TAB & StringFormat("%02d:%02d:%02d", @HOUR, @MIN, @SEC), 1)
_GUICtrlStatusBar_SetText($V2M_GUI[42], @TAB & StringFormat("%02d:%02d:%02d", @HOUR, @MIN, @SEC), 2)
_GUICtrlStatusBar_SetTipText($V2M_GUI[42], 1, IniRead(@ScriptDir & "\v2m_lang.ini", $V2M_GUI_Language, "MAIN_STATUS_TIP", "CURRENT STATUS"))

; Set icons
;_GUICtrlStatusBar_SetIcon ($V2M_GUI[42], 0, 23, "shell32.dll")
;_GUICtrlStatusBar_SetIcon ($V2M_GUI[42], 1, 40, "shell32.dll")

;_GUICtrlStatusBar_SetText($V2M_GUI[42], "Timers")
;$V2M_GUI[43] = GUICtrlCreateProgress(0, 0, -1, -1, $PBS_SMOOTH)
;GUICtrlSetColor($V2M_GUI[43], 0xff0000)
;_GUICtrlStatusBar_EmbedControl($V2M_GUI[42], 1, GUICtrlGetHandle($V2M_GUI[43]))


GUISetState(@SW_HIDE, $V2M_GUI_MiniTitle)

;
;=========================================================================================================================================================
; Create the debug GUI
Global $V2M_GUI_DebugHeight = $V2M_GUI[2] - 100

$V2M_GUI[27] = GUICreate($V2M_GUI_DebugTitle, $V2M_GUI[1], $V2M_GUI_DebugHeight, ((@DesktopWidth - $V2M_GUI[1]) / 2) + $V2M_GUI[1] + 5, ((@DesktopHeight - $V2M_GUI[2]) / 2), -1, BitOR(128, 8))

$V2M_GUI_DebugOutputEdit = GUICtrlCreateEdit("", 0, 0, $V2M_GUI[1], $V2M_GUI_DebugHeight - 30, BitOR(4096, 2097152, 1048576, 64, 128, 2048))

$CurLeft = 20
$V2M_GUI[28] = GUICtrlCreateButton(IniRead(@ScriptDir & "\v2m_lang.ini", $V2M_GUI_Language, "DEBUG_BTN_START", "SSH ONLY"), $CurLeft, $V2M_GUI_DebugHeight - 24, 80, 20)
$CurLeft = $CurLeft + 90
$V2M_GUI[29] = GUICtrlCreateButton(IniRead(@ScriptDir & "\v2m_lang.ini", $V2M_GUI_Language, "DEBUG_BTN_STOP", "STOP SSH"), $CurLeft, $V2M_GUI_DebugHeight - 24, 60, 20)
$CurLeft = $CurLeft + 80
$V2M_GUI[30] = GUICtrlCreateButton(IniRead(@ScriptDir & "\v2m_lang.ini", $V2M_GUI_Language, "DEBUG_BTN_COPY", "DEBUG > CLIPBOARD"), $CurLeft, $V2M_GUI_DebugHeight - 24, 160, 20)

GUISwitch($V2M_GUI[27])
GUISetState(@SW_HIDE, $V2M_GUI_DebugTitle)