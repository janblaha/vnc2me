

#Region --- Script analyzed by FreeStyle code Start 06.09.2008 - 20:04:16

#EndRegion --- Script analyzed by FreeStyle code End - no patching necessary


#Region --- Script analyzed by FreeStyle code Start 20.07.2008 - 11:14:59

#EndRegion --- Script analyzed by FreeStyle code End - no patching necessary
#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.2.8.1
 Author:         JDaus

 Script Function:
	Setup all Global Vars for including into VNC2Me.

#ce ----------------------------------------------------------------------------

; declare Main GUI Language
Dim $V2M_GUI_Language = IniRead(@ScriptDir & "\vnc2me_sc.ini", "Common", "LANGUAGE", "Lang_English")

; Program Title's, Version, etc
Global $V2M_Version = FileGetVersion(@ScriptFullPath)
Global $V2M_Name = IniRead(@ScriptDir & "\vnc2me_sc.ini", "Common", "APPName", "VNC2Me")
Global $V2M_GUI_MainTitle = $V2M_Name & " " & $V2M_Version
Global $V2M_GUI_MiniTitle = "V2M"
Global $V2M_GUI_DebugTitle = "V2M - Debug output"

Global $V2MPortMin = 20000				; Port ranges for session ID's
Global $V2MPortMax = 30000				; Port ranges for session ID's
Global $V2M_SessionCode					; Session code from input or generated between the above two numbers
Global $V2M_SC_SsnCodeRead				; Session code read from the input on SC Tab
Global $V2MGUITimer = 0					; has the Timer been started yet ???
Global $V2M_EventLog					; holds current event displayed in status
Global $V2M_VNC_PasswordRegAdded		; when password is added to registry
Global $V2M_Exit						; Exit out, close application cleanly
Global $V2M_VNC_SC						; which VNC server Application is used
Global $V2M_AutoReconnect				; if disconnected (or vnc closes) reconnects if 1
Global $V2M_SSH_Port = 443				; what port is ssh connecting to ?

; the following variables are for future use, to minimise the use of other variables
Global $V2M_Status[5][3]					; Status of [0] is ConnectType (SC, SRV, VWR, VWRSRV)
										; Status of [1] is state of each GUI [0]=main, [1]=mini, [2]=debug
										; Status of [2] is 
										; Status of [3] is 
										; Status of [4] is 
										; Status of [5] is 
;Global $V2M_Status[0][0]					; What type of Connection is being established

; Declare Main GUI dimensions
Dim $V2M_GUI_MainWidth = 420			; width of main GUI
Dim $V2M_GUI_MainHeight = 200			; height of main GUI
Dim $V2M_GUI_MainTabWidth = $V2M_GUI_MainWidth - 20			; width of TAB in main GUI
Dim $V2M_GUI_MainTabHeight = $V2M_GUI_MainHeight - 75		; Height of TAB in main GUI
; Declare Mini GUI dimensions
Dim $V2M_GUI_MiniWidth = 275			; width of mini GUI
Dim $V2M_GUI_MiniHeight = 40			; height of mini GUI


;GUI ControlID's
Dim $V2M_GUI_MainFileMenu
Dim $V2M_GUI_MiniStatusBar
Dim $V2M_GUI_MainStatusBar
Dim $V2M_GUI_VWR_ButtonConnect
Dim $V2M_GUI_VWR_ButtonStop
Dim $V2M_GUI_VWR_InputCode
Dim $V2M_GUI_VWR_
Dim $V2M_GUI_MainHelpMenu
Dim $V2M_GUI_MainAbout
Dim $V2M_GUI_MainTab
Dim $V2M_GUI_MainButtonExit
Dim $V2M_GUI_SC_
Dim $V2M_GUI_SC_InputCode
Dim $V2M_GUI_SC_ButtonConnect
Dim $V2M_GUI_SC_ButtonStop
Dim $V2M_GUI_MiniFileMenu
Dim $V2M_GUI_MiniSwap
Dim $V2M_GUI_MiniHelpMenu
Dim $V2M_GUI_MiniAbout
Dim $V2M_GUI_MiniSessionCode
Dim $V2M_GUI_Debug
Dim $V2M_GUI_DebugButtonConnect
Dim $V2M_GUI_DebugButtonStop
Dim $V2M_GUI_DebugButtonCopy
Dim $V2M_Tray_Exit
Dim $V2M_Tray_GUISwap

;misc
Dim $BaseLeft
Dim $BaseTop
Dim $CurLeft
Dim $CurTop

; is used by the session timer functions
Global $V2M_TimerTotal = 0, $V2M_TimerStarted = 0, $V2M_SessionTimeStart = 0, $V2M_SessionTimeEnd = 0, $V2M_TimerStartTicks = 0

Dim $V2M_LoopCount													;counts to ten loops through program before checking stdin, stdout & stderr

Dim $V2M_SSH_ReadCharsWaiting
Dim $V2M_SSH_ErrCharsWaiting
Dim $currentRead
Dim $currentErr
Dim $V2M_SSH_VNCDisconnect
Dim $V2M_MsgBox

Dim $V2M_GUI_Msg
Dim $V2M_TrayMsg
Dim $clipboard
Dim $V2M_VNC_ViewerProcessID

; declare VARS for searching stdout & stderr
Dim $V2M_SSH_DetectUsername = ".*ogin.*"							;what string to use to detect login
Dim $V2M_SSH_DetectPassword = ".*assword.*"							;what string to use to detect password
Dim $V2M_SSH_DetectNoHostKey = ".*host key is not cached.*"			;what string to use to detect Host key not cached
Dim $V2M_SSH_DetectPortRefused = ".*refused.*"						;what string to use to detect when things are refused
Dim $V2M_SSH_DetectVNCDisconnect = ".*Forwarded port closed.*"		;what string to use to detect when port closed, to start VNC again
Dim $V2M_SSH_DetectConnected = ".*Allocated pty.*"					;what string to use to detect initial stable connection

Dim $V2M_SSH_ReadUsername			; ???
Dim $V2M_SSH_ReadPassword			; ???
Dim $V2M_SSH_ErrHostKey				; ???
Dim $V2M_SSH_PortRefused			; ???
Dim $V2M_SSH_Connected				; ???
Dim $V2M_LoopCount					; how many loops have we done (approximated to seconds - not quite)

Dim $V2M_EventDisplay				; Current Event being displayed (stops repeating same event)
;Dim $V2M_EventLog

Dim $V2M_SSHStarted					; has SSH process been started yet ???
Dim $V2M_SSH_ProcessID				; Contains Process ID for Plink.exe
Dim $V2M_VNC_ProcessID				; Contains Process ID for VNC executables (not currently useful, but hopefully will be later)
Dim $V2M_GUI_MainSwap				;???
Dim $V2M_GUI_MiniNoTransparency
Dim $V2M_GUI_MainMenuExit
Dim $V2M_SSH_ProcessID
Dim $V2M_SSH_PortFwdDirection
Dim $V2M_VNC_SCStart
Dim $V2M_VNC_SRVStart
Dim $V2M_VNC_SCStarted
Dim $V2M_VNC_SRVStarted
Dim $V2M_GUI_DebugCheckbox
;Dim $V2M_GUI_DebugShow
Dim $V2M_GUI_VWR_SsnRndChbx_PreviousState = 0
Dim $V2M_GUI_VWR_SsnRndChbx

; Declare Viewer Tab VARs to stop errors on removal of GUI
Dim $V2M_GUI_VWR_
Dim $V2M_GUI_VWR_InputCode
Dim $V2M_GUI_VWR_SsnRndChbx
Dim $V2M_GUI_VWR_ButtonConnect
Dim $V2M_GUI_VWR_ButtonStop

Dim $V2M_GUI_SRV_
Dim $V2M_GUI_SRV_InputCode
Dim $V2M_GUI_SRV_ButtonConnect
Dim $V2M_GUI_SRV_ButtonStop



;Declare GUI Label VAR's
Dim $V2M_GUI_MainLabelTab_VWR = IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "GUI_TAB_VIEW", "View Desktop")
Dim $V2M_GUI_MainLabelTab_SRV = IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "GUI_TAB_SRV", "Start Collaboration")
Dim $V2M_GUI_MainLabelTab_SC = IniRead(@ScriptDir & "\vnc2me_sc.ini", $V2M_GUI_Language, "GUI_TAB_SC", "Share Desktop")
