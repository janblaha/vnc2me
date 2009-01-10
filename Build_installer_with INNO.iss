; Script created by JDaus for VNC2Me Project.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

[Setup]
AppName=VNC2Me SC
AppPublisher=Secure IT Technologies Pty Ltd
AppPublisherURL=http://secit.com.au
AppSupportURL=http://vnc2me.org/forum.html
AppUpdatesURL=http://vnc2me.org/downloads.html
AppCopyright=Secure IT Technologies Pty Ltd
;AppComments=
;AppContact=
;AppReadmeFile=
;AppSupportPhone=
AppVersion=0.1.0.1
AppVerName=VNC2Me 0.1.0.1
VersionInfoVersion=0.1.0.1

LicenseFile=.\compiled\license.txt
DefaultDirName={pf}\VNC2Me
DefaultGroupName=VNC2Me
AllowNoIcons=yes

UninstallDisplayIcon={app}\v2m.ico
ChangesAssociations=yes

OutputBaseFilename=.\..\VNC2Me_SC_install
SetupIconFile=.\compiled\v2m.ico
WindowShowCaption=no

Compression=lzma/max
SolidCompression=yes

;SignedUninstaller=yes
;WizardImageFile=.\logo.bmp
;WizardSmallImageFile=.\logo.bmp

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
;Name: "installvista"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}";
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}";
Name: "quicklaunchicon"; Description: "{cm:CreateQuickLaunchIcon}"; GroupDescription: "{cm:AdditionalIcons}";
;Name: "directicons"; Description: "{cm:CreateDirectIcons}"; GroupDescription: "{cm:AdditionalIcons}";

[Files]
Source: ".\compiled\VNC2Me.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: ".\compiled\license.txt"; DestDir: "{app}"; Flags: ignoreversion
;Source: ".\logo.bmp"; DestDir: "{app}"; Flags: ignoreversion
;Source: ".\compiled\icon1.ico"; DestDir: "{app}"; Flags: ignoreversion
Source: ".\compiled\v2m.ico"; DestDir: "{app}"; Flags: ignoreversion
Source: ".\compiled\vnc2me_sc.ini"; DestDir: "{app}"; Flags: ignoreversion
Source: ".\compiled\v2mplink.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: ".\compiled\V2Msc.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: ".\compiled\V2Mvwr.exe"; DestDir: "{app}"; Flags: ignoreversion
; Tasks: quicklaunchicon
Source: ".\compiled\Aero_disable.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: ".\compiled\.putty\sshhostkeys"; DestDir: "{app}\.putty"; Flags: ignoreversion
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{group}\VNC2Me"; Filename: "{app}\VNC2Me.exe"
Name: "{group}\{cm:ProgramOnTheWeb,VNC2Me}"; Filename: "http://vnc2me.org"
Name: "{group}\{cm:UninstallProgram,VNC2Me}"; Filename: "{uninstallexe}"
Name: "{commondesktop}\VNC2Me"; Filename: "{app}\VNC2Me.exe"; Tasks: desktopicon
Name: "{userappdata}\Microsoft\Internet Explorer\Quick Launch\VNC2Me"; Filename: "{app}\VNC2Me.exe"; Tasks: quicklaunchicon

;Name: "{group}\JDsVNC Direct - JD"; Filename: "{app}\jdvnc.exe"; WorkingDir: "{app}"; Parameters: "/JD"; Tasks: directicons
;Name: "{group}\JDsVNC Direct - Budg"; Filename: "{app}\jdvnc.exe"; WorkingDir: "{app}"; Parameters: "/Budg"; Tasks: directicons
[Run]
Filename: "{app}\VNC2Me.exe"; Description: "{cm:LaunchProgram,VNC2Me}"; Flags: nowait postinstall skipifsilent

