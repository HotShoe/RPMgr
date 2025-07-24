unit license;

{$mode ObjFPC}{$H+}

interface

uses
 Classes,SysUtils,Forms,Controls,Graphics,Dialogs,StdCtrls,ExtCtrls,BCButton;

type

 { Tlicfrm }

 Tlicfrm = class(TForm)
  BCButton1: TBCButton;
  Memo1: TMemo;
  Panel1: TPanel;
  procedure BCButton1Click(Sender: TObject);
  procedure FormCreate(Sender: TObject);
 private

 public

 end;

var
 licfrm: Tlicfrm;

implementation

{$R *.lfm}

{ Tlicfrm }

procedure Tlicfrm.BCButton1Click(Sender: TObject);
begin
     close;
end;

procedure Tlicfrm.FormCreate(Sender: TObject);
begin
     memo1.Lines.LoadFromFile('/usr/share/rpmgr/license.txt');
end;

end.

