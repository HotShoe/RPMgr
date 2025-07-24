unit about;

{$mode ObjFPC}{$H+}

interface

uses
 Classes,SysUtils,Forms,Controls,Graphics,Dialogs,StdCtrls,ExtCtrls,ComCtrls,
 BCButton;

type

 { Taboutfrm }

 Taboutfrm = class(TForm)
  licbtn: TBCButton;
  closebtn: TBCButton;
  Memo1: TMemo;
  Memo2: TMemo;
  Pages: TPageControl;
  Panel1: TPanel;
  Tab1: TTabSheet;
  Tab2: TTabSheet;
  procedure closebtnClick(Sender: TObject);
  procedure FormShow(Sender: TObject);
  procedure licbtnClick(Sender: TObject);
 private

 public

 end;

var
 aboutfrm: Taboutfrm;

implementation
uses
    license;

{$R *.lfm}

{ Taboutfrm }

procedure Taboutfrm.closebtnClick(Sender: TObject);
begin
     close;
end;

procedure Taboutfrm.FormShow(Sender: TObject);
begin
     pages.ActivePage:= Tab1;
end;

procedure Taboutfrm.licbtnClick(Sender: TObject);
begin
     licfrm.ShowModal;
end;

end.

