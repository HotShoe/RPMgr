unit installed;

{$mode ObjFPC}{$H+}

interface

uses
 Classes, SysUtils, DB, Forms, Controls, Graphics, Dialogs, DBGrids, DBCtrls,
 Menus, BCButton, ZDataset, ZAbstractRODataset;

type

 { Tinstfrm }

 Tinstfrm = class(TForm)
  applybtn: TBCButton;
  closebtn: TBCButton;
  insrc: TDataSource;
  ingrid: TDBGrid;
  desc: TDBMemo;
  instArch: TZRawStringField;
  instDesc: TZRawStringField;
  instGrp: TZRawStringField;
  instInstalled: TZBooleanField;
  instisize: TZRawStringField;
  instmnu: TPopupMenu;
  instName: TZRawStringField;
  instpsize: TZRawStringField;
  instVersion: TZRawStringField;
  instundo: TMenuItem;
  instuninst: TMenuItem;
  instshowfiles: TMenuItem;
  closeitm: TMenuItem;
  instunall: TMenuItem;
  Separator1: TMenuItem;
  inst: TZQuery;
  procedure applybtnClick(Sender: TObject);
  procedure closebtnClick(Sender: TObject);
  procedure closeitmClick(Sender: TObject);
  procedure FormShow(Sender: TObject);
  procedure instmnuPopup(Sender: TObject);
  procedure instshowfilesClick(Sender: TObject);
  procedure instunallClick(Sender: TObject);
  procedure instundoClick(Sender: TObject);
  procedure instuninstClick(Sender: TObject);
 private

 public

 end;

var
 instfrm: Tinstfrm;

implementation
uses
    data,
    globs,
    files,
    actions;

{$R *.lfm}

{ Tinstfrm }

procedure Tinstfrm.closebtnClick(Sender: TObject);
begin
     inst.close;
     close;
end;

procedure Tinstfrm.closeitmClick(Sender: TObject);
begin
     inst.close;
     close;
end;

procedure Tinstfrm.FormShow(Sender: TObject);
var
 sql : string;

begin
     inst.Active:= true;
end;

procedure Tinstfrm.instmnuPopup(Sender: TObject);
begin
     if optot > 0 then
     begin
     instundo.Enabled:= true;
     instunall.Enabled:= true;
     end
     else
     begin
     instundo.Enabled:= false;
     instunall.Enabled:= false;
     end;

end;

procedure Tinstfrm.instshowfilesClick(Sender: TObject);
begin
     filefrm.show;
end;

procedure Tinstfrm.instunallClick(Sender: TObject);
begin
     undoall;
end;

procedure Tinstfrm.instundoClick(Sender: TObject);
begin
     undolast;
end;

procedure Tinstfrm.instuninstClick(Sender: TObject);
var
   rc : longint;

begin
     oprec:= titemrec.Create;
     oprec.name:= insrc.DataSet.FieldValues['name'];
     oprec.ver:= insrc.DataSet.FieldValues['version'];
     oprec.op:= 'Remove';
     oprec.kind:= 1;

     try
     oplst.AddObject(oprec.name,oprec);
     inc(optot);

     except
     showmessage('Duplicate package ignored');
     exit;
     end;

     instundo.Enabled:= true;
     instunall.Enabled:= true;

     rc:= actfrm.actgrid.RowCount;
     actfrm.actgrid.RowCount:= rc+1;

     actfrm.actgrid.Cells[0,rc]:= oprec.name;
     actfrm.actgrid.Cells[1,rc]:= 'Remove';

     if not actfrm.Showing then
     actfrm.Show;

     applybtn.Enabled:= true;
     instundo.Enabled:= true;
     instunall.Enabled:= true;
end;

procedure Tinstfrm.applybtnClick(Sender: TObject);
begin
     if optot < 1 then
     exit;

     applybtn.Enabled:= false;
end;

end.

