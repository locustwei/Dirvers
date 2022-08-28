unit Utils;

interface

uses Winapi.Windows, System.SysUtils, System.StrUtils, Winapi.PsAPI;

function GetProcessFileName(ProHandle: THandle): String;
function DosPathToDevicePath(Path:String):String;
function DevicePathToDosPath(Path:String):String;
function IsWin64: Boolean;

implementation

function IsWin64: Boolean;
var
  Kernel32Handle: THandle;
  IsWow64Process: function(Handle: THandle; var Res: BOOL): BOOL; stdcall;
  GetNativeSystemInfo: procedure(var lpSystemInfo: TSystemInfo); stdcall;
  isWoW64: Bool;
  SystemInfo: TSystemInfo;
const
  PROCESSOR_ARCHITECTURE_AMD64 = 9;
  PROCESSOR_ARCHITECTURE_IA64 = 6;
  PROCESSOR_ARCHITECTURE_ARM64 = 12;
begin
  Kernel32Handle := GetModuleHandle('KERNEL32.DLL');
  if Kernel32Handle = 0 then
    Kernel32Handle := LoadLibrary('KERNEL32.DLL');
  if Kernel32Handle <> 0 then
  begin
    IsWOW64Process := GetProcAddress(Kernel32Handle,'IsWow64Process');
    GetNativeSystemInfo := GetProcAddress(Kernel32Handle,'GetNativeSystemInfo');
    if Assigned(IsWow64Process) then
    begin
      IsWow64Process(GetCurrentProcess,isWoW64);
      Result := isWoW64 and Assigned(GetNativeSystemInfo);
      if Result then
      begin
        GetNativeSystemInfo(SystemInfo);
        Result := (SystemInfo.wProcessorArchitecture = PROCESSOR_ARCHITECTURE_AMD64) or
                  (SystemInfo.wProcessorArchitecture = PROCESSOR_ARCHITECTURE_IA64) or
                  (SystemInfo.wProcessorArchitecture = PROCESSOR_ARCHITECTURE_ARM64);
      end;
    end
    else Result := False;
  end
  else Result := False;
end;


function GetProcessImageFileName(hProcess: tHANDLE;lpImageFileName: LPTSTR;nSize: DWORD): DWORD; stdcall; external 'psapi.dll' name 'GetProcessImageFileName'+{$IFDEF UNICODE}'W'{$ELSE}'A'{$ENDIF};

function DevicePathToDosPath(Path:String):String;
var
    Drive : Char;
    Text : String;
    Count : Integer;
begin
    Count := PosEx('\', Path, 2);
    Count := PosEx('\', Path, Count+1);

    Result := Copy(Path, Count, Length(Path));
    Delete(Path, Count, Length(Path));
    for Drive := 'A' to 'Z' do
    begin
        SetLength(Text, 100);
        if QueryDosDevice(PChar(String(Drive)+':'), PChar(Text), Length(Text)) <> 0 then
        begin
            Text := PChar(Text);
            if SameText(Path, Text) then
            begin
                Result := Drive+':'+Result;
                Exit;
            end;
        end;
    end;
    Result := '';
end;

function DosPathToDevicePath(Path:String):String;
var
    Drive, s: String;
    Text: string;
    Count: Integer;
begin
	  Result := '';
    Count := Pos(':', Path);
    if Count<=0 then
    	Exit;
    Drive := Copy(Path, 1, Count);

    SetLength(Text, 1000);
    if QueryDosDevice(PChar(Drive), PChar(Text), Length(Text)) <> 0 then
    begin
        s := PChar(Text);
        Result := ReplaceStr(Path, Drive, s);
    end;
end;


function GetProcessFileName(ProHandle: THandle): String;
var
    hMod:HMODULE;
    cbNeeded: DWORD;
    ilen:integer;
    p: PWChar;
begin
    Result := '';

    p := GetMemory((MAX_PATH + 1)*SizeOf(WideChar));
    if p=nil then
      Exit;
    ZeroMemory(p, (MAX_PATH + 1)*SizeOf(WideChar));

      if EnumProcessModules(ProHandle, @hMod, sizeof(hMod), cbNeeded) then
      begin
        iLen := GetModuleFileNameEx(ProHandle, hMod, p, (MAX_PATH));
        if iLen <> 0 then
        begin
          Result := p;
        end;
      end else
      begin
        if GetProcessImageFileName(ProHandle,p, MAX_PATH) <> 0 then
        begin
          Result := DevicePathToDosPath(p);
        end;
      end;

      FreeMemory(p);

end;

end.
