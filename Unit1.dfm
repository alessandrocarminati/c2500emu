object Form1: TForm1
  Left = -4
  Top = 28
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Cisco 2500 Emulator'
  ClientHeight = 533
  ClientWidth = 783
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 392
    Top = 8
    Width = 69
    Height = 13
    Caption = 'CPU Registers'
  end
  object Label2: TLabel
    Left = 392
    Top = 240
    Width = 64
    Height = 13
    Caption = 'Code window'
  end
  object Label3: TLabel
    Left = 0
    Top = 296
    Width = 29
    Height = 13
    Caption = 'View1'
  end
  object Label4: TLabel
    Left = 0
    Top = 408
    Width = 29
    Height = 13
    Caption = 'View2'
  end
  object Label5: TLabel
    Left = 0
    Top = 8
    Width = 71
    Height = 13
    Caption = 'Console output'
  end
  object Label6: TLabel
    Left = 256
    Top = 8
    Width = 31
    Height = 13
    Caption = 'status:'
  end
  object Label7: TLabel
    Left = 288
    Top = 8
    Width = 12
    Height = 13
    Caption = 'off'
  end
  object Label8: TLabel
    Left = 600
    Top = 240
    Width = 87
    Height = 13
    Caption = 'break point set @:'
  end
  object Label9: TLabel
    Left = 688
    Top = 240
    Width = 24
    Height = 13
    Caption = 'none'
  end
  object Label10: TLabel
    Left = 248
    Top = 416
    Width = 34
    Height = 13
    Caption = 'Cycles:'
  end
  object Label11: TLabel
    Left = 288
    Top = 416
    Width = 96
    Height = 13
    Caption = '0000000000000000'
  end
  object Label12: TLabel
    Left = 112
    Top = 8
    Width = 38
    Height = 13
    Caption = 'Label12'
  end
  object Label13: TLabel
    Left = 152
    Top = 416
    Width = 37
    Height = 13
    Caption = 'Confreg'
  end
  object Label14: TLabel
    Left = 472
    Top = 8
    Width = 38
    Height = 13
    Caption = 'Label14'
  end
  object Label15: TLabel
    Left = 536
    Top = 8
    Width = 38
    Height = 13
    Caption = 'Label15'
  end
  object Label16: TLabel
    Left = 104
    Top = 408
    Width = 6
    Height = 13
    Caption = '+'
  end
  object Button1: TButton
    Left = 0
    Top = 240
    Width = 41
    Height = 17
    Caption = '&Load'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Memo1: TMemo
    Left = 392
    Top = 24
    Width = 345
    Height = 212
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Fixedsys'
    Font.Style = []
    Lines.Strings = (
      '')
    ParentFont = False
    TabOrder = 1
  end
  object Button3: TButton
    Left = 0
    Top = 272
    Width = 41
    Height = 17
    Caption = '&Step'
    Enabled = False
    TabOrder = 2
    OnClick = Button3Click
  end
  object Button4: TButton
    Left = 40
    Top = 272
    Width = 49
    Height = 17
    Caption = 'R&eset'
    TabOrder = 3
    OnClick = Button4Click
  end
  object ListBox1: TListBox
    Left = 392
    Top = 256
    Width = 385
    Height = 273
    ItemHeight = 13
    TabOrder = 4
    Visible = False
  end
  object Memo2: TMemo
    Left = 0
    Top = 320
    Width = 385
    Height = 89
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 5
  end
  object Memo3: TMemo
    Left = 0
    Top = 432
    Width = 385
    Height = 97
    Font.Charset = OEM_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Terminal'
    Font.Style = []
    ParentFont = False
    TabOrder = 6
  end
  object Edit1: TEdit
    Left = 40
    Top = 296
    Width = 65
    Height = 21
    TabOrder = 7
    Text = '$00000000'
    OnExit = Edit1Exit
  end
  object Edit2: TEdit
    Left = 32
    Top = 408
    Width = 65
    Height = 21
    TabOrder = 8
    Text = '$0000'
    OnExit = Edit2Exit
  end
  object Memo4: TMemo
    Left = 0
    Top = 24
    Width = 297
    Height = 209
    Font.Charset = OEM_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Terminal'
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    TabOrder = 9
    WantTabs = True
    OnKeyPress = Memo4KeyPress
  end
  object Button6: TButton
    Left = 296
    Top = 200
    Width = 67
    Height = 17
    Caption = 'Console &on'
    TabOrder = 10
    OnClick = Button6Click
  end
  object Button7: TButton
    Left = 0
    Top = 256
    Width = 41
    Height = 17
    Caption = '&Run'
    Enabled = False
    TabOrder = 11
    OnClick = Button7Click
  end
  object Button8: TButton
    Left = 40
    Top = 256
    Width = 49
    Height = 17
    Caption = 'S&top'
    TabOrder = 12
    OnClick = Button8Click
  end
  object Edit3: TEdit
    Left = 120
    Top = 272
    Width = 73
    Height = 21
    TabOrder = 13
    Text = '$0'
  end
  object Button5: TButton
    Left = 360
    Top = 200
    Width = 33
    Height = 17
    Caption = 'SetPC'
    TabOrder = 14
    OnClick = Button5Click
  end
  object Edit4: TEdit
    Left = 120
    Top = 256
    Width = 73
    Height = 21
    TabOrder = 15
    Text = '$0'
  end
  object Button9: TButton
    Left = 336
    Top = 216
    Width = 25
    Height = 17
    Caption = 'Int'
    TabOrder = 16
    OnClick = Button9Click
  end
  object Button10: TButton
    Left = 192
    Top = 240
    Width = 33
    Height = 17
    Caption = 'regs'
    TabOrder = 17
    OnClick = Button10Click
  end
  object Edit5: TEdit
    Left = 120
    Top = 240
    Width = 73
    Height = 21
    TabOrder = 18
    Text = '$'
    OnExit = Edit5Exit
  end
  object Button12: TButton
    Left = 360
    Top = 216
    Width = 33
    Height = 17
    Caption = 'BPS'
    TabOrder = 19
    OnClick = Button12Click
  end
  object Button13: TButton
    Left = 120
    Top = 288
    Width = 17
    Height = 17
    Caption = 'Z'
    TabOrder = 20
    OnClick = Button13Click
  end
  object Button14: TButton
    Left = 136
    Top = 288
    Width = 17
    Height = 17
    Caption = 'V'
    TabOrder = 21
    OnClick = Button14Click
  end
  object Button15: TButton
    Left = 152
    Top = 288
    Width = 17
    Height = 17
    Caption = 'C'
    TabOrder = 22
    OnClick = Button15Click
  end
  object Button16: TButton
    Left = 168
    Top = 288
    Width = 17
    Height = 17
    Caption = 'N'
    TabOrder = 23
    OnClick = Button16Click
  end
  object Button17: TButton
    Left = 88
    Top = 240
    Width = 25
    Height = 17
    Caption = '&Full'
    TabOrder = 24
    OnClick = Button17Click
  end
  object Button18: TButton
    Left = 88
    Top = 256
    Width = 25
    Height = 17
    Caption = '&Half'
    TabOrder = 25
    OnClick = Button18Click
  end
  object Button19: TButton
    Left = 88
    Top = 272
    Width = 25
    Height = 17
    Caption = 'Lo&w'
    TabOrder = 26
    OnClick = Button19Click
  end
  object Memo5: TMemo
    Left = 232
    Top = 232
    Width = 153
    Height = 89
    Font.Charset = OEM_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Terminal'
    Font.Style = []
    ParentFont = False
    TabOrder = 27
  end
  object Memo6: TMemo
    Left = 296
    Top = 24
    Width = 97
    Height = 177
    Font.Charset = OEM_CHARSET
    Font.Color = clWindowText
    Font.Height = -8
    Font.Name = 'Terminal'
    Font.Style = []
    ParentFont = False
    TabOrder = 28
  end
  object Button2: TButton
    Left = 40
    Top = 240
    Width = 49
    Height = 17
    Caption = 'trace'
    TabOrder = 29
    OnClick = Button2Click
  end
  object Edit6: TEdit
    Left = 192
    Top = 408
    Width = 49
    Height = 21
    Enabled = False
    TabOrder = 30
    OnExit = Edit6Exit
  end
  object Button11: TButton
    Left = 296
    Top = 216
    Width = 41
    Height = 17
    Caption = 'Stats'
    TabOrder = 31
    OnClick = Button11Click
  end
  object Button20: TButton
    Left = 192
    Top = 256
    Width = 33
    Height = 17
    Caption = 'dump'
    TabOrder = 32
    OnClick = Button20Click
  end
  object Button21: TButton
    Left = 304
    Top = 8
    Width = 33
    Height = 17
    Caption = 'Save'
    TabOrder = 33
    OnClick = Button21Click
  end
  object Button22: TButton
    Left = 336
    Top = 8
    Width = 49
    Height = 17
    Caption = 'Load'
    TabOrder = 34
    OnClick = Button22Click
  end
  object Edit7: TEdit
    Left = 112
    Top = 408
    Width = 41
    Height = 21
    TabOrder = 35
    Text = '$0'
    OnExit = Edit2Exit
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 440
    Top = 40
  end
  object Timer2: TTimer
    Enabled = False
    Interval = 100
    OnTimer = Timer2Timer
    Left = 208
    Top = 32
  end
  object Timer3: TTimer
    OnTimer = Timer3Timer
    Left = 240
    Top = 32
  end
  object ServerSocket1: TServerSocket
    Active = True
    Port = 200
    ServerType = stNonBlocking
    OnClientRead = ServerSocket1ClientRead
    Left = 736
    Top = 48
  end
end
