{ *************************************************************************** }
{ TMS myCloudData REST Client data structures                                 }
{ for Delphi & C++Builder                                                     }
{                                                                             }
{ written by TMS Software                                                     }
{ copyright © 2016                                                            }
{ Email : info@tmssoftware.com                                                }
{ Web : http://www.tmssoftware.com                                            }
{                                                                             }
{ The source code is given as is. The author is not responsible               }
{ for any possible damage done due to the use of this code.                   }
{ The component can be freely used in any application. The complete           }
{ source code remains property of the author and may not be distributed,      }
{ published, given or sold in any form as such. No parts of the source        }
{ code can be included in any other component or application without          }
{ written authorization of the author.                                        }
{ *************************************************************************** }

unit REST.TMS.myCloudDataRestClient;

interface

uses
  // For debugging
  //Windows,
  //
  Classes, DB,
  Types,
  REST.Client,
  REST.Authenticator.OAuth,
  Data.Bind.Components,
  Data.Bind.ObjectScope,
  REST.Utils,
  REST.Types,
  REST.TMS.myCloudDataRestClient.Data;

const
  C1 = 52845;
  C2 = 22719;

type

  TOnConnectedStatusChangedEvent = procedure(ASender: TObject; const AConnected: Boolean) of object;

  TPersistLocation = (plIniFile, plRegistry, plDatabase);

  TPersistTokens = class(TPersistent)
  private
    FLocation: TPersistLocation;
    FSection: string;
    FKey: string;
    FDataSource: TDataSource;
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
  published
    property DataSource: TDataSource read FDataSource write FDataSource;
    property Location: TPersistLocation read FLocation write FLocation default plIniFile;
    property Section: string read FSection write FSection;
    property Key: string read FKey write FKey;
  end;

  TmyCloudDataRESTClient = class(TCustomMyCloudDataRESTClient)
  private
    FAuthenticator: TOAuth2Authenticator;
    FCallBackUrl: string;
    FClientID: string;
    FClientSecret: string;
    FPersistTokens: TPersistTokens;
    FOnConnectedStatusChanged: TOnConnectedStatusChangedEvent;
  protected

    procedure OAuth2_AuthTokenRedirect(const AURL: string; var DoCloseWebView: Boolean);
    procedure SetPersistTokens(const Value: TPersistTokens);
    procedure SetAccessToken(const Value: string);
    function GetIniFilePath(Value: string): string;
    function InternalConnect: Boolean;
    function GetAccessToken: string;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function GetLoginUrl: string; virtual;
    function IsTokenAvailable: Boolean;
    function ValidateAccessToken: Boolean;
    procedure Authenticate; virtual; abstract;
    procedure ClearToken;
    procedure Connect;
    procedure Disconnect;
    procedure LoadToken;
    procedure SaveToken;
  published
    property AccessToken: string read GetAccessToken write SetAccessToken;
    property CallBackUrl: string read FCallBackUrl write FCallBackUrl;
    property ClientID: string read FClientID write FClientID;
    property ClientSecret: string read FClientSecret write FClientSecret;
    property PersistTokens: TPersistTokens read FPersistTokens write SetPersistTokens;
    property OnConnectedStatusChanged: TOnConnectedStatusChangedEvent read FOnConnectedStatusChanged write FOnConnectedStatusChanged;
  end;

implementation

uses
  System.SysUtils, System.IOUtils, INIFiles {$IFDEF MSWINDOWS}, Registry {$ENDIF};

function EnDeCrypt(const Value: string): string;
var
  r: string;
  i: integer;
  c: char;
  b: byte;
begin
  r := '';
{$IFDEF DELPHI_LLVM}
  for i := 0 to length(Value) - 1 do
{$ELSE}
  for i := 1 to length(Value) do
{$ENDIF}
  begin
    b := ord(Value[i]);
    b := (b and $E0) + ((b and $1F) xor 5);
    c := chr(b);
    r := r + c;
  end;
  Result := r;
end;
{ TmyCloudDataRestClient }

procedure TmyCloudDataRESTClient.ClearToken;
begin
  AccessToken := '';
  SaveToken;
end;

procedure TmyCloudDataRESTClient.Connect;
begin
  if not IsConnected then
  begin

    if not IsTokenAvailable then
    begin
      LoadToken;
    end;

    if not IsTokenAvailable then
    begin
      Authenticate;
      Exit;
    end;

    if IsTokenAvailable then
    begin
      if InternalConnect then
      begin
        SaveToken;
      end
      else
      begin
        ClearToken;
      end;
    end;
  end;
end;

procedure TmyCloudDataRESTClient.Disconnect;
begin
  if IsConnected then
  begin
    FIsConnected := false;

    FreeLocalData;

    if Assigned(OnConnectedStatusChanged) then
    begin
      OnConnectedStatusChanged(self, FIsConnected);
    end;
  end;
end;

procedure TmyCloudDataRESTClient.LoadToken;
var
  Settings: TIniFile;
{$IFDEF MSWINDOWS}
  RegInifile: TReginifile;
{$ENDIF}
  S: string;
  fld: TField;
begin
  if PersistTokens = nil then
  begin
    Exit;
  end;

  if PersistTokens.Location <> plDatabase then
  begin
    if (PersistTokens.Key = '') OR (PersistTokens.Section = '') then
    begin
      Exit;
    end;
  end;

  case PersistTokens.Location of
    plIniFile:
      begin
        Settings := TIniFile.Create(GetIniFilePath(PersistTokens.Key));
        try
          S := Settings.ReadString(PersistTokens.Section, 'ACCESS_TOKEN', '');
          AccessToken := EnDeCrypt(S);
        finally
          Settings.Free;
        end;
      end;
    plRegistry:
      begin
{$IFDEF MSWINDOWS}
        RegInifile := TReginifile.Create(PersistTokens.Key);
        try
          S := RegInifile.ReadString(PersistTokens.Section, 'ACCESS_TOKEN', '');
          AccessToken := EnDeCrypt(S);
        finally
          RegInifile.Free;
        end;
{$ENDIF}
      end;
    plDatabase:
      begin
        if Assigned(PersistTokens.DataSource) and Assigned(PersistTokens.DataSource.DataSet) and (PersistTokens.DataSource.DataSet.Active) then
        begin
          fld := PersistTokens.DataSource.DataSet.FieldByName('ACCESS_TOKEN');
          if Assigned(fld) then
          begin
            S := fld.AsString;
            AccessToken := EnDeCrypt(S);
          end;
        end;
      end;
  end;
end;

constructor TmyCloudDataRESTClient.Create(AOwner: TComponent);
begin
  inherited;
  BaseURL := 'http://api.myclouddata.net/';
  CallBackUrl := 'http://myclouddata.net/afterlogin.html';
  FAuthenticator := TOAuth2Authenticator.Create(self);
  FAuthenticator.AccessToken := '';
  FAuthenticator.TokenType := TOAuth2TokenType.ttBEARER;
  FPersistTokens := TPersistTokens.Create;
  Authenticator := FAuthenticator;
end;

destructor TmyCloudDataRESTClient.Destroy;
begin
  if Assigned(FPersistTokens) then
    FPersistTokens.Free;
  if Assigned(FAuthenticator) then
    FAuthenticator.Free;
  inherited;
end;

function TmyCloudDataRESTClient.GetAccessToken: string;
begin
  Result := '';
  if Assigned(FAuthenticator) then
  begin
    Result := FAuthenticator.AccessToken;
  end;
end;

function TmyCloudDataRESTClient.GetIniFilePath(Value: string): string;
var
  iIndex: integer;
  sInvalidCharacters: array of string;
begin
  sInvalidCharacters := [' ', '\', '/', ':', '*', '?', '"', '<', '>', '|'];
  for iIndex := 1 to length(sInvalidCharacters) - 1 do
  begin
    Value := StringReplace(Value, sInvalidCharacters[iIndex], 'ss-', [rfReplaceAll]);
  end;
  Result := TPath.GetDocumentsPath + PathDelim + Value;
end;

function TmyCloudDataRESTClient.GetLoginUrl: string;
begin
  if ClientID = '' then
  begin
    raise Exception.Create('Please provide a ClientID');
  end;
  if CallBackUrl = '' then
  begin
    raise Exception.Create('Please provide a Callback URL');
  end;
  Result := BaseURL + '/login.html';
  Result := Result + '#?client_id=' + ClientID;
  Result := Result + '&redirect_uri=' + URIEncode(CallBackUrl);
  Result := Result + '&response_type=code&state=profile';
end;

function TmyCloudDataRESTClient.IsTokenAvailable: Boolean;
begin
  Result := AccessToken.Trim <> '';
end;

function TmyCloudDataRESTClient.InternalConnect: Boolean;
begin
  Result := false;
  if ValidateAccessToken then
  begin
    FIsConnected := true;
    Result := true;
    if Assigned(OnConnectedStatusChanged) then
    begin
      OnConnectedStatusChanged(self, FIsConnected);
    end;
  end;
end;

procedure TmyCloudDataRESTClient.OAuth2_AuthTokenRedirect(const AURL: string; var DoCloseWebView: Boolean);
var
  LAUTPos: integer;
  LCode: string;
  LAccessToken: string;
begin
  LAUTPos := Pos('code=', AURL);

  if (LAUTPos > 0) then
  begin
    LCode := Copy(AURL, LAUTPos + 5, length(AURL));
    if (Pos('&', LCode) > 0) then
    begin
      LCode := Copy(LCode, 1, Pos('&', LCode) - 1);
    end;

    DoCloseWebView := true;

    Request.ResetToDefaults;
    Request.Accept := 'application/json';
    Request.Client := self;

    LAccessToken := '';

    Request.Method := TRESTRequestMethod.rmPOST;
    Request.Resource := '/oauth/token';
    Request.Params.AddItem('code', LCode, TRESTRequestParameterKind.pkGETorPOST);
    Request.Params.AddItem('client_id', ClientID, TRESTRequestParameterKind.pkGETorPOST);
    Request.Params.AddItem('client_secret', ClientSecret, TRESTRequestParameterKind.pkGETorPOST);
    Request.Execute;

    if (Request.Response.Status.Success) then
    begin
      if Request.Response.GetSimpleValue('access_token', LAccessToken) then
      begin
        if (AccessToken <> LAccessToken) then
        begin
          AccessToken := LAccessToken;
          if InternalConnect then
          begin
            SaveToken;
          end
          else
          begin
            ClearToken;
          end;
        end;
      end
    end;
  end;
end;

procedure TmyCloudDataRESTClient.SaveToken;
var
  Settings: TIniFile;
{$IFDEF MSWINDOWS}
  RegInifile: TReginifile;
{$ENDIF}
  fld: TField;
  encToken: string;
begin

  if PersistTokens.Location <> plDatabase then
  begin
    if (PersistTokens.Key = '') OR (PersistTokens.Section = '') then
    begin
      Exit;
    end;
  end;

  encToken := '';
  if AccessToken <> '' then
  begin
    encToken := EnDeCrypt(AccessToken);
  end;
  case PersistTokens.Location of
    plIniFile:
      begin
        Settings := TIniFile.Create(GetIniFilePath(PersistTokens.Key));
        try
          Settings.WriteString(PersistTokens.Section, 'ACCESS_TOKEN', encToken);
        finally
          Settings.Free;
        end;
      end;
    plRegistry:
      begin
{$IFDEF MSWINDOWS}
        RegInifile := TReginifile.Create(PersistTokens.Key);
        try
          RegInifile.WriteString(PersistTokens.Section, 'ACCESS_TOKEN', encToken);
        finally
          RegInifile.Free;
        end;
{$ENDIF}
      end;
    plDatabase:
      begin
        if Assigned(PersistTokens.DataSource) and Assigned(PersistTokens.DataSource.DataSet) and (PersistTokens.DataSource.DataSet.Active) then
        begin
          PersistTokens.DataSource.DataSet.Edit;
          fld := PersistTokens.DataSource.DataSet.FieldByName('ACCESS_TOKEN');
          if Assigned(fld) then
          begin
            fld.AsString := string(encToken);
          end;
          PersistTokens.DataSource.DataSet.Post;
        end;
      end;
  end;
end;

procedure TmyCloudDataRESTClient.SetAccessToken(const Value: string);
begin
  if Assigned(FAuthenticator) then
  begin
    if (FAuthenticator.AccessToken.Trim <> Value.Trim) then
    begin
      FAuthenticator.AccessToken := Value;
      if IsConnected then
      begin
        Disconnect;
      end;
    end;
  end;
end;

procedure TmyCloudDataRESTClient.SetPersistTokens(const Value: TPersistTokens);
begin
  FPersistTokens.Assign(Value);
end;

function TmyCloudDataRESTClient.ValidateAccessToken: Boolean;
begin
  Result := false;
  if IsTokenAvailable then
  begin

    Request.ResetToDefaults;
    Request.Resource := '/v2/user';
    Request.Method := TRESTRequestMethod.rmGET;

    try
      Request.Execute;
      if Request.Response.Status.Success then
      begin
        if Assigned(FCurrentUser) then
        begin
          FCurrentUser.Free;
        end;
        FCurrentUser := TMyCloudDataUser.Create;
        if FCurrentUser.FromJSON(Request.Response.Content) then
        begin
          Result := true;
        end
      end;
    except
      on E: Exception do
      begin
        if Assigned(FCurrentUser) then
          FCurrentUser.Free;
        Result := false;
      end;
    end;
  end;
end;

{ TPersistTokens }

procedure TPersistTokens.Assign(Source: TPersistent);
begin
  if (Source is TPersistTokens) then
  begin
    FLocation := (Source as TPersistTokens).Location;
    FSection := (Source as TPersistTokens).Section;
    FKey := (Source as TPersistTokens).Key;
    FDataSource := (Source as TPersistTokens).DataSource;
  end;
end;

constructor TPersistTokens.Create;
begin
  inherited Create;
  FLocation := plIniFile;
end;

end.
