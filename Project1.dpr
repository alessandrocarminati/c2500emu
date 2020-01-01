program Project1;

uses
  Forms,
  Unit1 in 'Unit1.pas' {Form1},
  mc68k in 'mc68k.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Cisco 2500 Emulator';
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
