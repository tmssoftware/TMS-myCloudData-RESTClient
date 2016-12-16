unit Demos.VCL.Contacts;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, VCL.Graphics,
  VCL.Controls, VCL.Forms, VCL.Dialogs, IPPeerClient, Data.Bind.Components,
  Data.Bind.ObjectScope, REST.Client, REST.TMS.myCloudDataRestClient.Data,
  REST.TMS.myCloudDataRestClient, VCL.TMS.myCloudDataRestClient, VCL.StdCtrls,
  VCL.ExtCtrls, VCL.ComCtrls, VCL.Buttons;

type

  TContactsDemoForm = class(TForm)
    ConnectButton: TButton;
    DisconnectButton: TButton;
    GenderFilterRadioGroup: TRadioGroup;
    ContactsListBox: TListBox;
    ContactImage: TImage;
    AddContactButton: TButton;
    UpdateContactButton: TButton;
    DeleteContactButton: TButton;
    NameTextBox: TLabeledEdit;
    EmailTextBox: TLabeledEdit;
    BirthDatePicker: TDateTimePicker;
    GenderSelectRadioGroup: TRadioGroup;
    BirthDateLabel: TLabel;
    RelationshipLabel: TLabel;
    IsFriendCheckbox: TCheckBox;
    InsertPictureButton: TSpeedButton;
    RemovePictureButton: TSpeedButton;
    PictureOpenDialog: TOpenDialog;
    DetailsGroupBox: TGroupBox;
    PictureGroupBox: TGroupBox;
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
    procedure GenderFilterRadioGroupClick(Sender: TObject);
  private
    FIsConnected: Boolean;
    FSelectedContact: TmyCloudDataEntity;
    FContacstTable: TmyCloudDataTable;
    FContacts: TmyCloudDataEntities;
    MyCloudData: TVCLmyCloudDataRESTClient;

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

{$R *.dfm}
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
  GenderSelectRadioGroup.ItemIndex := -1;
  BirthDatePicker.Date := Now;
  IsFriendCheckbox.Checked := false;
  ContactImage.Picture := nil;
end;

procedure TContactsDemoForm.ConnectButtonClick(Sender: TObject);
begin
  MyCloudData.Connect;
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

  MyCloudData := TVCLmyCloudDataRESTClient.Create(self);

  MyCloudData.PersistTokens.Location := plRegistry;
  MyCloudData.PersistTokens.Section := 'test_section';
  MyCloudData.PersistTokens.Key := 'test_key';

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
    ConnectedAsValueLabel.Caption := MyCloudData.CurrentUser.Email;
    AccountTypeValueLabel.Caption := MyCloudData.CurrentUser.UserTypeAsString;
  end
  else
  begin
    ConnectedAsValueLabel.Caption := '';
    AccountTypeValueLabel.Caption := '';
  end;
end;

procedure TContactsDemoForm.GenderFilterRadioGroupClick(Sender: TObject);
begin
  LoadContacts;
end;

procedure TContactsDemoForm.InitializeComponents;
begin
  GenderFilterRadioGroup.ItemIndex := 2;
  ContactsListBox.Clear;
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
  GenderSelectRadioGroup.ItemIndex := SelectedContact.GetValue('GenderCode') - 1;
  IsFriendCheckbox.Checked := SelectedContact.GetValue('RelationShip') = 'F';
  LoadContactImage;
end;

procedure TContactsDemoForm.LoadContactImage;
var
  LPictureBlobField: TmyCloudDataBlob;
  LGraphic: TGraphic;
begin
  ContactImage.Picture := nil;
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
        if (LPictureBlobField.TryGetAsGraphic(LGraphic)) then
        begin
          ContactImage.Picture.Graphic := LGraphic;
          LGraphic.Free;
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
    if (GenderFilterRadioGroup.ItemIndex in [0, 1]) then
    begin
      ContactsTable.Filters.Add('GenderCode', GenderFilterRadioGroup.ItemIndex + 1, coEqual, loNone);
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
  if IsFriendCheckbox.Checked then
  begin
    AContact.SetValue('RelationShip', 'F');
  end
  else
  begin
    AContact.SetValue('RelationShip', '');
  end;

  case GenderSelectRadioGroup.ItemIndex of
    0:
      AContact.SetValue('GenderCode', 1);
    1:
      AContact.SetValue('GenderCode', 2);
  end;
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
    ContactsListBoxClick(ContactsListBox);
  end;
end;

end.
