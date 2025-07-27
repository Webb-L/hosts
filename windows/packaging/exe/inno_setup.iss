[Setup]
AppId={{app_id}}
AppName={{display_name}}
AppVersion={{version}}
AppPublisher={{publisher}}
AppPublisherURL={{publisher_url}}
AppSupportURL={{support_url}}
AppUpdatesURL={{updates_url}}
DefaultDirName={autopf}\{{display_name}}
DefaultGroupName={{display_name}}
AllowNoIcons=yes
LicenseFile={{license_file}}
SetupIconFile={{setup_icon_file}}
Compression=lzma
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=admin
DisableProgramGroupPage=yes
; 禁用自动启动和安装后运行
DisableStartupPrompt=yes
DisableFinishedPage=no
DisableReadyPage=no
ShowRunList=no

[Languages]
Name: "en"; MessagesFile: "compiler:Default.isl"
Name: "zh"; MessagesFile: "compiler:Languages\ChineseSimplified.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "{{files_path}}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{{display_name}}"; Filename: "{app}\{{executable_name}}"
Name: "{autodesktop}\{{display_name}}"; Filename: "{app}\{{executable_name}}"; Tasks: desktopicon

[Run]
; 注意：这里故意留空，不添加任何运行项目，确保安装后不会自动启动应用

[Registry]
; 不添加任何自启动注册表项