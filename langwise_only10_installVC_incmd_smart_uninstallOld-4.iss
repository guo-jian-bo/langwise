#define MyAppName "乃师"
; #define MyAppVersion "1.0.0"
#define MyAppPublisher "上海乃时智能科技有限公司"
#define MyAppURL "https://www.timelywise.cn"
#define MyAppExeName "langwise.exe"
#define MyAppAssocName "langwise File"
#define MyAppAssocExt ".myp"
#define MyAppAssocKey StringChange(MyAppAssocName, " ", "") + MyAppAssocExt

[Setup]
AppId={{85B4EA7C-7F35-4019-82BC-1F7351261643}}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={autopf}\langwise
UninstallDisplayIcon={app}\{#MyAppExeName}
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
ChangesAssociations=yes
DisableProgramGroupPage=yes
OutputDir=Output
OutputBaseFilename=langwise
SetupIconFile=build_assets\app_icon.ico
SolidCompression=yes
WizardStyle=modern
UsePreviousAppDir=no

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "chinese"; MessagesFile: "compiler:Languages\Chinese.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "build\windows\x64\runner\Release\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs; Excludes: "{#MyAppExeName}.WebView2\*"
Source: "build_assets\VC_redist.x64.exe"; DestDir: "{tmp}"; Flags: deleteafterinstall
Source: "build_assets\VC_redist.x86.exe"; DestDir: "{tmp}"; Flags: deleteafterinstall
Source: "build_assets\MicrosoftEdgeWebview2Setup.exe"; DestDir: "{tmp}"; Flags: deleteafterinstall

[Registry]
Root: HKA; Subkey: "Software\Classes\{#MyAppAssocExt}\OpenWithProgids"; ValueType: string; ValueName: "{#MyAppAssocKey}"; ValueData: ""; Flags: uninsdeletevalue
Root: HKA; Subkey: "Software\Classes\{#MyAppAssocKey}"; ValueType: string; ValueName: ""; ValueData: "{#MyAppAssocName}"; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Classes\{#MyAppAssocKey}\DefaultIcon"; ValueType: string; ValueName: ""; ValueData: "{app}\{#MyAppExeName},0"
Root: HKA; Subkey: "Software\Classes\{#MyAppAssocKey}\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\{#MyAppExeName}"" ""%1"""

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{sys}\cmd.exe"; Parameters: "/c ""{tmp}\InstallVCx64.bat"""; StatusMsg: "正在检测并安装 Microsoft Visual C++ x64 运行库..."; Flags: waituntilterminated; Check: not IsVC2015_2022x64Installed
Filename: "{sys}\cmd.exe"; Parameters: "/c ""{tmp}\InstallVCx86.bat"""; StatusMsg: "正在检测并安装 Microsoft Visual C++ x86 运行库..."; Flags: waituntilterminated; Check: not IsVC2015_2022x86Installed
Filename: "{tmp}\MicrosoftEdgeWebview2Setup.exe"; Parameters: "/silent /install"; StatusMsg: "正在检测并安装 Microsoft Edge WebView2 Runtime..."; Flags: waituntilterminated; Check: not IsWebView2Installed
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

[Code]
procedure CreateVCRedistBatch(Is64bit: Boolean);
var
  BatchFilePath: string;
  BatchContent: TStringList;
  VCRedistPath: string;
  ArchName: string;
begin
  if Is64bit then
  begin
    BatchFilePath := ExpandConstant('{tmp}\InstallVCx64.bat');
    VCRedistPath := ExpandConstant('{tmp}\VC_redist.x64.exe');
    ArchName := 'x64';
  end
  else
  begin
    BatchFilePath := ExpandConstant('{tmp}\InstallVCx86.bat');
    VCRedistPath := ExpandConstant('{tmp}\VC_redist.x86.exe');
    ArchName := 'x86';
  end;
  
  BatchContent := TStringList.Create;
  try
    BatchContent.Add('@echo off');
    BatchContent.Add('title 安装 Microsoft Visual C++ ' + ArchName + ' 运行库');
    BatchContent.Add('echo =======================================================');
    BatchContent.Add('echo   检测到缺少 Microsoft Visual C++ ' + ArchName + ' 运行库');
    BatchContent.Add('echo =======================================================');
    BatchContent.Add('echo.');
    BatchContent.Add('echo 正在安装，请稍候...');
    BatchContent.Add('echo.');
    
    // 执行静默安装
    BatchContent.Add('"' + VCRedistPath + '" /install /quiet /norestart');
    
    BatchContent.Add('echo.');
    BatchContent.Add('echo =======================================================');
    BatchContent.Add('echo   安装完成！');
    BatchContent.Add('echo =======================================================');
    BatchContent.Add('echo.');
    BatchContent.Add('echo 此窗口将在 5 秒后自动关闭...');
    BatchContent.Add('timeout /t 5 /nobreak > nul');
    BatchContent.Add('exit');
    
    BatchContent.SaveToFile(BatchFilePath);
  finally
    BatchContent.Free;
  end;
end;

function IsWindows10OrNewer: Boolean;
var
  Version: TWindowsVersion;
begin
  GetWindowsVersionEx(Version);
  Result := Version.Major >= 10;
end;

function GetWindowsFriendlyName: string;
var
  Version: TWindowsVersion;
begin
  GetWindowsVersionEx(Version);
  case Version.Major of
    10:
      begin
        if Version.Build >= 22000 then
          Result := 'Windows 11 (Build ' + IntToStr(Version.Build) + ')'
        else
          Result := 'Windows 10 (Build ' + IntToStr(Version.Build) + ')';
      end;
    6:
      begin
        case Version.Minor of
          1: Result := 'Windows 7';
          2: Result := 'Windows 8';
          3: Result := 'Windows 8.1';
          else Result := 'Windows (Version ' + IntToStr(Version.Major) + '.' + IntToStr(Version.Minor) + ')';
        end;
      end;
    5:
      begin
        case Version.Minor of
          1: Result := 'Windows XP';
          2: Result := 'Windows Server 2003 / XP x64';
          else Result := 'Windows (Version ' + IntToStr(Version.Major) + '.' + IntToStr(Version.Minor) + ')';
        end;
      end;
    else
      Result := 'Windows (Version ' + IntToStr(Version.Major) + '.' + IntToStr(Version.Minor) + ')';
  end;
end;

function IsVC2015_2022x64Installed: Boolean;
var
  v: Cardinal;
begin
  Result := RegQueryDWordValue(HKLM64, 'SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64', 'Installed', v) and (v = 1);
end;

function IsVC2015_2022x86Installed: Boolean;
var
  v: Cardinal;
begin
  Result := RegQueryDWordValue(HKLM32, 'SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x86', 'Installed', v) and (v = 1);
end;

function IsWebView2Installed: Boolean;
var
  Version: string;
begin
  Version := '';
  Result :=
    RegQueryStringValue(HKLM, 'SOFTWARE\WOW6432Node\Microsoft\EdgeUpdate\Clients\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}', 'pv', Version) or
    RegQueryStringValue(HKCU, 'SOFTWARE\WOW6432Node\Microsoft\EdgeUpdate\Clients\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}', 'pv', Version) or
    RegQueryStringValue(HKLM, 'SOFTWARE\Microsoft\EdgeUpdate\Clients\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}', 'pv', Version) or
    RegQueryStringValue(HKCU, 'SOFTWARE\Microsoft\EdgeUpdate\Clients\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}', 'pv', Version);
end;

function GetUninstallString: string;
var
  sUnInstPath: string;
  sUnInstallString: String;
begin
  Result := '';
  sUnInstPath := ExpandConstant('Software\Microsoft\Windows\CurrentVersion\Uninstall\{#SetupSetting("AppId")}');
  sUnInstallString := '';
  if not RegQueryStringValue(HKLM, sUnInstPath, 'UninstallString', sUnInstallString) then
    RegQueryStringValue(HKCU, sUnInstPath, 'UninstallString', sUnInstallString);
  Result := sUnInstallString;
end;

function IsUpgrade: Boolean;
begin
  Result := (GetUninstallString() <> '');
end;

function UninstallOldVersion: Boolean;
var
  sUnInstallString: string;
  iResultCode: Integer;
begin
  Result := True;
  sUnInstallString := GetUninstallString();
  if sUnInstallString <> '' then
  begin
    sUnInstallString := RemoveQuotes(sUnInstallString);
    Exec(sUnInstallString, '/SILENT /NORESTART /SUPPRESSMSGBOXES', '', SW_HIDE, ewWaitUntilTerminated, iResultCode);
    Result := (iResultCode = 0);
  end;
end;

function InitializeSetup: Boolean;
var
  ErrorMsg: string;
begin
  if not IsWindows10OrNewer then
  begin
    ErrorMsg := '当前系统: ' + GetWindowsFriendlyName() + #13#10 + #13#10 +
                '此安装程序需要 Windows 10 或更高版本的操作系统。' + #13#10 +
                '您的系统版本不符合要求，安装无法继续。';
    MsgBox(ErrorMsg, mbError, MB_OK);
    Result := False;
  end
  else
  begin
    Result := True;
    if IsUpgrade then
    begin
      UninstallOldVersion;
    end;
  end;
end;

// 只有一个 CurStepChanged 函数，删除了重复的
procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssInstall then
  begin
    if IsUpgrade then
    begin
      UninstallOldVersion;
    end;
    
    // 创建批处理文件
    if not IsVC2015_2022x64Installed then
      CreateVCRedistBatch(True);
      
    if not IsVC2015_2022x86Installed then
      CreateVCRedistBatch(False);
  end;
end;
