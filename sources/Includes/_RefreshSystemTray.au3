; http://www.autoitscript.com/forum/index.php?showtopic=7404&hl=_RefreshSystemTray()

; ===================================================================
; _RefreshSystemTray($nDelay = 1000)
;
; Removes any dead icons from the notification area.
; Parameters:
;    $nDelay - IN/OPTIONAL - The delay to wait for the notification area to expand with Windows XP's
;        "Hide Inactive Icons" feature (In milliseconds).
; Returns:
;    Sets @error on failure:
;        1 - Tray couldn't be found.
;        2 - DllCall error.
; ===================================================================
Func _RefreshSystemTray($nDelay = 1000)
; Save Opt settings
    Local $oldMatchMode = Opt("WinTitleMatchMode", 4)
    Local $oldChildMode = Opt("WinSearchChildren", 1)
    Local $error = 0
    Do; Pseudo loop
        Local $hWnd = WinGetHandle("classname=TrayNotifyWnd")
        If @error Then
            $error = 1
            ExitLoop
        EndIf

        Local $hControl = ControlGetHandle($hWnd, "", "Button1")
        
    ; We're on XP and the Hide Inactive Icons button is there, so expand it
        If $hControl <> "" And ControlCommand($hWnd, "", $hControl, "IsVisible") Then
            ControlClick($hWnd, "", $hControl)
            Sleep($nDelay)
        EndIf
        
        Local $posStart = MouseGetPos()
        Local $posWin = WinGetPos($hWnd)    
        
        Local $y = $posWin[1]
        While $y < $posWin[3] + $posWin[1]
            Local $x = $posWin[0]
            While $x < $posWin[2] + $posWin[0]
                DllCall("user32.dll", "int", "SetCursorPos", "int", $x, "int", $y)
                If @error Then
                    $error = 2
                    ExitLoop 3; Jump out of While/While/Do
                EndIf
                $x = $x + 8
            WEnd
            $y = $y + 8
        WEnd
        DllCall("user32.dll", "int", "SetCursorPos", "int", $posStart[0], "int", $posStart[1])
    ; We're on XP so we need to hide the inactive icons again.
        If $hControl <> "" And ControlCommand($hWnd, "", $hControl, "IsVisible") Then
            ControlClick($hWnd, "", $hControl)
        EndIf
    Until 1
    
; Restore Opt settings
    Opt("WinTitleMatchMode", $oldMatchMode)
    Opt("WinSearchChildren", $oldChildMode)
    SetError($error)
EndFunc; _RefreshSystemTray()