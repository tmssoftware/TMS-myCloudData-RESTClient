{ *************************************************************************** }
{ TMS FMX myCloudData RESTClient                                              }
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

unit FMX.TMS.myCloudDataRestClient;

interface

uses
  REST.TMS.myCloudDataRestClient, IndyPeerImpl,
  REST.TMS.myCloudDataRestClient.Data,
  REST.Authenticator.OAuth.WebForm.FMX, System.UITypes, FMX.Graphics;

type
  TFMXmyCloudDataRESTClient = class(TmyCloudDataRESTClient)
  private
    procedure OnWebformClosed(Sender: TObject; var Action: TCloseAction);
  public
    procedure Authenticate; override;
  end;

  MyCloudDataBlobClassHelper = class helper for TmyCloudDataBlob
  public
    function TryGetAsBitmap(out ABitmap: TBitmap): Boolean;
  end;

implementation

uses
  REST.Utils, System.Classes, System.SysUtils;

{$IFDEF IOS}
{$DEFINE TMSRESTMOBILE}
{$ENDIF}
{$IFDEF ANDROID}
{$DEFINE TMSRESTMOBILE}
{$ENDIF}
{ TFMXmyCloudDataRESTClient }

procedure TFMXmyCloudDataRESTClient.Authenticate;
var
  LWebForm: Tfrm_OAuthWebForm;
begin

  if (ClientID.Trim = '') OR (ClientSecret.Trim = '') then
  begin
    raise Exception.Create('Please make sure to set your application KEY and SECRET that you can obtain by registering at http://myclouddata.net');
  end;

  LWebForm := Tfrm_OAuthWebForm.Create(Owner);

{$IFDEF TMSRESTMOBILE}
  LWebForm.OnBeforeRedirect := OAuth2_AuthTokenRedirect;
{$ELSE}
  LWebForm.OnAfterRedirect := OAuth2_AuthTokenRedirect;
{$ENDIF}
  LWebForm.Caption := 'myCloudData login';
  LWebForm.OnClose := OnWebformClosed;
  LWebForm.ShowWithURL(GetLoginUrl);
end;

procedure TFMXmyCloudDataRESTClient.OnWebformClosed(Sender: TObject; var Action: TCloseAction);
var
  LWebForm: Tfrm_OAuthWebForm;
begin
  LWebForm := Sender AS Tfrm_OAuthWebForm;
  if LWebForm <> nil then
  begin
{$IFDEF TMSRESTMOBILE}
    LWebForm.OnBeforeRedirect := nil;
{$ELSE}
    LWebForm.OnAfterRedirect := nil;
{$ENDIF}
    LWebForm.Release;
  end;
end;

{ MyCloudDataBlobClassHelper }

function MyCloudDataBlobClassHelper.TryGetAsBitmap(out ABitmap: TBitmap): Boolean;
var
  LStream: TStream;
  LBitmap: TBitmap;
begin
  LStream := GetStream;
  try
    LBitmap := TBitmap.Create;
    try
      Result := True;
      LBitmap.LoadFromStream(LStream);
      ABitmap := LBitmap;
      Exit;
    except
      on E: Exception do
      begin
        LBitmap.Free;
        Result := False;
        Exit;
      end;
    end;
    Result := False;
  finally
    LStream.Free;
  end;
end;

end.
