#AutoIt3Wrapper_Au3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6

; downloaded from http://www.autoitscript.com/forum/index.php?showtopic=74933

#include-once
#include <Misc.au3>
; #INDEX# =======================================================================================================================
; Title .........: InetFileUpdate
; Version .......: 1.0.1.2
; AutoIt Version : 3.2 or better
; Language ......: English
; Description ...: A series of UDF's that allow you to query a website to check for updates by comparing file versions and file
;                  sizes.  It also provides a means to download files and install updates either automatically or through the use
;                  of an updating batchfile located on the desktop.  An optional download progress GUI is included in the UDF,
;                  however, you are also have the option to use your own download progress GUI with the UDF.
; Author ........: MickK (PartyPooper)
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
; _InetFile_VersionCheck
; _InetFile_SizeCheck
; _InetFile_Download
; _InetFile_Install
;==============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Name ..........: _InetFile_VersionCheck
; Description ...: A UDF used to check for an updated file on a website using a Version Control File (VCF).
; Syntax ........: _InetFile_VersionCheck($s_WebSite[, $s_RemoteDir = ""[, $s_RemoteFileName = ""[, $s_LocalFilePath = ""[, $s_VCFile = ""[, $i_Suppress = 0]]]]])
; Parameters ....: $s_WebSite         - website hosting the file
;                  $s_RemoteDir       - directory located on the website that contains the remote file (default = root ("/"))
;                  $s_RemoteFileName  - filename to be checked (default = @ScriptName)
;                  $s_LocalFilePath   - folder or directory where the file to be checked against resides (default = @ScriptDir)
;                  $s_VCFile          - Inifile on website containing version number (default = "vcf.dat")
;                  $i_Suppress        - suppress local error messages and use returned values instead (default = 0 [No])
; Return values .: Success - sets @error 0 and returns an array where 0 = number of elements, 1 = remote file version, 2 = local file version
;                  Failure - either returns an appropriately formatted error message or a version array as above and sets @error:
;                  |@error = 1 (function parameter error)
;                  |@error = 2 (version / VCF error)
;                  |@error = 3 (file error)
;                  |@error = 4 (internet error)
;                  |@error = 5 (manual download required)
;                  |@error = 6 (no update available)
;                  |@error = 7 (you have a later version)
; Author ........: PartyPooper
; Modified ......:
; Remarks .......: $s_RemoteFileName should be reflected in the VCF.  If you specify $s_RemoteFileName, you must also specify $s_LocalFilePath.
;                  Version number should be in the format of: Major.Minor.Build.Revision eg. 1.5.0.1
;                  "Vers=Manual" in the vcf.dat is used to trigger a message stating user must visit website to manually update file.
;                  The Version Control File method is useful for updating executable files and files that have return a version number when queried.
;                  Unlike the File Size method in _InetFile_SizeCheck, the Version Control File method will compare the currently running program
;                  version number (or one in a given local file) with the one stored on a website in a version control inifile.  If the one located
;                  on the website is found to be greater, a successful return message will be triggered.
;                  Requires a version control file (inifile) located on a webserver having the format of:
;                  [MyProgram.exe]
;                  Vers=
;                  [Another Program.exe]
;                  Vers=
;                  etc...
; Related .......: _InetFile_SizeCheck
; Link ..........:
; Examples ......:
; ===============================================================================================================================
Func _InetFile_VersionCheck($s_WebSite, $s_RemoteDir = "", $s_RemoteFileName = "", $s_LocalFilePath = "", $s_VCFile = "", $i_Suppress = 0)
	If $s_RemoteDir = "" Or $s_RemoteDir = -1 Then $s_RemoteDir = "/" ; set remote directory to root if not specified
	If $s_RemoteFileName = "" Or $s_RemoteFileName = -1 Then $s_RemoteFileName = @ScriptName ; set remote filename to check against if not specified
	If $s_LocalFilePath = "" Or $s_LocalFilePath = -1 Then $s_LocalFilePath = @ScriptDir ; set local file path to the current script directory if not specified
	If $s_VCFile = "" Or $s_VCFile = -1 Then $s_VCFile = "vcf.dat" ; set default Version Control File (VCF) if not specified
	If $i_Suppress = "" Or $i_Suppress = -1 Then $i_Suppress = 0 ; show local error messages
	;#####################################################
	; check local filepath is set if remote filename was specified
	If $s_RemoteFileName <> @ScriptName And $s_LocalFilePath = @ScriptDir Then
		If $i_Suppress = 0 Then MsgBox(262160, StringTrimRight(@ScriptName, 4) & " ERROR", "PROGRAM FAULT" & @CRLF & @CRLF & "Possible cause: Local file path not specified correctly.")
		Return SetError(1, 0, "262160|" & StringTrimRight(@ScriptName, 4) & " ERROR|PROGRAM FAULT|Possible cause: Local file path not specified correctly.")
	EndIf
	;#####################################################
	; check for slash at end of website address and remove if found
	If StringRight($s_WebSite, 1) = "/" Then $s_WebSite = StringTrimRight($s_WebSite, 1)
	;#####################################################
	; check for slash at beginning of remote directory and put one in if not found
	If StringLeft($s_RemoteDir, 1) <> "/" Then $s_RemoteDir = "/" & $s_RemoteDir
	;#####################################################
	; check for trailing slash on remote directory and put one in if not found
	If StringRight($s_RemoteDir, 1) <> "/" Then $s_RemoteDir = $s_RemoteDir & "/"
	;#####################################################
	; check for trailing backslash on local file path and put one in if not found
	If StringRight($s_LocalFilePath, 1) <> "\" Then $s_LocalFilePath = $s_LocalFilePath & "\"
	;#####################################################
	; set local filename if remote filename was specified
	Local $s_LocalFile
	If $s_RemoteFileName <> @ScriptName Then ; user has specified remote filename
		$s_LocalFile = $s_LocalFilePath & $s_RemoteFileName
	Else
		$s_LocalFile = @ScriptFullPath
	EndIf
	;#####################################################
	; get local file version number
	Local $s_LocalVersion = FileGetVersion($s_LocalFile)
	If @error Then ; not found
		If $i_Suppress = 0 Then MsgBox(262160, StringTrimRight(@ScriptName, 4) & " ERROR", "UPDATE CHECK FAILED" & @CRLF & @CRLF & "Possible cause: The version number of the local file (" & $s_LocalVersion & ") cannot be found.")
		Return SetError(2, 0, "262160|" & StringTrimRight(@ScriptName, 4) & " ERROR|UPDATE CHECK FAILED|Possible cause: The version number of the local file (" & $s_LocalVersion & ") cannot be found.")
	EndIf
	;#####################################################
	; check for old version control file and delete it
	If FileExists(@TempDir & "\" & $s_VCFile) Then
		If Not FileDelete(@TempDir & "\" & $s_VCFile) Then ; problem deleting old version control file
			If $i_Suppress = 0 Then MsgBox(262160, StringTrimRight(@ScriptName, 4) & " ERROR", "UPDATE CHECK FAILED" & @CRLF & @CRLF & "Possible cause: Old VCF file cannot be overwritten (may be read only).")
			Return SetError(3, 0, "262160|" & StringTrimRight(@ScriptName, 4) & " ERROR|UPDATE CHECK FAILED|Possible cause: Old VCF file cannot be overwritten (may be read only).")
		EndIf
	EndIf
	;#####################################################
	; download version control file from web to temp dir
	Local $s_GetVersFile = InetGet($s_WebSite & $s_RemoteDir & $s_VCFile, @TempDir & "\" & $s_VCFile, 1)
	If $s_GetVersFile = 0 Then ; version file or internet not available
		If $i_Suppress = 0 Then MsgBox(262160, StringTrimRight(@ScriptName, 4) & " ERROR", "UPDATE CHECK FAILED" & @CRLF & @CRLF & "Possible cause: Website Offline or Internet connection issues.  Try again later.")
		Return SetError(4, 0, "262160|" & StringTrimRight(@ScriptName, 4) & " ERROR|UPDATE CHECK FAILED|Possible cause: Website Offline or Internet connection issues.  Try again later.")
	EndIf
	Do
		Sleep(250) ; create a delay loop to ensure that file has been downloaded and saved before continuing
	Until FileExists(@TempDir & "\" & $s_VCFile) ; keep looping until file exists
	;#####################################################
	; get remote file version number from control file
	Local $s_RemoteVersion = IniRead(@TempDir & "\" & $s_VCFile, $s_RemoteFileName, "Vers", "Entry Not Found")
	If $s_RemoteVersion = "Entry Not Found" Then ; remote file version number not found
		If $i_Suppress = 0 Then MsgBox(262160, StringTrimRight(@ScriptName, 4) & " ERROR", "UPDATE CHECK FAILED" & @CRLF & @CRLF & "Possible cause: Version " & $s_LocalVersion & " outdated or is not available on website.")
		Return SetError(2, 0, "262160|" & StringTrimRight(@ScriptName, 4) & " ERROR|UPDATE CHECK FAILED|Possible cause: Version " & $s_LocalVersion & " outdated or is not available on website.")
	EndIf
	If $s_RemoteVersion = "Manual" Then ; update requires manual download
		If $i_Suppress = 0 Then MsgBox(262192, StringTrimRight(@ScriptName, 4), "ATTENTION" & @CRLF & @CRLF & "Update needs to be manually installed.  Please visit Website to get the latest version.")
		Return SetError(5, 0, "262192|" & StringTrimRight(@ScriptName, 4) & "|ATTENTION|Update needs to be manually installed.  Please visit Website to get the latest version.")
	EndIf
	;#####################################################
	; delete version control file - no longer needed
	If Not FileDelete(@TempDir & "\" & $s_VCFile) Then ; problem deleting file
		If $i_Suppress = 0 Then MsgBox(262160, StringTrimRight(@ScriptName, 4) & " ERROR", "UPDATE CHECK FAILED" & @CRLF & @CRLF & "Possible cause: VCF file cannot be overwritten (may be read only).")
		Return SetError(3, 0, "262160|" & StringTrimRight(@ScriptName, 4) & " ERROR|UPDATE CHECK FAILED|Possible cause: VCF file cannot be overwritten (may be read only).")
	EndIf
	
	;#####################################################
	; compare versions and return with results
	Local $i_Result = _VersionCompare($s_RemoteVersion, $s_LocalVersion)
	Local $a_RtnVal[3]
	$a_RtnVal[0] = 2
	$a_RtnVal[1] = $s_RemoteVersion
	$a_RtnVal[2] = $s_LocalVersion
	If $i_Result = 0 Then ; no update available
		Return SetError(6, 0, $a_RtnVal) ; return to calling script with versions
	ElseIf $i_Result = 1 Then ; update available
		Return SetError(0, 0, $a_RtnVal) ; return to calling script with versions
	ElseIf $i_Result = -1 Then ; you have a later version
		Return SetError(7, 0, $a_RtnVal) ; return to calling script with versions
	EndIf
EndFunc   ;==>_InetFile_VersionCheck

; #FUNCTION# ====================================================================================================================
; Name ..........: _InetFile_SizeCheck
; Description ...: A UDF used to check a website for an updated file using a a difference in filesize.
; Syntax ........: _InetFile_SizeCheck($s_WebSite[, $s_RemoteDir = ""[, $s_RemoteFileName = ""[, $s_LocalFilePath = ""[, $i_Suppress = 0]]]])
; Parameters ....: $s_WebSite         - website hosting the file
;                  $s_RemoteDir       - directory located on the website that contains the remote file (default = root ("/"))
;                  $s_RemoteFileName  - filename to be checked (default = @ScriptName)
;                  $s_LocalFilePath   - folder or directory where the file to be checked against resides (default = @ScriptDir)
;                  $i_Suppress        - suppress local error messages and use returned values instead (default = 0 [No])
; Return values .: Success - sets @error 0 and returns an array where 0 = number of elements, 1 = remote file version, 2 = local file version
;                  Failure - either returns an appropriately formatted error message or a version array as above and sets @error:
;                  |@error = 1 (function parameter error)
;                  |@error = 2 (not used)
;                  |@error = 3 (file error)
;                  |@error = 4 (internet error)
;                  |@error = 5 (not used)
;                  |@error = 6 (no update available)
; Author ........: PartyPooper
; Modified ......:
; Remarks .......: If you specify $s_RemoteFileName, you must also specify $s_LocalFilePath.
;                  File Size method is useful for checking those files that don't have version numbers and so can't be used with a Version
;                  Control File (like mp3's and text files).  The downside to using the File Size method is that any changes in file size
;                  (larger or smaller) will trigger a successful return message.  There is no way of knowning if the file is truely an "updated"
;                  version or not, just that it is a different file size and therefore, a valid "update".
; Related .......: _InetFile_VersionCheck
; Link ..........:
; Examples ......:
; ===============================================================================================================================
Func _InetFile_SizeCheck($s_WebSite, $s_RemoteDir = "", $s_RemoteFileName = "", $s_LocalFilePath = "", $i_Suppress = 0)
	If $s_RemoteDir = "" Or $s_RemoteDir = -1 Then $s_RemoteDir = "/" ; set remote directory to root if not specified
	If $s_RemoteFileName = "" Or $s_RemoteFileName = -1 Then $s_RemoteFileName = @ScriptName ; set remote filename to check against if not specified
	If $s_LocalFilePath = "" Or $s_LocalFilePath = -1 Then $s_LocalFilePath = @ScriptDir ; set local file path to the current script directory if not specified
	If $i_Suppress = "" Or $i_Suppress = -1 Then $i_Suppress = 0 ; show local error messages
	;#####################################################
	; check local filepath is set if remote filename was specified
	If $s_RemoteFileName <> @ScriptName And $s_LocalFilePath = @ScriptDir Then
		If $i_Suppress = 0 Then MsgBox(262160, StringTrimRight(@ScriptName, 4) & " ERROR", "PROGRAM FAULT" & @CRLF & @CRLF & "Possible cause: Local file path not specified correctly.")
		Return SetError(1, 0, "262160|" & StringTrimRight(@ScriptName, 4) & " ERROR|PROGRAM FAULT|Possible cause: Local file path not specified correctly.")
	EndIf
	;#####################################################
	; check for slash at end of website address and remove if found
	If StringRight($s_WebSite, 1) = "/" Then $s_WebSite = StringTrimRight($s_WebSite, 1)
	;#####################################################
	; check for slash at beginning of remote directory and put one in if not found
	If StringLeft($s_RemoteDir, 1) <> "/" Then $s_RemoteDir = "/" & $s_RemoteDir
	;#####################################################
	; check for trailing slash on remote directory and put one in if not found
	If StringRight($s_RemoteDir, 1) <> "/" Then $s_RemoteDir = $s_RemoteDir & "/"
	;#####################################################
	; check for trailing backslash on local file path and put one in if not found
	If StringRight($s_LocalFilePath, 1) <> "\" Then $s_LocalFilePath = $s_LocalFilePath & "\"
	;#####################################################
	; set local filename if remote filename was specified
	Local $s_LocalFile
	If $s_RemoteFileName <> @ScriptName Then
		$s_LocalFile = $s_LocalFilePath & $s_RemoteFileName
	Else
		$s_LocalFile = @ScriptFullPath
	EndIf
	;#####################################################
	; get file size of remote file
	Local $i_CheckRFSize = InetGetSize($s_WebSite & $s_RemoteDir & $s_RemoteFileName)
	If @error Then ; file not found
		If $i_Suppress = 0 Then MsgBox(262160, StringTrimRight(@ScriptName, 4) & " ERROR", "UPDATE CHECK FAILED" & @CRLF & @CRLF & "Possible cause:  File not found on website.")
		Return SetError(4, 0, "262160|" & StringTrimRight(@ScriptName, 4) & " ERROR|UPDATE CHECK FAILED|Possible cause:  File not found on website.")
	EndIf
	;#####################################################
	; get file size of local file
	Local $i_CheckLFSize = FileGetSize($s_LocalFile)
	If @error Then ; file not found
		If $i_Suppress = 0 Then ; display message
			If MsgBox(262164, StringTrimRight(@ScriptName, 4) & " ERROR", "UPDATE CHECK FAILED" & @CRLF & @CRLF & "Possible cause:  Local file not found.  Would you like to continue and download the file?") = 6 Then
				$i_CheckLFSize = 0
			Else
				Return SetError(3, 0, "262160|" & StringTrimRight(@ScriptName, 4) & " ERROR|UPDATE CHECK FAILED|Possible cause:  Local file not found.")
			EndIf
		Else
			Return SetError(3, 0, "262160|" & StringTrimRight(@ScriptName, 4) & " ERROR|UPDATE CHECK FAILED|Possible cause:  Local file not found.")
		EndIf
	EndIf
	;#####################################################
	; compare remote filesize with local filesize and if not the same, return with results
	Local $a_RtnVal[3]
	If $i_CheckLFSize <> $i_CheckRFSize Then ; file sizes are different
		$a_RtnVal[0] = 2
		$a_RtnVal[1] = $i_CheckRFSize
		$a_RtnVal[2] = $i_CheckLFSize
		Return SetError(0, 0, $a_RtnVal)
	Else ; no update available
		Return SetError(6, 0, $a_RtnVal)
	EndIf
EndFunc   ;==>_InetFile_SizeCheck

; #FUNCTION# ====================================================================================================================
; Name ..........: _InetFile_Download
; Description ...: A UDF used for downloading files from a website.
; Syntax ........: _InetFile_Download($s_WebSite[, $s_RemoteDir = ""[, $s_RemoteFileName = ""[, $s_DownloadDir = ""[, $i_PBar = 0[, $i_Left = -1[, $i_Top = -1[, $i_Suppress = 0]]]]]]])
; Parameters ....: $s_WebSite         - website hosting the file
;                  $s_RemoteDir       - directory located on the website that contains the remote file (default = root ("/"))
;                  $s_RemoteFileName  - filename to be downloaded (default = @ScriptName)
;                  $s_DownloadDir     - directory where file will be downloaded to (default = @TempDir)
;                  $i_PBar            - whether or not a user created progress bar will be displayed [0=No, 1=Yes] (default = No, use local one)
;                  $i_Left            - The left side of the progress bar (default = left will be computed according to GUICoordMode.)
;                  $i_Top             - The top of the progress bar (default = top will be computed according to GUICoordMode.)
;                  $i_Suppress        - suppress local error messages and use returned values instead (default = 0 [No])
; Return values .: Success - sets @error 0 and returns an integer of the remote file size (for use with user created progressbars/GUI's if needed)
;                  Failure - either returns an appropriately formatted error message or returns an integer as above and sets @error:
;                  |@error = 1 (function parameter error)
;                  |@error = 2 (not used)
;                  |@error = 3 (file error)
;                  |@error = 4 (internet error)
; Author ........: PartyPooper
; Modified ......:
; Remarks .......: Includes the ability to display either a locally produced progress bar window or one in the calling script.
; Related .......:
; Link ..........: http://www.autoitscript.com/forum/index.php?showtopic=
; Examples ......:
; ===============================================================================================================================
Func _InetFile_Download($s_WebSite, $s_RemoteDir = "", $s_RemoteFileName = "", $s_DownloadDir = "", $s_PBar = 0, $i_Left = -1, $i_Top = -1, $i_Suppress = 0)
	If $s_RemoteDir = "" Or $s_RemoteDir = -1 Then $s_RemoteDir = "/" ; set remote directory to root if not specified
	If $s_RemoteFileName = "" Or $s_RemoteFileName = -1 Then $s_RemoteFileName = @ScriptName ; set remote filename to check against if not specified
	If $s_DownloadDir = "" Or $s_DownloadDir = -1 Then $s_DownloadDir = @TempDir ; set download directory to temp if not specified
	If $s_PBar = "" Or $s_PBar = -1 Then $s_PBar = 0 ; set to display local progress bar window
	If $i_Left = "" Then $i_Left = 1 ; left will be computed according to GUICoordMode if not specified
	If $i_Top = "" Then $i_Top = -1 ; top will be computed according to GUICoordMode if not specified
	If $i_Suppress = "" Or $i_Suppress = -1 Then $i_Suppress = 0 ; show local error messages
	;#####################################################
	; check for slash at end of website address and remove if found
	If StringRight($s_WebSite, 1) = "/" Then $s_WebSite = StringTrimRight($s_WebSite, 1)
	;#####################################################
	; check for slash at beginning of remote directory and put one in if not found
	If StringLeft($s_RemoteDir, 1) <> "/" Then $s_RemoteDir = "/" & $s_RemoteDir
	;#####################################################
	; check for trailing slash on remote directory and put one in if not found
	If StringRight($s_RemoteDir, 1) <> "/" Then $s_RemoteDir = $s_RemoteDir & "/"
	;#####################################################
	; check download directory for trailing backslash and put one in if not found
	If StringRight($s_DownloadDir, 1) <> "\" Then $s_DownloadDir = $s_DownloadDir & "\"
	;#####################################################
	; get file size for progress bar
	Local $i_CheckRFSize = InetGetSize($s_WebSite & $s_RemoteDir & $s_RemoteFileName)
	If @error Then ; update not found
		If $i_Suppress = 0 Then MsgBox(262160, StringTrimRight(@ScriptName, 4) & " ERROR", "DOWNLOAD FAILED" & @CRLF & @CRLF & "Possible cause:  File not found on website.")
		Return SetError(4, 0, "262160|" & StringTrimRight(@ScriptName, 4) & " ERROR|DOWNLOAD FAILED|Possible cause:  File not found on website.")
	EndIf
	;#####################################################
	; check for old download
	If FileExists($s_DownloadDir & $s_RemoteFileName) Then ; delete old file if found
		If Not FileDelete($s_DownloadDir & $s_RemoteFileName) Then ; problem deleting old download
			If $i_Suppress = 0 Then MsgBox(262160, StringTrimRight(@ScriptName, 4) & " ERROR", "DOWNLOAD FAILED" & @CRLF & @CRLF & "Possible cause: Old download cannot be overwritten (may be read only).")
			Return SetError(3, 0, "262160|" & StringTrimRight(@ScriptName, 4) & " ERROR|DOWNLOAD FAILED|Possible cause: Old download cannot be overwritten (may be read only).")
		EndIf
	EndIf
	;#####################################################
	; start downloading remote file to download directory and return with results
	Local $i_GetFile = InetGet($s_WebSite & $s_RemoteDir & $s_RemoteFileName, $s_DownloadDir & $s_RemoteFileName, 1, 1)
	If $i_GetFile = 1 Then ; remote file can be downloaded
		If $s_PBar = 0 Then ; show progress bar window
			ProgressOn("Downloading...", $s_RemoteFileName, "0 %", $i_Left, $i_Top) ; display progress bar
			Do
				ProgressSet(Round((@InetGetBytesRead / $i_CheckRFSize) * 100, 0), Int(@InetGetBytesRead / $i_CheckRFSize * 100) & '% (' & Round(@InetGetBytesRead / 1024) & ' KB' & ' of ' & Round($i_CheckRFSize / 1024) & ' KB' & ')') ; update progress bar
			Until Not @InetGetActive ; do until file is fully downloaded
			ProgressSet(100, "Done", "Complete") ; successfully downloaded program
			ProgressOff() ; delete progress bar
			Do
				Sleep(250) ; create a delay loop to ensure that file has been downloaded and saved before continuing
			Until FileExists($s_DownloadDir & $s_RemoteFileName) ; keep looping until file exists in download directory
			Return SetError(0, 0, $i_CheckRFSize)
		Else ; don't display progress bar window - user will provide their own
			Return SetError(0, 0, $i_CheckRFSize) ; return to calling script with filesize
		EndIf
	Else ; remote file can't be downloaded for some reason
		If $i_Suppress = 0 Then MsgBox(262160, StringTrimRight(@ScriptName, 4) & " ERROR", "DOWNLOAD FAILED" & @CRLF & @CRLF & "Possible cause: File cannot be downloaded for some reason.")
		Return SetError(4, 0, "262160|" & StringTrimRight(@ScriptName, 4) & " ERROR|DOWNLOAD FAILED|Possible cause: File cannot be downloaded for some reason.")
	EndIf
EndFunc   ;==>_InetFile_Download

; #FUNCTION# ====================================================================================================================
; Name ..........: _InetFile_Install
; Description ...: A UDF that can be used to update a running script after downloading an update using _InetFile_Download.
; Syntax ........: _InetFile_Install([$s_RemoteFileName = ""[, $s_DownloadDir = ""[, $s_BatchFileName = ""[, $i_AutoInstall = 1[, $i_Suppress = 0]]]]])
; Parameters ....: $s_RemoteFileName  - file to be installed (default = @ScriptName)
;                  $s_DownloadDir     - folder or directory where the file to be installed resides (default = @ScriptDir)
;                  $s_BatchFileName   - name of the updating batchfile (default = $s_RemoteFileName_Update.bat).
;                  $i_AutoInstall     - automatically install (default = 1 [yes])
;                  $i_Suppress        - suppress local error messages and use returned values instead (default = 0 [No])
; Return values .: Success - exits program and runs batchfile
;                  Failure - returns an appropriately formatted error message and sets @error:
;                  |@error = 1 (not used)
;                  |@error = 2 (not used)
;                  |@error = 3 (file error)
;                  |@error = 4 (not used)
;                  |@error = 5 (manual install required)
; Author ........: PartyPooper
; Modified ......:
; Remarks .......: You must have called _InetFile_Download prior to using this UDF.
; Related .......: _InetFile_Download
; Link ..........: http://www.autoitscript.com/forum/index.php?showtopic=
; Examples ......:
; ===============================================================================================================================
Func _InetFile_Install($s_RemoteFileName = "", $s_DownloadDir = "", $s_BatchFileName = "", $i_AutoInstall = 1, $i_Suppress = 0)
	If $s_RemoteFileName = "" Or $s_RemoteFileName = -1 Then $s_RemoteFileName = @ScriptName ; set remote filename to check against if not specified
	If $s_DownloadDir = "" Or $s_DownloadDir = -1 Then $s_DownloadDir = @TempDir ; set download directory to temp if not specified
	If $s_BatchFileName = "" Or $s_BatchFileName = -1 Then $s_BatchFileName = StringTrimRight(@ScriptName, 4) & "_Update.bat" ; set updating batch filename
	If $i_AutoInstall = "" Or $i_AutoInstall = -1 Then $i_AutoInstall = 1 ; auto install
	If $i_Suppress = "" Or $i_Suppress = -1 Then $i_Suppress = 0 ; show local error messages
	;#####################################################
	; check download directory for trailing backslash and put one in if not found
	If StringRight($s_DownloadDir, 1) <> "\" Then $s_DownloadDir = $s_DownloadDir & "\"
	;#####################################################
	; check for old batchfiles and delete
	If FileExists(@TempDir & "\" & $s_BatchFileName) Then ; found old batchfile in temp directory, delete it
		If Not FileDelete(@TempDir & "\" & $s_BatchFileName) Then ; problem deleting old update batch file
			If $i_Suppress = 0 Then MsgBox(262160, StringTrimRight(@ScriptName, 4) & " ERROR", "INSTALL FAILED" & @CRLF & @CRLF & "Possible cause: Old batchfile cannot be overwritten (may be read only).")
			Return SetError(3, 0, "262160|" & StringTrimRight(@ScriptName, 4) & " ERROR|INSTALL FAILED|Possible cause: Old batchfile cannot be overwritten (may be read only).")
		EndIf
	EndIf
	If FileExists(@DesktopDir & "\" & $s_BatchFileName) Then ; found old batchfile on desktop, delete it
		If Not FileDelete(@DesktopDir & "\" & $s_BatchFileName) Then ; problem deleting old update batch file
			If $i_Suppress = 0 Then MsgBox(262160, StringTrimRight(@ScriptName, 4) & " ERROR", "INSTALL FAILED" & @CRLF & @CRLF & "Possible cause: Old batchfile cannot be overwritten (may be read only).")
			Return SetError(3, 0, "262160|" & StringTrimRight(@ScriptName, 4) & " ERROR|INSTALL FAILED|Possible cause: Old batchfile cannot be overwritten (may be read only).")
		EndIf
	EndIf
	;#####################################################
	; create an empty batch file used for updating
	Local $h_BatchFile = FileOpen(@TempDir & "\" & $s_BatchFileName, 2)
	If $h_BatchFile = -1 Then ; batch file can't be created for some reason
		If $i_Suppress = 0 Then MsgBox(262160, StringTrimRight(@ScriptName, 4) & " ERROR", "INSTALL FAILED" & @CRLF & @CRLF & "Possible cause: Unable to create batch file used in updating process.")
		Return SetError(3, 0, "262160|" & StringTrimRight(@ScriptName, 4) & " ERROR|INSTALL FAILED|Possible cause: Unable to create batch file used in updating process.")
	EndIf
	;#####################################################
	; insert the required DOS commands into the batchfile
	FileWriteLine($h_BatchFile, '@echo off') ; have batch file suppress DOS prompt
	FileWriteLine($h_BatchFile, 'rem **************************************************') ; leave a note for the curious
	FileWriteLine($h_BatchFile, 'rem *   THIS BATCH FILE IS SAFE TO DELETE ONCE RUN   *') ; leave a note for the curious
	FileWriteLine($h_BatchFile, 'rem **************************************************') ; leave a note for the curious
	If $i_AutoInstall = 1 Then FileWriteLine($h_BatchFile, 'ping -n 5 -w 1000 localhost >nul') ; have the batch file use ping to delay execution to allow calling program to gracefully exit
	FileWriteLine($h_BatchFile, 'move /Y "' & $s_DownloadDir & $s_RemoteFileName & '" "' & @ScriptDir & '" >nul') ; have batch file move the updated program to its dir
	FileWriteLine($h_BatchFile, 'start "Updating..." "' & @ScriptName & '"') ; have batch file start the updated program
	FileWriteLine($h_BatchFile, "exit >nul") ; have batch file exit upon completion
	FileClose($h_BatchFile) ; close the file
	;#####################################################
	; run the batchfile and update or return to calling script so user can manually run the update
	If $i_AutoInstall = 1 Then ; install update automatically using batch file
		Run('RunDll32.exe shell32.dll,ShellExec_RunDLL "' & @TempDir & '\' & $s_BatchFileName & '"', "", @SW_HIDE) ; start running the batch file but don't wait for it to finish to continue
		Exit ; exit the program so batch file can do its business
	Else ; install update by manually running batchfile
		FileMove(@TempDir & "\" & $s_BatchFileName, @DesktopDir & "\" & $s_BatchFileName, 1) ; move the batchfile to the desktop so user has easy access
		If @error Then ; batchfile couldn't be moved
			If $i_Suppress = 0 Then MsgBox(262160, StringTrimRight(@ScriptName, 4) & " ERROR", "INSTALL FAILED" & @CRLF & @CRLF & "Possible cause: Unable to move batch file to desktop.")
			Return SetError(3)
		EndIf
		If $i_Suppress = 0 Then MsgBox(262192, StringTrimRight(@ScriptName, 4), "ATTENTION" & @CRLF & @CRLF & "You will need to exit this program and manually run the batchfile located on your desktop called" & @CRLF & $s_BatchFileName)
		Return SetError(5, 0, "262192|" & StringTrimRight(@ScriptName, 4) & "|ATTENTION|You will need to exit this program and manually run the batchfile located on your desktop called" & @CRLF & $s_BatchFileName)
	EndIf
EndFunc   ;==>_InetFile_Install