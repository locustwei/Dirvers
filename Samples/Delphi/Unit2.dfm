object Form2: TForm2
  Left = 0
  Top = 0
  Caption = 'Form2'
  ClientHeight = 422
  ClientWidth = 712
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object pgc1: TPageControl
    Left = 16
    Top = 8
    Width = 688
    Height = 393
    ActivePage = ts3
    TabOrder = 0
    object ts1: TTabSheet
      Caption = #36827#31243#40657#21517#21333
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object btn1: TSpeedButton
        Left = 400
        Top = 24
        Width = 23
        Height = 22
        OnClick = btn1Click
      end
      object edt1: TEdit
        Left = 48
        Top = 24
        Width = 345
        Height = 21
        TabOrder = 0
        Text = 'wisecalc.exe'
      end
      object btn2: TBitBtn
        Left = 48
        Top = 51
        Width = 129
        Height = 25
        Caption = #28155#21152#40657#21517#21333
        TabOrder = 1
        OnClick = btn2Click
      end
      object BitBtn1: TBitBtn
        Left = 183
        Top = 51
        Width = 129
        Height = 25
        Caption = #40657#21517#21333#21015#34920
        TabOrder = 2
        OnClick = BitBtn1Click
      end
      object lst1: TListBox
        Left = 56
        Top = 120
        Width = 561
        Height = 217
        ItemHeight = 13
        TabOrder = 3
      end
      object BitBtn2: TBitBtn
        Left = 318
        Top = 52
        Width = 129
        Height = 25
        Caption = #31227#38500#40657#21517#21333
        TabOrder = 4
        OnClick = BitBtn2Click
      end
    end
    object ts2: TTabSheet
      Caption = #36827#31243#30333#21517#21333
      ImageIndex = 1
      OnShow = ts2Show
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object lst2: TListBox
        Left = 3
        Top = 13
        Width = 361
        Height = 346
        ItemHeight = 13
        TabOrder = 0
      end
      object BitBtn3: TBitBtn
        Left = 370
        Top = 13
        Width = 129
        Height = 25
        Caption = #28155#21152#30333#21517#21333
        TabOrder = 1
        OnClick = BitBtn3Click
      end
      object BitBtn4: TBitBtn
        Left = 370
        Top = 44
        Width = 129
        Height = 25
        Caption = #30333#21517#21333#21015#34920
        TabOrder = 2
        OnClick = BitBtn4Click
      end
      object BitBtn5: TBitBtn
        Left = 370
        Top = 75
        Width = 129
        Height = 25
        Caption = #31227#38500#30333#21517#21333
        TabOrder = 3
        OnClick = BitBtn5Click
      end
      object lst3: TListBox
        Left = 373
        Top = 144
        Width = 272
        Height = 215
        ItemHeight = 13
        TabOrder = 4
      end
    end
    object ts3: TTabSheet
      Caption = #25991#20214#20445#25252
      ImageIndex = 2
      object BitBtn6: TBitBtn
        Left = 56
        Top = 59
        Width = 129
        Height = 25
        Caption = #28155#21152#20445#25252#25991#20214
        TabOrder = 0
        OnClick = BitBtn6Click
      end
      object BitBtn7: TBitBtn
        Left = 191
        Top = 59
        Width = 129
        Height = 25
        Caption = #20445#25252#25991#20214#21015#34920
        TabOrder = 1
        OnClick = BitBtn7Click
      end
      object ListBox1: TListBox
        Left = 64
        Top = 128
        Width = 561
        Height = 217
        ItemHeight = 13
        TabOrder = 2
      end
      object BitBtn8: TBitBtn
        Left = 326
        Top = 60
        Width = 129
        Height = 25
        Caption = #31227#38500#20445#25252#25991#20214
        TabOrder = 3
        OnClick = BitBtn8Click
      end
    end
  end
  object dlgOpen1: TOpenDialog
    Left = 312
    Top = 312
  end
end
