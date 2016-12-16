unit Demos.FMX.Contacts;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  FMX.Types,
  FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  REST.TMS.myCloudDataRestClient.Data,
  REST.TMS.myCloudDataRestClient,
  FMX.TMS.myCloudDataRestClient,
  FMX.Controls.Presentation,
  FMX.StdCtrls,
  FMX.Layouts,
  FMX.ListBox, FMX.Edit, FMX.DateTimeCtrls, FMX.Objects;

type
  TContactsDemoForm = class(TForm)
    ConnectButton: TButton;
    DisconnectButton: TButton;
    GenderFilterRadioGroup: TGroupBox;
    GenderFilterMaleRadioButton: TRadioButton;
    GenderFilterFemaleRadioButton: TRadioButton;
    GenderFilterAllRadioButton: TRadioButton;
    ContactsListBox: TListBox;
    ContactImage: TImage;
    AddContactButton: TButton;
    UpdateContactButton: TButton;
    DeleteContactButton: TButton;
    NameTextBox: TEdit;
    NameLabel: TLabel;
    EmailLabel: TLabel;
    EmailTextBox: TEdit;
    BirthDatePicker: TDateEdit;
    GenderSelectRadioGroup: TGroupBox;
    IsFriendCheckbox: TCheckBox;
    GenderSelectMaleRadioButton: TRadioButton;
    GenderSelectFemaleRadioButton: TRadioButton;
    InsertPictureButton: TButton;
    RemovePictureButton: TButton;
    PictureOpenDialog: TOpenDialog;
    ContactListGroupBox: TGroupBox;
    DetailsGroupBox: TGroupBox;
    PictureGroupBox: TGroupBox;
    BirthDateLabel: TLabel;
    RelationShipGroupBox: TGroupBox;
    ConnectedAsLabel: TLabel;
    ConnectedAsValueLabel: TLabel;
    AccountTypeLabel: TLabel;
    AccountTypeValueLabel: TLabel;
    BlobsNotEnabledWarning: TLabel;

    procedure FormCreate(Sender: TObject);
    procedure ConnectButtonClick(Sender: TObject);
    procedure DisconnectButtonClick(Sender: TObject);
    procedure ConnectedStatusChanged(ASender: TObject; const AConnected: Boolean);
    procedure ContactsListBoxClick(Sender: TObject);
    procedure AddContactButtonClick(Sender: TObject);
    procedure UpdateContactButtonClick(Sender: TObject);
    procedure DeleteContactButtonClick(Sender: TObject);
    procedure InsertPictureButtonClick(Sender: TObject);
    procedure RemovePictureButtonClick(Sender: TObject);
    procedure GenderFilterRadioOnChange(Sender: TObject);
  private
    FIsConnected: Boolean;
    FSelectedContact: TmyCloudDataEntity;
    FGenderFilter: integer;
    FContacstTable: TmyCloudDataTable;
    FContacts: TmyCloudDataEntities;
    MyCloudData: TFMXmyCloudDataRESTClient;

    procedure SetSelectedContact(AContactEntity: TmyCloudDataEntity);
    function GetApplicationInitialized: Boolean;
    property IsConnected: Boolean read FIsConnected write FIsConnected;
    property ApplicationInitialized: Boolean read GetApplicationInitialized;
    property ContactsTable: TmyCloudDataTable read FContacstTable write FContacstTable;
    property Contacts: TmyCloudDataEntities read FContacts write FContacts;
    property SelectedContact: TmyCloudDataEntity read FSelectedContact write SetSelectedContact;
    function BlobFieldsAreEnabled: Boolean;
    procedure InitializeComponents;
    procedure ToggleComponents;
    procedure InitializeContactsTable;
    procedure GetUserDetails;
    procedure LoadContacts;
    procedure UpdateContactsList;
    procedure ClearContactDetails;
    procedure LoadContactDetails;
    procedure LoadContactImage;
    procedure UpdateContactFromUI(AContact: TmyCloudDataEntity);
    procedure ShowErrorMessage(AMessage: string; AError: Exception);
  public
    destructor Destroy; override;
  end;

var
  ContactsDemoForm: TContactsDemoForm;

implementation

{$R *.fmx}
// TO RUN THIS DEMO APPLICATION, PLEASE USE A VALID INCLUDE FILE THAT CONTAINS
// THE APPLICATION KEY & SECRET FOR THE MyCloudData APPLICATION YOU WANT TO USE
// STRUCTURE OF THIS .INC FILE SHOULD BE
//
// const
//  MCDClientId = 'xxxxxxxxx';
//  MCDClientSecret = 'yyyyyyyy';

{$I APPIDS.INC}

procedure TContactsDemoForm.AddContactButtonClick(Sender: TObject);
var
  LContact: TmyCloudDataEntity;
begin
  LContact := ContactsTable.Entities.CreateEntity;
  UpdateContactFromUI(LContact);
  ContactsTable.Entities.Save;
  SelectedContact := LContact;
  UpdateContactsList;
end;

function TContactsDemoForm.BlobFieldsAreEnabled: Boolean;
begin
  Result := IsConnected AND MyCloudData.CurrentUser.CanUseBlobFields;
end;

procedure TContactsDemoForm.ClearContactDetails;
begin
  NameTextBox.Text := '';
  EmailTextBox.Text := '';
  GenderSelectMaleRadioButton.IsChecked := false;
  GenderSelectFemaleRadioButton.IsChecked := false;
  BirthDatePicker.DateTime := Now;
  IsFriendCheckbox.IsChecked := false;
  ContactImage.Bitmap := nil;
end;

procedure TContactsDemoForm.ConnectButtonClick(Sender: TObject);
begin
  try
    MyCloudData.Connect;
  except
    on E: Exception do
      ShowErrorMessage('Failed to connect', E);
  end;
end;

procedure TContactsDemoForm.ContactsListBoxClick(Sender: TObject);
var
  LContact: TmyCloudDataEntity;
begin
  if ContactsListBox.ItemIndex >= 0 then
  begin
    LContact := ContactsListBox.items.Objects[ContactsListBox.ItemIndex] as TmyCloudDataEntity;
    if not(LContact = nil) then
    begin
      SelectedContact := LContact;
    end
    else
    begin
      SelectedContact := nil;
    end;
  end;
end;

procedure TContactsDemoForm.DeleteContactButtonClick(Sender: TObject);
begin
  if not(SelectedContact = nil) then
  begin
    ContactsTable.Entities.RemoveEntity(SelectedContact.ID);
    ContactsTable.Entities.Save;
    UpdateContactsList;
  end;
end;

destructor TContactsDemoForm.Destroy;
begin
  if Assigned(MyCloudData) then
  begin
    MyCloudData.Free;
  end;
  inherited;
end;

procedure TContactsDemoForm.DisconnectButtonClick(Sender: TObject);
begin
  MyCloudData.Disconnect;
  MyCloudData.ClearToken;
end;

procedure TContactsDemoForm.FormCreate(Sender: TObject);
begin
  ReportMemoryLeaksOnShutdown := true;

  MyCloudData := TFMXmyCloudDataRESTClient.Create(self);

  MyCloudData.PersistTokens.Location := plIniFile;
  MyCloudData.PersistTokens.Section := 'test_section';
  MyCloudData.PersistTokens.Key := 'test_key.ini';

  MyCloudData.ClientId := MCDClientId;
  MyCloudData.ClientSecret := MCDClientSecret;
  MyCloudData.OnConnectedStatusChanged := ConnectedStatusChanged;

  MyCloudData.LoadToken;
  if (MyCloudData.IsTokenAvailable) then
  begin
    MyCloudData.Connect;
  end;

  ToggleComponents;
end;

function TContactsDemoForm.GetApplicationInitialized: Boolean;
begin
  Result := IsConnected AND Assigned(ContactsTable);
end;

procedure TContactsDemoForm.GetUserDetails;
begin
  if IsConnected AND (MyCloudData.CurrentUser <> nil) then
  begin
    ConnectedAsValueLabel.Text := MyCloudData.CurrentUser.Email;
    AccountTypeValueLabel.Text := MyCloudData.CurrentUser.UserTypeAsString;
  end
  else
  begin
    ConnectedAsValueLabel.Text := '';
    AccountTypeValueLabel.Text := '';
  end;
end;

procedure TContactsDemoForm.GenderFilterRadioOnChange(Sender: TObject);
var
  LNewGenderFilter: integer;
begin
  LNewGenderFilter := 0;
  if GenderFilterMaleRadioButton.IsChecked then
  begin
    LNewGenderFilter := 1;
  end;
  if GenderFilterFemaleRadioButton.IsChecked then
  begin
    LNewGenderFilter := 2;
  end;

  if (LNewGenderFilter <> FGenderFilter) then
  begin
    FGenderFilter := LNewGenderFilter;
    LoadContacts;
  end;

end;

procedure TContactsDemoForm.InitializeComponents;
begin
  GenderFilterAllRadioButton.IsChecked := true;
  ContactsListBox.items.Clear;
  ContactsListBox.ItemIndex := -1;
  ClearContactDetails;
  GetUserDetails;
end;

procedure TContactsDemoForm.InitializeContactsTable;
begin
  try
    // Get OR Create the table
    ContactsTable := MyCloudData.Tables.GetOrCreateTable('TMSRestClientDemo_Contacts');

    // Ensure that all necessary fields are present on the table
    ContactsTable.Fields.AddOrUpdate('Name', ftWideString, 50);
    ContactsTable.Fields.AddOrUpdate('EmailAddress', ftWideString);

    ContactsTable.Fields.AddOrUpdate('GenderCode', ftInteger);

    ContactsTable.Fields.AddOrUpdate('DateOfBirth', ftDateTime);
    ContactsTable.Fields.AddOrUpdate('RelationShip', ftWideString, 1);

    if BlobFieldsAreEnabled then
    begin
      ContactsTable.Fields.AddOrUpdate('Picture', ftBlob);
    end;

    // Save the fields
    ContactsTable.Fields.Save;

  except
    on E: Exception do
    begin
      if ContactsTable <> nil then
      begin
        ContactsTable := nil;
      end;
      ShowErrorMessage('Failed to initialize contacts table', E);
    end;
  end;
end;

procedure TContactsDemoForm.InsertPictureButtonClick(Sender: TObject);
var
  LPictureBlobField: TmyCloudDataBlob;
begin
  if SelectedContact <> nil then
  begin
    if PictureOpenDialog.Execute then
    begin
      LPictureBlobField := SelectedContact.GetBlobField('Picture');
      try
        LPictureBlobField.FromFile(PictureOpenDialog.FileName);
      except
        on E: Exception do
          ShowMessage('Upload failed, please try again');
      end;
      LoadContactImage;
    end;
  end;
end;

procedure TContactsDemoForm.LoadContactDetails;
begin
  NameTextBox.Text := SelectedContact.GetValue('Name');
  EmailTextBox.Text := SelectedContact.GetValue('EmailAddress');
  BirthDatePicker.Date := SelectedContact.GetValue('DateOfBirth');
  GenderSelectMaleRadioButton.IsChecked := SelectedContact.GetValue('GenderCode') = 1;
  GenderSelectFemaleRadioButton.IsChecked := SelectedContact.GetValue('GenderCode') = 2;
  IsFriendCheckbox.IsChecked := SelectedContact.GetValue('RelationShip') = 'F';
  LoadContactImage;
end;

procedure TContactsDemoForm.LoadContactImage;
var
  LPictureBlobField: TmyCloudDataBlob;
  LBitmap: TBitmap;
begin
  ContactImage.Bitmap := nil;
  InsertPictureButton.Enabled := false;
  RemovePictureButton.Enabled := false;
  if SelectedContact <> nil then
  begin
    LPictureBlobField := SelectedContact.GetBlobField('Picture');
    if (LPictureBlobField <> nil) then
    begin
      InsertPictureButton.Enabled := true;
      if (LPictureBlobField.HasData) then
      begin
        if (LPictureBlobField.TryGetAsBitmap(LBitmap)) then
        begin
          ContactImage.Bitmap := LBitmap;
          LBitmap.Free;
        end;
        RemovePictureButton.Enabled := true;
      end;
    end;
  end;
end;

procedure TContactsDemoForm.LoadContacts;
begin
  if ContactsTable <> nil then
  begin
    ContactsTable.Filters.Clear;
    if GenderFilterMaleRadioButton.IsChecked then
    begin
      ContactsTable.Filters.Add('GenderCode', 1, coEqual, loNone);
    end;
    if GenderFilterFemaleRadioButton.IsChecked then
    begin
      ContactsTable.Filters.Add('GenderCode', 2, coEqual, loNone);
    end;
    ContactsTable.Query;
    UpdateContactsList;
  end;
end;

procedure TContactsDemoForm.ConnectedStatusChanged(ASender: TObject; const AConnected: Boolean);
begin
  try

    IsConnected := AConnected;
    InitializeComponents;

    if AConnected then
    begin
      InitializeContactsTable;
      if ApplicationInitialized then
      begin
        LoadContacts;
      end;
    end
    else
    begin
      FSelectedContact := nil;
    end;

    ToggleComponents;
  except
    on E: Exception do
      ShowErrorMessage('Something went wrong', E);
  end;
end;

procedure TContactsDemoForm.RemovePictureButtonClick(Sender: TObject);
var
  LPictureBlobField: TmyCloudDataBlob;
begin
  if SelectedContact <> nil then
  begin
    LPictureBlobField := SelectedContact.GetBlobField('Picture');
    try
      LPictureBlobField.Stream := nil;
    except
      on E: Exception do
        ShowErrorMessage('Delete failed, please try again', E);
    end;
    LoadContactImage;
  end;
end;

procedure TContactsDemoForm.SetSelectedContact(AContactEntity: TmyCloudDataEntity);
begin
  if not(AContactEntity = nil) then
  begin
    if not(AContactEntity = FSelectedContact) then
    begin
      FSelectedContact := AContactEntity;
      LoadContactDetails;
      ToggleComponents;
    end;
  end
  else
  begin
    FSelectedContact := nil;
    ClearContactDetails;
  end;
end;

procedure TContactsDemoForm.ShowErrorMessage(AMessage: string; AError: Exception);
begin
  ShowMessage(AMessage + sLineBreak + sLineBreak + 'Details: ' + sLineBreak + AError.Message);
end;

procedure TContactsDemoForm.ToggleComponents;
begin
  ConnectButton.Enabled := not IsConnected;
  DisconnectButton.Enabled := IsConnected;
  GenderFilterRadioGroup.Enabled := ApplicationInitialized;
  ContactsListBox.Enabled := ApplicationInitialized;
  NameTextBox.Enabled := ApplicationInitialized;
  EmailTextBox.Enabled := ApplicationInitialized;
  GenderSelectRadioGroup.Enabled := ApplicationInitialized;
  BirthDatePicker.Enabled := ApplicationInitialized;
  IsFriendCheckbox.Enabled := ApplicationInitialized;
  AddContactButton.Enabled := ApplicationInitialized;
  UpdateContactButton.Enabled := ApplicationInitialized AND (SelectedContact <> nil);
  DeleteContactButton.Enabled := ApplicationInitialized AND (SelectedContact <> nil);

  BlobsNotEnabledWarning.Visible := IsConnected AND (not BlobFieldsAreEnabled);
  InsertPictureButton.Visible := ApplicationInitialized AND BlobFieldsAreEnabled AND (SelectedContact <> nil);
  RemovePictureButton.Visible := ApplicationInitialized AND BlobFieldsAreEnabled AND (SelectedContact <> nil);
  ContactImage.Visible := ApplicationInitialized AND BlobFieldsAreEnabled AND (SelectedContact <> nil);
end;

procedure TContactsDemoForm.UpdateContactButtonClick(Sender: TObject);
var
  LContact: TmyCloudDataEntity;
begin
  LContact := ContactsTable.Entities.GetEntity(SelectedContact.ID);
  if LContact <> nil then
  begin
    UpdateContactFromUI(LContact);
    ContactsTable.Entities.Save;
    UpdateContactsList;
  end;
end;

procedure TContactsDemoForm.UpdateContactFromUI(AContact: TmyCloudDataEntity);
begin
  AContact.SetValue('Name', NameTextBox.Text);
  AContact.SetValue('EmailAddress', EmailTextBox.Text);
  AContact.SetValue('DateOfBirth', BirthDatePicker.DateTime);
  if IsFriendCheckbox.IsChecked then
  begin
    AContact.SetValue('RelationShip', 'F');
  end
  else
  begin
    AContact.SetValue('RelationShip', '');
  end;

  if GenderSelectMaleRadioButton.IsChecked then
    AContact.SetValue('GenderCode', 1);
  if GenderSelectFemaleRadioButton.IsChecked then
    AContact.SetValue('GenderCode', 2);

end;

procedure TContactsDemoForm.UpdateContactsList;
var
  LContact: TmyCloudDataEntity;
  LIndexCounter: integer;
  LSelectedContactFound: Boolean;
begin
  if ContactsTable <> nil then
  begin
    Contacts := ContactsTable.Entities;
    ContactsListBox.Clear;
    LIndexCounter := 0;
    LSelectedContactFound := false;
    for LContact in Contacts do
    begin
      ContactsListBox.items.AddObject(LContact.GetValue('Name'), LContact);
      if (SelectedContact <> nil) AND (LContact.ID = SelectedContact.ID) then
      begin
        ContactsListBox.ItemIndex := LIndexCounter;
        LSelectedContactFound := true;
      end;
      LIndexCounter := LIndexCounter + 1;
    end;
    if (not LSelectedContactFound) then
    begin
      if (ContactsListBox.items.Count > 0) then
      begin
        ContactsListBox.ItemIndex := 0;
      end
      else
      begin
        ContactsListBox.ItemIndex := -1;
        SelectedContact := nil;
      end;
    end;
  end;
end;

end.
