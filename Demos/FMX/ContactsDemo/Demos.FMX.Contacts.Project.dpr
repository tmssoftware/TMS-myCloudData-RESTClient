program Demos.FMX.Contacts.Project;

uses
  System.StartUpCopy,
  FMX.Forms,
  Demos.FMX.Contacts in 'Demos.FMX.Contacts.pas' {ContactsDemoForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TContactsDemoForm, ContactsDemoForm);
  Application.Run;
end.
