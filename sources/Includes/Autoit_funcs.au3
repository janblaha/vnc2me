#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.0.0
 Author:         myName

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

; Script Start - Add your code below here
Global $Debug_SB
#Region --- Script patched by FreeStyle code Start 01.02.2009 - 08:58:04
Func _GUICtrlStatusBar_SetIcon($hWnd, $iPart, $hIcon = -1, $sIconFile = "")
	If $Debug_SB Then _GUICtrlStatusBar_ValidateClassName($hWnd)
	Local $tIcon, $result
	If $hIcon = -1 Then ; Remove Icon
		Return _SendMessage($hWnd, 1039, $iPart, $hIcon, 0, "wparam", "hwnd") <> 0
	ElseIf StringLen($sIconFile) > 0 Then ; set icon from file
		$tIcon = DllStructCreate("int")
		$result = DllCall("shell32.dll", "int", "ExtractIconEx", "str", $sIconFile, "int", $hIcon, "hwnd", 0, "ptr", DllStructGetPtr($tIcon), "int", 1)
		$result = $result[0]
		If $result > 0 Then $result = _SendMessage($hWnd, 1039, $iPart, DllStructGetData($tIcon, 1), 0, "wparam", "ptr")
		DllCall("user32.dll", "int", "DestroyIcon", "hwnd", DllStructGetData($tIcon, 1))
		Return $result <> 0
	Else ; set icon from icon handle
		Return _SendMessage($hWnd, 1039, $iPart, $hIcon) <> 0
	EndIf
EndFunc   ;==>_GUICtrlStatusBar_SetIcon
Func _GUICtrlStatusBar_SetText($hWnd, $sText = "", $iPart = 0, $iUFlag = 0)
	If $Debug_SB Then _GUICtrlStatusBar_ValidateClassName($hWnd)
	Local $ret, $struct_String, $sBuffer_pointer, $struct_MemMap, $Memory_pointer, $iBuffer
	Local $fUnicode = _GUICtrlStatusBar_GetUnicodeFormat($hWnd)
	$iBuffer = StringLen($sText) + 1
	If $fUnicode Then
		$iBuffer *= 2
		$struct_String = DllStructCreate("wchar Text[" & $iBuffer & "]")
	Else
		$struct_String = DllStructCreate("char Text[" & $iBuffer & "]")
	EndIf
	$sBuffer_pointer = DllStructGetPtr($struct_String)
	DllStructSetData($struct_String, "Text", $sText)
	If _GUICtrlStatusBar_IsSimple($hWnd) Then $iPart = 255
	If _WinAPI_InProcess($hWnd, $__ghSBLastWnd) Then
		If $fUnicode Then
			$ret = _SendMessage($hWnd, 1035, BitOR($iPart, $iUFlag), $sBuffer_pointer, 0, "wparam", "ptr")
		Else
			$ret = _SendMessage($hWnd, 1025, BitOR($iPart, $iUFlag), $sBuffer_pointer, 0, "wparam", "ptr")
		EndIf
	Else
		$Memory_pointer = _MemInit($hWnd, $iBuffer, $struct_MemMap)
		_MemWrite($struct_MemMap, $sBuffer_pointer)
		If $fUnicode Then
			$ret = _SendMessage($hWnd, 1035, BitOR($iPart, $iUFlag), $Memory_pointer, 0, "wparam", "ptr")
		Else
			$ret = _SendMessage($hWnd, 1025, BitOR($iPart, $iUFlag), $Memory_pointer, 0, "wparam", "ptr")
		EndIf
		_MemFree($struct_MemMap)
	EndIf
	Return $ret <> 0
EndFunc   ;==>_GUICtrlStatusBar_SetText
Func _WinAPI_LoadShell32Icon($iIconID)
	Local $iIcons, $tIcons, $pIcons
	$tIcons = DllStructCreate("int Data")
	$pIcons = DllStructGetPtr($tIcons)
	$iIcons = _WinAPI_ExtractIconEx("Shell32.dll", $iIconID, 0, $pIcons, 1)
	_WinAPI_Check("_Lib_GetShell32Icon", ($iIcons = 0), -1)
	Return DllStructGetData($tIcons, "Data")
EndFunc   ;==>_WinAPI_LoadShell32Icon
Func _GUICtrlStatusBar_GetUnicodeFormat($hWnd)
	If $Debug_SB Then _GUICtrlStatusBar_ValidateClassName($hWnd)
	Return _SendMessage($hWnd, 8198) <> 0
EndFunc   ;==>_GUICtrlStatusBar_GetUnicodeFormat
Func _GUICtrlStatusBar_IsSimple($hWnd)
	If $Debug_SB Then _GUICtrlStatusBar_ValidateClassName($hWnd)
	Return _SendMessage($hWnd, 1038) <> 0
EndFunc   ;==>_GUICtrlStatusBar_IsSimple
Func _GUICtrlStatusBar_ValidateClassName($hWnd)
	_GUICtrlStatusBar_DebugPrint("This is for debugging only, set the debug variable to false before submitting")
	_WinAPI_ValidateClassName($hWnd, $__STATUSBARCONSTANT_ClassName)
EndFunc   ;==>_GUICtrlStatusBar_ValidateClassName
Func _MemFree(ByRef $tMemMap)
	Local $hProcess, $pMemory, $bResult
	$pMemory = DllStructGetData($tMemMap, "Mem")
	$hProcess = DllStructGetData($tMemMap, "hProc")
	; Thanks to jpm for his tip on using @OSType instead of @OSVersion
	If @OSTYPE = "WIN32_WINDOWS" Then
		$bResult = _MemVirtualFree($pMemory, 0, 32768)
	Else
		$bResult = _MemVirtualFreeEx($hProcess, $pMemory, 0, 32768)
	EndIf
	_WinAPI_CloseHandle($hProcess)
	Return $bResult
EndFunc   ;==>_MemFree
Func _MemInit($hWnd, $iSize, ByRef $tMemMap)
	Local $iAccess, $iAlloc, $pMemory, $hProcess, $iProcessID
	_WinAPI_GetWindowThreadProcessId($hWnd, $iProcessID)
	If $iProcessID = 0 Then _MemShowError("_MemInit: Invalid window handle [0x" & Hex($hWnd) & "]")
	$iAccess = BitOR(8, 16, 32)
	$hProcess = _WinAPI_OpenProcess($iAccess, False, $iProcessID, True)
	; Thanks to jpm for his tip on using @OSType instead of @OSVersion
	If @OSTYPE = "WIN32_WINDOWS" Then
		$iAlloc = BitOR(8192, 4096, 134217728)
		$pMemory = _MemVirtualAlloc(0, $iSize, $iAlloc, 4)
	Else
		$iAlloc = BitOR(8192, 4096)
		$pMemory = _MemVirtualAllocEx($hProcess, 0, $iSize, $iAlloc, 4)
	EndIf
	If $pMemory = 0 Then _MemShowError("_MemInit: Unable to allocate memory")
	$tMemMap = DllStructCreate($tagMEMMAP)
	DllStructSetData($tMemMap, "hProc", $hProcess)
	DllStructSetData($tMemMap, "Size", $iSize)
	DllStructSetData($tMemMap, "Mem", $pMemory)
	Return $pMemory
EndFunc   ;==>_MemInit
Func _MemWrite(ByRef $tMemMap, $pSrce, $pDest = 0, $iSize = 0, $sSrce = "ptr")
	Local $iWritten
	If $pDest = 0 Then $pDest = DllStructGetData($tMemMap, "Mem")
	If $iSize = 0 Then $iSize = DllStructGetData($tMemMap, "Size")
	Return _WinAPI_WriteProcessMemory(DllStructGetData($tMemMap, "hProc"), $pDest, $pSrce, $iSize, $iWritten, $sSrce)
EndFunc   ;==>_MemWrite
Func _SendMessage($hWnd, $iMsg, $wParam = 0, $lParam = 0, $iReturn = 0, $wParamType = "wparam", $lParamType = "lparam", $sReturnType = "lparam")
	Local $aResult = DllCall("user32.dll", $sReturnType, "SendMessage", "hwnd", $hWnd, "int", $iMsg, $wParamType, $wParam, $lParamType, $lParam)
	If @error Then Return SetError(@error, @extended, "")
	If $iReturn >= 0 And $iReturn <= 4 Then Return $aResult[$iReturn]
	Return $aResult
EndFunc   ;==>_SendMessage
Func _WinAPI_Check($sFunction, $fError, $vError, $fTranslate = False)
	If $fError Then
		If $fTranslate Then $vError = _WinAPI_GetLastErrorMessage()
		_WinAPI_ShowError($sFunction & ": " & $vError)
	EndIf
EndFunc   ;==>_WinAPI_Check
Func _WinAPI_ExtractIconEx($sFile, $iIndex, $pLarge, $pSmall, $iIcons)
	Local $aResult
	$aResult = DllCall("Shell32.dll", "int", "ExtractIconEx", "str", $sFile, "int", $iIndex, "ptr", $pLarge, "ptr", $pSmall, "int", $iIcons)
	If @error Then Return SetError(@error, 0, 0)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_ExtractIconEx
Func _WinAPI_InProcess($hWnd, ByRef $hLastWnd)
	Local $iI, $iCount, $iProcessID
	If $hWnd = $hLastWnd Then Return True
	For $iI = $winapi_gaInProcess[0][0] To 1 Step -1
		If $hWnd = $winapi_gaInProcess[$iI][0] Then
			If $winapi_gaInProcess[$iI][1] Then
				$hLastWnd = $hWnd
				Return True
			Else
				Return False
			EndIf
		EndIf
	Next
	_WinAPI_GetWindowThreadProcessId($hWnd, $iProcessID)
	$iCount = $winapi_gaInProcess[0][0] + 1
	If $iCount >= 64 Then $iCount = 1
	$winapi_gaInProcess[0][0] = $iCount
	$winapi_gaInProcess[$iCount][0] = $hWnd
	$winapi_gaInProcess[$iCount][1] = ($iProcessID = @AutoItPID)
	Return $winapi_gaInProcess[$iCount][1]
EndFunc   ;==>_WinAPI_InProcess
Func _GUICtrlStatusBar_DebugPrint($sText, $iLine = @ScriptLineNumber)
	ConsoleWrite( _
			"!===========================================================" & @LF & _
			"+======================================================" & @LF & _
			"-->Line(" & StringFormat("%04d", $iLine) & "):" & @TAB & $sText & @LF & _
			"+======================================================" & @LF)
EndFunc   ;==>_GUICtrlStatusBar_DebugPrint
Func _MemShowError($sText, $fExit = True)
	_MemMsgBox(16 + 4096, "Error", $sText)
	If $fExit Then Exit
EndFunc   ;==>_MemShowError
Func _MemVirtualAlloc($pAddress, $iSize, $iAllocation, $iProtect)
	Local $aResult
	$aResult = DllCall("Kernel32.dll", "ptr", "VirtualAlloc", "ptr", $pAddress, "int", $iSize, "int", $iAllocation, "int", $iProtect)
	Return SetError($aResult[0] = 0, 0, $aResult[0])
EndFunc   ;==>_MemVirtualAlloc
Func _MemVirtualAllocEx($hProcess, $pAddress, $iSize, $iAllocation, $iProtect)
	Local $aResult
	$aResult = DllCall("Kernel32.dll", "ptr", "VirtualAllocEx", "int", $hProcess, "ptr", $pAddress, "int", $iSize, "int", $iAllocation, "int", $iProtect)
	Return SetError($aResult[0] = 0, 0, $aResult[0])
EndFunc   ;==>_MemVirtualAllocEx
Func _MemVirtualFree($pAddress, $iSize, $iFreeType)
	Local $aResult
	$aResult = DllCall("Kernel32.dll", "ptr", "VirtualFree", "ptr", $pAddress, "int", $iSize, "int", $iFreeType)
	Return $aResult[0]
EndFunc   ;==>_MemVirtualFree
Func _MemVirtualFreeEx($hProcess, $pAddress, $iSize, $iFreeType)
	Local $aResult
	$aResult = DllCall("Kernel32.dll", "ptr", "VirtualFreeEx", "hwnd", $hProcess, "ptr", $pAddress, "int", $iSize, "int", $iFreeType)
	Return $aResult[0]
EndFunc   ;==>_MemVirtualFreeEx
Func _WinAPI_CloseHandle($hObject)
	Local $aResult
	$aResult = DllCall("Kernel32.dll", "int", "CloseHandle", "int", $hObject)
	_WinAPI_Check("_WinAPI_CloseHandle", ($aResult[0] = 0), 0, True)
	Return $aResult[0] <> 0
EndFunc   ;==>_WinAPI_CloseHandle
Func _WinAPI_GetLastErrorMessage()
	Local $tText
	$tText = DllStructCreate("char Text[4096]")
	_WinAPI_FormatMessage(4096, 0, _WinAPI_GetLastError(), 0, DllStructGetPtr($tText), 4096, 0)
	Return DllStructGetData($tText, "Text")
EndFunc   ;==>_WinAPI_GetLastErrorMessage
Func _WinAPI_GetWindowThreadProcessId($hWnd, ByRef $iPID)
	Local $pPID, $tPID, $aResult
	$tPID = DllStructCreate("int ID")
	$pPID = DllStructGetPtr($tPID)
	$aResult = DllCall("User32.dll", "int", "GetWindowThreadProcessId", "hwnd", $hWnd, "ptr", $pPID)
	If @error Then Return SetError(@error, 0, 0)
	$iPID = DllStructGetData($tPID, "ID")
	Return $aResult[0]
EndFunc   ;==>_WinAPI_GetWindowThreadProcessId
Func _WinAPI_OpenProcess($iAccess, $fInherit, $iProcessID, $fDebugPriv = False)
	Local $hToken, $aResult
	; Attempt to open process with standard security priviliges
	$aResult = DllCall("Kernel32.dll", "int", "OpenProcess", "int", $iAccess, "int", $fInherit, "int", $iProcessID)
	If Not $fDebugPriv Or ($aResult[0] <> 0) Then
		_WinAPI_Check("_WinAPI_OpenProcess:Standard", ($aResult[0] = 0), 0, True)
		Return $aResult[0]
	EndIf
	; Enable debug privileged mode
	$hToken = _Security__OpenThreadTokenEx(BitOR(32, 8))
	_WinAPI_Check("_WinAPI_OpenProcess:OpenThreadTokenEx", @error, @extended)
	_Security__SetPrivilege($hToken, "SeDebugPrivilege", True)
	_WinAPI_Check("_WinAPI_OpenProcess:SetPrivilege:Enable", @error, @extended)
	; Attempt to open process with debug priviliges
	$aResult = DllCall("Kernel32.dll", "int", "OpenProcess", "int", $iAccess, "int", $fInherit, "int", $iProcessID)
	_WinAPI_Check("_WinAPI_OpenProcess:Priviliged", ($aResult[0] = 0), 0, True)
	; Disable debug privileged mode
	_Security__SetPrivilege($hToken, "SeDebugPrivilege", False)
	_WinAPI_Check("_WinAPI_OpenProcess:SetPrivilege:Disable", @error, @extended)
	_WinAPI_CloseHandle($hToken)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_OpenProcess
Func _WinAPI_ShowError($sText, $fExit = True)
	_WinAPI_MsgBox(266256, "Error", $sText)
	If $fExit Then Exit
EndFunc   ;==>_WinAPI_ShowError
Func _WinAPI_ValidateClassName($hWnd, $sClassNames)
	Local $aClassNames, $sSeperator = Opt("GUIDataSeparatorChar"), $sText
	If Not _WinAPI_IsClassName($hWnd, $sClassNames) Then
		$aClassNames = StringSplit($sClassNames, $sSeperator)
		For $x = 1 To $aClassNames[0]
			$sText &= $aClassNames[$x] & ", "
		Next
		$sText = StringTrimRight($sText, 2)
		_WinAPI_ShowError("Invalid Class Type(s):" & @LF & @TAB & _
				"Expecting Type(s): " & $sText & @LF & @TAB & _
				"Received Type : " & _WinAPI_GetClassName($hWnd))
	EndIf
EndFunc   ;==>_WinAPI_ValidateClassName
Func _WinAPI_WriteProcessMemory($hProcess, $pBaseAddress, $pBuffer, $iSize, ByRef $iWritten, $sBuffer = "ptr")
	Local $pWritten, $tWritten, $aResult
	$tWritten = DllStructCreate("int Written")
	$pWritten = DllStructGetPtr($tWritten)
	$aResult = DllCall("Kernel32.dll", "int", "WriteProcessMemory", "int", $hProcess, "int", $pBaseAddress, $sBuffer, $pBuffer, _
			"int", $iSize, "int", $pWritten)
	_WinAPI_Check("_WinAPI_WriteProcessMemory", ($aResult[0] = 0), 0, True)
	$iWritten = DllStructGetData($tWritten, "Written")
	Return $aResult[0]
EndFunc   ;==>_WinAPI_WriteProcessMemory
Func _MemMsgBox($iFlags, $sTitle, $sText)
	BlockInput(0)
	MsgBox($iFlags, $sTitle, $sText & "      ")
EndFunc   ;==>_MemMsgBox
Func _Security__OpenThreadTokenEx($iAccess, $hThread = 0, $fOpenAsSelf = False)
	Local $hToken
	$hToken = _Security__OpenThreadToken($iAccess, $hThread, $fOpenAsSelf)
	If $hToken = 0 Then
		If _WinAPI_GetLastError() = 1008 Then
			If Not _Security__ImpersonateSelf() Then Return SetError(-1, _WinAPI_GetLastError(), 0)
			$hToken = _Security__OpenThreadToken($iAccess, $hThread, $fOpenAsSelf)
			If $hToken = 0 Then Return SetError(-2, _WinAPI_GetLastError(), 0)
		Else
			Return SetError(-3, _WinAPI_GetLastError(), 0)
		EndIf
	EndIf
	Return SetError(0, 0, $hToken)
EndFunc   ;==>_Security__OpenThreadTokenEx
Func _Security__SetPrivilege($hToken, $sPrivilege, $fEnable)
	Local $pRequired, $tRequired, $iLUID, $iAttributes, $iCurrState, $pCurrState, $tCurrState, $iPrevState, $pPrevState, $tPrevState
	$iLUID = _Security__LookupPrivilegeValue("", $sPrivilege)
	If $iLUID = 0 Then Return SetError(-1, 0, False)
	$tCurrState = DllStructCreate($tagTOKEN_PRIVILEGES)
	$pCurrState = DllStructGetPtr($tCurrState)
	$iCurrState = DllStructGetSize($tCurrState)
	$tPrevState = DllStructCreate($tagTOKEN_PRIVILEGES)
	$pPrevState = DllStructGetPtr($tPrevState)
	$iPrevState = DllStructGetSize($tPrevState)
	$tRequired = DllStructCreate("int Data")
	$pRequired = DllStructGetPtr($tRequired)
	; Get current privilege setting
	DllStructSetData($tCurrState, "Count", 1)
	DllStructSetData($tCurrState, "LUID", $iLUID)
	If Not _Security__AdjustTokenPrivileges($hToken, False, $pCurrState, $iCurrState, $pPrevState, $pRequired) Then
		Return SetError(-2, @error, False)
	EndIf
	; Set privilege based on prior setting
	DllStructSetData($tPrevState, "Count", 1)
	DllStructSetData($tPrevState, "LUID", $iLUID)
	$iAttributes = DllStructGetData($tPrevState, "Attributes")
	If $fEnable Then
		$iAttributes = BitOR($iAttributes, 2)
	Else
		$iAttributes = BitAND($iAttributes, BitNOT(2))
	EndIf
	DllStructSetData($tPrevState, "Attributes", $iAttributes)
	If Not _Security__AdjustTokenPrivileges($hToken, False, $pPrevState, $iPrevState, $pCurrState, $pRequired) Then
		Return SetError(-3, @error, False)
	EndIf
	Return SetError(0, 0, True)
EndFunc   ;==>_Security__SetPrivilege
Func _WinAPI_FormatMessage($iFlags, $pSource, $iMessageID, $iLanguageID, $pBuffer, $iSize, $vArguments)
	Local $aResult
	$aResult = DllCall("Kernel32.dll", "int", "FormatMessageA", "int", $iFlags, "hwnd", $pSource, "int", $iMessageID, "int", $iLanguageID, _
			"ptr", $pBuffer, "int", $iSize, "ptr", $vArguments)
	If @error Then Return SetError(@error, 0, 0)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_FormatMessage
Func _WinAPI_GetClassName($hWnd)
	Local $aResult
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)
	$aResult = DllCall("User32.dll", "int", "GetClassName", "hwnd", $hWnd, "str", "", "int", 4096)
	If @error Then Return SetError(@error, 0, "")
	Return $aResult[2]
EndFunc   ;==>_WinAPI_GetClassName
Func _WinAPI_GetLastError()
	Local $aResult
	$aResult = DllCall("Kernel32.dll", "int", "GetLastError")
	If @error Then Return SetError(@error, 0, 0)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_GetLastError
Func _WinAPI_IsClassName($hWnd, $sClassName)
	Local $sSeperator, $aClassName, $sClassCheck
	$sSeperator = Opt("GUIDataSeparatorChar")
	$aClassName = StringSplit($sClassName, $sSeperator)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)
	$sClassCheck = _WinAPI_GetClassName($hWnd) ; ClassName from Handle
	; check array of ClassNames against ClassName Returned
	For $x = 1 To UBound($aClassName) - 1
		If StringUpper(StringMid($sClassCheck, 1, StringLen($aClassName[$x]))) = StringUpper($aClassName[$x]) Then
			Return True
		EndIf
	Next
	Return False
EndFunc   ;==>_WinAPI_IsClassName
Func _WinAPI_MsgBox($iFlags, $sTitle, $sText)
	BlockInput(0)
	MsgBox($iFlags, $sTitle, $sText & "      ")
EndFunc   ;==>_WinAPI_MsgBox
Func _Security__AdjustTokenPrivileges($hToken, $fDisableAll, $pNewState, $iBufferLen, $pPrevState = 0, $pRequired = 0)
	Local $aResult
	$aResult = DllCall("Advapi32.dll", "int", "AdjustTokenPrivileges", "hwnd", $hToken, "int", $fDisableAll, "ptr", $pNewState, _
			"int", $iBufferLen, "ptr", $pPrevState, "ptr", $pRequired)
	Return SetError($aResult[0] = 0, 0, $aResult[0] <> 0)
EndFunc   ;==>_Security__AdjustTokenPrivileges
Func _Security__ImpersonateSelf($iLevel = 2)
	Local $aResult
	$aResult = DllCall("Advapi32.dll", "int", "ImpersonateSelf", "int", $iLevel)
	Return SetError($aResult[0] = 0, 0, $aResult[0] <> 0)
EndFunc   ;==>_Security__ImpersonateSelf
Func _Security__LookupPrivilegeValue($sSystem, $sName)
	Local $tData, $aResult
	$tData = DllStructCreate("int64 LUID")
	$aResult = DllCall("Advapi32.dll", "int", "LookupPrivilegeValue", "str", $sSystem, "str", $sName, "ptr", DllStructGetPtr($tData))
	Return SetError($aResult[0] = 0, 0, DllStructGetData($tData, "LUID"))
EndFunc   ;==>_Security__LookupPrivilegeValue
Func _Security__OpenThreadToken($iAccess, $hThread = 0, $fOpenAsSelf = False)
	Local $tData, $pToken, $aResult
	If $hThread = 0 Then $hThread = _WinAPI_GetCurrentThread()
	$tData = DllStructCreate("int Token")
	$pToken = DllStructGetPtr($tData, "Token")
	$aResult = DllCall("Advapi32.dll", "int", "OpenThreadToken", "int", $hThread, "int", $iAccess, "int", $fOpenAsSelf, "ptr", $pToken)
	Return SetError($aResult[0] = 0, 0, DllStructGetData($tData, "Token"))
EndFunc   ;==>_Security__OpenThreadToken
Func _WinAPI_GetCurrentThread()
	Local $aResult
	$aResult = DllCall("Kernel32.dll", "int", "GetCurrentThread")
	If @error Then Return SetError(@error, 0, 0)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_GetCurrentThread
#EndRegion --- Script patched by FreeStyle code Start 01.02.2009 - 08:58:04