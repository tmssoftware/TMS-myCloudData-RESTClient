{ *************************************************************************** }
{ TMS VCL myCloudData RESTClient                                              }
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

unit VCL.TMS.myCloudDataRestClient;

interface

uses
  System.Classes, SysUtils, AnsiStrings,
  GIFImg, PNGImage, JPEG,
  REST.TMS.myCloudDataRestClient,
  REST.TMS.myCloudDataRestClient.Data,
  REST.Authenticator.OAuth.WebForm.Win,
  VCL.Controls, VCL.Forms, VCL.Dialogs, VCL.StdCtrls, VCL.ExtCtrls, VCL.Graphics;

type
  TVCLmyCloudDataRESTClient = class(TmyCloudDataRESTClient)
  public
    procedure Authenticate; override;
  end;

  TMyCloudDataBlobClassHelper = class helper for TMyCloudDataBlob
  private
    function FindGraphicClass(const Buffer; const BufferSize: Int64; out GraphicClass: TGraphicClass): Boolean;
  public
    function TryGetAsGraphic(out AGraphic: TGraphic): Boolean;
  end;

implementation

uses
  REST.Utils;

{ VCLTMSMyCloudDataClient }

procedure TVCLmyCloudDataRESTClient.Authenticate;
var
  LWebForm: Tfrm_OAuthWebForm;
begin

  if (ClientID.Trim = '') OR (ClientSecret.Trim = '') then
  begin
    raise Exception.Create('Please make sure to set your application KEY and SECRET that you can obtain by registering at http://myclouddata.net');
  end;

  LWebForm := Tfrm_OAuthWebForm.Create(Owner);
  try
    LWebForm.OnAfterRedirect := OAuth2_AuthTokenRedirect;
    LWebForm.ShowModalWithURL(GetLoginUrl);
  finally
    LWebForm.Release;
  end;
end;

{ TMyCloudDataBlobClassHelper }
const
  MinGraphicSize = 40;

function TMyCloudDataBlobClassHelper.FindGraphicClass(const Buffer; const BufferSize: Int64; out GraphicClass: TGraphicClass): Boolean;
var
  LongWords: array [Byte] of LongWord absolute Buffer;
  Words: array [Byte] of Word absolute Buffer;
begin
  GraphicClass := nil;
  Result := False;
  if BufferSize < MinGraphicSize then
    Exit;
  case Words[0] of
    $4D42:
      GraphicClass := TBitmap;
    $D8FF:
      GraphicClass := TJPEGImage;
    $4949:
      if Words[1] = $002A then
        GraphicClass := TWicImage; // i.e., TIFF
    $4D4D:
      if Words[1] = $2A00 then
        GraphicClass := TWicImage; // i.e., TIFF
  else
    if Int64(Buffer) = $A1A0A0D474E5089 then
      GraphicClass := TPNGImage
    else if LongWords[0] = $9AC6CDD7 then
      GraphicClass := TMetafile
    else if (LongWords[0] = 1) and (LongWords[10] = $464D4520) then
      GraphicClass := TMetafile

    else if AnsiStrings.StrLComp(PAnsiChar(@Buffer), 'GIF', 3) = 0 then
      GraphicClass := TGIFImage
    else if Words[1] = 1 then
      GraphicClass := TIcon;
  end;
  Result := (GraphicClass <> nil);
end;

function TMyCloudDataBlobClassHelper.TryGetAsGraphic(out AGraphic: TGraphic): Boolean;
var
  Buffer: PByte;
  LStream: TStream;
  LGraphicClass: TGraphicClass;
  LJPEGImage: TJPEGImage;
  LBitmap: TBitmap;
  LPNGImage: TPNGImage;
  LGIFImage: TGIFImage;
begin
  LStream := GetStream;
  try
    Buffer := TCustomMemoryStream(LStream).Memory;
    Result := FindGraphicClass(Buffer^, LStream.Size, LGraphicClass);
    if (Result) then
    begin
      if LGraphicClass = TJPEGImage then
      begin
        LJPEGImage := TJPEGImage.Create;
        try
          LJPEGImage.LoadFromStream(LStream);
          AGraphic := LJPEGImage;
          Exit;
        except
          on E: Exception do
          begin
            LJPEGImage.Free;
            Result := False;
            Exit;
          end;
        end;
      end;
      // TBitmap:
      if LGraphicClass = TBitmap then
      begin
        LBitmap := TBitmap.Create;
        try
          LBitmap.LoadFromStream(LStream);
          AGraphic := LBitmap;
          Exit;
        except
          on E: Exception do
          begin
            LBitmap.Free;
            Result := False;
            Exit;
          end;
        end;
      end;
      // TPNGImage:
      if LGraphicClass = TPNGImage then
      begin
        LPNGImage := TPNGImage.Create;
        try
          LPNGImage.LoadFromStream(LStream);
          AGraphic := LPNGImage;
          Exit;
        except
          on E: Exception do
          begin
            LPNGImage.Free;
            Result := False;
            Exit;
          end;
        end;
      end;
      // TGIFImage:
      if LGraphicClass = TGIFImage then
      begin
        LGIFImage := TGIFImage.Create;
        try
          LGIFImage.LoadFromStream(LStream);
          AGraphic := LGIFImage;
          Exit;
        except
          on E: Exception do
          begin
            LGIFImage.Free;
            Result := False;
            Exit;
          end;
        end;
      end;
    end;
    Result := False;
  finally
    LStream.Free;
  end;
end;

end.
