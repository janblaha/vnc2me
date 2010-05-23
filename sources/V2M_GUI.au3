#cs ----------------------------------------------------------------------------
	
	AutoIt Version: 3.2.10.0
	Author:         myName
	
	Script Function:
	Template AutoIt script.
	
#ce ----------------------------------------------------------------------------

; Script Start - Add your code below here

If FileExists(@ScriptDir & "\" & $V2M_VNC_SC) And (IniRead($AppINI, "V2M_GUI", "MAIN_HIDE_SC", 0) = 0) Then
	$V2M_GUI_TAB_DISPLAY_SC = 1
	$V2M_EventDisplay = YTS_EventLog("GUI - File: " & @ScriptDir & "\" & $V2M_VNC_SC & " exists", $V2M_EventDisplay, '9')
EndIf
If FileExists(@ScriptDir & "\" & $V2M_VNC_SVR) And (IniRead($AppINI, " V2M_GUI", " MAIN_HIDE_SVR", 0) = 0) Then
	$V2M_GUI_TAB_DISPLAY_SVR = 1
	$V2M_EventDisplay = YTS_EventLog("GUI - File: " & @ScriptDir & "\" & $V2M_VNC_SVR & " exists", $V2M_EventDisplay, '9')
EndIf
If FileExists(@ScriptDir & "\" & $V2M_VNC_VWR) And (IniRead($AppINI, "V2M_GUI", "MAIN_HIDE_VWR", 0) = 0) Then
	$V2M_GUI_TAB_DISPLAY_VWR = 1
	$V2M_EventDisplay = YTS_EventLog("GUI - File: " & @ScriptDir & "\" & $V2M_VNC_VWR & " exists", $V2M_EventDisplay, '9')
EndIf
If FileExists(@ScriptDir & "\" & $V2M_VNC_UVNC) And (IniRead($AppINI, "V2M_GUI", "MAIN_HIDE_UVNC", 0) = 0) Then
	$V2M_GUI_TAB_DISPLAY_UVNC = 1
	$V2M_EventDisplay = YTS_EventLog("GUI - file: " & @ScriptDir & "\" & $V2M_VNC_UVNC & " exists", $V2M_EventDisplay, '9')
EndIf
If $V2M_NoGUI = 0 Then
	If $V2M_GUI_TAB_DISPLAY_UVNC = 1 Then
		;			$V2M_EventDisplay = YTS_EventLog("GUI - UVNC.exe exists", $V2M_EventDisplay, '9')
		$V2M_GUI[1] = $V2M_GUI[1] + 50 ;Main GUI width
		$V2M_GUI[2] = $V2M_GUI[2] + 50 ;Main GUI height
		$V2M_GUI[3] = $V2M_GUI[3] + 50 ;GUI TAB width
		$V2M_GUI[4] = $V2M_GUI[4] + 50 ;GUI TAB height
	ElseIf $V2M_GUI_TAB_DISPLAY_SVR + $V2M_GUI_TAB_DISPLAY_UVNC + $V2M_GUI_TAB_DISPLAY_VWR > 0 Then
		$V2M_GUI[1] = $V2M_GUI[1] ;Main GUI width
		$V2M_GUI[2] = $V2M_GUI[2] ;Main GUI height
		$V2M_GUI[3] = $V2M_GUI[3] ;GUI TAB width
		$V2M_GUI[4] = $V2M_GUI[4] ;GUI TAB height
	Else ; SC TAB IS ONLY TAB, make small GUI
		$V2M_GUI[1] = 260 ; width of main GUI
		$V2M_GUI[2] = 80 ; height of main GUI
		$V2M_GUI[3] = 0 ; width of TAB in main GUI
		$V2M_GUI[4] = 0 ; Height of TAB in main GUI
	EndIf
	;
	;=========================================================================================================================================================
	; Create the main GUI

	If $V2M_GUI[3] + $V2M_GUI[4] > 0 Then ; create tabbed GUI
		$V2M_GUI_Main = GUICreate($V2M_GUI_MainTitle, $V2M_GUI[1], $V2M_GUI[2], (@DesktopWidth - $V2M_GUI[1]) / 2, (@DesktopHeight - $V2M_GUI[2]) / 2)
		If $INI_colorbg1 <> 0 Then GUICtrlSetColor(-1, $INI_colorbg1)

		GUISetIcon("v2m.ico")
		$V2M_GUI[7] = GUICtrlCreateMenu(_Translate($V2M_GUI_Language, "MAIN_MNU_FILE", "FILE"))
		$V2M_GUI[32] = GUICtrlCreateMenuItem(_Translate($V2M_GUI_Language, "MAIN_MNU_EXIT", "EXIT"), $V2M_GUI[7])

		$V2M_GUI[14] = GUICtrlCreateMenu(_Translate($V2M_GUI_Language, "MAIN_MNU_HELP", "HELP"))
		$V2M_GUI[15] = GUICtrlCreateMenuItem(_Translate($V2M_GUI_Language, "MAIN_MNU_ABOUT", "ABOUT"), $V2M_GUI[14])

		$V2M_GUI[16] = GUICtrlCreateTab(10, 0, $V2M_GUI[3], $V2M_GUI[4])

		$BaseLeft = 20
		$BaseTop = 35


		$V2M_GUI[17] = GUICtrlCreateButton(_Translate($V2M_GUI_Language, "MAIN_BTN_EXIT", "EXIT"), $BaseLeft, $V2M_GUI[2] - 70, 60, 20)
		GUICtrlSetTip(-1, _Translate($V2M_GUI_Language, "MAIN_BTN_EXIT_TIP", "EXIT THE APP"))
		$CurLeft = $BaseLeft + 80


		If $V2M_Status[1][2] = 1 Then ; EnableDebugingCheckbox
			$V2M_GUI[33] = GUICtrlCreateCheckbox(_Translate($V2M_GUI_Language, "MAIN_DbgBox", "DEBUG"), $CurLeft, $V2M_GUI[2] - 70)
			GUICtrlSetTip(-1, _Translate($V2M_GUI_Language, "MAIN_DBGBOX_TIP", "DISPLAY DEBUG WINDOW"))
			$V2M_GUI[65] = 1
		ElseIf $V2M_Status[1][4] = 1 Then ; EnableCompressionCheckbox
			$V2M_GUI[65] = GUICtrlCreateCheckbox(_Translate($V2M_GUI_Language, "MAIN_COMPRESSBOX", "COMPRESS"), $CurLeft, $V2M_GUI[2] - 70)
			GUICtrlSetTip(-1, _Translate($V2M_GUI_Language, "MAIN_COMPRESSBOX_TIP", "ENABLE COMPRESSION FOR SLOW CONNECTIONS"))
			$V2M_GUI[33] = 1
		Else
			$V2M_GUI[33] = 1 ; debugingcheckbox
			$V2M_GUI[65] = 1 ; compresscheckbox
		EndIf
	Else ; create small SC only GUI
		$V2M_GUI_Main = GUICreate($V2M_GUI_MainTitle, $V2M_GUI[1], $V2M_GUI[2], (@DesktopWidth - $V2M_GUI[1]) / 2, (@DesktopHeight - $V2M_GUI[2]) / 2, -1, BitOR(128, 8))

		GUISetIcon("v2m.ico")

		$V2M_GUI[7] = 1
		$V2M_GUI[32] = 1
		$V2M_GUI[14] = 1
		$V2M_GUI[15] = 1
		$V2M_GUI[16] = 0
		$V2M_GUI[40] = 1
		$V2M_GUI[41] = 1

		$BaseLeft = 5
		$BaseTop = 35


		$V2M_GUI[17] = 1
	EndIf


	Global $StatusBar_Parts[3] = [50, $V2M_GUI[1] - 60, -1], $StatusBar_Text[3] = [@TAB & "", @TAB & @TAB & "", ""]
	$V2M_GUI[43] = _GUICtrlStatusBar_Create($V2M_GUI_Main, $StatusBar_Parts, $StatusBar_Text, $SBARS_TOOLTIPS)

	; Set parts
	;_GUICtrlStatusBar_SetParts ($V2M_GUI[43], $StatusBar_Parts)
	_GUICtrlStatusBar_SetText($V2M_GUI[43], @TAB & StringFormat("%02d:%02d", @HOUR, @MIN), 0)
	_GUICtrlStatusBar_SetText($V2M_GUI[43], $V2M_Name & " " & $V2M_Version, 1)
	_GUICtrlStatusBar_SetText($V2M_GUI[43], @TAB & StringFormat("%02d:%02d:%02d", @HOUR, @MIN, @SEC), 2)
	; Set icon
	;	_GUICtrlStatusBar_SetIcon($V2M_GUI[43], 2, _WinAPI_LoadShell32Icon(111))
	;	_GUICtrlStatusBar_SetBkColor($V2M_GUI[43], 0xFFFFFF)
	;_GUICtrlStatusBar_SetText ($V2M_GUI[43], @TAB & , 1)
	;$V2M_GUI[9] = GUICtrlCreateEdit("", $BaseLeft - 20, $V2M_GUI[2] - 40, $V2M_GUI[1], 21, BitOR(4096, 64, 2048))
	;GUICtrlSetTip(-1,_Translate($V2M_GUI_Language, "MAIN_STATUS_TIP", "CURRENT STATUS"))

	;
	; Tab SC sharing
	;
	If $V2M_GUI_TAB_DISPLAY_SC = 1 Then ; if not turned off in INI then ...
		If $V2M_GUI[3] + $V2M_GUI[4] > 0 Then ; if viewer or collaboration server tabs are shown then ...
			$V2M_EventDisplay = YTS_EventLog("GUI - Creating SC tab - ($V2M_GUI[3] = " & $V2M_GUI[3] & ", $V2M_GUI[4] = " & $V2M_GUI[4] & ")", $V2M_EventDisplay, '7')
			$V2M_GUI[18] = GUICtrlCreateTabItem("  " & _Translate($V2M_GUI_Language, "MAIN_TAB_SC", "SHARE DESKTOP") & "  ")
			$CurLeft = $BaseLeft
			$CurTop = $BaseTop

			$CurLeft = $CurLeft + 10

			GUICtrlCreateLabel(_Translate($V2M_GUI_Language, "MAIN_SC_SSN", "SESSION CODE"), $CurLeft, $CurTop + 3)
			$V2M_GUI[19] = GUICtrlCreateInput("", $CurLeft + 80, $CurTop, 200)
			GUICtrlSetTip(-1, _Translate($V2M_GUI_Language, "MAIN_SC_SSN_TIP", "INPUT SESSION CODE TO CONNECT"))
			$CurTop = $CurTop + 30
			$CurLeft = $CurLeft + 20
			$V2M_GUI[20] = GUICtrlCreateButton(_Translate($V2M_GUI_Language, "MAIN_SC_BTN_START", "SHARE DESKTOP"), $CurLeft, $V2M_GUI[4] - 40, 140, 20) ; VNC SC spawn button
			GUICtrlSetImage($V2M_GUI[20], @ScriptDir & "\v2m.ico")
			$CurLeft = $CurLeft + 160
			$V2M_GUI[21] = GUICtrlCreateButton(_Translate($V2M_GUI_Language, "MAIN_SC_BTN_STOP", "STOP SHARING"), $CurLeft, $V2M_GUI[4] - 40, 140, 20)
			If (IniRead($AppINI, "V2M_Server", "SESSION_CODE", "") <> "") Then
				$V2M_EventDisplay = YTS_EventLog("GUI - Session Code found in INI, loading it into GUI", $V2M_EventDisplay, '9')
				GUICtrlSetData($V2M_GUI[19] & @CRLF, IniRead($AppINI, "V2M_Server", "SESSION_CODE", ""))
				GUICtrlSetState($V2M_GUI[19], $GUI_DISABLE) ;disable the session code box after setting from INI
				;	Else
				;		GUICtrlSetData($V2M_GUI[19] & @CRLF, V2MRandomPort())
			EndIf
		Else ; viewer & collaboration server tabs are not shown
			;display minimal SC GUI (not tab)
			$V2M_EventDisplay = YTS_EventLog("GUI - Creating SC GUI (not tab)", $V2M_EventDisplay, '4')
			$CurLeft = $BaseLeft
			$CurTop = $BaseTop - 30
			GUICtrlCreateLabel(_Translate($V2M_GUI_Language, "MAIN_SC_SSN", "SESSION CODE"), $CurLeft, $CurTop + 3)
			$V2M_GUI[19] = GUICtrlCreateInput("", $CurLeft + 80, $CurTop, 80)
			GUICtrlSetTip(-1, _Translate($V2M_GUI_Language, "MAIN_SC_SSN_TIP", "INPUT SESSION CODE TO CONNECT"))
			If $V2M_Status[1][2] = 1 Then ; EnableDebugingCheckbox
				$V2M_GUI[33] = GUICtrlCreateCheckbox(_Translate($V2M_GUI_Language, "MAIN_DbgBox", "DEBUG"), $CurLeft + 170, $CurTop + 1)
				GUICtrlSetTip(-1, _Translate($V2M_GUI_Language, "MAIN_DBGBOX_TIP", "DISPLAY DEBUG WINDOW"))
				$V2M_GUI[65] = 1
			ElseIf $V2M_Status[1][4] = 1 Then ; EnableCompressionCheckbox
				$V2M_GUI[33] = 1
				$V2M_GUI[65] = GUICtrlCreateCheckbox(_Translate($V2M_GUI_Language, "MAIN_COMPRESSBOX", "COMPRESS"), $CurLeft + 170, $CurTop + 1)
				GUICtrlSetTip(-1, _Translate($V2M_GUI_Language, "MAIN_COMPRESSBOX_TIP", "ENABLE COMPRESSION FOR SLOW CONNECTIONS"))
			Else
				$V2M_GUI[33] = 1
				$V2M_GUI[65] = 1
			EndIf
			$CurTop = $CurTop + 25
			$CurLeft = $BaseLeft
			$V2M_GUI[20] = GUICtrlCreateButton(_Translate($V2M_GUI_Language, "MAIN_SC_BTN_START", "SHARE DESKTOP"), $CurLeft, $CurTop, 120, 20) ; VNC SC spawn button
			;			$V2M_GUI[20] = GUICtrlCreateButton(_Translate($V2M_GUI_Language, "MAIN_SC_BTN_START", "SHARE DESKTOP"), $CurLeft, $CurTop, 120, 20, -1, BitOR($BS_DEFPUSHBUTTON)) ; VNC SC spawn button
			;			GUICtrlSetImage($V2M_GUI[20], @ScriptDir & "\v2m.ico")
			$CurLeft = $CurLeft + 125
			$V2M_GUI[17] = GUICtrlCreateButton(_Translate($V2M_GUI_Language, "MAIN_BTN_EXIT", "EXIT"), $CurLeft, $CurTop, 120, 20)
			$V2M_GUI[21] = 1
			If (IniRead($AppINI, "V2M_Server", "SESSION_CODE", "") <> "") Then
				$V2M_EventDisplay = YTS_EventLog("GUI - Session Code found in INI, loading it into GUI", $V2M_EventDisplay, '9')
				GUICtrlSetData($V2M_GUI[19] & @CRLF, IniRead($AppINI, "V2M_Server", "SESSION_CODE", ""))
				GUICtrlSetState($V2M_GUI[19], $GUI_DISABLE) ;disable the session code box after setting from INI
				;	Else
				;		GUICtrlSetData($V2M_GUI[19] & @CRLF, V2MRandomPort())
			EndIf
			GUICtrlSetState($V2M_GUI[19], $GUI_FOCUS)
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
	If $V2M_GUI_TAB_DISPLAY_SVR = 1 Then
		$V2M_EventDisplay = YTS_EventLog("GUI - Creating SVR tab", $V2M_EventDisplay, '4')
		$V2M_GUI[34] = GUICtrlCreateTabItem("  " & _Translate($V2M_GUI_Language, "MAIN_TAB_SVR", "START COLLABORATION") & "  ")
		$CurLeft = $BaseLeft
		$CurTop = $BaseTop

		$CurLeft = $CurLeft + 10
		GUICtrlCreateLabel(_Translate($V2M_GUI_Language, "MAIN_SVR_SSN", "SESSION CODE"), $CurLeft, $CurTop + 3)
		$CurLeft = $CurLeft + 80
		$V2M_GUI[35] = GUICtrlCreateInput("", $CurLeft, $CurTop, 200, '', BitOR(4096, 64))
		GUICtrlSetTip(-1, _Translate($V2M_GUI_Language, "MAIN_SVR_SSN_TIP", "INPUT SEESION CODE TO START"))
		$CurLeft = $CurLeft + 220
		$V2M_GUI[39] = GUICtrlCreateCheckbox(_Translate($V2M_GUI_Language, "MAIN_VWR_RND", "RANDOM"), $CurLeft, $CurTop, $V2M_GUI[3] - $CurLeft)
		GUICtrlSetTip(-1, _Translate($V2M_GUI_Language, "MAIN_VWR_RND_TIP", "GENERATE RANDOM SESSION CODE"))
		$CurTop = $CurTop + 30
		$CurLeft = $BaseLeft + 30
		$V2M_GUI[36] = GUICtrlCreateButton(_Translate($V2M_GUI_Language, "MAIN_SVR_BTN_START", "START COLLAB"), $CurLeft, $V2M_GUI[4] - 40, 140, 20)
		$CurLeft = $CurLeft + 160
		$V2M_GUI[37] = GUICtrlCreateButton(_Translate($V2M_GUI_Language, "MAIN_SVR_BTN_STOP", "STOP COLLAB"), $CurLeft, $V2M_GUI[4] - 40, 140, 20)
		If (IniRead($AppINI, "V2M_Server", "SESSION_CODE", "") <> "") Then
			$V2M_EventDisplay = YTS_EventLog("GUI - Session Code found in INI, loading it into GUI", $V2M_EventDisplay, '9')
			GUICtrlSetData($V2M_GUI[35] & @CRLF, IniRead($AppINI, "V2M_Server", "SESSION_CODE", ""))
			GUICtrlSetState($V2M_GUI[35], $GUI_DISABLE) ;disable the session code box after setting from INI
			GUICtrlSetState($V2M_GUI[39], $GUI_DISABLE) ;disable the random session code checkbox
		Else
			$V2M_EventDisplay = YTS_EventLog("GUI - Session Code NOT found in INI, generating random code", $V2M_EventDisplay, '9')
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
	If $V2M_GUI_TAB_DISPLAY_VWR = 1 Then
		$V2M_EventDisplay = YTS_EventLog("GUI - Creating VWR tab", $V2M_EventDisplay, '4')
		$V2M_GUI[13] = GUICtrlCreateTabItem("  " & _Translate($V2M_GUI_Language, "MAIN_TAB_VIEW", "VIEW DESKTOP") & "  ")
		$CurLeft = $BaseLeft
		$CurTop = $BaseTop

		$CurLeft = $CurLeft + 10
		GUICtrlCreateLabel(_Translate($V2M_GUI_Language, "MAIN_VWR_SSN", "SESSION CODE"), $CurLeft, $CurTop + 3)
		$CurLeft = $CurLeft + 80
		$V2M_GUI[12] = GUICtrlCreateInput("", $CurLeft, $CurTop, 200, '', BitOR(4096, 64)) ;session code
		GUICtrlSetTip(-1, _Translate($V2M_GUI_Language, "MAIN_VWR_SSN_TIP", "INPUT SESSION CODE TO CONNECT"))
		$CurLeft = $CurLeft + 220
		$V2M_GUI[38] = GUICtrlCreateCheckbox(_Translate($V2M_GUI_Language, "MAIN_VWR_RND", "RANDOM"), $CurLeft, $CurTop, $V2M_GUI[3] - $CurLeft)
		GUICtrlSetTip(-1, _Translate($V2M_GUI_Language, "MAIN_VWR_RND_TIP", "GENERATE RANDOM SESSION CODE"))
		$CurLeft = $BaseLeft + 30
		$CurTop = $CurTop + 25
		If (IniRead($AppINI, "V2M_GUI", "VNC_VWR_SC_ONLY", 0) = 1) Then ;VWR_SC_WANTED
			$V2M_EventDisplay = YTS_EventLog("VWR - SC VWR Only", $V2M_EventDisplay, '8')
			$V2M_Status[3][8] = 1 ;vwrSCwanted
			$V2M_GUI[40] = 1
			$V2M_GUI[41] = 1
		ElseIf (IniRead($AppINI, "V2M_GUI", "VNC_VWR_SVR_ONLY", 0) = 1) Then ;VWR_SVR_WANTED
			$V2M_EventDisplay = YTS_EventLog("VWR - SVR VWR Only", $V2M_EventDisplay, '8')
			$V2M_Status[3][9] = 1 ;vwrSVRwanted
			$V2M_GUI[40] = 1
			$V2M_GUI[41] = 1
		Else ;ASK user what to connect to ...
			$V2M_EventDisplay = YTS_EventLog("VWR - Ask for connection type", $V2M_EventDisplay, '8')
			GUIStartGroup()
			$V2M_GUI[40] = GUICtrlCreateRadio(_Translate($V2M_GUI_Language, "MAIN_VWR_RADIO_SC", "CONNECT TO SC"), $CurLeft, $CurTop, 100, 20, $GUI_SS_DEFAULT_RADIO)
			$CurLeft = ($V2M_GUI[3] / 2) + 10
			$V2M_GUI[41] = GUICtrlCreateRadio(_Translate($V2M_GUI_Language, "MAIN_VWR_RADIO_SVR", "CONNECT TO SVR"), $CurLeft, $CurTop, 100, 20)
			GUICtrlSetState($V2M_GUI[40], 1) ;Check the SC vwr radio item.
			$V2M_Status[3][8] = 1 ;vwrSCwanted
		EndIf
		$CurTop = $CurTop + 10
		$CurLeft = $BaseLeft + 30
		$V2M_GUI[10] = GUICtrlCreateButton(_Translate($V2M_GUI_Language, "MAIN_VWR_BTN_START", "START VIEWING"), $CurLeft, $V2M_GUI[4] - 40, 140, 20)
		$CurLeft = $CurLeft + 160
		$V2M_GUI[11] = GUICtrlCreateButton(_Translate($V2M_GUI_Language, "MAIN_VWR_BTN_STOP", "STOP VIEWING"), $CurLeft, $V2M_GUI[4] - 40, 140, 20)
		If (IniRead($AppINI, "V2M_Server", "SESSION_CODE", "") <> "") Then
			$V2M_EventDisplay = YTS_EventLog("GUI - Session Code found in INI, loading it into GUI", $V2M_EventDisplay, '9')
			GUICtrlSetData($V2M_GUI[12] & @CRLF, IniRead($AppINI, "V2M_Server", "SESSION_CODE", ""))
			GUICtrlSetState($V2M_GUI[12], $GUI_DISABLE) ;disable the session code box after setting from INI
			GUICtrlSetState($V2M_GUI[38], $GUI_DISABLE) ;disable the random session code checkbox
		Else
			$V2M_EventDisplay = YTS_EventLog("GUI - Session Code NOT found in INI, generating random code", $V2M_EventDisplay, '9')
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

	; Show the GUI window
	If ($V2M_Status[5][1] + $V2M_Status[5][2] + $V2M_Status[5][3]) > 0 Then
		$V2M_EventDisplay = YTS_EventLog("GUI - Showing the main window (more than one tab visable)", $V2M_EventDisplay, '4')
		;		GUISetState(@SW_SHOW, $V2M_GUI_MainTitle)
		;		TrayItemSetState($V2M_Tray[3], $TRAY_CHECKED)
	Else
		$V2M_EventDisplay = YTS_EventLog("GUI - No Tabs visable in the main GUI, VNC2Me will now exit", $V2M_EventDisplay, '2')
		TrayTip(_Translate($V2M_GUI_Language, "TRAYTIP_APP_EXITING_TITLE", "APP_EXITING_TITLE"), _Translate($V2M_GUI_Language, "TRAYTIP_APP_EXITING_LINE1", "") & @CR & _Translate($V2M_GUI_Language, "TRAYTIP_APP_EXITING_LINE2", ""), 30)
		MsgBox(0, "What ?", "No VNC files found, exiting", 10)
		$V2M_Exit = 1
	EndIf
	$V2M_Status[2][1] = 'show'

	;
	;=========================================================================================================================================================
	; Create the mini GUI
	;=========================================================================================================================================================

	$V2M_GUI_Mini = GUICreate($V2M_GUI_MiniTitle, $V2M_GUI[5], $V2M_GUI[6], ((@DesktopWidth - $V2M_GUI[5]) / 2), 0, 2147483648, BitOR(128, 8))
	$V2M_GUI[31] = GUICtrlCreateButton(IniRead($AppINI, $V2M_GUI_Language, "MINI_BTN_EXIT", " C L O S E   R E M O T E   S E S S I O N "), 0, 0, $V2M_GUI[5], 20)
	GUICtrlSetTip(-1, IniRead($AppINI, $V2M_GUI_Language, "MINI_BTN_EXIT_TIP", "EXIT VNC2ME"))
	Global $StatusBar_Mini_Parts[3] = [50, $V2M_GUI[5] - 60, -1], $StatusBar_Text[3] = [@TAB & "", @TAB & @TAB & "", ""]
	;$StatusBar_Mini_Parts[2] = $V2M_GUI[5] - 60
	$V2M_GUI[42] = _GUICtrlStatusBar_Create($V2M_GUI_Mini, $StatusBar_Mini_Parts, $StatusBar_Text, $SBARS_TOOLTIPS)

	GUISetState(@SW_HIDE, $V2M_GUI_MiniTitle)

	;
	;=========================================================================================================================================================
	; Create the debug GUI
	If $V2M_GUI_DebugHeight < 100 Then $V2M_GUI_DebugHeight = 100

	$V2M_GUI_Debug = GUICreate($V2M_GUI_DebugTitle, $V2M_GUI_DebugWidth, $V2M_GUI_DebugHeight, (@DesktopWidth - $V2M_GUI_DebugWidth), (@DesktopHeight - $V2M_GUI_DebugHeight - 30), -1, BitOR(128, 8))

	$V2M_GUI_DebugOutputEdit = GUICtrlCreateEdit("", 0, 0, $V2M_GUI_DebugWidth, $V2M_GUI_DebugHeight - 30, BitOR(4096, 2097152, 1048576, 64, 128, 2048))

	$CurLeft = 20
	$V2M_GUI[28] = GUICtrlCreateButton(_Translate($V2M_GUI_Language, "DEBUG_BTN_START", "SSH ONLY"), $CurLeft, $V2M_GUI_DebugHeight - 24, 80, 20)
	$CurLeft = $CurLeft + 90
	$V2M_GUI[29] = GUICtrlCreateButton(_Translate($V2M_GUI_Language, "DEBUG_BTN_STOP", "STOP SSH"), $CurLeft, $V2M_GUI_DebugHeight - 24, 60, 20)
	$CurLeft = $CurLeft + 80
	$V2M_GUI[30] = GUICtrlCreateButton(_Translate($V2M_GUI_Language, "DEBUG_BTN_COPY", "DEBUG > CLIPBOARD"), $CurLeft, $V2M_GUI_DebugHeight - 24, 160, 20)

	GUISwitch($V2M_GUI_Debug)
	GUISetState(@SW_HIDE, $V2M_GUI_DebugTitle)


	;
	;=========================================================================================================================================================
	; Create the Disclaimer GUI

	If FileExists(@ScriptDir & "\disclaimer.htm") Then
		_IEErrorHandlerRegister()

		$oIE = _IECreateEmbedded()
		$V2M_GUI_Disclaimer = GUICreate("Embedded Web control Test", $V2M_GUI_DisclaimerWidth, @DesktopHeight - 100, (@DesktopWidth - $V2M_GUI_DisclaimerWidth) / 2, 10, $WS_OVERLAPPEDWINDOW + $WS_VISIBLE + $WS_CLIPSIBLINGS + $WS_CLIPCHILDREN, BitOR(128, 8), $V2M_GUI_Main)
		$GUIActiveX = GUICtrlCreateObj($oIE, 10, 10, $V2M_GUI_DisclaimerWidth - 20, @DesktopHeight - 150)

		$CurLeft = 20
		$V2M_GUI[61] = GUICtrlCreateButton(_Translate($V2M_GUI_Language, "BTN_DISCLAIMER_ACCEPT", "ACCEPT"), $CurLeft, @DesktopHeight - 124, 80, 20)
		$CurLeft = $CurLeft + 90
		$V2M_GUI[62] = GUICtrlCreateButton(_Translate($V2M_GUI_Language, "BTN_DISCLAIMER_REJECT", "REJECT"), $CurLeft, @DesktopHeight - 124, 60, 20)
		$CurLeft = $CurLeft + 80
		$V2M_GUI[63] = GUICtrlCreateButton(_Translate($V2M_GUI_Language, "BTN_DISCLAIMER_EXIT", "EXIT VNC2Me"), $CurLeft, @DesktopHeight - 124, 160, 20)
		GUISetState(@SW_SHOWDEFAULT, $V2M_GUI_Disclaimer) ;Show GUI
		_IENavigate($oIE, @ScriptDir & "\disclaimer.htm")
	Else
		$V2M_GUI_Disclaimer = 1
		$V2M_GUI[61] = 1
		$V2M_GUI[62] = 1
		$V2M_GUI[63] = 1
		GUISetState(@SW_SHOW, $V2M_GUI_Main)
		TrayItemSetState($V2M_Tray[3], $TRAY_CHECKED)
	EndIf

Else
	$V2M_EventDisplay = YTS_EventLog("GUI - $V2M_NoGUI <> 0", $V2M_EventDisplay, '9')
EndIf