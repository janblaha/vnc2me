

#Region --- Script analyzed by FreeStyle code Start 06.09.2008 - 20:06:11

#EndRegion --- Script analyzed by FreeStyle code End - no patching necessary


#Region --- Script analyzed by FreeStyle code Start 06.09.2008 - 20:04:22

#EndRegion --- Script analyzed by FreeStyle code End - no patching necessary


#Region --- Script analyzed by FreeStyle code Start 20.07.2008 - 11:15:10

#EndRegion --- Script analyzed by FreeStyle code End - no patching necessary
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

$V2M_GUI_Main = GUICreate($V2M_GUI_MainTitle, $V2M_GUI_MainWidth, $V2M_GUI_MainHeight, (@DesktopWidth - $V2M_GUI_MainWidth) / 2, (@DesktopHeight - $V2M_GUI_MainHeight) / 2)

GUISetIcon("v2m.ico")
$V2M_GUI_MainFileMenu = GUICtrlCreateMenu(IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "GUI_MNU_FILE", "File"))
$V2M_GUI_MainMenuExit = GUICtrlCreateMenuItem(IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "GUI_MNU_EXIT", "Exit"), $V2M_GUI_MainFileMenu)

$V2M_GUI_MainHelpMenu = GUICtrlCreateMenu(IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "GUI_MNU_HELP", "Help"))
$V2M_GUI_MainAbout = GUICtrlCreateMenuItem(IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "GUI_MNU_ABOUT", "About"), $V2M_GUI_MainHelpMenu)

$V2M_GUI_MainTab = GUICtrlCreateTab(10, 0, $V2M_GUI_MainTabWidth, $V2M_GUI_MainTabHeight)

$BaseLeft = 20
$BaseTop = 35

$V2M_GUI_MainButtonExit = GUICtrlCreateButton(IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "MAIN_BTN_EXIT", "Exit"), $BaseLeft, $V2M_GUI_MainHeight - 70, 60, 20)
GUICtrlSetTip(-1,IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "MAIN_BTN_EXIT_TIP", "Exit the Application"))
$CurLeft = $BaseLeft + 80
If IniRead(@ScriptDir & "\vnc2me_sc.ini", "V2M_GUI", "MAIN_DEBUG_OPTIONS", "") <> 0 Then
	$V2M_GUI_DebugCheckbox = GUICtrlCreateCheckbox(IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "MAIN_DbgBox", "Debug"), $CurLeft, $V2M_GUI_MainHeight - 70)
	GUICtrlSetTip(-1,IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "MAIN_DBGBOX_TIP", "Display Debug Window"))
EndIf
$V2M_GUI_MainStatusBar = GUICtrlCreateEdit("", $BaseLeft - 20, $V2M_GUI_MainHeight - 40, $V2M_GUI_MainWidth, 21, BitOR(4096, 64, 2048))
GUICtrlSetTip(-1,IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "MAIN_STATUS_TIP", "Indicates Program's status"))

;
; Tab SC sharing
;
If FileExists(@ScriptDir & "\V2Msc.exe") Then
	$V2M_GUI_SC_ = GUICtrlCreateTabItem("  " & $V2M_GUI_MainLabelTab_SC & "  ")
	$CurLeft = $BaseLeft
	$CurTop = $BaseTop

	$CurLeft = $CurLeft + 10

	GUICtrlCreateLabel(IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "MAIN_SC_SSN", "Session Code"), $CurLeft, $CurTop + 3)
	$V2M_GUI_SC_InputCode = GUICtrlCreateInput("", $CurLeft + 80, $CurTop, 200)
	GUICtrlSetTip(-1,IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "MAIN_SC_SSN_TIP", "Input Session Code to connect"))
	$CurTop = $CurTop + 30
	$CurLeft = $CurLeft + 20
; Create a read-only edit control
; $V2M_GUI_SC_Edit = GUICtrlCreateEdit("", $CurLeft, $CurTop + 10, 323, 61, BitOR(4096, 2097152, 1048576, 64, 128, 2048))

; VNC Server spawn button
	$V2M_GUI_SC_ButtonConnect = GUICtrlCreateButton(IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "MAIN_SC_BTN_START", "Share Desktop"), $CurLeft, $V2M_GUI_MainTabHeight - 40, 120, 20)
	$CurLeft = $CurLeft + 140
	$V2M_GUI_SC_ButtonStop = GUICtrlCreateButton(IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "MAIN_SC_BTN_STOP", "Stop Sharing"), $CurLeft, $V2M_GUI_MainTabHeight - 40, 100, 20)
	If (IniRead(@ScriptDir & "\vnc2me_sc.ini", "V2M_Server", "SESSION_CODE", "") <> "") Then
		GUICtrlSetData($V2M_GUI_SC_InputCode & @CRLF, IniRead(@ScriptDir & "\vnc2me_sc.ini", "V2M_Server", "SESSION_CODE", ""))
		GUICtrlSetState($V2M_GUI_SC_InputCode, 128)
	EndIf
EndIf
;
; Tab Collaboration
;
If FileExists(@ScriptDir & "\V2Msrv.exe") Then
	$V2M_GUI_SRV_ = GUICtrlCreateTabItem("  " & $V2M_GUI_MainLabelTab_SRV & "  ")
	$CurLeft = $BaseLeft
	$CurTop = $BaseTop

	$CurLeft = $CurLeft + 10
	GUICtrlCreateLabel(IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "MAIN_SRV_SSN", "Session Code"), $CurLeft, $CurTop + 3)
	$CurLeft = $CurLeft + 80
	$V2M_GUI_SRV_InputCode = GUICtrlCreateInput("", $CurLeft, $CurTop, 200, '', BitOR(4096, 64))
	GUICtrlSetTip(-1,IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "MAIN_SRV_SSN_TIP", "Input Session Code to Start Sharing Your Desktop"))
	$CurLeft = $CurLeft + 220

	$CurTop = $CurTop + 30
	$CurLeft = $BaseLeft + 30
	$V2M_GUI_SRV_ButtonConnect = GUICtrlCreateButton(IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "MAIN_SRV_BTN_START", "Start Collab"), $CurLeft, $V2M_GUI_MainTabHeight - 40, 120, 20)
	$CurLeft = $CurLeft + 140
	$V2M_GUI_SRV_ButtonStop = GUICtrlCreateButton(IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "MAIN_SRV_BTN_STOP", "Stop Collab"), $CurLeft, $V2M_GUI_MainTabHeight - 40, 100, 20)
	If (IniRead(@ScriptDir & "\vnc2me_sc.ini", "V2M_Server", "SESSION_CODE", "") <> "") Then
		GUICtrlSetData($V2M_GUI_SRV_InputCode & @CRLF, IniRead(@ScriptDir & "\vnc2me_sc.ini", "V2M_Server", "SESSION_CODE", ""))
		GUICtrlSetState($V2M_GUI_SRV_InputCode, 128)
	EndIf
EndIf

;
; Tab viewing
;
If FileExists(@ScriptDir & "\V2Mvwr.exe") Then
	$V2M_GUI_VWR_ = GUICtrlCreateTabItem("  " & $V2M_GUI_MainLabelTab_VWR & "  ")
	$CurLeft = $BaseLeft
	$CurTop = $BaseTop

	$CurLeft = $CurLeft + 10
	GUICtrlCreateLabel(IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "MAIN_VWR_SSN", "Session Code"), $CurLeft, $CurTop + 3)
	$CurLeft = $CurLeft + 80
	$V2M_GUI_VWR_InputCode = GUICtrlCreateInput("", $CurLeft, $CurTop, 200, '', BitOR(4096, 64))
	GUICtrlSetTip(-1,IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "MAIN_VWR_SSN_TIP", "Input Session Code to connect"))
	$CurLeft = $CurLeft + 220
	$V2M_GUI_VWR_SsnRndChbx = GUICtrlCreateCheckbox(IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "MAIN_VWR_RND", "Random"), $CurLeft, $CurTop, $V2M_GUI_MainTabWidth - $CurLeft)
	GUICtrlSetTip(-1,IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "MAIN_VWR_RND_TIP", "Generate Random Session Code"))
	$CurLeft = $BaseLeft + 30
	$CurTop = $CurTop + 25
	GUIStartGroup()
	If (IniRead(@ScriptDir & "\vnc2me_sc.ini", "V2M_GUI", "MAIN_VWR_CONNECTO", "SC") = 'SRV') Then
		$V2M_MAIN_VWR_CONNECTO = 'SRV'
	ElseIf (IniRead(@ScriptDir & "\vnc2me_sc.ini", "V2M_GUI", "MAIN_VWR_CONNECTO", "") = 'CHOOSE') Then
		$V2M_MAIN_VWR_CONNECTO = 'CHOOSE'
		$MAIN_VWR_RADIO_SC = GUICtrlCreateRadio ("Connect to &SC", $CurLeft, $CurTop, 100, 20)
		$CurLeft = $CurLeft + 110
		$MAIN_VWR_RADIO_SRV = GUICtrlCreateRadio ("Connect to &SRV", $CurLeft, $CurTop, 100, 20)
	Else
		$V2M_MAIN_VWR_CONNECTO = 'SC'
	EndIf
	$CurTop = $CurTop + 10
	$CurLeft = $BaseLeft + 30
	$V2M_GUI_VWR_ButtonConnect = GUICtrlCreateButton(IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "MAIN_VWR_BTN_START", "View Desktop"), $CurLeft, $V2M_GUI_MainTabHeight - 40, 120, 20)
	$CurLeft = $CurLeft + 140
	$V2M_GUI_VWR_ButtonStop = GUICtrlCreateButton(IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "MAIN_VWR_BTN_STOP", "Stop Viewing"), $CurLeft, $V2M_GUI_MainTabHeight - 40, 100, 20)
	If (IniRead(@ScriptDir & "\vnc2me_sc.ini", "V2M_Server", "SESSION_CODE", "") <> "") Then
		GUICtrlSetData($V2M_GUI_VWR_InputCode & @CRLF, IniRead(@ScriptDir & "\vnc2me_sc.ini", "V2M_Server", "SESSION_CODE", ""))
		GUICtrlSetState($V2M_GUI_VWR_InputCode, 128)
		GUICtrlSetState($V2M_GUI_VWR_SsnRndChbx, 128)
	EndIf
EndIf

; Show the GUI window
JDs_debug("GUI Main Starting")
GUISetState(@SW_SHOW, $V2M_GUI_MainTitle)
;
;=========================================================================================================================================================
; Create the mini GUI
$V2M_GUI_Mini = GUICreate($V2M_GUI_MiniTitle, $V2M_GUI_MiniWidth, $V2M_GUI_MiniHeight, ((@DesktopWidth / 2) - ($V2M_GUI_MiniWidth / 2)), 0, 2147483648, BitOR(128, 8))

;$V2M_GUI_MiniFileMenu = GUICtrlCreateMenu(IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "GUI_MNU_FILE", "File"))
;$V2M_GUI_MiniSwap = GUICtrlCreateMenuItem(IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "GUI_MNU_SWAP", "Show Main Window"), $V2M_GUI_MiniFileMenu)
;
;$V2M_GUI_MiniHelpMenu = GUICtrlCreateMenu(IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "GUI_MNU_HELP", "Help"))
;$V2M_GUI_MiniAbout = GUICtrlCreateMenuItem(IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "GUI_MNU_ABOUT", "About"), $V2M_GUI_MiniHelpMenu)

;$V2M_GUI_MiniFileMenu = GUICtrlCreateMenu("File")
;$V2M_GUI_MiniSwap = GUICtrlCreateMenuItem("Show Main Window", $V2M_GUI_MiniFileMenu)

;$V2M_GUI_MiniHelpMenu = GUICtrlCreateMenu("Help")
;$V2M_GUI_MiniAbout = GUICtrlCreateMenuItem("About", $V2M_GUI_MiniHelpMenu)

$V2M_GUI_MiniButtonExit = GUICtrlCreateButton(IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "MINI_BTN_EXIT", " C l o s e   R e m o t e   S e s s i o n "), 0, 0, $V2M_GUI_MiniWidth, 20)
GUICtrlSetTip(-1, IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "MINI_BTN_EXIT_TIP", "Exit Application"))
$V2M_GUI_MiniStatusBar = GUICtrlCreateEdit("", 0, 20, $V2M_GUI_MiniWidth - 50, 21, BitOR(4096, 64, 2048))
GUICtrlSetTip(-1,IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "MINI_STATUS_TIP", "Status & Events"))
$V2M_GUI_MiniSessionCode = GUICtrlCreateEdit("", $V2M_GUI_MiniWidth - 50, 20, 50, 21, BitOR(4096, 64, 2048))
GUICtrlSetTip(-1, IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "MINI_SESSION_TIP", "VNC2Me Session Code"))


GUISetState(@SW_HIDE, $V2M_GUI_MiniTitle)

;
;=========================================================================================================================================================
; Create the debug GUI
$V2M_GUI_Debug = GUICreate($V2M_GUI_DebugTitle, $V2M_GUI_MainWidth, $V2M_GUI_MainHeight + 8, ((@DesktopWidth - $V2M_GUI_MainWidth) / 2) + $V2M_GUI_MainWidth + 5, ((@DesktopHeight - $V2M_GUI_MainHeight) / 2), -1, BitOR(128, 8))

$V2M_GUI_DebugOutputEdit = GUICtrlCreateEdit("", 0, 0, $V2M_GUI_MainWidth, $V2M_GUI_MainHeight - 30, BitOR(4096, 2097152, 1048576, 64, 128, 2048))

$CurLeft = 20
$V2M_GUI_DebugButtonConnect = GUICtrlCreateButton("SSH Only", $CurLeft, $V2M_GUI_MainHeight - 20, 80, 20)
$CurLeft = $CurLeft + 90
$V2M_GUI_DebugButtonStop = GUICtrlCreateButton("Stop SSH", $CurLeft, $V2M_GUI_MainHeight - 20, 60, 20)
$CurLeft = $CurLeft + 80
$V2M_GUI_DebugButtonCopy = GUICtrlCreateButton("Debug > clipboard", $CurLeft, $V2M_GUI_MainHeight - 20, 120, 20)

GUISwitch($V2M_GUI_Debug)
GUISetState(@SW_HIDE, $V2M_GUI_DebugTitle )



GUICtrlSetState($V2M_GUI_VWR_SsnRndChbx, 1)
