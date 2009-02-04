#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.2.8.1
 Author:         JDaus

 Script Function:
	Setup all Global Vars for including into VNC2Me.

#ce ----------------------------------------------------------------------------
Const $SPI_SETMOUSESONAR =4125 
Const $SPIF_DONT_UPDATE_PROFILE =0 
Const $SPIF_SENDCHANGE =2 
Const $SPIF_SENDWININICHANGE =2 
Const $SPIF_UPDATEINIFILE =1 

Const $GUI_SS_DEFAULT_RADIO = 0
Const $GUI_ENABLE = 64
Const $GUI_DISABLE = 128
Const $GUI_FOCUS = 256
Const $GUI_DEFBUTTON = 512

; declare Main GUI Language
Global $V2M_GUI_Language = "Lang_"&IniRead(@ScriptDir & "\vnc2me_sc.ini", "Common", "LANGUAGE", "")
; Program Title's, Version, etc
Global $V2M_Version = FileGetVersion(@ScriptFullPath)
Global $V2M_Name = IniRead(@ScriptDir & "\vnc2me_sc.ini", "Common", "APPName", "VNC2Me")
Global $V2M_GUI_MainTitle = $V2M_Name & " " & $V2M_Version
Global $V2M_GUI_MiniTitle = "V2M"
Global $V2M_GUI_DebugTitle = "V2M - Debug output"
Global $V2M_cmdline[10]

Global $V2MPortMin = 20000				; Port ranges for session ID's
Global $V2MPortMax = 30000				; Port ranges for session ID's
Global $V2M_SessionCode					; Session code from input or generated between the above two numbers
Global $V2M_SC_SsnCodeRead				; Session code read from the input on SC Tab
Global $V2MGUITimer = 0					; has the Timer been started yet ???
;Global $V2M_EventLog					; holds current event displayed in status
Global $V2M_VNC_PasswordRegAdded		; when password is added to registry
Global $V2M_Exit						; Exit out, close application cleanly
Global $V2M_VNC_SC						; which VNC server Application is used
Global $V2M_VNC_SVR
Global $V2M_VNC_VWR

Global $V2M_GUI_Main
Global $V2M_GUI_DebugOutputEdit
Global $V2M_GUI_Mini

;declare host, user & pass, if include is commented out, script asks for them.
Global $V2M_SSH[30]
$V2M_SSH[1] = IniRead(@ScriptDir & "\vnc2me_sc.ini", "V2M_Server", "Hostname", "")			;SSH_Hostname
$V2M_SSH[2] = IniRead(@ScriptDir & "\vnc2me_sc.ini", "V2M_Server", "Username", "")			;SSH_Username
$V2M_SSH[3] = IniRead(@ScriptDir & "\vnc2me_sc.ini", "V2M_Server", "Password", "")			;SSH_Password

; declare VARS for searching stdout & stderr
;$V2M_SSH[8]		;V2M_SSH_ReadCharsWaiting
;$V2M_SSH[9]		;V2M_SSH_ErrCharsWaiting
$V2M_SSH[11] = IniRead(@ScriptDir & "\vnc2me_sc.ini", "V2M_Server", "DetectLogin", ".*ogin.*")							;what string to use to detect login
$V2M_SSH[13] = IniRead(@ScriptDir & "\vnc2me_sc.ini", "V2M_Server", "DetectPassword", ".*assword.*")							;what string to use to detect password
$V2M_SSH[15] = IniRead(@ScriptDir & "\vnc2me_sc.ini", "V2M_Server", "DetectHostKey", ".*host key is not cached.*")			;what string to use to detect Host key not cached
$V2M_SSH[17] = IniRead(@ScriptDir & "\vnc2me_sc.ini", "V2M_Server", "DetectPortRefused", ".*refused.*")						;what string to use to detect when things are refused
$V2M_SSH[19] = IniRead(@ScriptDir & "\vnc2me_sc.ini", "V2M_Server", "DetectPortClosed", ".*Forwarded port closed.*")		;what string to use to detect when port closed, to start VNC again
$V2M_SSH[21] = IniRead(@ScriptDir & "\vnc2me_sc.ini", "V2M_Server", "DetectStableSSH", ".*Access granted.*")					;what string to use to detect initial stable connection
$V2M_SSH[23] = IniRead(@ScriptDir & "\vnc2me_sc.ini", "V2M_Server", "DetectDisconnectT2", ".*SSH_DISCONNECT_PROTOCOL_ERROR.*")					;what string to use to detect initial stable connection
$V2M_SSH[25] = IniRead(@ScriptDir & "\vnc2me_sc.ini", "V2M_Server", "DetectAES256", ".*Initialised AES-256.*")					;what string to use to detect initial stable connection
;$V2M_SSH[12]			; ???
;$V2M_SSH[14]			; ???
;$V2M_SSH[16]				; ???
;$V2M_SSH[18]			; ???
;$V2M_SSH[20]
;$V2M_SSH[22]				; ???
;$V2M_LoopCount					; how many loops have we done (approximated to seconds - not quite)

; the following variables are for future use, to minimise the use of other variables

Global $V2M_Status[4][14]				; Status of [1]   [1] is ConnectType (SC, SVR, VWR, VWRSVR), [2] is enabledebuging, [3] is passcount
										; Status of [2] is state of each GUI [1]=main, [2]=mini, [3]=debug, [4]=timer, 1 is active, 0 is inactive
										; Status of [3] is state of connection [1]=sshwanted, [2]=sshstarted, [3]=sshconnected, [4]=scwanted, [5]=scstarted, [6]=SVRwanted, [7]SVRstarted, [8]=vwrscwanted, [9]vwrSVRwanted, [10]=vwrstarted, [11]=tabsc, [12]=tabsvr, [13]=tabvwr
										; Status of [4] is 
										; Status of [5] is 
										; Status of [6] is 
$V2M_Status[1][3] = 0


; Declare Main GUI dimensions
Global $V2M_GUI[60]
$V2M_GUI[1] = 420			; width of main GUI
$V2M_GUI[2] = 200			; height of main GUI
$V2M_GUI[3] = $V2M_GUI[1] - 20			; width of TAB in main GUI
$V2M_GUI[4] = $V2M_GUI[2] - 75		; Height of TAB in main GUI
; Declare Mini GUI dimensions
$V2M_GUI[5] = 325			; width of mini GUI
$V2M_GUI[6] = 42			; height of mini GUI




;Tray Icon Controls
Global $V2M_Tray[10]
;$V2M_Tray[1]		;Tray_Exit
;$V2M_Tray[2]		;Tray_MenuShow
;$V2M_Tray[3]		;Tray_Exit
;$V2M_Tray[4]		;Tray_Exit
;$V2M_Tray[5]		;Tray_Exit
;Global $V2M_Tray_About
;Global $V2M_Tray_GUIShowMini
;Global $V2M_Tray_GUIShowTimer
;Global $V2M_Tray_GUIShowDebug
;Global $V2M_Tray_GUIShowNone

;misc
Global $BaseLeft
Global $BaseTop
Global $CurLeft
Global $CurTop

; is used by the session timer functions
Global $V2M_Timer[7]				;[1]=TimerTotal, [2]=TimerStarted, [3]=SessionTimeStart, [4]=SessionTimeEnd, [5]=TimerStartTicks, [6]=TimerTotalTicks
Global $V2M_LoopCount[3]				;counts to ten loops through program before checking stdin, stdout & stderr
Global $V2M_MsgBox
Global $V2M_GUI_Msg
Global $V2M_TrayMsg
Global $clipboard
Global $V2M_EventDisplay				; Current Event being displayed (stops repeating same event)


Global $V2M_ProcessIDs[5] ;[1]=ssh, [2]=vwr, [3]=sc, [4]=svr



;Global $V2M_EventLog

;Global $V2M_SSHStarted					; has SSH process been started yet ???
;Global $V2M_GUI_MainSwap				;???
;Global $V2M_GUI_MiniNoTransparency
;Dim $V2M_SSH_ProcessID
;Global $V2M_SSH_PortFwdDirection
;Dim $V2M_VNC_SCStart
;Dim $V2M_VNC_SVRStart
;Dim $V2M_VNC_SCStarted
;Dim $V2M_VNC_SVRStarted

; Declare Viewer Tab VARs to stop errors on removal of GUI
;Dim $V2M_GUI[10]
;Dim $V2M_GUI[11]
;Dim $V2M_GUI[12]
;Dim $V2M_GUI[13]

;GUI ControlID's
;Dim $V2M_GUI[7] 		;GUI_MainFileMenu
;Dim $V2M_GUI[8]		;GUI_MiniStatusBar
;Dim $V2M_GUI[9]		;GUI_MainStatusBar
;Dim $V2M_GUI[10]		;GUI_VWR_ButtonConnect
;Dim $V2M_GUI[11]		;GUI_VWR_ButtonStop
;Dim $V2M_GUI[12]		;GUI_VWR_InputCode
;Dim $V2M_GUI[13]		;GUI_VWR_TAB
;Dim $V2M_GUI[14]		;GUI_MainHelpMenu
;Dim $V2M_GUI[15]		;GUI_MainAbout
;Dim $V2M_GUI[16]		;GUI_MainTab
;Dim $V2M_GUI[17]		;GUI_MainButtonExit
;Dim $V2M_GUI[18]		;GUI_SC_TAB
;Dim $V2M_GUI[19]		;GUI_SC_InputCode
;Dim $V2M_GUI[20]		;GUI_SC_ButtonConnect
;Dim $V2M_GUI[21]		;GUI_SC_ButtonStop
;Dim $V2M_GUI[22]		;GUI_MiniFileMenu
;Dim $V2M_GUI[23]		;GUI_MiniSwap
;Dim $V2M_GUI[24]		;GUI_MiniHelpMenu
;Dim $V2M_GUI[25]		;GUI_MiniAbout
;Dim $V2M_GUI[26]		;GUI_MiniSessionCode
;Dim $V2M_GUI[27]		;GUI_Debug
;Dim $V2M_GUI[28]		;GUI_DebugButtonConnect
;Dim $V2M_GUI[29]		;GUI_DebugButtonStop
;Dim $V2M_GUI[30]		;GUI_DebugButtonCopy
;Dim $V2M_GUI[31]		;GUI_MiniButtonExit
;Dim $V2M_GUI[32]		;GUI_MainMenuExit
;Dim $V2M_GUI[33]		;GUI_MainDebugChbx
;Dim $V2M_GUI[34]		;GUI_SVR_TAB
;Dim $V2M_GUI[35]		;GUI_SVR_InputCode
;Dim $V2M_GUI[36]		;GUI_SVR_ButtonConnect
;Dim $V2M_GUI[37]		;GUI_SVR_ButtonStop
;Dim $V2M_GUI[38]		;GUI_VWR_SsnRndChbx
;Dim $V2M_GUI[39]		;GUI_SVR_SsnRndChbx
;Dim $V2M_GUI[40]		;GUI_VWR_Radio_SC
;Dim $V2M_GUI[41]		;GUI_VWR_Radio_SVR
;Dim $V2M_GUI[50]		;GUI_UVNC_TAB
;Dim $V2M_GUI[51]		;GUI_UVNC_Address
;Dim $V2M_GUI[52]		;GUI_UVNC_Port
;Dim $V2M_GUI[53]		;GUI_UVNC_ButtonConnect
;Dim $V2M_GUI[54]		;GUI_UVNC_ButtonStop
;Dim $V2M_GUI[55]		;GUI_UVNC_




$V2M_VNC_SC = "V2Msc.exe"
$V2M_VNC_SVR = "spcwinv.exe"
$V2M_VNC_VWR = "v2mvwr.exe"

