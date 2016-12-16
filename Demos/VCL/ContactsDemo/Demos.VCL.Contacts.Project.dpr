program Demos.VCL.Contacts.Project;

uses
  Vcl.Forms,
  Demos.VCL.Contacts in 'Demos.VCL.Contacts.pas' {ContactsDemoForm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TContactsDemoForm, ContactsDemoForm);
  Application.Run;
end.
