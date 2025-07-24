unit search;

{$mode ObjFPC}{$H+}

interface

uses
 Classes, SysUtils, Forms, Controls, Graphics, Dialogs, DBGrids, ExtCtrls,
 DBCtrls, Menus, BCButton;

type

 { Tsrchfrm }

 Tsrchfrm = class(TForm)
  applybtn: TBCButton;
  closebtn: TBCButton;
  MenuItem1: TMenuItem;
  srchclose: TMenuItem;
  Separator1: TMenuItem;
  srchundo: TMenuItem;
  srchreinst: TMenuItem;
  srchinstall: TMenuItem;
  srchuninstall: TMenuItem;
  srchapply: TMenuItem;
  srchmnu: TPopupMenu;
  srchgrid: TDBGrid;
  desc: TDBMemo;
  Panel1: TPanel;
  procedure applybtnClick(Sender: TObject);
  procedure closebtnClick(Sender: TObject);
  procedure FormShow(Sender: TObject);
  procedure srchcloseClick(Sender: TObject);
  procedure srchinstallClick(Sender: TObject);
  procedure srchmnuPopup(Sender: TObject);
  procedure srchreinstClick(Sender: TObject);
  procedure srchundoallClick(Sender: TObject);
  procedure srchundoClick(Sender: TObject);
  procedure srchuninstallClick(Sender: TObject);
  procedure srchapplyClick(Sender: TObject);
 private

 public

 end;

var
 srchfrm: Tsrchfrm;

implementation
uses
    data,
    globs,
    actions;

{$R *.lfm}

{ Tsrchfrm }

procedure Tsrchfrm.closebtnClick(Sender: TObject);
begin
     close;
end;

procedure Tsrchfrm.FormShow(Sender: TObject);
begin
     if optot > 0 then
     applybtn.Enabled:= true
     else
     applybtn.Enabled:= false;
end;

procedure Tsrchfrm.srchcloseClick(Sender: TObject);
begin
     close;
end;

procedure Tsrchfrm.applybtnClick(Sender: TObject);
begin

end;

procedure Tsrchfrm.srchinstallClick(Sender: TObject);
var
   rc : longint;

begin
     oprec.kind:= 1;
     oprec.name:= dm.ssrc.DataSet.FieldValues['name'];
     oprec.op:= 'Install';
     oprec.ver:= dm.ssrc.DataSet.FieldValues['version'];

     try
     oplst.AddObject(oprec.name,oprec);
     inc(optot);

     except
     showmessage('Duplicate package ignored');
     exit;
     end;

     applybtn.Enabled:= true;
     srchmnu.Items[3].Enabled:= true;
     srchmnu.Items[4].Enabled:= true;

     rc:= actfrm.actgrid.RowCount;
     actfrm.actgrid.RowCount:= rc+1;

     actfrm.actgrid.Cells[0,rc]:= oprec.name;
     actfrm.actgrid.Cells[1,rc]:= 'Install';

     if not actfrm.Showing then
     actfrm.Show;

end;

procedure Tsrchfrm.srchmnuPopup(Sender: TObject);
begin
     if dm.pkgInstalled.AsBoolean then
     begin
     srchinstall.Enabled:= false;
     srchreinst.Enabled:= true;
     srchuninstall.Enabled:= true;
     end
     else
     begin
     srchinstall.Enabled:= true;
     srchreinst.Enabled:= false;
     srchuninstall.Enabled:= false;
     end;

     if optot > 0 then
     begin
     srchapply.Enabled:= true;
     srchundo.Enabled:= true;
     end
     else
     begin
     srchapply.Enabled:= false;
     srchundo.Enabled:= false;
     end;

end;

procedure Tsrchfrm.srchreinstClick(Sender: TObject);
var
   rc : longint;

begin
     oprec:= Titemrec.Create;
     oprec.kind:= 1;
     oprec.name:= dm.ssrc.DataSet.FieldValues['name'];
     oprec.op:= 'Re-Install';
     oprec.ver:= dm.ssrc.DataSet.FieldValues['version'];

     try
     oplst.AddObject(oprec.name,oprec);
     inc(optot);

     except
     showmessage('Duplicate package ignored');
     exit;
     end;

     applybtn.Enabled:= true;
     srchmnu.Items[3].Enabled:= true;
     srchmnu.Items[4].Enabled:= true;

     rc:= actfrm.actgrid.RowCount;
     actfrm.actgrid.RowCount:= rc+1;

     actfrm.actgrid.Cells[0,rc]:= oprec.name;
     actfrm.actgrid.Cells[1,rc]:= 'Re-Install';

     if not actfrm.Showing then
     actfrm.Show;

end;

procedure Tsrchfrm.srchundoallClick(Sender: TObject);
begin
     undoall;
end;

procedure Tsrchfrm.srchundoClick(Sender: TObject);
begin
     undolast;
end;

procedure Tsrchfrm.srchuninstallClick(Sender: TObject);
var
   rc : longint;

begin
     oprec:= titemrec.Create;
     oprec.kind:= 1;
     oprec.name:= dm.ssrc.DataSet.FieldValues['name'];
     oprec.op:= 'Remove';
     oprec.ver:= dm.ssrc.DataSet.FieldValues['version'];

     try
     oplst.AddObject(curpkg,oprec);
     inc(optot);

     except
     showmessage('Duplicate package ignored');
     exit;
     end;

     applybtn.Enabled:= true;
     srchmnu.Items[3].Enabled:= true;
     srchmnu.Items[4].Enabled:= true;

     rc:= actfrm.actgrid.RowCount;
     actfrm.actgrid.RowCount:= rc+1;

     actfrm.actgrid.Cells[0,rc]:= oprec.name;
     actfrm.actgrid.Cells[1,rc]:= 'Remove';

     if not actfrm.Showing then
     actfrm.Show;

end;

procedure Tsrchfrm.srchapplyClick(Sender: TObject);
begin
     applyall;
end;

end.

