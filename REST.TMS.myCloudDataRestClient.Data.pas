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

unit REST.TMS.myCloudDataRestClient.Data;

interface

{$M+}

uses
  Classes,
  SysUtils,
  System.Variants,
  System.Generics.Collections,
  System.JSON,
  REST.Client,
  REST.HttpClient;

type

  // The actual Client
  TCustomMyCloudDataRESTClient = class;

  // Model base classes
  TmyCloudDataModelBase = class;
  TmyCloudDataModelCollectionBase<T: class> = class;

  // Model classes
  TmyCloudDataBlob = class;
  TmyCloudDataEntities = class;
  TmyCloudDataEntity = class;
  TmyCloudDataEntityFilter = class;
  TmyCloudDataEntityFilters = class;
  TmyCloudDataEntityQuery = class;
  TmyCloudDataEntityQueryResult = class;
  TmyCloudDataEntitySorting = class;
  TmyCloudDataEntitySortingCollection = class;
  TmyCloudDataField = class;
  TmyCloudDataFieldMetaData = class;
  TmyCloudDataFields = class;
  TmyCloudDataLookupData = class;
  TmyCloudDataLookupDataCollection = class;
  TmyCloudDataTable = class;
  TmyCloudDataPermissions = class;
  TmyCloudDataTables = class;
  TmyCloudDataTableShare = class;
  TmyCloudDataTableShares = class;
  TmyCloudDataUser = class;

  { ------------------------------------------------------------------------- }

  TCustomMyCloudDataRESTClient = class(TRESTClient)
  private
    FRequest: TRESTRequest;
    FTables: TmyCloudDataTables;
    function GetTables: TmyCloudDataTables;
  protected
    FCurrentUser: TmyCloudDataUser;
    FIsConnected: Boolean;
    function GetTable(ATableId: integer): TmyCloudDataTable;
    property Request: TRESTRequest read FRequest;
    function GetHttpClient: TRESTHTTP;
    procedure EnsureConnectedState; virtual;
    procedure HandleMyCloudDataErrorResponse(AResponse: TCustomRESTResponse);
    procedure FreeLocalData;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property IsConnected: Boolean read FIsConnected;
    property CurrentUser: TmyCloudDataUser read FCurrentUser;
    property Tables: TmyCloudDataTables read GetTables;
  end;

  TmyCloudDataModelBase = class abstract(TPersistent)
  private
    FOwner: TCustomMyCloudDataRESTClient;
  public
    constructor Create(AOwner: TCustomMyCloudDataRESTClient); virtual;
    property Owner: TCustomMyCloudDataRESTClient read FOwner;
  end;

  TmyCloudDataUserType = (utFree, utSubscription, utAdmin);

  TmyCloudDataUser = class(TPersistent)
  private
    FUserId: integer;
    FFirstName: string;
    FLastName: string;
    FEmail: string;
    FCompany: string;
    FUserType: TmyCloudDataUserType;
    FPermissions: TmyCloudDataPermissions;
  public
    destructor Destroy; override;
    function CanUseBlobFields: Boolean;
    function FromJSON(ASource: string): Boolean;
    function UserTypeAsString: string;
    property Company: string read FCompany;
    property Email: string read FEmail;
    property FirstName: string read FFirstName;
    property Lastname: string read FLastName;
    property Permission: TmyCloudDataPermissions read FPermissions;
    property UserId: integer read FUserId;
    property UserType: TmyCloudDataUserType read FUserType;
  end;

  TmyCloudDataModelCollectionBase<T: class> = class abstract(TmyCloudDataModelBase)
  private
    FItems: TObjectList<T>;
    function GetItem(i: integer): T;
    function GetItemCount: integer;
    function GetItems: TObjectList<T>;
  protected
    function LoadItems: TObjectList<T>; virtual;
    property Items: TObjectList<T> read GetItems;
  public
    constructor Create(AOwner: TCustomMyCloudDataRESTClient); reintroduce; virtual;
    destructor Destroy; override;
    function GetEnumerator: TEnumerator<T>;
    procedure Reset; virtual;
    property Item[i: integer]: T read GetItem; default;
    property Count: integer read GetItemCount;
  end;

  TmyCloudDataFieldDataType = (ftInteger, ftFloat, ftWideString, ftBoolean, ftDateTime, ftDate, ftTime, ftBlob);

  TmyCloudDataFieldMetaTypedField = (tfNone, tfRadioButton, tfComboBox, tfCheckBox);

  TmyCloudDataFieldMetaData = class(TObject)
  private
    FEnabled: Boolean;
    FLabelText: string;
    FLookupTable: int64;
    FMask: string;
    FWidth: integer;
    FMaximum: double;
    FOrder: integer;
    FMinimumDate: TDatetime;
    FMaximumDate: TDatetime;
    FLookupKeyField: string;
    FLookupField: string;
    FVisible: Boolean;
    FDescription: string;
    FMinimum: double;
    FTypedValues: TDictionary<string, string>;
    FTypedField: TmyCloudDataFieldMetaTypedField;
    FDefaultValue: string;
    FRequired: Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    function Equals(Obj: TObject): Boolean; override;
    property DefaultValue: string read FDefaultValue write FDefaultValue;
    property Description: string read FDescription write FDescription;
    property Enabled: Boolean read FEnabled write FEnabled;
    property LabelText: string read FLabelText write FLabelText;
    property LookupField: string read FLookupField write FLookupField;
    property LookupKeyField: string read FLookupKeyField write FLookupKeyField;
    property LookupTable: int64 read FLookupTable write FLookupTable;
    property Mask: string read FMask write FMask;
    property Maximum: double read FMaximum write FMaximum;
    property MaximumDate: TDatetime read FMaximumDate write FMaximumDate;
    property Minimum: double read FMinimum write FMinimum;
    property MinimumDate: TDatetime read FMinimumDate write FMinimumDate;
    property Order: integer read FOrder write FOrder;
    property Required: Boolean read FRequired write FRequired;
    property TypedField: TmyCloudDataFieldMetaTypedField read FTypedField write FTypedField;
    property TypedValues: TDictionary<string, string> read FTypedValues write FTypedValues;
    property Visible: Boolean read FVisible write FVisible;
    property Width: integer read FWidth write FWidth;
  end;

  TmyCloudDataField = class(TObject)
  private
    FTableID: integer;
    FFieldName: string;
    FOriginalFieldName: string;
    FDataType: TmyCloudDataFieldDataType;
    FIsNullable: Boolean;
    FMaxFieldSize: integer;
    FMetaData: TmyCloudDataFieldMetaData;
    function CheckForExtraMetaData: Boolean;
    function StringToDataType(AString: string): TmyCloudDataFieldDataType; virtual;
    function DataTypeToString(ADataType: TmyCloudDataFieldDataType): string; virtual;
  protected
    function FromJSON(AJSONString: string): Boolean;
    function ToJSON(AIsNew: Boolean): string;
    function ToMetaDataJSON: string;
  public
    constructor Create(ATableId: integer);
    destructor Destroy; override;
    function CompareBasicFields(AOtherField: TmyCloudDataField): Boolean;
    function CompareExtraMetaData(AOtherField: TmyCloudDataField): Boolean;
    property DataType: TmyCloudDataFieldDataType read FDataType write FDataType;
    property FieldName: string read FFieldName write FFieldName;
    property HasExtraMetaData: Boolean read CheckForExtraMetaData;
    property IsNullable: Boolean read FIsNullable write FIsNullable;
    property MaxFieldSize: integer read FMaxFieldSize write FMaxFieldSize;
    property MetaData: TmyCloudDataFieldMetaData read FMetaData write FMetaData;
    property OriginalFieldName: string read FOriginalFieldName;
    property TableID: integer read FTableID;
  end;

  TmyCloudDataFields = class(TmyCloudDataModelCollectionBase<TmyCloudDataField>)
  private
    FTableID: integer;
  protected
    function LoadItems: TObjectList<TmyCloudDataField>; override;
    function TryParseJSON(AJSONString: string; out AResult: TObjectList<TmyCloudDataField>): Boolean;
  public
    constructor Create(AOwner: TCustomMyCloudDataRESTClient; ATableId: integer); reintroduce; overload;
    function Add(AFieldName: string; ADataType: TmyCloudDataFieldDataType): TmyCloudDataField; overload;
    function Add(AFieldName: string; ADataType: TmyCloudDataFieldDataType; AFieldSize: integer): TmyCloudDataField; overload;
    function AddOrUpdate(AFieldName: string; ADataType: TmyCloudDataFieldDataType): TmyCloudDataField; overload;
    function AddOrUpdate(AFieldName: string; ADataType: TmyCloudDataFieldDataType; AFieldSize: integer): TmyCloudDataField; overload;
    function GetByName(AFieldName: string): TmyCloudDataField;
    function GetByOriginalName(AOriginalFieldName: string): TmyCloudDataField;
    procedure Save;
    property TableID: integer read FTableID;
  end;

  TmyCloudDataBlob = class(TmyCloudDataModelBase)
  private
    FHasData: Boolean;
    FUrl: string;
  protected
    function GetStream: TStream;
    procedure SetStream(AStream: TStream);
    function FromJSON(AJSONString: string): Boolean;
  public
    function AsString: string;
    function ToFile(AFileName: string): Boolean;
    procedure FromFile(AFileName: string);
    property HasData: Boolean read FHasData;
    property Stream: TStream read GetStream write SetStream;
  end;

  TmyCloudDataJSonHelper = class
  public
    class function TryGetJSonProperty<T>(AJSonValue: TJSONValue; APath: string; ADefaultValue: T): T; overload;
    class function TryGetJSonProperty<T>(AJSonValue: TJSONValue; APath: string): T; overload;
    class function TryParseBooleanFieldValue(ASource: string; out AResult: Variant): Boolean;
    class function TryParseDateTimeFieldValue(ASource: string; out AResult: Variant): Boolean;
    class function TryParseFieldValue(ASource: string; ADataType: TmyCloudDataFieldDataType; out AResult: Variant): Boolean;
    class function TryParseFloatFieldValue(ASource: string; out AResult: Variant): Boolean;
    class function TryParseIntegerFieldValue(ASource: string; out AResult: Variant): Boolean;
    class function TrySerializeBooleanFieldValue(AValue: Variant; out AStringResult: string): Boolean;
    class function TrySerializeDateTimeFieldValue(AValue: Variant; out AStringResult: string): Boolean;
    class function TrySerializeFieldValue(AValue: Variant; ADataType: TmyCloudDataFieldDataType; out AStringResult: string): Boolean;
    class function TrySerializeFloatFieldValue(AValue: Variant; out AStringResult: string): Boolean;
    class function TrySerializeIntegerFieldValue(AValue: Variant; out AStringResult: string): Boolean;
    class function TrySerializeStringFieldValue(AValue: Variant; out AStringResult: string): Boolean;
    class function IntToZStr(i, l: integer): string;
  end;

  TmyCloudDataEntity = class(TmyCloudDataModelBase)
  private
    FBlobValues: TObjectDictionary<string, TmyCloudDataBlob>;
    FEntityId: int64;
    FFields: TmyCloudDataFields;
    FHasUnsavedChanges: Boolean;
    FTableID: integer;
    FValues: TDictionary<string, Variant>;
  protected
    function GetIsNew: Boolean;

  protected
    function FromJSON(AJSONString: string; AFieldCollection: TmyCloudDataFields): Boolean;
    function ToJSON: string;
  public
    constructor Create(AOwner: TCustomMyCloudDataRESTClient; ATableId: integer; AFieldSet: TmyCloudDataFields); reintroduce; overload;
    destructor Destroy; override;
    function GetBlobField(AFieldName: string): TmyCloudDataBlob;
    function GetValue(AFieldName: string): Variant;
    function GetValueAsString(AFieldName: string): string;
    function TrySetValueFromString(AFieldName: string; AValue: string): Boolean;
    procedure SetValue(AFieldName: string; AValue: Variant);
    property HasUnsavedChanges: Boolean read FHasUnsavedChanges;
    property ID: int64 read FEntityId;
    property IsNew: Boolean read GetIsNew;
    property TableID: integer read FTableID;
  end;

  TmyCloudDataEntities = class(TmyCloudDataModelCollectionBase<TmyCloudDataEntity>)
  private
    FTableID: integer;
    FFieldCollection: TmyCloudDataFields;
    FRemovedEntities: TList<int64>;
  protected
    function FromJSON(AJSONString: string): Boolean;
  public
    constructor Create(AOwner: TCustomMyCloudDataRESTClient; ATableId: integer; AFieldCollection: TmyCloudDataFields); reintroduce; overload;
    destructor Destroy; override;
    function CreateEntity: TmyCloudDataEntity;
    function GetEntity(AEntityId: int64): TmyCloudDataEntity;
    procedure RemoveEntity(AEntityId: int64);
    procedure Save;
    property TableID: integer read FTableID;
  end;

  TComparisonOperator = (coEqual, coNotEqual, coLike, coGreater, coGreaterOrEqual, coLess, coLessOrEqual, coStartsWith, coEndsWith, coNull,
    coNotNull);

  TLogicalOperator = (loAnd, loOr, loNone);

  TmyCloudDataEntityFilter = class
  private
    FFieldName: string;
    FValue: Variant;
    FComparisonOperator: TComparisonOperator;
    FLogicalOperator: TLogicalOperator;
    function OperatorAsString(AOperator: TComparisonOperator): string; overload;
    function OperatorAsString(AOperator: TLogicalOperator): string; overload;
  protected
    function ToJSON: TJSONObject;
  public
    property ComparisonOperator: TComparisonOperator read FComparisonOperator write FComparisonOperator;
    property FieldName: string read FFieldName write FFieldName;
    property LogicalOperator: TLogicalOperator read FLogicalOperator write FLogicalOperator;
    property Value: Variant read FValue write FValue;
  end;

  TmyCloudDataEntityFilters = class(TObjectList<TmyCloudDataEntityFilter>)
  public
    function Add(AFieldName: string; AValue: Variant; AComparisonOperator: TComparisonOperator = coEqual; ALogicalOperator: TLogicalOperator = loAnd)
      : integer; overload;
  end;

  TSortDirection = (soAscending, soDescending);

  TmyCloudDataEntitySorting = class
  private
    FFieldName: string;
    FSortOrder: TSortDirection;
    function SortOrderAsString(ASortOrder: TSortDirection): string;
  protected
    function ToJSON: TJSONObject;
  public
    property FieldName: string read FFieldName write FFieldName;
    property SortDirection: TSortDirection read FSortOrder write FSortOrder;
  end;

  TmyCloudDataEntitySortingCollection = class(TObjectList<TmyCloudDataEntitySorting>)
  public
    function Add(AFieldName: string; AOrder: TSortDirection): integer; overload;
  end;

  TmyCloudDataEntityQuery = class
  private
    FTableID: integer;
    FPageSize: integer;
    FPageIndex: integer;
    FFilters: TmyCloudDataEntityFilters;
    FSorting: TmyCloudDataEntitySortingCollection;
    FFields: TList<string>;
    function GetIsPaged: Boolean;
  protected
    function ToJSON: string;
  public
    constructor Create(ATableId: integer);
    destructor Destroy; override;
    procedure Reset;
    property Fields: TList<string> read FFields write FFields;
    property Filters: TmyCloudDataEntityFilters read FFilters write FFilters;
    property IsPaged: Boolean read GetIsPaged;
    property PageIndex: integer read FPageIndex write FPageIndex;
    property PageSize: integer read FPageSize write FPageSize;
    property Sorting: TmyCloudDataEntitySortingCollection read FSorting write FSorting;
    property TableID: integer read FTableID;
  end;

  TmyCloudDataEntityQueryResult = class(TObjectList<TmyCloudDataEntity>)
  private
    FPageSize: integer;
    FPageIndex: integer;
    FTotalResults: integer;
    FResults: TmyCloudDataEntities;
  published
    destructor Destroy; override;
    property Entities: TmyCloudDataEntities read FResults write FResults;
    property PageSize: integer read FPageSize write FPageSize;
    property PageIndex: integer read FPageIndex write FPageIndex;
    property TotalResults: integer read FTotalResults write FTotalResults;
  end;

  TmyCloudDataPermission = (pCreate, pRead, pUpdate, pDelete);

  TmyCloudDataPermissions = class(TList<TmyCloudDataPermission>)
  protected
    procedure SetFromString(ASource: string);
  public
    function ToString: string; override;
    function IsSameAs(AOther: TmyCloudDataPermissions): Boolean;
    class function FromString(ASource: string): TmyCloudDataPermissions;
    class function ReadOnly: TmyCloudDataPermissions;
    class function ReadWrite: TmyCloudDataPermissions;
    class function None: TmyCloudDataPermissions;
  end;

  TmyCloudDataTableShare = class
  private
    FEmail: string;
    FPermissions: TmyCloudDataPermissions;
    FTableID: integer;
    FHasUnchangedChanges: Boolean;
    procedure SetPermissions(const Value: TmyCloudDataPermissions);
  public
    constructor Create(ATableId: integer; AEmail: string; APermissions: TmyCloudDataPermissions; IsNew: Boolean = True);
  published
    property Email: string read FEmail;
    property HasUnsavedChanges: Boolean read FHasUnchangedChanges;
    property Permissions: TmyCloudDataPermissions read FPermissions write SetPermissions;
    property TableID: integer read FTableID;
  end;

  TmyCloudDataTableShares = class(TmyCloudDataModelCollectionBase<TmyCloudDataTableShare>)
  private
    FTableID: integer;
  protected
    function LoadItems: TObjectList<TmyCloudDataTableShare>; override;
    function TryParseJSON(AJSONString: string; out AResult: TObjectList<TmyCloudDataTableShare>): Boolean;
  public
    constructor Create(AOwner: TCustomMyCloudDataRESTClient; ATableId: integer); reintroduce; overload;
    function GetShare(AEmail: string): TmyCloudDataTableShare;
    procedure RemoveShare(AEmail: string);
    procedure Save;
    procedure SetShare(AEmail: string; APermissions: TmyCloudDataPermissions);
  end;

  TmyCloudDataLookupData = class(TDictionary<Variant, Variant>)
  end;

  TmyCloudDataLookupDataCollection = class(TObjectDictionary<string, TmyCloudDataLookupData>)
  end;

  /// <summary>
  /// This class represents a single table on the myCloudData.net service
  /// </summary>
  TmyCloudDataTable = class(TmyCloudDataModelBase)
  private
    FEntities: TmyCloudDataEntities;
    FEntityQuery: TmyCloudDataEntityQuery;
    FFields: TmyCloudDataFields;
    FFilters: TmyCloudDataEntityFilters;
    FIsOwner: Boolean;
    FLookupData: TmyCloudDataLookupDataCollection;
    FOriginalTableName: string;
    FOwnerID: integer;
    FPageIndex: integer;
    FPageSize: integer;
    FPermissions: string;
    FShares: TmyCloudDataTableShares;
    FSorting: TmyCloudDataEntitySortingCollection;
    FTableID: integer;
    FTableName: string;
    function GetEntities: TmyCloudDataEntities;
    function GetFields: TmyCloudDataFields;
    function GetLookupData: TmyCloudDataLookupDataCollection;
  protected
    function ToJSON: string;
  public
    constructor Create(AOwner: TCustomMyCloudDataRESTClient); override;
    destructor Destroy; override;
    function ExecuteQuery(AQuery: TmyCloudDataEntityQuery): TmyCloudDataEntityQueryResult;
    function FromJSON(AJSONContent: string): Boolean;
    function GetLookupDataForField(AFieldName: string): TmyCloudDataLookupData;
    function Query: Boolean;
    property Entities: TmyCloudDataEntities read GetEntities;
    property Fields: TmyCloudDataFields read GetFields;
    property Filters: TmyCloudDataEntityFilters read FFilters write FFilters;
    property IsOwner: Boolean read FIsOwner write FIsOwner;
    property LookupData: TmyCloudDataLookupDataCollection read GetLookupData;
    property OwnerID: integer read FOwnerID;
    property PageIndex: integer read FPageIndex write FPageIndex;
    property PageSize: integer read FPageSize write FPageSize;
    property Permissions: string read FPermissions;
    property Shares: TmyCloudDataTableShares read FShares write FShares;
    property Sorting: TmyCloudDataEntitySortingCollection read FSorting write FSorting;
    property TableID: integer read FTableID;
    property TableName: string read FTableName write FTableName;
  end;

  TmyCloudDataTables = class(TmyCloudDataModelCollectionBase<TmyCloudDataTable>)
  protected
    function TryParseJSON(AJSONString: string; out AResult: TObjectList<TmyCloudDataTable>): Boolean;
    function LoadItems: TObjectList<TmyCloudDataTable>; override;
  public
    function CreateTable(ATableName: string): TmyCloudDataTable;
    function GetOrCreateTable(ATableName: string): TmyCloudDataTable;
    function GetTableByName(ATableName: string): TmyCloudDataTable;
    function GetTableByID(ATableId: integer): TmyCloudDataTable;
    procedure RemoveTable(ATableId: integer);
  end;

implementation

uses
  StrUtils,
  System.JSON.Readers,
  System.JSON.Types,
  REST.Types,
  REST.Utils;

function TmyCloudDataField.CheckForExtraMetaData: Boolean;
var
  LEmptyMetaData: TmyCloudDataFieldMetaData;
begin
  LEmptyMetaData := TmyCloudDataFieldMetaData.Create;
  try
    Result := MetaData.Equals(LEmptyMetaData);
  finally
    LEmptyMetaData.Free;
  end;
end;

{ TmyCloudDataModelBase }

constructor TmyCloudDataModelBase.Create(AOwner: TCustomMyCloudDataRESTClient);
begin
  FOwner := AOwner;
end;

{ TmyCloudDataEntity }

constructor TmyCloudDataEntity.Create(AOwner: TCustomMyCloudDataRESTClient; ATableId: integer; AFieldSet: TmyCloudDataFields);
begin
  inherited Create(AOwner);
  FTableID := ATableId;
  FFields := AFieldSet;
  FValues := TDictionary<string, Variant>.Create;
  FBlobValues := TObjectDictionary<string, TmyCloudDataBlob>.Create([doOwnsValues]);
end;

destructor TmyCloudDataEntity.Destroy;
begin
  if Assigned(FValues) then
    FValues.Free;
  if Assigned(FBlobValues) then
    FBlobValues.Free;
  inherited;
end;

function TmyCloudDataEntity.FromJSON(AJSONString: string; AFieldCollection: TmyCloudDataFields): Boolean;
var
  LObject: TJSONValue;
  LField: TmyCloudDataField;
  LFieldValue: Variant;
  LBlobFieldValue: TmyCloudDataBlob;
  LFieldStringValue: string;
  LFieldJSONValue: TJSONValue;
begin
  Result := False;
  LObject := TJSONObject.ParseJSONValue(AJSONString);
  try
    FEntityId := TmyCloudDataJSonHelper.TryGetJSonProperty<integer>(LObject, '_ID', 0);
    if FEntityId > 0 then
    begin
      FValues.Clear;
      for LField in AFieldCollection do
      begin
        if not(LField.DataType = ftBlob) then
        begin
          if LObject.TryGetValue<string>(LField.FieldName, LFieldStringValue) then
          begin
            if TmyCloudDataJSonHelper.TryParseFieldValue(LFieldStringValue, LField.DataType, LFieldValue) then
            begin
              FValues.Add(LField.FieldName, LFieldValue);
            end;
          end;
        end
        else
        begin
          if LObject.TryGetValue<TJSONValue>(LField.FieldName, LFieldJSONValue) then
          begin
            LBlobFieldValue := TmyCloudDataBlob.Create(Owner);
            if not LBlobFieldValue.FromJSON(LFieldJSONValue.ToJSON) then
            begin
              LBlobFieldValue.FHasData := False;
              LBlobFieldValue.FUrl := '?tableid=' + FTableID.ToString + '&id=' + FEntityId.ToString + '&fieldname=' + LField.FieldName;
            end;
            FBlobValues.Add(LField.FieldName, LBlobFieldValue);
          end;
        end;
      end;
      Result := True;
    end;
  finally
    LObject.Free;
  end;
end;

function TmyCloudDataEntity.GetBlobField(AFieldName: string): TmyCloudDataBlob;
begin
  Result := nil;
  if FBlobValues.ContainsKey(AFieldName) then
  begin
    Result := FBlobValues[AFieldName];
  end;
end;

function TmyCloudDataEntity.GetIsNew: Boolean;
begin
  Result := (ID = 0);
end;

function TmyCloudDataEntity.GetValue(AFieldName: string): Variant;
begin
  Result := default (Variant);
  if FValues.ContainsKey(AFieldName) then
  begin
    Result := FValues[AFieldName];
  end;
end;

function TmyCloudDataEntity.GetValueAsString(AFieldName: string): string;
begin
  Result := GetValue(AFieldName);
end;

procedure TmyCloudDataEntity.SetValue(AFieldName: string; AValue: Variant);
begin
  FValues.AddOrSetValue(AFieldName, AValue);
  FHasUnsavedChanges := True;
end;

function TmyCloudDataEntity.ToJSON: string;
var
  LJSONResult: TJSONObject;
  LFieldValuesList: TJSONObject;
  LField: TmyCloudDataField;
  LFieldValue: string;
begin
  LJSONResult := TJSONObject.Create;
  LFieldValuesList := TJSONObject.Create;
  try
    LJSONResult.AddPair('tableid', TableID.ToString);
    if not IsNew then
    begin
      LFieldValuesList.AddPair('_ID', ID.ToString);
    end;
    if (FValues.Count > 0) then
    begin
      for LField in FFields do
      begin
        if (FValues.ContainsKey(LField.FieldName)) then
        begin
          LFieldValue := '';
          if (TmyCloudDataJSonHelper.TrySerializeFieldValue(FValues[LField.FieldName], LField.DataType, LFieldValue)) then
          begin
            LFieldValuesList.AddPair(LField.FieldName, LFieldValue);
          end;
        end;
      end;
      if (LFieldValuesList.Count > 0) then
      begin
        LJSONResult.AddPair('fields', LFieldValuesList);
      end;
    end;
    Result := LJSONResult.ToString;
  finally
    LJSONResult.Free;
  end;
end;

class function TmyCloudDataJSonHelper.TryParseBooleanFieldValue(ASource: string; out AResult: Variant): Boolean;
var
  LBoolValue: Boolean;
begin
  AResult := default (Variant);
  Result := Boolean.TryToParse(ASource, LBoolValue);
  if Result then
  begin
    AResult := LBoolValue;
  end;
end;

class function TmyCloudDataJSonHelper.TryParseDateTimeFieldValue(ASource: string; out AResult: Variant): Boolean;
var
  da, mo, ye, ho, mi, se: Word;
  err: integer;
  LDateResult: TDatetime;
begin
  try
    Val(Copy(ASource, 1, 4), ye, err);
    Val(Copy(ASource, 6, 2), mo, err);
    Val(Copy(ASource, 9, 2), da, err);
    Val(Copy(ASource, 12, 2), ho, err);
    Val(Copy(ASource, 15, 2), mi, err);
    Val(Copy(ASource, 18, 2), se, err);

    if ye < 100 then
      ye := 100;
    if mo < 1 then
      mo := 1;
    if da < 1 then
      da := 1;

    LDateResult := EncodeDate(ye, mo, da) + EncodeTime(ho, mi, se, 0);
    AResult := LDateResult;
    Result := True;
  except
    on E: Exception do
      Result := False;
  end;

end;

class function TmyCloudDataJSonHelper.TryParseFieldValue(ASource: string; ADataType: TmyCloudDataFieldDataType; out AResult: Variant): Boolean;
begin
  Result := False;
  case ADataType of
    ftInteger:
      begin
        Result := TryParseIntegerFieldValue(ASource, AResult);
      end;
    ftFloat:
      begin
        Result := TryParseFloatFieldValue(ASource, AResult);
      end;
    ftBoolean:
      begin
        Result := TryParseBooleanFieldValue(ASource, AResult);
      end;
    ftWideString:
      begin
        Result := True;
        AResult := ASource;
      end;
    ftDateTime, ftDate, ftTime:
      begin
        Result := TryParseDateTimeFieldValue(ASource, AResult);
      end;
  end;
end;

class function TmyCloudDataJSonHelper.TryParseFloatFieldValue(ASource: string; out AResult: Variant): Boolean;
var
  LInt64Value: int64;
begin
  Result := int64.TryParse(ASource, LInt64Value);
  if Result then
  begin
    AResult := LInt64Value;
  end;
end;

class function TmyCloudDataJSonHelper.TryParseIntegerFieldValue(ASource: string; out AResult: Variant): Boolean;
var
  LIntValue: integer;
begin
  Result := integer.TryParse(ASource, LIntValue);
  if Result then
  begin
    AResult := LIntValue;
  end;
end;

class function TmyCloudDataJSonHelper.TrySerializeBooleanFieldValue(AValue: Variant; out AStringResult: string): Boolean;
var
  LValue: Boolean;
begin
  AStringResult := '';
  Result := False;
  try
    LValue := AValue;
    if LValue then
    begin
      AStringResult := 'true';
      Result := True;
    end
    else
    begin
      AStringResult := 'false';
      Result := True;
    end;
  except
    on E: Exception do
      // nothing
  end;
end;

class function TmyCloudDataJSonHelper.TrySerializeDateTimeFieldValue(AValue: Variant; out AStringResult: string): Boolean;
var
  da, mo, ye, ho, mi, se, ms: Word;
  LDateTimeValue: TDatetime;
begin
  try
    LDateTimeValue := AValue;
    DecodeDate(LDateTimeValue, ye, mo, da);
    DecodeTime(LDateTimeValue, ho, mi, se, ms);
    AStringResult := IntToZStr(ye, 4) + '-' + IntToZStr(mo, 2) + '-' + IntToZStr(da, 2) + 'T' + IntToZStr(ho, 2) + ':' + IntToZStr(mi, 2) + ':' +
      IntToZStr(se, 2) + '.000Z';
    Result := True;
  except
    on E: Exception do
      Result := False;
  end;
end;

class function TmyCloudDataJSonHelper.IntToZStr(i, l: integer): string;
var
  Res: string;
begin
  Res := IntToStr(i);
  while Length(Res) < l do
  begin
    Res := '0' + Res;
  end;
  Result := Res;
end;

class function TmyCloudDataJSonHelper.TrySerializeFieldValue(AValue: Variant; ADataType: TmyCloudDataFieldDataType;
  out AStringResult: string): Boolean;
begin
  Result := False;
  case ADataType of
    ftInteger:
      Result := TrySerializeIntegerFieldValue(AValue, AStringResult);
    ftFloat:
      Result := TrySerializeFloatFieldValue(AValue, AStringResult);
    ftWideString:
      Result := TrySerializeStringFieldValue(AValue, AStringResult);
    ftBoolean:
      Result := TrySerializeBooleanFieldValue(AValue, AStringResult);
    ftDateTime, ftDate, ftTime:
      Result := TrySerializeDateTimeFieldValue(AValue, AStringResult);
  end;
end;

class function TmyCloudDataJSonHelper.TrySerializeFloatFieldValue(AValue: Variant; out AStringResult: string): Boolean;
begin
  try
    AStringResult := FloatToStr(AValue);
    Result := True;
  except
    on E: Exception do
      Result := False;
  end;
end;

class function TmyCloudDataJSonHelper.TrySerializeIntegerFieldValue(AValue: Variant; out AStringResult: string): Boolean;
begin
  try
    AStringResult := IntToStr(AValue);
    Result := True;
  except
    on E: Exception do
      Result := False;
  end;
end;

class function TmyCloudDataJSonHelper.TrySerializeStringFieldValue(AValue: Variant; out AStringResult: string): Boolean;
begin
  try
    Result := True;
    AStringResult := StringReplace(AValue, '\', '\\', [rfReplaceAll]);
    AStringResult := StringReplace(AStringResult, '"', '\"', [rfReplaceAll]);
    AStringResult := StringReplace(AStringResult, #9, '\t', [rfReplaceAll]);
    AStringResult := StringReplace(AStringResult, #$A, '\n', [rfReplaceAll]);
    AStringResult := StringReplace(AStringResult, #$D, '\r', [rfReplaceAll]);
  except
    on E: Exception do
      Result := False;
  end;
end;

function TmyCloudDataEntity.TrySetValueFromString(AFieldName, AValue: string): Boolean;
var
  LField: TmyCloudDataField;
  LValue: Variant;
begin
  Result := False;
  for LField in FFields do
  begin
    if LField.FFieldName = AFieldName then
    begin
      if not(LField.DataType = ftBlob) then
      begin
        Result := TmyCloudDataJSonHelper.TryParseFieldValue(AValue, LField.DataType, LValue);
        if Result then
        begin
          SetValue(AFieldName, LValue);
          Result := True;
        end;
      end;
      Exit;
    end;
  end;
end;

{ TmyCloudDataEntityQuery }

constructor TmyCloudDataEntityQuery.Create(ATableId: integer);
begin
  FTableID := ATableId;
  FFilters := TmyCloudDataEntityFilters.Create;
  FSorting := TmyCloudDataEntitySortingCollection.Create;
  FFields := TList<string>.Create;
end;

destructor TmyCloudDataEntityQuery.Destroy;
begin
  inherited;
  if Assigned(FFilters) then
    FFilters.Free;
  if Assigned(FSorting) then
    FSorting.Free;
  if Assigned(FFields) then
    FFields.Free;
end;

function TmyCloudDataEntityQuery.GetIsPaged: Boolean;
begin
  Result := (PageSize > 0) and (PageIndex >= 0);
end;

procedure TmyCloudDataEntityQuery.Reset;
begin
  FFilters.Clear;
  FSorting.Clear;
  FFields.Clear;
  FPageSize := 0;
  FPageIndex := 0;
end;

function TmyCloudDataEntityQuery.ToJSON: string;
var
  LJSONResult: TJSONObject;
  LFilter: TmyCloudDataEntityFilter;
  LFiltersArray: TJSONArray;
  LSorting: TmyCloudDataEntitySorting;
  LSortingArray: TJSONArray;
  LField: string;
  LFieldsFilter: string;
begin
  LJSONResult := TJSONObject.Create;
  try

    LJSONResult.AddPair('tableid', IntToStr(TableID));

    if (IsPaged) then
    begin
      LJSONResult.AddPair('pagesize', IntToStr(PageSize));
      LJSONResult.AddPair('pageindex', IntToStr(PageIndex));
    end;

    if (Filters.Count > 0) then
    begin
      LFiltersArray := TJSONArray.Create;
      for LFilter in Filters do
      begin
        LFiltersArray.Add(LFilter.ToJSON);
      end;
      LJSONResult.AddPair('filters', LFiltersArray);
    end;

    if (Sorting.Count > 0) then
    begin
      LSortingArray := TJSONArray.Create;
      for LSorting in Sorting do
      begin
        LSortingArray.Add(LSorting.ToJSON);
      end;
      LJSONResult.AddPair('sorting', LSortingArray);
    end;

    if (Fields.Count > 0) then
    begin
      LFieldsFilter := '';
      for LField in Fields do
      begin
        LFieldsFilter := LFieldsFilter + LField + ',';
      end;
      LJSONResult.AddPair('fields', LFieldsFilter.TrimRight([',']));
    end;

    Result := LJSONResult.ToString;
  finally
    LJSONResult.Free;
  end;
end;

{ TmyCloudDataTable }

constructor TmyCloudDataTable.Create(AOwner: TCustomMyCloudDataRESTClient);
begin
  inherited;
  Filters := TmyCloudDataEntityFilters.Create;
  Sorting := TmyCloudDataEntitySortingCollection.Create;
end;

destructor TmyCloudDataTable.Destroy;
begin
  if Assigned(FFilters) then
    FFilters.Free;
  if Assigned(FSorting) then
    FSorting.Free;
  if Assigned(FFields) then
    FFields.Free;
  if Assigned(FEntities) then
    FEntities.Free;
  if Assigned(FEntityQuery) then
    FEntityQuery.Free;
  if Assigned(FLookupData) then
    FLookupData.Free;
  inherited;
end;

function TmyCloudDataTable.ExecuteQuery(AQuery: TmyCloudDataEntityQuery): TmyCloudDataEntityQueryResult;
var
  LCountStringValue: string;
begin

  Result := nil;
  Owner.EnsureConnectedState;

  try
    Owner.Request.ResetToDefaults;
    Owner.Request.Resource := '/v2/data/tablefilter';
    Owner.Request.Method := TRESTRequestMethod.rmPOST;
    Owner.Request.AddBody(AQuery.ToJSON, ctAPPLICATION_JSON);
    Owner.Request.Execute;

    if (Owner.Request.Response.Status.Success) then
    begin
      Result := TmyCloudDataEntityQueryResult.Create(True);
      try
        Result.PageSize := AQuery.PageSize;
        Result.PageIndex := AQuery.PageIndex;
        Result.Entities := TmyCloudDataEntities.Create(Owner, TableID, Fields);
        if Result.Entities.FromJSON(Owner.Request.Response.Content) then
        begin
          if AQuery.IsPaged and ((AQuery.PageIndex > 0) or (AQuery.PageSize = Result.Entities.Count)) then
          begin

            Owner.Request.ResetToDefaults;
            Owner.Request.Resource := '/v2/data/tablecount';
            Owner.Request.Method := TRESTRequestMethod.rmPOST;
            Owner.Request.AddBody(AQuery.ToJSON, ctAPPLICATION_JSON);
            Owner.Request.Execute;

            if Owner.Request.Response.Status.Success then
            begin
              Owner.Request.Response.GetSimpleValue('count', LCountStringValue);
              Result.TotalResults := StrToInt(LCountStringValue);
            end
            else
            begin
              Owner.HandleMyCloudDataErrorResponse(Owner.Request.Response);
            end;

          end
          else
          begin
            Result.TotalResults := Result.Entities.Count;
          end;
        end;
      except
        on E: Exception do
        begin
          Result.Free;
          raise;
        end;
      end;
    end
    else
    begin
      Owner.HandleMyCloudDataErrorResponse(Owner.Request.Response);
    end;
  finally
    AQuery.Free;
  end;
end;

function TmyCloudDataTable.FromJSON(AJSONContent: string): Boolean;
var
  LJSonValue: TJSONValue;
begin
  Result := False;
  LJSonValue := TJSONObject.ParseJSONValue(AJSONContent);
  try
    if LJSonValue.TryGetValue<integer>('tableid', FTableID) then
    begin
      FTableName := TmyCloudDataJSonHelper.TryGetJSonProperty<string>(LJSonValue, 'tablename', TableName);
      FOriginalTableName := FTableName;
      FPermissions := TmyCloudDataJSonHelper.TryGetJSonProperty<string>(LJSonValue, 'permissions');
      FOwnerID := TmyCloudDataJSonHelper.TryGetJSonProperty<integer>(LJSonValue, 'ownerid');
      FIsOwner := TmyCloudDataJSonHelper.TryGetJSonProperty<Boolean>(LJSonValue, 'isowner');
      Result := True;
    end;
  finally
    LJSonValue.Free;
  end;

end;

function TmyCloudDataTable.GetEntities: TmyCloudDataEntities;
begin
  if not Assigned(FEntities) then
  begin
    FEntities := TmyCloudDataEntities.Create(Owner, TableID, Fields);
  end;
  Result := FEntities;
end;

function TmyCloudDataTable.GetFields: TmyCloudDataFields;
begin
  if (FFields = nil) then
  begin
    FFields := TmyCloudDataFields.Create(Owner, TableID);
  end;
  Result := FFields;
end;

function TmyCloudDataTable.GetLookupData: TmyCloudDataLookupDataCollection;
var
  LField: TmyCloudDataField;
  LLookupTable: TmyCloudDataTable;
  LLookupKeyFieldName: string;
  LLookupValueFieldName: string;
  LQuery: TmyCloudDataEntityQuery;
  LQueryResult: TmyCloudDataEntityQueryResult;
  LFieldLookupData: TmyCloudDataLookupData;
  LEntity: TmyCloudDataEntity;
begin
  if FLookupData = nil then
  begin
    FLookupData := TmyCloudDataLookupDataCollection.Create;
    try
      for LField in Fields do
      begin
        if (LField.MetaData.LookupTable > 0) then
        begin
          LLookupKeyFieldName := LField.MetaData.LookupKeyField.Trim;
          LLookupValueFieldName := LField.MetaData.LookupField.Trim;
          if (LLookupKeyFieldName <> '') and (LLookupValueFieldName <> '') then
          begin
            LLookupTable := Owner.GetTable(LField.MetaData.LookupTable);
            if (LLookupTable <> nil) then
            begin
              LQuery := TmyCloudDataEntityQuery.Create(LLookupTable.TableID);
              LQuery.Fields.Add(LLookupKeyFieldName);
              LQuery.Fields.Add(LLookupValueFieldName);
              LQueryResult := LLookupTable.ExecuteQuery(LQuery);
              try
                if (LQueryResult.TotalResults > 0) then
                begin
                  LFieldLookupData := TmyCloudDataLookupData.Create;
                  for LEntity in LQueryResult.Entities do
                  begin
                    if not LFieldLookupData.ContainsKey(LEntity.GetValue(LLookupKeyFieldName)) then
                    begin
                      LFieldLookupData.Add(LEntity.GetValue(LLookupKeyFieldName), LEntity.GetValue(LLookupValueFieldName));
                    end;
                  end;
                  FLookupData.Add(LField.FieldName, LFieldLookupData);
                end;
              finally
                LQueryResult.Free
              end;
            end;
          end;
        end;
      end;
    except
      on E: Exception do
      begin
        FLookupData.Free;
        raise;
      end;
    end;
  end;
  Result := FLookupData;
end;

function TmyCloudDataTable.GetLookupDataForField(AFieldName: string): TmyCloudDataLookupData;
begin
  Result := nil;
  if (LookupData.ContainsKey(AFieldName)) then
  begin
    Result := LookupData[AFieldName];
  end;
end;

function TmyCloudDataTable.Query: Boolean;
var
  LQuery: TmyCloudDataEntityQuery;
  LQueryResult: TmyCloudDataEntityQueryResult;
  LFilter: TmyCloudDataEntityFilter;
  LSorting: TmyCloudDataEntitySorting;
begin
  LQuery := TmyCloudDataEntityQuery.Create(TableID);
  try
    LQuery.PageSize := PageSize;
    LQuery.PageIndex := PageIndex;
    for LFilter in Filters do
    begin
      LQuery.Filters.Add(LFilter.FFieldName, LFilter.Value, LFilter.ComparisonOperator, LFilter.LogicalOperator);
    end;
    for LSorting in Sorting do
    begin
      LQuery.Sorting.Add(LSorting.FFieldName, LSorting.SortDirection);
    end;

    LQueryResult := ExecuteQuery(LQuery);
    try
      if Assigned(FEntities) then
      begin
        FEntities.Free;
        FEntities := LQueryResult.Entities;
      end
      else
      begin
        FEntities := LQueryResult.Entities;
      end;
      Result := True;
    finally
      LQueryResult.Entities := nil;
      LQueryResult.Free;
    end;

  except
    on E: Exception do
    begin
      if Assigned(LQuery) then
        LQuery.Free;
      raise;
    end;
  end;
end;

function TmyCloudDataTable.ToJSON: string;
var
  LRequestBody: TJSONObject;
begin
  LRequestBody := TJSONObject.Create;
  try
    if (TableID = 0) then
    begin
      // A new Table:
      LRequestBody.AddPair('tablename', TableName);
    end
    else
    begin
      // A table update
      LRequestBody.AddPair('tableid', IntToStr(TableID));
      LRequestBody.AddPair('newname', TableName);
    end;
    Result := LRequestBody.ToJSON;
  finally
    LRequestBody.Free;
  end;
end;

{ TmyCloudDataTables }

function TmyCloudDataTables.CreateTable(ATableName: string): TmyCloudDataTable;
begin

  Result := TmyCloudDataTable.Create(Owner);
  try
    Result.TableName := ATableName;
    Owner.Request.ResetToDefaults;
    Owner.Request.Resource := '/v2/schema/table';
    Owner.Request.Method := TRESTRequestMethod.rmPOST;
    Owner.Request.Body.Add(Result.ToJSON, ctAPPLICATION_JSON);
    Owner.Request.Execute;

    if Owner.Request.Response.Status.Success then
    begin
      if (Result.FromJSON(Owner.Request.Response.Content)) then
      begin
        Items.Add(Result);
      end
      else
      begin
        raise Exception.Create('Failed to parse incoming JSON as a table');
      end;
    end
    else
    begin
      Owner.HandleMyCloudDataErrorResponse(Owner.Request.Response);
    end;
  except
    on E: Exception do
    begin
      if Assigned(Result) then
        Result.Free;
      raise;
    end;
  end;
end;

function TmyCloudDataTables.GetTableByID(ATableId: integer): TmyCloudDataTable;
var
  LItem: TmyCloudDataTable;
begin
  if Items <> nil then
  begin
    for LItem in Items do
    begin
      if LItem.TableID = ATableId then
      begin
        Result := LItem;
        Exit;
      end;
    end;
  end;
  Result := nil;
end;

function TmyCloudDataTables.GetTableByName(ATableName: string): TmyCloudDataTable;
var
  LItem: TmyCloudDataTable;
begin
  if Items <> nil then
  begin
    for LItem in Items do
    begin
      if LItem.TableName = ATableName then
      begin
        Result := LItem;
        Exit;
      end;
    end;
  end;
  Result := nil;
end;

function TmyCloudDataTables.GetOrCreateTable(ATableName: string): TmyCloudDataTable;
begin
  Result := GetTableByName(ATableName);
  if Result = nil then
  begin
    Result := CreateTable(ATableName);
  end;
end;

function TmyCloudDataTables.LoadItems: TObjectList<TmyCloudDataTable>;
begin
  try
    Result := nil;

    Owner.EnsureConnectedState;
    Owner.Request.ResetToDefaults;

    Owner.Request.Resource := '/v2/schema/table';
    Owner.Request.Method := TRESTRequestMethod.rmGET;
    Owner.Request.Execute;

    if Owner.Request.Response.Status.Success then
    begin
      if not TryParseJSON(Owner.Request.Response.Content, Result) then
      begin
        raise Exception.Create('Failed to parse the incoming JSON');
      end;
    end
    else
    begin
      Owner.HandleMyCloudDataErrorResponse(Owner.Request.Response);
    end;

  except
    on E: Exception do
    begin
      if Assigned(Result) then
      begin
        Result.Free;
      end;
      raise;
    end;
  end;
end;

procedure TmyCloudDataTables.RemoveTable(ATableId: integer);
var
  LTableToRemove: TmyCloudDataTable;
begin
  LTableToRemove := GetTableByID(ATableId);
  if LTableToRemove <> nil then
  begin
    Owner.Request.ResetToDefaults;
    Owner.Request.Resource := '/v2/schema/table?tableid={tableId}';
    Owner.Request.Params.AddUrlSegment('tableId', IntToStr(ATableId));
    Owner.Request.Method := TRESTRequestMethod.rmDELETE;
    Owner.Request.Execute;
    if Owner.Request.Response.Status.Success then
    begin
      Items.Delete(Items.IndexOf(LTableToRemove));
    end
    else
    begin
      Owner.HandleMyCloudDataErrorResponse(Owner.Request.Response);
    end;
  end;
end;

function TmyCloudDataTables.TryParseJSON(AJSONString: string; out AResult: TObjectList<TmyCloudDataTable>): Boolean;
var
  LObject: TJSONValue;
  LArray: TJSONArray;
  LTable: TmyCloudDataTable;
begin
  Result := True;
  AResult := TObjectList<TmyCloudDataTable>.Create(True);
  LArray := TJSONObject.ParseJSONValue(AJSONString) as TJSONArray;
  try
    for LObject in LArray do
    begin
      LTable := TmyCloudDataTable.Create(Owner);
      if LTable.FromJSON(LObject.ToJSON) then
      begin
        AResult.Add(LTable);
      end
      else
      begin
        LTable.Free;
        Result := False;
        Break;
      end;
    end;
  finally
    LArray.Free;
  end;
end;

{ TCustommyCloudDataRESTClient }

procedure TCustomMyCloudDataRESTClient.FreeLocalData;
begin
  if Assigned(FTables) and (FTables <> nil) then
  begin
    FTables.Free;
  end;
  FTables := nil;

  if Assigned(FCurrentUser) and (FCurrentUser <> nil) then
  begin
    FCurrentUser.Free;
  end;
  FCurrentUser := nil;
end;

constructor TCustomMyCloudDataRESTClient.Create(AOwner: TComponent);
begin
  inherited;
  FRequest := TRESTRequest.Create(self);
  FRequest.Accept := 'application/json';
  FRequest.Client := self;
end;

destructor TCustomMyCloudDataRESTClient.Destroy;
begin
  if Assigned(FTables) and (FTables <> nil) then
    FTables.Free;
  if Assigned(FRequest) and (FRequest <> nil) then
    FRequest.Free;
  if Assigned(FCurrentUser) and (FCurrentUser <> nil) then
    FCurrentUser.Free;
  inherited;
end;

procedure TCustomMyCloudDataRESTClient.EnsureConnectedState;
begin
  if not IsConnected then
  begin
    raise Exception.Create('Client is not connected');
  end;
end;

function TCustomMyCloudDataRESTClient.GetHttpClient: TRESTHTTP;
var
  LParameter: TRESTRequestParameter;
  LValue: string;
  LName: string;
begin
  Result := TRESTHTTP.Create;
  Result.AllowCookies := True;
  Result.OnValidateCertificate := OnValidateCertificate;
  Result.ProxyParams.ProxyPassword := ProxyPassword;
  Result.ProxyParams.ProxyPort := ProxyPort;
  Result.ProxyParams.ProxyServer := ProxyServer;
  Result.ProxyParams.ProxyUsername := ProxyUsername;
  Result.Request.CustomHeaders.Clear;
  Authenticator.Authenticate(Request);
  Result.Request.Accept := 'text/plain';
  Result.Request.AcceptCharSet := 'gzip,deflate,sdch';
  Result.Request.AcceptEncoding := 'text';
  Result.Request.UserAgent := 'myCloudDataRestClient';
  Result.Request.ContentType := 'application/json';
  for LParameter in Request.CreateUnionParameterList do
  begin
    if LParameter.Kind = TRESTRequestParameterKind.pkHTTPHEADER then
    begin
      if (TRESTRequestParameterOption.poDoNotEncode in LParameter.Options) then
      begin
        LName := LParameter.Name;
        LValue := LParameter.Value;
      end
      else
      begin
        LName := URIEncode(LParameter.Name);
        LValue := URIEncode(LParameter.Value);
      end;
      Result.Request.CustomHeaders.Values[LName] := LValue;
    end;
  end;

end;

function TCustomMyCloudDataRESTClient.GetTable(ATableId: integer): TmyCloudDataTable;
begin
  Result := Tables.GetTableByID(ATableId);
end;

function TCustomMyCloudDataRESTClient.GetTables: TmyCloudDataTables;
begin
  if FTables = nil then
  begin
    FTables := TmyCloudDataTables.Create(self as TCustomMyCloudDataRESTClient);
  end;
  Result := FTables;
end;

procedure TCustomMyCloudDataRESTClient.HandleMyCloudDataErrorResponse(AResponse: TCustomRESTResponse);
var
  LJSonValue: TJSONValue;
  LServiceError: string;
begin
  if (AResponse <> nil) and (AResponse.Content.Trim <> '') then
  begin
    LJSonValue := TJSONObject.ParseJSONValue(AResponse.Content);
    try
      if LJSonValue.TryGetValue('error', LServiceError) then
      begin
        raise Exception.Create('MyCloudData Exception: ' + LServiceError);
        Exit;
      end;
    finally
      LJSonValue.Free;
    end;
  end;
  raise Exception.Create('Unknown MyCloudData Exception');
end;

{ TmyCloudDataEntityCollection }

{ TmyCloudDataFieldCollection }

function TmyCloudDataFields.Add(AFieldName: string; ADataType: TmyCloudDataFieldDataType; AFieldSize: integer): TmyCloudDataField;
begin
  if not(ADataType = ftWideString) then
  begin
    raise Exception.Create('FieldSize can only be set on a string field');
  end;
  Result := Add(AFieldName, ADataType);
  Result.MaxFieldSize := AFieldSize;
end;

function TmyCloudDataFields.AddOrUpdate(AFieldName: string; ADataType: TmyCloudDataFieldDataType): TmyCloudDataField;
begin
  Result := GetByName(AFieldName);
  if Result = nil then
  begin
    Result := Add(AFieldName, ADataType);
    Exit;
  end;
  Result.FieldName := AFieldName;
  Result.DataType := ADataType;
  if (ADataType = ftWideString) then
  begin
    Result.MaxFieldSize := 200;
  end;
end;

function TmyCloudDataFields.AddOrUpdate(AFieldName: string; ADataType: TmyCloudDataFieldDataType; AFieldSize: integer): TmyCloudDataField;
begin
  Result := GetByName(AFieldName);
  if Result = nil then
  begin
    Result := Add(AFieldName, ADataType, AFieldSize);
    Exit;
  end;
  Result.FieldName := AFieldName;
  Result.DataType := ADataType;
  Result.MaxFieldSize := AFieldSize;
end;

function TmyCloudDataFields.Add(AFieldName: string; ADataType: TmyCloudDataFieldDataType): TmyCloudDataField;
begin

  if not(GetByName(AFieldName) = nil) then
  begin
    raise Exception.Create('A Field with the name ' + AFieldName + ' already exists on this table');
  end;

  if (ADataType = ftBlob) and (not Owner.CurrentUser.CanUseBlobFields) then
  begin
    raise Exception.Create('Current user cannot use BLOB fields');
  end;

  Result := TmyCloudDataField.Create(TableID);
  Items.Add(Result);
  Result.FieldName := AFieldName;
  Result.DataType := ADataType;

  if (ADataType = ftWideString) then
  begin
    Result.MaxFieldSize := 200;
  end;
end;

constructor TmyCloudDataFields.Create(AOwner: TCustomMyCloudDataRESTClient; ATableId: integer);
begin
  inherited Create(AOwner);
  FTableID := ATableId;
end;

function TmyCloudDataFields.TryParseJSON(AJSONString: string; out AResult: TObjectList<TmyCloudDataField>): Boolean;
var
  LObject: TJSONValue;
  LArray: TJSONArray;
  LField: TmyCloudDataField;
begin
  Result := True;
  AResult := TObjectList<TmyCloudDataField>.Create;
  LArray := TJSONObject.ParseJSONValue(AJSONString) as TJSONArray;
  try
    for LObject in LArray do
    begin
      LField := TmyCloudDataField.Create(TableID);
      if LField.FromJSON(LObject.ToJSON) then
      begin
        if not(LField.FieldName = '_ID') then
        begin
          AResult.Add(LField);
        end
        else
        begin
          LField.Free;
        end;
      end
      else
      begin
        LField.Free;
        Result := False;
        Break;
      end;
    end;
  finally
    LArray.Free;
  end;
end;

function TmyCloudDataFields.GetByName(AFieldName: string): TmyCloudDataField;
var
  LItem: TmyCloudDataField;
begin
  for LItem in Items do
  begin
    if LItem.FieldName.ToLowerInvariant = AFieldName.ToLowerInvariant then
    begin
      Result := LItem;
      Exit;
    end;
  end;
  Result := nil;
end;

function TmyCloudDataFields.GetByOriginalName(AOriginalFieldName: string): TmyCloudDataField;
var
  LItem: TmyCloudDataField;
begin
  for LItem in Items do
  begin
    if LItem.OriginalFieldName.ToLowerInvariant = AOriginalFieldName.ToLowerInvariant then
    begin
      Result := LItem;
      Exit;
    end;
  end;
  Result := nil;
end;

function TmyCloudDataFields.LoadItems: TObjectList<TmyCloudDataField>;
begin
  try

    Owner.EnsureConnectedState;
    Owner.Request.ResetToDefaults;

    Owner.Request.Resource := '/v2/schema/table/field?tableid={tableId}';
    Owner.Request.Params.AddUrlSegment('tableId', IntToStr(TableID));
    Owner.Request.Method := TRESTRequestMethod.rmGET;
    Owner.Request.Execute;

    if Owner.Request.Response.Status.Success then
    begin
      if not TryParseJSON(Owner.Request.Response.Content, Result) then
      begin
        raise Exception.Create('Failed to parse the incoming JSON');
      end;
    end
    else
    begin
      Owner.HandleMyCloudDataErrorResponse(Owner.Request.Response);
    end;

  except
    on E: Exception do
    begin
      if Assigned(Result) then
      begin
        Result.Free;
      end;
      raise;
    end;
  end;
end;

/// <summary>
/// Compares the fieldset for this table with the saved fields on the myCloudData.net service
/// and Creates, Updates or Deletes the fields where needed.
/// </summary>
procedure TmyCloudDataFields.Save;
var
  LSavedFields: TObjectList<TmyCloudDataField>;
  LSavedField: TmyCloudDataField;
  LNewField: TmyCloudDataField;
  LIsNewField: Boolean;
begin

  // Get the previous fieldset from the myCloudData.net service
  LSavedFields := LoadItems;
  try

    // Loop over the previous fieldset to look for updatedOrRemoved removed fields:
    if not(LSavedFields = nil) then
    begin
      // LFieldsToRemove := TList<string>.Create;
      for LSavedField in LSavedFields do
      begin

        LNewField := GetByOriginalName(LSavedField.FFieldName);

        if (LNewField = nil) then
        begin

          // FIELD WAS REMOVED
          Owner.Request.ResetToDefaults;
          Owner.Request.Resource := '/v2/schema/table/field?tableid={tableId}&fieldname={fieldName}';
          Owner.Request.Params.AddUrlSegment('tableId', IntToStr(FTableID));
          Owner.Request.Params.AddUrlSegment('fieldName', LSavedField.FFieldName);
          Owner.Request.Method := TRESTRequestMethod.rmDELETE;
          Owner.Request.Execute;

          if not Owner.Request.Response.Status.Success then
          begin
            Owner.HandleMyCloudDataErrorResponse(Owner.Request.Response);
          end;

        end
        else
        begin

          if (LNewField.DataType = ftBlob) and (not Owner.CurrentUser.CanUseBlobFields) then
          begin
            raise Exception.Create('Current user cannot use BLOB fields');
          end;

          if not LNewField.CompareBasicFields(LSavedField) then
          begin

            // FIELD WAS UPDATED
            Owner.Request.ResetToDefaults;
            Owner.Request.Resource := '/v2/schema/table/field';
            Owner.Request.Method := TRESTRequestMethod.rmPUT;
            Owner.Request.AddBody(LNewField.ToJSON(False), ctAPPLICATION_JSON);
            Owner.Request.Execute;

            if not Owner.Request.Response.Status.Success then
            begin
              Owner.HandleMyCloudDataErrorResponse(Owner.Request.Response);
            end;

          end;

          if not(LNewField.CompareExtraMetaData(LSavedField)) then
          begin
            Owner.Request.ResetToDefaults;
            Owner.Request.Resource := '/v2/schema/table/metadata';
            Owner.Request.Method := TRESTRequestMethod.rmPOST;
            Owner.Request.AddBody(LNewField.ToMetaDataJSON, ctAPPLICATION_JSON);
            Owner.Request.Execute;

            if not Owner.Request.Response.Status.Success then
            begin
              Owner.HandleMyCloudDataErrorResponse(Owner.Request.Response);
            end;

          end;

        end;
      end;
    end
    else
    begin
      LSavedFields := TObjectList<TmyCloudDataField>.Create;
    end;

    for LNewField in FItems do
    begin
      LIsNewField := True;
      for LSavedField in LSavedFields do
      begin
        if LSavedField.FieldName.ToLowerInvariant = LNewField.OriginalFieldName.ToLowerInvariant then
        begin
          LIsNewField := False;
        end;
      end;
      if LIsNewField then
      begin

        if (LNewField.DataType = ftBlob) and (not Owner.CurrentUser.CanUseBlobFields) then
        begin
          raise Exception.Create('Current user cannot use BLOB fields');
        end;

        // FIELD WAS ADDED
        Owner.Request.ResetToDefaults;
        Owner.Request.Resource := '/v2/schema/table/field';
        Owner.Request.Method := TRESTRequestMethod.rmPOST;
        Owner.Request.AddBody(LNewField.ToJSON(True), ctAPPLICATION_JSON);
        Owner.Request.Execute;

        if not Owner.Request.Response.Status.Success then
        begin
          Owner.HandleMyCloudDataErrorResponse(Owner.Request.Response);
        end;

        if LNewField.HasExtraMetaData then
        begin
          Owner.Request.ResetToDefaults;
          Owner.Request.Resource := '/v2/schema/table/metadata';
          Owner.Request.Method := TRESTRequestMethod.rmPOST;
          Owner.Request.AddBody(LNewField.ToMetaDataJSON, ctAPPLICATION_JSON);
          Owner.Request.Execute;

          if not Owner.Request.Response.Status.Success then
          begin
            Owner.HandleMyCloudDataErrorResponse(Owner.Request.Response);
          end;

        end;

      end;
    end;
  finally
    LSavedFields.Free;
  end;
end;

constructor TmyCloudDataField.Create(ATableId: integer);
begin
  inherited Create;
  FTableID := ATableId;
  FMetaData := TmyCloudDataFieldMetaData.Create;
end;

function TmyCloudDataField.DataTypeToString(ADataType: TmyCloudDataFieldDataType): string;
begin
  if ADataType = ftInteger then
    Result := 'int';

  if ADataType = ftFloat then
    Result := 'float';

  if ADataType = ftWideString then
    Result := 'nvarchar';

  if ADataType = ftBoolean then
    Result := 'bit';

  if ADataType = ftDateTime then
    Result := 'datetime';

  if ADataType = ftDate then
    Result := 'date';

  if ADataType = ftTime then
    Result := 'time';

  if ADataType = ftBlob then
    Result := 'varbinary';
end;

destructor TmyCloudDataField.Destroy;
begin
  FMetaData.Free;
  inherited;
end;

function TmyCloudDataField.FromJSON(AJSONString: string): Boolean;
var
  LObject: TJSONValue;
  LDataTypeAsString: string;
  LTypedValuesArray: TJSONArray;
  LTypedValueJSON: TJSONValue;
  LTypedValueKey: string;
  LTypedValueValue: string;
begin
  Result := True;

  LObject := TJSONObject.ParseJSONValue(AJSONString);

  try
    if not(LObject.TryGetValue('column_name', FFieldName)) then
    begin
      Result := False;
      Exit;
    end;

    if not(LObject.TryGetValue('data_type', LDataTypeAsString)) then
    begin
      Result := False;
      Exit;
    end;

    FOriginalFieldName := FieldName;
    DataType := StringToDataType(LDataTypeAsString);

    IsNullable := LowerCase(TmyCloudDataJSonHelper.TryGetJSonProperty<string>(LObject, 'is_nullable', 'no')) = 'yes';

    if DataType = ftWideString then
      MaxFieldSize := TmyCloudDataJSonHelper.TryGetJSonProperty<integer>(LObject, 'character_maximum_length')
    else
      MaxFieldSize := 0;

    // Extra metadata
    MetaData.LabelText := TmyCloudDataJSonHelper.TryGetJSonProperty<string>(LObject, 'fieldlabel');
    MetaData.DefaultValue := TmyCloudDataJSonHelper.TryGetJSonProperty<string>(LObject, 'fielddefaultvalue');
    MetaData.Width := TmyCloudDataJSonHelper.TryGetJSonProperty<integer>(LObject, 'fieldwidth');
    MetaData.Order := TmyCloudDataJSonHelper.TryGetJSonProperty<integer>(LObject, 'fieldorder');
    MetaData.Mask := TmyCloudDataJSonHelper.TryGetJSonProperty<string>(LObject, 'fieldmask');
    MetaData.Minimum := TmyCloudDataJSonHelper.TryGetJSonProperty<double>(LObject, 'fieldminimum');
    MetaData.Maximum := TmyCloudDataJSonHelper.TryGetJSonProperty<double>(LObject, 'fieldmaximum');
    MetaData.MinimumDate := TmyCloudDataJSonHelper.TryGetJSonProperty<TDatetime>(LObject, 'fieldminimumdate');
    MetaData.MaximumDate := TmyCloudDataJSonHelper.TryGetJSonProperty<TDatetime>(LObject, 'fieldmaximumdate');
    MetaData.Visible := TmyCloudDataJSonHelper.TryGetJSonProperty<Boolean>(LObject, 'fieldvisible');
    MetaData.Enabled := TmyCloudDataJSonHelper.TryGetJSonProperty<Boolean>(LObject, 'fieldenabled');
    MetaData.Required := TmyCloudDataJSonHelper.TryGetJSonProperty<Boolean>(LObject, 'fieldrequired');
    MetaData.Description := TmyCloudDataJSonHelper.TryGetJSonProperty<string>(LObject, 'fielddescription');
    MetaData.LookupTable := TmyCloudDataJSonHelper.TryGetJSonProperty<int64>(LObject, 'fieldlookuptable');
    MetaData.LookupField := TmyCloudDataJSonHelper.TryGetJSonProperty<string>(LObject, 'fieldlookupfield');
    MetaData.LookupKeyField := TmyCloudDataJSonHelper.TryGetJSonProperty<string>(LObject, 'fieldlookupkeyfield');

    if LObject.TryGetValue('fieldtypedvalues', LTypedValuesArray) then
    begin
      if LTypedValuesArray <> nil then
      begin
        for LTypedValueJSON in LTypedValuesArray do
        begin
          LTypedValueKey := TmyCloudDataJSonHelper.TryGetJSonProperty<string>(LTypedValueJSON, 'datavalue', '');
          LTypedValueValue := TmyCloudDataJSonHelper.TryGetJSonProperty<string>(LTypedValueJSON, 'displayvalue', '');
          MetaData.TypedValues.Add(LTypedValueKey, LTypedValueValue);
        end;
      end;

    end;

  finally
    LObject.Free;
  end;

end;

function TmyCloudDataField.CompareBasicFields(AOtherField: TmyCloudDataField): Boolean;
begin
  Result := (TableID = AOtherField.TableID) and (FieldName = AOtherField.FieldName) and (DataType = AOtherField.DataType) and
    (MaxFieldSize = AOtherField.MaxFieldSize);
end;

function TmyCloudDataField.CompareExtraMetaData(AOtherField: TmyCloudDataField): Boolean;
begin
  Result := MetaData.Equals(AOtherField.MetaData);
end;

function TmyCloudDataField.StringToDataType(AString: string): TmyCloudDataFieldDataType;
begin
  Result := ftWideString;
  // Default to string

  if AString = 'bigint' then
    Result := ftInteger;

  if AString = 'int' then
    Result := ftInteger;

  if AString = 'float' then
    Result := ftFloat;

  if AString = 'nvarchar' then
    Result := ftWideString;

  if AString = 'bit' then
    Result := ftBoolean;

  if AString = 'datetime' then
    Result := ftDateTime;

  if AString = 'date' then
    Result := ftDate;

  if AString = 'time' then
    Result := ftTime;

  if AString = 'varbinary' then
    Result := ftBlob;

end;

function TmyCloudDataField.ToJSON(AIsNew: Boolean): string;
var
  LJsonObject: TJSONObject;
begin
  LJsonObject := TJSONObject.Create;
  try

    LJsonObject.AddPair('tableid', IntToStr(TableID));
    if AIsNew then
    begin
      LJsonObject.AddPair('fieldname', FieldName);
    end
    else
    begin
      LJsonObject.AddPair('oldname', OriginalFieldName);
      LJsonObject.AddPair('newname', FieldName);
    end;
    LJsonObject.AddPair('datatype', DataTypeToString(DataType));
    LJsonObject.AddPair('length', IntToStr(MaxFieldSize));
    Result := LJsonObject.ToJSON;
  finally
    LJsonObject.Free;
  end;

end;

function TmyCloudDataField.ToMetaDataJSON: string;
var
  LJsonObject: TJSONObject;
  LStringValue: string;
begin
  LJsonObject := TJSONObject.Create;
  try

    LJsonObject.AddPair('tableid', IntToStr(TableID));
    LJsonObject.AddPair('fieldname', FieldName);

    LJsonObject.AddPair('fielddefaultvalue', MetaData.DefaultValue);
    LJsonObject.AddPair('fieldlabel', MetaData.LabelText);
    LJsonObject.AddPair('fieldwidth', IntToStr(MetaData.Width));
    LJsonObject.AddPair('fieldorder', IntToStr(MetaData.Order));
    LJsonObject.AddPair('fieldmask', MetaData.Mask);
    LJsonObject.AddPair('fieldmin', FloatToStr(MetaData.Minimum));
    LJsonObject.AddPair('fieldmax', FloatToStr(MetaData.Maximum));

    if TmyCloudDataJSonHelper.TrySerializeDateTimeFieldValue(MetaData.MinimumDate, LStringValue) then
    begin
      LJsonObject.AddPair('fieldmindate', LStringValue);
    end;

    if TmyCloudDataJSonHelper.TrySerializeDateTimeFieldValue(MetaData.MaximumDate, LStringValue) then
    begin
      LJsonObject.AddPair('fieldmaxdate', LStringValue);
    end;

    if TmyCloudDataJSonHelper.TrySerializeBooleanFieldValue(MetaData.Visible, LStringValue) then
    begin
      LJsonObject.AddPair('fieldvisible', LStringValue);
    end;

    if TmyCloudDataJSonHelper.TrySerializeBooleanFieldValue(MetaData.Enabled, LStringValue) then
    begin
      LJsonObject.AddPair('fieldenabled', LStringValue);
    end;

    if TmyCloudDataJSonHelper.TrySerializeBooleanFieldValue(MetaData.Required, LStringValue) then
    begin
      LJsonObject.AddPair('fieldrequired', LStringValue);
    end;

    LJsonObject.AddPair('fielddescription', MetaData.Description);

    if MetaData.LookupTable > 0 then
    begin
      LJsonObject.AddPair('fieldlookuptable', IntToStr(MetaData.LookupTable));
    end
    else
    begin
      LJsonObject.AddPair('fieldlookuptable', nil);
    end;

    LJsonObject.AddPair('fieldlookupfield', MetaData.LookupField);
    LJsonObject.AddPair('fieldlookupkeyfield', MetaData.LookupKeyField);

    Result := LJsonObject.ToJSON;
  finally
    LJsonObject.Free;
  end;

end;

{ TmyCloudDataJSonHelper }

class function TmyCloudDataJSonHelper.TryGetJSonProperty<T>(AJSonValue: TJSONValue; APath: string; ADefaultValue: T): T;
begin
  try
    if ((AJSonValue is TJSONNull) or not AJSonValue.TryGetValue<T>(APath, Result)) then
    begin
      Result := ADefaultValue;
    end;
  except
    on E: Exception do
      Result := ADefaultValue;
  end;
end;

class function TmyCloudDataJSonHelper.TryGetJSonProperty<T>(AJSonValue: TJSONValue; APath: string): T;
begin
  Result := TryGetJSonProperty(AJSonValue, APath, default (T));
end;

{------------------------------------------------------------------------------}

{ TmyCloudDataEntityFilter }

function TmyCloudDataEntityFilter.OperatorAsString(AOperator: TComparisonOperator): string;
begin
  case AOperator of
    coEqual:
      Result := '=';
    coNotEqual:
      Result := '<>';
    coLike:
      Result := 'LIKE';
    coGreater:
      Result := '>';
    coGreaterOrEqual:
      Result := '<=';
    coLess:
      Result := '>';
    coLessOrEqual:
      Result := '>=';
    coStartsWith:
      Result := 'STARTSWITH';
    coEndsWith:
      Result := 'ENDWITH';
    coNull:
      Result := 'ISNULL';
    coNotNull:
      Result := 'ISNOTNULL';
  end;
end;

function TmyCloudDataEntityFilter.OperatorAsString(AOperator: TLogicalOperator): string;
begin
  case AOperator of
    loAnd:
      Result := 'AND';
    loOr:
      Result := 'OR';
    loNone:
      Result := '';
  end;
end;

function TmyCloudDataEntityFilter.ToJSON: TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('field', FieldName);
  Result.AddPair('operator', OperatorAsString(ComparisonOperator));
  Result.AddPair('value', Value);
  Result.AddPair('logical', OperatorAsString(LogicalOperator));
end;

{------------------------------------------------------------------------------}

{ TmyCloudDataEntitySorting }

function TmyCloudDataEntitySorting.SortOrderAsString(ASortOrder: TSortDirection): string;
begin
  case ASortOrder of
    soAscending:
      Result := 'ASC';
    soDescending:
      Result := 'DESC';
  end;
end;

function TmyCloudDataEntitySorting.ToJSON: TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('field', FieldName);
  Result.AddPair('sortorder', SortOrderAsString(SortDirection));
end;

{------------------------------------------------------------------------------}

{ TmyCloudDataEntityCollection }

constructor TmyCloudDataEntities.Create(AOwner: TCustomMyCloudDataRESTClient; ATableId: integer; AFieldCollection: TmyCloudDataFields);
begin
  inherited Create(AOwner);
  FTableID := ATableId;
  FRemovedEntities := TList<int64>.Create;
  FFieldCollection := AFieldCollection;
end;

function TmyCloudDataEntities.CreateEntity: TmyCloudDataEntity;
begin
  Result := TmyCloudDataEntity.Create(Owner, TableID, FFieldCollection);
  Items.Add(Result);
end;

destructor TmyCloudDataEntities.Destroy;
begin
  inherited;
  FRemovedEntities.Free;
end;

function TmyCloudDataEntities.FromJSON(AJSONString: string): Boolean;
var
  LObject: TJSONValue;
  LArray: TJSONArray;
  LEntity: TmyCloudDataEntity;
begin
  Result := True;
  LArray := TJSONObject.ParseJSONValue(AJSONString) as TJSONArray;
  try
    for LObject in LArray do
    begin
      LEntity := TmyCloudDataEntity.Create(Owner, TableID, FFieldCollection);
      if LEntity.FromJSON(LObject.ToJSON, FFieldCollection) then
      begin
        Items.Add(LEntity);
      end
      else
      begin
        LEntity.Free;
        Result := False;
        Break;
      end;
    end;
  finally
    LArray.Free;
  end;
end;

function TmyCloudDataEntities.GetEntity(AEntityId: int64): TmyCloudDataEntity;
var
  LEntity: TmyCloudDataEntity;
begin
  Result := nil;
  for LEntity in Items do
  begin
    if (LEntity.ID = AEntityId) then
    begin
      Result := LEntity;
      Exit;
    end;
  end;
end;

procedure TmyCloudDataEntities.RemoveEntity(AEntityId: int64);
var
  LEntity: TmyCloudDataEntity;
begin
  LEntity := GetEntity(AEntityId);
  if not(LEntity = nil) then
  begin
    FRemovedEntities.Add(AEntityId);
    Items.Remove(LEntity);
  end;
end;

procedure TmyCloudDataEntities.Save;
var
  LEntity: TmyCloudDataEntity;
  LRemovedEntityId: int64;
begin
  Owner.EnsureConnectedState;

  for LEntity in Items do
  begin

    if (LEntity.IsNew) then
    begin

      Owner.Request.ResetToDefaults;
      Owner.Request.Resource := '/v2/data/table';
      Owner.Request.Method := TRESTRequestMethod.rmPOST;
      Owner.Request.AddBody(LEntity.ToJSON, ctAPPLICATION_JSON);
      Owner.Request.Execute;
      if Owner.Request.Response.Status.Success then
      begin
        if not LEntity.FromJSON(Owner.Request.Response.Content, FFieldCollection) then
        begin
          raise Exception.Create('Failed to insert entity');
        end;
      end
      else
      begin
        Owner.HandleMyCloudDataErrorResponse(Owner.Request.Response);
      end;
    end
    else
    begin
      if LEntity.HasUnsavedChanges then
      begin

        Owner.Request.ResetToDefaults;
        Owner.Request.Resource := '/v2/data/table';
        Owner.Request.Method := TRESTRequestMethod.rmPUT;
        Owner.Request.AddBody(LEntity.ToJSON, ctAPPLICATION_JSON);
        Owner.Request.Execute;

        if not Owner.Request.Response.Status.Success then
        begin
          Owner.HandleMyCloudDataErrorResponse(Owner.Request.Response);
        end;
      end;
    end;

  end;
  for LRemovedEntityId in FRemovedEntities do
  begin

    Owner.Request.ResetToDefaults;
    Owner.Request.Resource := '/v2/data/table?tableid={tableId}&recordid={entityId}';
    Owner.Request.Params.AddUrlSegment('tableId', IntToStr(FTableID));
    Owner.Request.Params.AddUrlSegment('entityId', IntToStr(LRemovedEntityId));
    Owner.Request.Method := TRESTRequestMethod.rmDELETE;
    Owner.Request.Execute;

    if not Owner.Request.Response.Status.Success then
    begin
      Owner.HandleMyCloudDataErrorResponse(Owner.Request.Response);
    end;
  end;
  FRemovedEntities.Clear;
end;

{------------------------------------------------------------------------------}

{ TmyCloudDataFieldMeta }

constructor TmyCloudDataFieldMetaData.Create;
begin
  inherited;
  FTypedValues := TDictionary<string, string>.Create;
  FVisible := True;
  FEnabled := True;
  FRequired := False;
end;

destructor TmyCloudDataFieldMetaData.Destroy;
begin
  if Assigned(FTypedValues) then
    FTypedValues.Free;
  inherited;
end;

function TmyCloudDataFieldMetaData.Equals(Obj: TObject): Boolean;
var
  AOther: TmyCloudDataFieldMetaData;
begin
  Result := False;
  if (Obj is TmyCloudDataFieldMetaData) then
  begin
    AOther := Obj as TmyCloudDataFieldMetaData;

    Result := (LabelText = AOther.LabelText) and (DefaultValue = AOther.DefaultValue) and (Width = AOther.Width) and (Order = AOther.Order) and
      (Mask = AOther.Mask) and (Minimum = AOther.Minimum) and (Maximum = AOther.Maximum) and (MinimumDate = AOther.MinimumDate) and
      (MaximumDate = AOther.MaximumDate) and (Visible = AOther.Visible) and (Enabled = AOther.Enabled) and (Required = AOther.Required) and
      (Description = AOther.Description) and (LookupTable = AOther.LookupTable) and (LookupField = AOther.LookupField) and
      (LookupKeyField = AOther.LookupKeyField) and (TypedField = AOther.TypedField);
  end;
end;

{ TmyCloudDataBlob }

function TmyCloudDataBlob.AsString: string;
begin
  if (HasData) then
  begin
    Result := '[Binary]';
  end
  else
  begin
    Result := '[Empty]';
  end;
end;

procedure TmyCloudDataBlob.FromFile(AFileName: string);
var
  LFileStream: TFileStream;
begin
  LFileStream := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyWrite);
  try
    SetStream(LFileStream);
  finally
    LFileStream.Free;
  end;
end;

function TmyCloudDataBlob.FromJSON(AJSONString: string): Boolean;
var
  LJSonValue: TJSONValue;
begin

  Result := False;

  LJSonValue := TJSONObject.ParseJSONValue(AJSONString);
  try
    if LJSonValue.TryGetValue<string>('url', FUrl) then
    begin
      FHasData := TmyCloudDataJSonHelper.TryGetJSonProperty<Boolean>(LJSonValue, 'hasdata', False);
      Result := True;
    end;
  finally
    LJSonValue.Free;
  end;

end;

function TmyCloudDataBlob.GetStream: TStream;
var
  LHttpClient: TRESTHTTP;
begin
  Result := nil;
  if HasData then
  begin
    Owner.EnsureConnectedState;
    Owner.Request.ResetToDefaults;
    Owner.Request.Resource := '/v2/data/files{url}';
    Owner.Request.Params.AddUrlSegment('url', FUrl);
    Result := TMemoryStream.Create;
    try
      LHttpClient := Owner.GetHttpClient;
      try
        LHttpClient.Get(Owner.Request.GetFullRequestURL, Result);
      finally
        LHttpClient.Free;
      end;
    except
      on E: Exception do
      begin
        Result.Free;
        raise;
      end;
    end;
  end;
end;

procedure TmyCloudDataBlob.SetStream(AStream: TStream);
var
  LHttpClient: TRESTHTTP;
  LOutStream: TMemoryStream;
  LBodyStream: TStringStream;
const
  LBoundary: string = 'lLKk515255fskd54d2hLKHL1';
begin

  Owner.EnsureConnectedState;
  Owner.Request.ResetToDefaults;
  Owner.Request.Resource := '/v2/data/files{url}';
  Owner.Request.Params.AddUrlSegment('url', FUrl);

  LOutStream := TMemoryStream.Create;
  LBodyStream := TStringStream.Create;
  LHttpClient := Owner.GetHttpClient;
  try
    LHttpClient.Request.ContentType := 'multipart/form-data; boundary=' + LBoundary;
    LBodyStream.WriteString('--' + LBoundary + sLineBreak);
    LBodyStream.WriteString('Content-Disposition: form-data; name="file"; filename="BIN"' + sLineBreak);
    LBodyStream.WriteString('Content-Type: application/octet-stream' + sLineBreak);
    LBodyStream.WriteString(sLineBreak);
    if AStream <> nil then
    begin
      LBodyStream.CopyFrom(AStream, 0);
    end;
    LBodyStream.WriteString(sLineBreak);
    LBodyStream.WriteString('--' + LBoundary + '--');

    LHttpClient.Post(Owner.Request.GetFullRequestURL, LBodyStream, LOutStream);

    FHasData := True;

  finally
    LOutStream.Free;
    LBodyStream.Free;
    LHttpClient.Free;
  end;
end;

function TmyCloudDataBlob.ToFile(AFileName: string): Boolean;
var
  LStream: TStream;
  LFileStream: TFileStream;
begin
  Result := False;
  if HasData then
  begin
    LStream := GetStream;
    try
      if (LStream <> nil) and (LStream.Size > 0) then
      begin
        LFileStream := TFileStream.Create(AFileName, fmCreate);
        try
          LStream.Position := 0;
          LFileStream.CopyFrom(LStream, LStream.Size);
          Result := True;
        finally
          LFileStream.Free;
        end;
      end;
    finally
      LStream.Free;
    end;
  end;
end;

constructor TmyCloudDataModelCollectionBase<T>.Create(AOwner: TCustomMyCloudDataRESTClient);
begin
  inherited Create(AOwner);
  FItems := nil;
end;

destructor TmyCloudDataModelCollectionBase<T>.Destroy;
begin
  if Assigned(FItems) then
    FItems.Free;
  inherited;
end;

function TmyCloudDataModelCollectionBase<T>.GetEnumerator: TEnumerator<T>;
begin
  Result := Items.GetEnumerator;
end;

function TmyCloudDataModelCollectionBase<T>.GetItem(i: integer): T;
begin
  Result := Items[i];
end;

function TmyCloudDataModelCollectionBase<T>.GetItemCount: integer;
begin
  Result := Items.Count
end;

function TmyCloudDataModelCollectionBase<T>.GetItems: TObjectList<T>;
begin
  if FItems = nil then
  begin
    FItems := LoadItems;
  end;
  Result := FItems;
end;

function TmyCloudDataModelCollectionBase<T>.LoadItems: TObjectList<T>;
begin
  // The default behaviour is to just create a new TObjectList<T>
  Result := TObjectList<T>.Create(True);
end;

procedure TmyCloudDataModelCollectionBase<T>.Reset;
begin
  if Assigned(FItems) then
  begin
    FItems.Free
  end;
end;

{------------------------------------------------------------------------------}

{ TmyCloudDataEntityFilterCollection }

function TmyCloudDataEntityFilters.Add(AFieldName: string; AValue: Variant; AComparisonOperator: TComparisonOperator;
  ALogicalOperator: TLogicalOperator): integer;
var
  LFilter: TmyCloudDataEntityFilter;
begin
  LFilter := TmyCloudDataEntityFilter.Create;
  LFilter.FieldName := AFieldName;
  LFilter.Value := AValue;
  LFilter.LogicalOperator := ALogicalOperator;
  LFilter.ComparisonOperator := AComparisonOperator;
  Result := Add(LFilter);
end;

{------------------------------------------------------------------------------}

{ TmyCloudDataEntitySortingCollection }

function TmyCloudDataEntitySortingCollection.Add(AFieldName: string; AOrder: TSortDirection): integer;
var
  LSorting: TmyCloudDataEntitySorting;
begin
  LSorting := TmyCloudDataEntitySorting.Create;
  LSorting.FieldName := AFieldName;
  LSorting.SortDirection := AOrder;
  Result := Add(LSorting);
end;

{------------------------------------------------------------------------------}

{ TmyCloudDataTablePermissions }

function TmyCloudDataPermissions.IsSameAs(AOther: TmyCloudDataPermissions): Boolean;
var
  LPermission: TmyCloudDataPermission;
begin
  Result := False;
  if (Count = AOther.Count) then
  begin
    for LPermission in AOther do
    begin
      if not contains(LPermission) then
      begin
        Result := False;
        Exit;
      end;
    end;
    Result := True;
  end;
end;

class function TmyCloudDataPermissions.FromString(ASource: string): TmyCloudDataPermissions;
begin
  Result := TmyCloudDataPermissions.None;
  Result.SetFromString(ASource);
end;

class function TmyCloudDataPermissions.None: TmyCloudDataPermissions;
begin
  Result := TmyCloudDataPermissions.Create;
end;

class function TmyCloudDataPermissions.ReadOnly: TmyCloudDataPermissions;
begin
  Result := TmyCloudDataPermissions.FromString('R');
end;

class function TmyCloudDataPermissions.ReadWrite: TmyCloudDataPermissions;
begin
  Result := TmyCloudDataPermissions.FromString('CRUD');
end;

procedure TmyCloudDataPermissions.SetFromString(ASource: string);
begin
  ASource := ASource.Trim.ToUpperInvariant;
  if ContainsStr(ASource, 'C') then
    Add(pCreate);
  if ContainsStr(ASource, 'R') then
    Add(pRead);
  if ContainsStr(ASource, 'U') then
    Add(pUpdate);
  if ContainsStr(ASource, 'D') then
    Add(pDelete);
end;

function TmyCloudDataPermissions.ToString: string;
begin
  Result := '';
  if contains(pCreate) then
    Result := Result + 'C';
  if contains(pRead) then
    Result := Result + 'R';
  if contains(pUpdate) then
    Result := Result + 'U';
  if contains(pDelete) then
    Result := Result + 'D';
end;

{------------------------------------------------------------------------------}

{ TmyCloudDataTableShare }

constructor TmyCloudDataTableShare.Create(ATableId: integer; AEmail: string; APermissions: TmyCloudDataPermissions; IsNew: Boolean = True);
begin
  FTableID := ATableId;
  FEmail := AEmail;
  FPermissions := APermissions;
  if IsNew then
  begin
    // make sure that this one gets saved
    FHasUnchangedChanges := True;
  end;
end;

procedure TmyCloudDataTableShare.SetPermissions(const Value: TmyCloudDataPermissions);
begin
  if not(FPermissions.IsSameAs(Value)) then
  begin
    FHasUnchangedChanges := True;
    FPermissions := Value;
  end;
end;

{------------------------------------------------------------------------------}

{ TmyCloudDataTableShares }

procedure TmyCloudDataTableShares.Save;
var
  LShare: TmyCloudDataTableShare;
begin
  for LShare in Items do
  begin
    if (LShare.HasUnsavedChanges) then
    begin

    end;
  end;
end;

procedure TmyCloudDataTableShares.SetShare(AEmail: string; APermissions: TmyCloudDataPermissions);
var
  LShare: TmyCloudDataTableShare;
begin
  LShare := GetShare(AEmail);
  if LShare <> nil then
  begin
    LShare.Permissions.SetFromString(APermissions.ToString);
  end
  else
  begin
    LShare := TmyCloudDataTableShare.Create(FTableID, AEmail, APermissions);
    Items.Add(LShare);
  end;
end;

function TmyCloudDataTableShares.TryParseJSON(AJSONString: string; out AResult: TObjectList<TmyCloudDataTableShare>): Boolean;
var
  LObject: TJSONValue;
  LArray: TJSONArray;
  LEmail: string;
  LPermissions: string;
begin
  Result := True;
  AResult := TObjectList<TmyCloudDataTableShare>.Create;
  LArray := TJSONObject.ParseJSONValue(AJSONString) as TJSONArray;
  try
    for LObject in LArray do
    begin
      LEmail := TmyCloudDataJSonHelper.TryGetJSonProperty<string>(LObject, 'email', '');
      LPermissions := TmyCloudDataJSonHelper.TryGetJSonProperty<string>(LObject, 'permissions', '');
      if LEmail <> '' then
      begin
        AResult.Add(TmyCloudDataTableShare.Create(FTableID, LEmail, TmyCloudDataPermissions.FromString(LPermissions)));
      end
    end;
  finally
    LArray.Free;
  end;
end;

constructor TmyCloudDataTableShares.Create(AOwner: TCustomMyCloudDataRESTClient; ATableId: integer);
begin
  inherited Create(AOwner);
  FTableID := ATableId;
end;

function TmyCloudDataTableShares.GetShare(AEmail: string): TmyCloudDataTableShare;
var
  LItem: TmyCloudDataTableShare;
begin
  for LItem in Items do
  begin
    if LItem.Email.Trim.ToLowerInvariant = AEmail.Trim.ToLowerInvariant then
    begin
      Result := LItem;
      Exit;
    end;
  end;
  Result := nil;
end;

function TmyCloudDataTableShares.LoadItems: TObjectList<TmyCloudDataTableShare>;
begin
  try
    Result := nil;

    Owner.EnsureConnectedState;
    Owner.Request.ResetToDefaults;

    Owner.Request.Resource := '/v2/schema/share/table?tableid={tableId}';
    Owner.Request.Params.AddUrlSegment('tableId', IntToStr(FTableID));
    Owner.Request.Method := TRESTRequestMethod.rmGET;
    Owner.Request.Execute;

    if Owner.Request.Response.StatusCode = 200 then
    begin
      if not TryParseJSON(Owner.Request.Response.Content, Result) then
      begin
        raise Exception.Create('Failed to parse the incoming JSON');
      end;
    end
    else
    begin
      Owner.HandleMyCloudDataErrorResponse(Owner.Request.Response);
    end;

  except
    on E: Exception do
    begin
      if Assigned(Result) then
      begin
        Result.Free;
      end;
      raise;
    end;
  end;
end;

procedure TmyCloudDataTableShares.RemoveShare(AEmail: string);
begin
  GetShare(AEmail).SetPermissions(TmyCloudDataPermissions.None);
end;

{------------------------------------------------------------------------------}

{ TmyCloudDataEntityQueryResult }

destructor TmyCloudDataEntityQueryResult.Destroy;
begin
  if Assigned(FResults) then
    FResults.Free;
  inherited;
end;

{ TmyCloudDataUser }

{ TmyCloudDataUser }

function TmyCloudDataUser.CanUseBlobFields: Boolean;
begin
  Result := FUserType <> utFree;
end;

destructor TmyCloudDataUser.Destroy;
begin
  if Assigned(FPermissions) then
    FPermissions.Free;
  inherited;
end;

function TmyCloudDataUser.FromJSON(ASource: string): Boolean;
var
  LJSonValue: TJSONValue;
  LUserIdAsString: string;
  LStatusAsString: string;
  LPermissionsAsString: string;
begin
  Result := False;

  LJSonValue := TJSONObject.ParseJSONValue(ASource);

  try

    LUserIdAsString := TmyCloudDataJSonHelper.TryGetJSonProperty(LJSonValue, 'id', '');
    LStatusAsString := TmyCloudDataJSonHelper.TryGetJSonProperty(LJSonValue, 'status', '');
    LPermissionsAsString := TmyCloudDataJSonHelper.TryGetJSonProperty(LJSonValue, 'permissions', '');

    FEmail := TmyCloudDataJSonHelper.TryGetJSonProperty(LJSonValue, 'email', '');
    FFirstName := TmyCloudDataJSonHelper.TryGetJSonProperty(LJSonValue, 'firstname', '');
    FLastName := TmyCloudDataJSonHelper.TryGetJSonProperty(LJSonValue, 'name', '');
    FCompany := TmyCloudDataJSonHelper.TryGetJSonProperty(LJSonValue, 'company', '');

    LJSonValue.Free;

    LStatusAsString := LStatusAsString.ToLowerInvariant.Trim;

    if (LStatusAsString = 'free') then
      FUserType := utFree;
    if (LStatusAsString = 'subscription') then
      FUserType := utSubscription;
    if (LStatusAsString = 'admin') then
      FUserType := utAdmin;

    FPermissions := TmyCloudDataPermissions.FromString(LPermissionsAsString);

    if (TryStrToInt(LUserIdAsString, FUserId)) and Assigned(FPermissions) then
    begin
      Result := True;
    end;

  except
    on E: Exception do
    begin
      Result := False;
      if Assigned(LJSonValue) then
      begin
        LJSonValue.Free;
      end;
    end;
  end;

end;

function TmyCloudDataUser.UserTypeAsString: string;
begin
  if (FUserType = utFree) then
    Result := 'free';
  if (FUserType = utSubscription) then
    Result := 'subscription';
  if (FUserType = utAdmin) then
    Result := 'admin';
end;

end.
