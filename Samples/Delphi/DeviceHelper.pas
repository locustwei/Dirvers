unit DeviceHelper;

interface

uses
  Windows, Classes, SysUtils, StrUtils, ShLwApi, System.Generics.Collections;

type

  TProtectFile=class
  public
    id: ULONG64;
    pt: DWORD; //PP_TYPE;
    Name: string;
  end;

  TDeviceHelper = class(TObject)
  private
    FLastErrCode: Integer;
    hDriver: THandle;

    function GetLastErrCode: Integer;
    function OpenCtrlDevice(): Boolean;
    function GetVersion(): DWORD;
    function CallDriver(code: Cardinal; input: Pointer; input_size: Cardinal; output: Pointer = nil; output_size: Cardinal = 0; ret_size: PDWORD = nil): Boolean;
    function BuildFileRecord(filename: string; pt: Integer): Pointer;
    procedure ClearBlackList;
    procedure ClearWhiteList;
    procedure ClearFileList;
    function BuildProtectList(buffer: PByte; leng: Integer; list: TList<TProtectFile>): Boolean;
  public
    FBlackList: TList<TProtectFile>;
    FWhiteList: TList<DWORD>;
    FFileList: TList<TProtectFile>;

    constructor Create();
    destructor Destroy; override;
    function IsValid(): Boolean;

    //添加黑名单（黑名单：可执行文件名添加到驱动中，阻止其运行）
    //filename：可执行文件名。可以不包含路径
    function AddBlackList(filename: string): Boolean;
    //从驱动中获取全部黑名单。
    function GetBlackList(): Boolean;
    //从驱动中移除黑名单。
    function RemoveBlack(pf: TProtectFile): Boolean;
    //--------------------------------------------------------------------------
    //添加白名单（白名单：驱动保护正在运行的程序不被其它程序强制终止）
    function AddProcessById(pid: DWORD): Boolean;
    //从驱动中获取全部白名单。
    function GetWhiteList(): Boolean;
    //从驱动中移除白名单。
    function RemoveWhite(pid: DWORD): Boolean;
    //--------------------------------------------------------------------------
    //添加保护文件（文件保护：任意文件添加到驱动中，阻止被删除。）
    //filename：可执行文件名。
    function AddProtectFile(filename: string): Boolean;
    //从驱动中获取全部黑名单。
    function GetProctectList(): Boolean;
    //从驱动中移除黑名单。
    function RemoveProtectFile(pf: TProtectFile): Boolean;
    //--------------------------------------------------------------------------

    property LastErrCode: Integer read GetLastErrCode;
  end;

implementation

uses Utils;

const
  IOCTL_VERSION = ($00000022 shl 16) or ((0) shl 14) or ($601 shl 2) or 0;
  //-----------------------------------------------------------------------------------------
  IOCTL_PP_ADD           = ($00000022 shl 16) or ((0) shl 14) or ($C01 shl 2) or 0;
  IOCTL_PP_BLACK_REMOVE  = ($00000022 shl 16) or ((0) shl 14) or ($C02 shl 2) or 0;
  IOCTL_PP_WHITE_REMOVE  = ($00000022 shl 16) or ((0) shl 14) or ($C03 shl 2) or 0;
  IOCTL_PP_ENUM          = ($00000022 shl 16) or ((0) shl 14) or ($C04 shl 2) or 0;
  P_PROCESS_RUN = $1;
  P_PROCESS_TEM = $4;
  //------------------------------------------------------------------------------------------
  IOCTL_FP_ADD           = ($00000022 shl 16) or ((0) shl 14) or ($901 shl 2) or 0;
  IOCTL_FP_REMOVE        = ($00000022 shl 16) or ((0) shl 14) or ($902 shl 2) or 0;
  IOCTL_FP_ENUM          = ($00000022 shl 16) or ((0) shl 14) or ($903 shl 2) or 0;
  P_FILE_DELETE = $100;

type
  TNAME_PATH=packed record
    nPath: USHORT;
    nName: USHORT;
  end;

  TPP_NAME_RECORD = packed record
    cb: ULONG;
    pt: DWORD; //PP_TYPE;
//    WCHAR filename[0];
  end;
  PPP_NAME_RECORD = ^TPP_NAME_RECORD;


procedure DugOutput(const f: string; const Args: array of const);
var
    s: string;
begin
    try
        if Length(Args)>0 then
            s := Format(f, args)
        else
            s := f;
        s := s+#13#10;
        OutputDebugString(PChar(s));
    except
        OutputDebugString(PChar(f));
    end;
end;


{ TDeviceHelper }

function TDeviceHelper.AddProcessById(pid: DWORD): Boolean;
begin

  Result := CallDriver(IOCTL_PP_ADD, @pid, SizeOf(dword));

  if Result then
  begin
    FWhiteList.Add(pid);
  end;
end;

function TDeviceHelper.AddProtectFile(filename: string): Boolean;
var
    p: PPP_NAME_RECORD;
    ret_id: ULONG64;
  pf: TProtectFile;
begin
  filename := DosPathToDevicePath(filename);

  p := BuildFileRecord(filename, P_FILE_DELETE);
  if p=nil then
    Exit(False);

  Result := CallDriver(IOCTL_FP_ADD, p, p.cb, @ret_id, SizeOf(ret_id));
  FreeMemory(p);

  if Result then
  begin
    pf := TProtectFile.Create;
    pf.id := ret_id;
    pf.Name := (filename);
    FFileList.Add(pf);

  end;
end;

function TDeviceHelper.BuildFileRecord(filename: string; pt: Integer): Pointer;
var
    pFile: PPP_NAME_RECORD;
    cb: Integer;
    Pos: Integer;
begin

    if filename='' then
      Exit(nil);

    cb := SizeOf(TPP_NAME_RECORD) + (Length(filename) + 1) * SizeOf(wchar);

    pFile := GetMemory(cb);
    if pFile=nil then
      Exit(nil);

    ZeroMemory(pFile, cb);
    pFile.cb := cb;
    pFile.pt := pt;

    Pos := SizeOf(TPP_NAME_RECORD);

    CopyMemory((PByte(pFile)+Pos), PChar(filename), Length(filename)* SizeOf(char));

    Result := pFile;
end;


function TDeviceHelper.AddBlackList(filename: string): Boolean;
var
  p: PPP_NAME_RECORD;
  ret_id: ULONG64;
  pf: TProtectFile;
begin
  p := BuildFileRecord(filename, P_PROCESS_RUN);
  if p=nil then
    Exit(False);

  Result := CallDriver(IOCTL_PP_ADD, p, p.cb, @ret_id, SizeOf(ret_id));

  FreeMemory(p);

  if Result then
  begin
    pf := TProtectFile.Create;
    pf.id := ret_id;
    pf.Name := (filename);
    FBlackList.Add(pf);
  end;
end;


function TDeviceHelper.CallDriver(code: Cardinal; input: Pointer; input_size: Cardinal; output: Pointer; output_size: Cardinal; ret_size: PDWORD): Boolean;
var
  OutSize: DWORD;
begin
  if hDriver=INVALID_HANDLE_VALUE then
    Exit(False);

  Result := DeviceIoControl(hDriver, code, input, input_size, output, output_size, OutSize, nil);
  if (ret_size<>nil) then
    ret_size^:=OutSize;
end;

procedure TDeviceHelper.ClearBlackList;
var
  i: Integer;
begin
  for i := 0 to FBlackList.Count-1 do
    FBlackList[i].Free;

  FBlackList.Clear;
end;

procedure TDeviceHelper.ClearWhiteList;
begin

  FWhiteList.Clear;
end;

procedure TDeviceHelper.ClearFileList;
var
  i: Integer;
begin
  for i := 0 to FFileList.Count-1 do
    FFileList[i].Free;

  FFileList.Clear;
end;

constructor TDeviceHelper.Create;
begin
  hDriver := INVALID_HANDLE_VALUE;
  FBlackList := TList<TProtectFile>.Create;
  FWhiteList := TList<DWORD>.Create;
  FFileList := TList<TProtectFile>.Create;

  OpenCtrlDevice();
end;

destructor TDeviceHelper.Destroy;
var
  i: Integer;
begin
  ClearBlackList;
  FBlackList.Free;

  ClearWhiteList;
  FWhiteList.Free;

  ClearFileList;
  FFileList.Free;


  if hDriver <> INVALID_HANDLE_VALUE then
    CloseHandle(hDriver);
  inherited;
end;

function TDeviceHelper.GetBlackList(): Boolean;
var
  out_size: DWORD;
  buffer: PByte;
  k: ULONG;
begin
  out_size := 0;

  ClearBlackList;

  k := 1;
  CallDriver(IOCTL_PP_ENUM, @k, SizeOf(k), nil, 0, @out_size);      //查询需要内存大小

  if out_size>0 then
  begin
    buffer := GetMemory(out_size);
    if not CallDriver(IOCTL_PP_ENUM, @k, SizeOf(k), buffer, out_size, nil) then
    begin
      FreeMemory(buffer);
      Exit(result);
    end;

    BuildProtectList(buffer, out_size, FBlackList);

    FreeMemory(buffer);
  end;


end;

function TDeviceHelper.BuildProtectList(buffer: PByte; leng: Integer; list: TList<TProtectFile>): Boolean;
var
  pf: TProtectFile;
  pn: PPP_NAME_RECORD;
  pI: PUInt64;
  pos: Integer;
  k: ULONG;
begin

    pos:=0;
    while pos < leng do
    begin
      pf := TProtectFile.Create;
      pi := PUInt64(buffer + pos);
      pf.id := pi^;

      Pos := pos + SizeOf(uint64);
      pn := PPP_NAME_RECORD(buffer + pos);

      pf.pt := pn.pt;
      pf.Name := PChar(PByte(pn)+SizeOf(TPP_NAME_RECORD));
      list.Add(pf);

      pos := Pos + pn.cb;

    end;

    FreeMemory(buffer);

end;

function TDeviceHelper.GetLastErrCode: Integer;
begin
  if FLastErrCode = 0 then
    Result := GetLastError
  else
    Result := FLastErrCode;
end;

function TDeviceHelper.GetProctectList: Boolean;
var
  out_size: DWORD;
  buffer: PByte;
begin
  out_size := 0;

  ClearFileList;

  CallDriver(IOCTL_FP_ENUM, nil, 0, nil, 0, @out_size);      //查询需要内存大小

  if out_size>0 then
  begin
    buffer := GetMemory(out_size);
    if not CallDriver(IOCTL_FP_ENUM, nil, 0, buffer, out_size, nil) then
    begin
      FreeMemory(buffer);
      Exit(result);
    end;

    BuildProtectList(buffer, out_size, FFileList);

    FreeMemory(buffer);
  end;

end;

function TDeviceHelper.GetVersion: DWORD;
begin
  if not CallDriver(IOCTL_VERSION, nil, 0, @result, SizeOf(result)) then
    Result := 0;
end;

function TDeviceHelper.GetWhiteList: Boolean;
var
  out_size: DWORD;
  buffer: PByte;
  pos: Integer;
  k: ULONG;
begin
  out_size := 0;

  ClearWhiteList;

  k := 2;
  CallDriver(IOCTL_PP_ENUM, @k, SizeOf(k), nil, 0, @out_size);      //查询需要内存大小

  if out_size>0 then
  begin
    buffer := GetMemory(out_size);
    if not CallDriver(IOCTL_PP_ENUM, @k, SizeOf(k), buffer, out_size, nil) then
    begin
      FreeMemory(buffer);
      Exit(result);
    end;

    pos:=0;
    while pos < out_size do
    begin
      FWhiteList.Add(pdword(PByte(buffer)+pos)^);

      pos := Pos + SizeOf(dword);

    end;

    FreeMemory(buffer);
  end;
end;

function TDeviceHelper.IsValid: Boolean;
begin
  Result := hDriver <> INVALID_HANDLE_VALUE;
end;

function TDeviceHelper.OpenCtrlDevice: Boolean;
const
  DEVICE_NAME = '\\.\LdProtect';
begin
  if hDriver <> INVALID_HANDLE_VALUE then
    Exit(True);

  hDriver := CreateFile(DEVICE_NAME, GENERIC_READ or GENERIC_WRITE, FILE_SHARE_READ or FILE_SHARE_WRITE, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);

  DugOutput('OpenCtrlDevice %x', [hDriver]);

  Result := hDriver <> INVALID_HANDLE_VALUE;
  if not Result then
    FLastErrCode := GetLastErrCode;

end;

function TDeviceHelper.RemoveBlack(pf: TProtectFile): Boolean;
begin
  result := CallDriver(IOCTL_PP_BLACK_REMOVE, @pf.id, SizeOf(pf.id), nil, 0);
  if Result then
    FBlackList.Remove(pf);
end;

function TDeviceHelper.RemoveProtectFile(pf: TProtectFile): Boolean;
begin
  result := CallDriver(IOCTL_FP_REMOVE, @pf.id, SizeOf(pf.id), nil, 0);
  if Result then
    FFileList.Remove(pf);
end;

function TDeviceHelper.RemoveWhite(pid: DWORD): Boolean;
begin
  result := CallDriver(IOCTL_PP_WHITE_REMOVE, @pid, SizeOf(pid));
  if Result then
    FWhiteList.Remove(pid);

end;

initialization

end.

