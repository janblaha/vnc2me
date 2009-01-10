#Region --- Script patched by FreeStyle code Start 20.07.2008 - 11:15:29
 
#EndRegion --- Script patched by FreeStyle code End
;===============================================================================
;
; Description:		Session Timer Handling Function
; Parameter(s):		$TimerAction	=	Start	=	Start or INIT the timer functions
;														Loading Global $V2M_SessionTimeStart with hours:mins:sec of call
;										Stop	=	Stop the timer function
;														Loading Global $V2M_SessionTimeEnd with hours:mins:sec of call
;										Read	=	Reads the Session Times and returns
;					$JDs_debug_only	=	0, text is display in statusbar. else, only sent to debug dll
; Requirement(s):	
; Return Value(s):	$V2M_EventDisplay
; Author(s):		Jim Dolby
; Note(s):			
;
;===============================================================================

Func V2M_Timer($TimerAction = 'Start')
	Local $iSec, $iMin, $iHour, $ReadTicks, $V2M_TotalTicks
	If $TimerAction = "Start" Then
		if $V2M_TimerStarted = 0 then
			$V2M_TimerStartTicks = TimerInit()
			$V2M_SessionTimeStart = @HOUR & ":" & @MIN & ":" & @SEC
			$V2M_TimerStarted = 1
			Return $V2M_SessionTimeStart
		EndIf
	ElseIf $TimerAction = "Stop" And $V2M_TimerStarted = 0 Then
		Return 0
	ElseIf $TimerAction = "Stop" And $V2M_TimerStarted = 1 Then
		$V2M_TotalTicks = TimerDiff($V2M_TimerStartTicks)
		_TicksToTime(Int($V2M_TotalTicks), $iHour, $iMin, $iSec)
		$V2M_TimerTotal = StringFormat("%02i:%02i:%02i", $iHour, $iMin, $iSec)
		$V2M_SessionTimeEnd = @HOUR & ":" & @MIN & ":" & @SEC
		Return $V2M_TimerTotal
	ElseIf $TimerAction = "Read" Then
		_TicksToTime(Int(TimerDiff($V2M_TimerStartTicks)), $iHour, $iMin, $iSec)
		$ReadTicks = StringFormat("%02i:%02i:%02i", $iHour, $iMin, $iSec)
		Return $ReadTicks
	EndIf
EndFunc

;
;=========================================================================================================================================================
;


#Region --- Script patched by FreeStyle code Start 06.09.2008 - 20:04:01

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


#EndRegion --- Script patched by FreeStyle code End
