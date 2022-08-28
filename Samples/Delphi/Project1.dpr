program Project1;

uses
  Vcl.Forms,
  WinSvc,
  Winapi.Windows,
  System.Classes,
  System.SysUtils,
  System.Win.Registry,
  Unit2 in 'Unit2.pas' {Form2},
  DeviceHelper in 'DeviceHelper.pas',
  Utils in 'Utils.pas';

{$R *.res}

function InstallDriver(path: string): Boolean;
const
    ServiceName: string = 'LdProtect';
var
    reg: TRegistry;
    regpath: string;
    hSCManager, hService: THandle;
    nilvalue: PWideChar;
begin
    Result := False;
    nilvalue := nil;

    hSCManager := OpenSCManager(nil, nil, SC_MANAGER_ALL_ACCESS);
    if hSCManager <> 0 then
    begin
        hService := OpenService(hSCManager, PChar(ServiceName), SERVICE_ALL_ACCESS);
        if hService = 0 then
        begin
            if (GetLastError = 1060 {ERROR_SERVICE_DOES_NOT_EXIST}) or (GetLastError = 123{ERROR_INVALID_NAME}) then
            begin
                hService := CreateService(hSCManager, PWideChar(ServiceName), PWideChar(ServiceName), SERVICE_ALL_ACCESS, SERVICE_FILE_SYSTEM_DRIVER, SERVICE_AUTO_START, SERVICE_ERROR_IGNORE, PChar(path), 'FSFilter Activity Monitor'#0, nil, 'FltMgr'#0, nil, nil);
                if hService<>0 then
                begin
                    reg := TRegistry.Create;
                    try
                        regpath := 'System\CurrentControlSet\Services\' + ServiceName;
                        reg.RootKey := HKEY_LOCAL_MACHINE;
                        if not reg.OpenKey(regpath, True) then
                            Exit;
                        if not reg.OpenKey('Instances', True) then
                            Exit;
                        reg.WriteString('DefaultInstance', ServiceName + ' Instance');
                        reg.OpenKey(ServiceName + ' Instance', True);
                        reg.WriteString('Altitude', '370055');
                        reg.WriteInteger('Flags', 0);
                    finally
                        reg.CloseKey;
                        reg.Free;
                    end;

                end;
            end;
        end;

        if hService<>0 then
        begin

            Result := StartService(hService, 0, nilvalue);

            CloseServiceHandle(hService);

            CloseServiceHandle(hSCManager);

        end else
        begin
            CloseServiceHandle(hSCManager);
            RaiseLastOSError;
        end;
    end else
      RaiseLastOSError;

end;

function CopyDriverFile2System(): string;
var
  path, sys: string;
  b: Boolean;
  Buf: array[0..MAX_PATH] of char;
begin

  b := IsWin64;
  path := ExtractFilePath(ParamStr(0));
  if b then
    sys := path + '64\LdProtect.sys'
  else
    sys := path + '32\LdProtect.sys';

  if not FileExists(sys) then
    raise Exception.Create('driver file not found!');


  GetWindowsDirectory(Buf, MAX_PATH);
  Result:=StrPas(Buf);
  Result := Result+ '\system32\drivers\LdProtect.sys';

  if not CopyFile(PChar(sys), PChar(Result), False) then
    RaiseLastOSError;

end;

begin
  Application.Initialize;
  if (ParamCount=2) and (ParamStr(1)='/install') then
  begin
    if not InstallDriver(CopyDriverFile2System) then
      RaiseLastOSError;

    Exit;
  end;

  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.
