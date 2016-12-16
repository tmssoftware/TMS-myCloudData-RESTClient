object ContactsDemoForm: TContactsDemoForm
  Left = 0
  Top = 12
  Caption = 'MyCloudData - VCL Contacts DEMO application'
  ClientHeight = 472
  ClientWidth = 922
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesigned
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object ConnectedAsLabel: TLabel
    Left = 241
    Top = 12
    Width = 59
    Height = 11
    Caption = 'Connected as:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -9
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object ConnectedAsValueLabel: TLabel
    Left = 308
    Top = 12
    Width = 69
    Height = 11
    Caption = 'not connected'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -9
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object AccountTypeLabel: TLabel
    Left = 241
    Top = 25
    Width = 58
    Height = 11
    Caption = 'Account type:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -9
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object AccountTypeValueLabel: TLabel
    Left = 308
    Top = 25
    Width = 69
    Height = 11
    Caption = 'not connected'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -9
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object DetailsGroupBox: TGroupBox
    Left = 280
    Top = 56
    Width = 329
    Height = 393
    Caption = 'Contact Details'
    TabOrder = 4
    object BirthDateLabel: TLabel
      Left = 16
      Top = 200
      Width = 61
      Height = 13
      Caption = 'Date of birth'
    end
    object RelationshipLabel: TLabel
      Left = 16
      Top = 264
      Width = 58
      Height = 13
      Caption = 'Relationship'
    end
    object EmailTextBox: TLabeledEdit
      Left = 16
      Top = 96
      Width = 297
      Height = 21
      EditLabel.Width = 24
      EditLabel.Height = 13
      EditLabel.Caption = 'Email'
      TabOrder = 1
    end
    object AddContactButton: TButton
      Left = 17
      Top = 336
      Width = 94
      Height = 33
      Caption = 'Add'
      TabOrder = 5
      OnClick = AddContactButtonClick
    end
    object BirthDatePicker: TDateTimePicker
      Left = 16
      Top = 219
      Width = 297
      Height = 21
      Date = 42709.405151655090000000
      Time = 42709.405151655090000000
      TabOrder = 3
    end
    object DeleteContactButton: TButton
      Left = 220
      Top = 336
      Width = 96
      Height = 33
      Caption = 'Delete'
      TabOrder = 7
      OnClick = DeleteContactButtonClick
    end
    object GenderSelectRadioGroup: TRadioGroup
      Left = 16
      Top = 131
      Width = 297
      Height = 55
      Caption = 'Gender'
      Columns = 2
      ItemIndex = 0
      Items.Strings = (
        'Male'
        'Female')
      TabOrder = 2
      TabStop = True
    end
    object IsFriendCheckbox: TCheckBox
      Left = 16
      Top = 283
      Width = 97
      Height = 17
      Caption = 'Friend'
      TabOrder = 4
    end
    object NameTextBox: TLabeledEdit
      Left = 16
      Top = 44
      Width = 297
      Height = 21
      EditLabel.Width = 27
      EditLabel.Height = 13
      EditLabel.Caption = 'Name'
      TabOrder = 0
    end
    object UpdateContactButton: TButton
      Left = 118
      Top = 336
      Width = 95
      Height = 33
      Caption = 'Update'
      TabOrder = 6
      OnClick = UpdateContactButtonClick
    end
  end
  object ConnectButton: TButton
    Left = 8
    Top = 8
    Width = 105
    Height = 33
    Caption = 'Connect'
    TabOrder = 0
    OnClick = ConnectButtonClick
  end
  object DisconnectButton: TButton
    Left = 119
    Top = 8
    Width = 105
    Height = 33
    Caption = 'Disconnect'
    TabOrder = 1
    OnClick = DisconnectButtonClick
  end
  object GenderFilterRadioGroup: TRadioGroup
    Left = 8
    Top = 56
    Width = 249
    Height = 65
    Caption = 'Filter by gender'
    Columns = 3
    ItemIndex = 2
    Items.Strings = (
      'Male'
      'Female'
      'All')
    TabOrder = 2
    TabStop = True
    OnClick = GenderFilterRadioGroupClick
  end
  object ContactsListBox: TListBox
    Left = 8
    Top = 136
    Width = 249
    Height = 313
    ItemHeight = 13
    TabOrder = 3
    OnClick = ContactsListBoxClick
  end
  object PictureGroupBox: TGroupBox
    Left = 623
    Top = 56
    Width = 281
    Height = 393
    Caption = 'Contact Image'
    TabOrder = 5
    object InsertPictureButton: TSpeedButton
      Left = 18
      Top = 336
      Width = 111
      Height = 33
      Caption = 'Insert Picture'
      OnClick = InsertPictureButtonClick
    end
    object RemovePictureButton: TSpeedButton
      Left = 135
      Top = 336
      Width = 98
      Height = 33
      Caption = 'Remove picture'
      OnClick = RemovePictureButtonClick
    end
    object ContactImage: TImage
      Left = 16
      Top = 43
      Width = 249
      Height = 257
      Proportional = True
      Stretch = True
    end
    object BlobsNotEnabledWarning: TLabel
      Left = 16
      Top = 25
      Width = 203
      Height = 12
      Caption = 'Blob fields are not available for free accounts.'
      Color = clRed
      Font.Charset = DEFAULT_CHARSET
      Font.Color = cl3DDkShadow
      Font.Height = -10
      Font.Name = 'Tahoma'
      Font.Style = [fsItalic]
      ParentColor = False
      ParentFont = False
    end
  end
  object PictureOpenDialog: TOpenDialog
    Filter = 'Images|*.jpeg;*.jpg;*.png;*.gif;*.bmp'
    Left = 680
    Top = 120
  end
end
