unit Unit2;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.Generics.Collections,
  DeviceHelper, Vcl.StdCtrls, Vcl.Buttons, Vcl.ComCtrls;

type
  TForm2 = class(TForm)
    dlgOpen1: TOpenDialog;
    pgc1: TPageControl;
    ts1: TTabSheet;
    edt1: TEdit;
    btn1: TSpeedButton;
    btn2: TBitBtn;
    BitBtn1: TBitBtn;
    lst1: TListBox;
    BitBtn2: TBitBtn;
    ts2: TTabSheet;
    lst2: TListBox;
    BitBtn3: TBitBtn;
    BitBtn4: TBitBtn;
    BitBtn5: TBitBtn;
    lst3: TListBox;
    ts3: TTabSheet;
    BitBtn6: TBitBtn;
    BitBtn7: TBitBtn;
    ListBox1: TListBox;
    BitBtn8: TBitBtn;
    procedure FormCreate(Sender: TObject);
    procedure btn2Click(Sender: TObject);
    procedure btn1Click(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure ts2Show(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
    procedure BitBtn4Click(Sender: TObject);
    procedure BitBtn5Click(Sender: TObject);
    procedure BitBtn6Click(Sender: TObject);
    procedure BitBtn7Click(Sender: TObject);
    procedure BitBtn8Click(Sender: TObject);
  private
    { Private declarations }
    FHelper: TDeviceHelper;
    procedure EnumProcess;
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

uses Winapi.PsAPI, Winapi.TlHelp32, Utils, Winapi.ShellAPI;

{$R *.dfm}


procedure TForm2.BitBtn1Click(Sender: TObject);
var
  i: Integer;
begin
  FHelper.GetBlackList();
  lst1.Clear;
  for i := 0 to FHelper.FBlackList.Count-1 do
  begin
    lst1.AddItem(FHelper.FBlackList[i].Name, FHelper.FBlackList[i]);
  end;
end;

procedure TForm2.BitBtn2Click(Sender: TObject);
begin
  if lst1.ItemIndex=-1 then
  begin
    ShowMessage('选择要移除文件');
    Exit;
  end;

  if FHelper.RemoveBlack(TProtectFile(lst1.Items.Objects[lst1.ItemIndex])) then
    lst1.Items.Delete(lst1.ItemIndex);
end;

procedure TForm2.BitBtn3Click(Sender: TObject);
begin
  if lst2.ItemIndex=-1 then
  begin
    ShowMessage('选择进程');
    Exit;
  end;

  FHelper.AddProcessById(Cardinal(lst2.Items.Objects[lst2.ItemIndex]));
end;

procedure TForm2.BitBtn4Click(Sender: TObject);
var
  i: Integer;
begin
  FHelper.GetWhiteList;
  lst3.Clear;
  for i := 0 to FHelper.FWhiteList.Count-1 do
  begin
      lst3.AddItem(IntToStr(FHelper.FWhiteList[i]), TObject(FHelper.FWhiteList[i]))

  end;

end;

procedure TForm2.BitBtn5Click(Sender: TObject);
begin
  if lst3.ItemIndex=-1 then
  begin
    ShowMessage('选择要移除文件');
    Exit;
  end;

  if FHelper.RemoveWhite(dword(lst3.Items.Objects[lst3.ItemIndex])) then
    lst3.Items.Delete(lst3.ItemIndex);
end;

procedure TForm2.BitBtn6Click(Sender: TObject);
begin
  if dlgOpen1.Execute(Handle) then
    FHelper.AddProtectFile(dlgOpen1.FileName);
end;

procedure TForm2.BitBtn7Click(Sender: TObject);
var
  i: Integer;
begin
  FHelper.GetProctectList;
  ListBox1.Clear;
  for i := 0 to FHelper.FFileList.Count-1 do
  begin
      ListBox1.AddItem(FHelper.FFileList[i].Name, TObject(FHelper.FFileList[i]))

  end;
end;

procedure TForm2.BitBtn8Click(Sender: TObject);
begin
  if ListBox1.ItemIndex=-1 then
  begin
    ShowMessage('选择要移除文件');
    Exit;
  end;

  if FHelper.RemoveProtectFile(TProtectFile(ListBox1.Items.Objects[ListBox1.ItemIndex])) then
    ListBox1.Items.Delete(ListBox1.ItemIndex);

end;

procedure TForm2.btn1Click(Sender: TObject);
begin
    if dlgOpen1.Execute(Handle) then
      edt1.Text := dlgOpen1.FileName;
end;

procedure TForm2.btn2Click(Sender: TObject);
begin
    FHelper.AddBlackList(edt1.Text);
end;

function RunElevated(const AParameters: String): Cardinal; overload;
var
  SEI: TShellExecuteInfo;
  Host: String;
  Args: String;
begin
    Result := 0;
  Host := ParamStr(0);
  Args := AParameters;

  FillChar(SEI, SizeOf(SEI), 0);
  SEI.cbSize := SizeOf(SEI);
  SEI.fMask := SEE_MASK_NOCLOSEPROCESS or SEE_MASK_WAITFORINPUTIDLE or SEE_MASK_NOASYNC;
  {$IFDEF UNICODE}
  SEI.fMask := SEI.fMask or SEE_MASK_UNICODE;
  {$ENDIF}
  SEI.Wnd := 0;
  SEI.lpVerb := 'runas';
  SEI.lpFile := PChar(Host);
  SEI.lpParameters := PChar(Args);
  SEI.nShow := SW_SHOWNORMAL;
  ShellExecuteEx(@SEI);
end;

procedure TForm2.FormCreate(Sender: TObject);
begin

  FHelper := TDeviceHelper.Create();
  if not FHelper.IsValid then
  begin
      if MessageDlg( 'Fail to load the driver, install or start driver. install now?', mtError, [mbYes, mbNo], 0) = IDYES then
          RunElevated('/install');
  end;

end;


procedure TForm2.EnumProcess();
var
    IsLoopContinue:BOOL;
    FSnapshotHandle:THandle;
    FProcessEntry32:TProcessEntry32;
    fileName:string;
    ProHandle: THandle;

    procedure initEntry();
    begin
        FillChar(FProcessEntry32, SizeOf(FProcessEntry32), 0);
        FProcessEntry32.dwSize := SizeOf(FProcessEntry32);
    end;

begin
    FSnapshotHandle:= CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS,0); // 创建系统快照
    initEntry(); //FProcessEntry32.dwSize:=Sizeof(FProcessEntry32); // 必须先设置结构的大小
    IsLoopContinue:= Process32First(FSnapshotHandle,FProcessEntry32); //得到第一个进程信息
    while IsLoopContinue do
    begin
        ProHandle := OpenProcess(PROCESS_QUERY_INFORMATION,False,FProcessEntry32.th32ProcessID);
        if ProHandle<>0 then
        begin
            fileName := GetProcessFileName(ProHandle);
            CloseHandle(ProHandle);
            if fileName<>'' then
              lst2.AddItem(Format('%d %s', [FProcessEntry32.th32ProcessID, fileName]), TObject(FProcessEntry32.th32ProcessID));
        end;

        initEntry();
        IsLoopContinue:=Process32Next(FSnapshotHandle,FProcessEntry32); // 继续枚举
    end;
    CloseHandle(FSnapshotHandle); // 释放快照句柄
end;

procedure TForm2.ts2Show(Sender: TObject);
begin
  lst2.Clear;
  EnumProcess;
end;

end.
