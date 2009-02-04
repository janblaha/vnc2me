; Script created by JDaus for VNC2Me Project.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

[Setup]
AppName=VNC2Me SC Roll-Your-Own
AppPublisher=Secure IT Technologies Pty Ltd
AppPublisherURL=http://secit.com.au
AppSupportURL=http://vnc2me.org/forum.html
AppUpdatesURL=http://vnc2me.org/downloads.html
AppCopyright=Secure IT Technologies Pty Ltd 2008-2009
;AppComments=
;AppContact=
;AppReadmeFile=
;AppSupportPhone=
AppVersion=0.0.0.1
AppVerName=VNC2Me 0.0.0.1
VersionInfoVersion=0.0.0.1

LicenseFile=.\compiled\license.txt
DefaultDirName={pf}\VNC2Me\Roll-Your-Own
DefaultGroupName=VNC2Me - Roll-Your-Own
AllowNoIcons=yes

UninstallDisplayIcon={app}\v2m.ico
ChangesAssociations=yes

OutputBaseFilename=..\VNC2Me_SC_Roll-Your-Own
SetupIconFile=.\compiled\v2m.ico
WindowShowCaption=no

Compression=lzma/max
SolidCompression=yes



;SignedUninstaller=yes
;WizardImageFile=.\logo.bmp
;WizardSmallImageFile=.\logo.bmp


[Languages]
Name: english; MessagesFile: compiler:Default.isl

[Tasks]
;Name: "installvista"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}";
Name: desktopicon; Description: {cm:CreateDesktopIcon}; GroupDescription: {cm:AdditionalIcons}
Name: quicklaunchicon; Description: {cm:CreateQuickLaunchIcon}; GroupDescription: {cm:AdditionalIcons}
;Name: "directicons"; Description: "{cm:CreateDirectIcons}"; GroupDescription: "{cm:AdditionalIcons}";

[Files]
Source: .\compiled\Aero_disable.exe; DestDir: {app}\compiled; Flags: ignoreversion
Source: .\compiled\license.txt; DestDir: {app}\compiled; Flags: comparetimestamp confirmoverwrite
Source: .\compiled\v2m.ico; DestDir: {app}\compiled; Flags: comparetimestamp confirmoverwrite
Source: .\compiled\v2mplink.exe; DestDir: {app}\compiled; Flags: ignoreversion
Source: .\compiled\V2Msc.exe; DestDir: {app}\compiled; Flags: ignoreversion
Source: .\compiled\V2Msvr.exe; DestDir: {app}\compiled; Flags: ignoreversion skipifsourcedoesntexist
Source: .\compiled\V2Mvwr.exe; DestDir: {app}\compiled; Flags: ignoreversion
Source: .\compiled\VNC2Me.exe; DestDir: {app}\compiled; Flags: ignoreversion
Source: .\compiled\vnc2me_sc.ini; DestDir: {app}\compiled; Flags: ignoreversion comparetimestamp confirmoverwrite

Source: .\build_resources\7z_sfx_config.txt; DestDir: {app}\build_resources; Flags: ignoreversion comparetimestamp confirmoverwrite
Source: .\build_resources\7z_v2m.sfx; DestDir: {app}\build_resources; Flags: ignoreversion
Source: .\build_resources\7za.exe; DestDir: {app}\build_resources; Flags: ignoreversion
Source: .\build_resources\upx.exe; DestDir: {app}\build_resources; Flags: ignoreversion
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: {group}\Build VNC2Me; Filename: {app}\Build_VNC2Me_SC_7zip.exe
Name: {group}\{cm:ProgramOnTheWeb,VNC2Me}; Filename: http://vnc2me.org
Name: {group}\{cm:UninstallProgram,VNC2Me}; Filename: {uninstallexe}
Name: {commondesktop}\Build VNC2Me; Filename: {app}\Build_VNC2Me_SC_7zip.exe; Tasks: desktopicon
Name: {userappdata}\Microsoft\Internet Explorer\Quick Launch\Build VNC2Me; Filename: {app}\Build_VNC2Me_SC_7zip.exe; Tasks: quicklaunchicon
;Name: {group}\{cm:UninstallProgram, VNC2Me SC Roll-Your-Own}; Filename: {uninstallexe}

[Registry]
Root: HKCU; Subkey: Software\SecIT; Flags: uninsdeletekey
Root: HKCU; Subkey: Software\SecIT\VNC2Me; Flags: uninsdeletekey
Root: HKCU; Subkey: Software\SecIT\VNC2Me; ValueType: string; ValueName: SelfDelete; ValueData: no
Root: HKLM; Subkey: Software\SecIT; Flags: uninsdeletekey
Root: HKLM; Subkey: Software\SecIT\VNC2Me; Flags: uninsdeletekey
Root: HKLM; Subkey: Software\SecIT\VNC2Me; ValueType: string; ValueName: SelfDelete; ValueData: no

[Messages]
BeveledLabel=VNC2Me SC Roll-Your-Own Setup
