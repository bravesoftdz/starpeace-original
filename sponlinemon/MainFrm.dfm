object MainForm: TMainForm
  Left = 127
  Top = 177
  Width = 811
  Height = 453
  Caption = 'Online Players Monitor'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Icon.Data = {
    0000010001002020100000000000E80200001600000028000000200000004000
    0000010004000000000080020000000000000000000000000000000000000000
    000000008000008000000080800080000000800080008080000080808000C0C0
    C0000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF000000
    000000000000000000000000000000CC000000000000000000000000000000CC
    0000000000000000000000000000CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
    CCCCCCCCCCCCCCCCCCCCCCCCCCCC00CC000000000000000000000000000000CC
    000000000000000000000000000000CC099000000000000000000000000000CC
    099900000000000000000000000000CC009990000000000000000000000000CC
    000999000000000000000000000000CC000099990000000000000000000000CC
    000009999900000000000000000000CC000000099999900000000000000000CC
    000000000999999900000000000000CC00000000000FFFFFFFFF0000000000CC
    00000000FFFFFFFFFFFFFFFF000000CC00000FFFFFFF0000099FFFFFFF0000CC
    000FFFFFF00000000009990FFFFF00CC000FFF0000000000000099000FFF00CC
    000000000000000000000990000000CC000000000000000000000999000000CC
    000000000000000000000099000000CC000000000000000000000099000000CC
    000000000000000000000009900000CC000000000000000000000009900000CC
    000000000000000000000009900000CC000000000000000000000000000000CC
    0000000000000000000000000000000000000000000000000000000000000000
    000000000000000000000000000000000000000000000000000000000000FFFF
    FFFFCFFFFFFFCFFFFFFF0000000000000000CFFFFFFFCFFFFFFFC9FFFFFFC8FF
    FFFFCC7FFFFFCE3FFFFFCF0FFFFFCF83FFFFCFE07FFFCFF80FFFCFFE00FFCFF0
    000FCF80F803CE07FE20CE3FFF38CFFFFF9FCFFFFF8FCFFFFFCFCFFFFFCFCFFF
    FFE7CFFFFFE7CFFFFFE7CFFFFFFFCFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF}
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 803
    Height = 384
    Align = alClient
    BevelOuter = bvNone
    Caption = 'Panel1'
    TabOrder = 0
    object Splitter1: TSplitter
      Left = 153
      Top = 0
      Width = 5
      Height = 384
      Cursor = crHSplit
    end
    object tvMonTree: TTreeView
      Left = 0
      Top = 0
      Width = 153
      Height = 384
      Align = alLeft
      Indent = 19
      ReadOnly = True
      TabOrder = 0
      OnChange = tvMonTreeChange
    end
    object Chart1: TChart
      Left = 158
      Top = 0
      Width = 645
      Height = 384
      AnimatedZoom = True
      BackWall.Brush.Color = clWhite
      BackWall.Brush.Style = bsClear
      Title.Text.Strings = (
        'Online Players')
      Title.Visible = False
      Chart3DPercent = 10
      Legend.Visible = False
      View3D = False
      Align = alClient
      TabOrder = 1
      AutoSize = True
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 384
    Width = 803
    Height = 42
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object Label1: TLabel
      Left = 6
      Top = 14
      Width = 37
      Height = 13
      Caption = 'Server: '
    end
    object Label2: TLabel
      Left = 334
      Top = 14
      Width = 25
      Height = 13
      Caption = 'Port: '
    end
    object btnStart: TButton
      Left = 427
      Top = 12
      Width = 86
      Height = 25
      Caption = 'Start'
      TabOrder = 0
      OnClick = btnStartClick
    end
    object eServer: TEdit
      Left = 48
      Top = 13
      Width = 265
      Height = 21
      TabOrder = 1
      Text = '10.10.15.101'
    end
    object ePort: TEdit
      Left = 362
      Top = 13
      Width = 45
      Height = 21
      TabOrder = 2
      Text = '2222'
    end
  end
  object TickTimer: TTimer
    Enabled = False
    Interval = 60000
    OnTimer = TickTimerTimer
    Left = 696
    Top = 312
  end
end
