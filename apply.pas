unit apply;

{$mode ObjFPC}{$H+}

interface

uses
 Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
 BCButton;

type

    { Tapplyfrm }

    Tapplyfrm = class(TForm)
     applybtn: TBCButton;
     closebtn: TBCButton;
     cancelbtn: TBCButton;
     info: TMemo;
     Panel1: TPanel;
     procedure applybtnClick(Sender: TObject);
     procedure closebtnClick(Sender: TObject);
     procedure cancelbtnClick(Sender: TObject);
     procedure FormShow(Sender: TObject);
    private

    public

    end;

var
 applyfrm: Tapplyfrm;
 applyok : boolean;

implementation
uses
    data,
    globs,
    notes,
    binexec;

{$R *.lfm}

{ Tapplyfrm }

procedure Tapplyfrm.FormShow(Sender: TObject);
begin

     applyok:= false;

     if optot = 0 then
     begin
     applybtn.Enabled:= false;
     cancelbtn.Enabled:= false;
     end
     else
     begin
     applybtn.Enabled:= true;
     cancelbtn.Enabled:= true;
     end;

     info.Clear;
     info.Lines.Add('The following changes will be made :');
     info.Lines.Add('');

     if pkgaddstr <> '' then
     begin
     info.Lines.Add('Installing packages:');
     info.Lines.Add(pkgaddstr);
     end;

     if pkgrinstr <> '' then
     begin
     info.Lines.Add('Re-Installing packages:');
     info.Lines.Add(pkgrinstr);
     end;

     if pkgdelstr <> '' then
     begin
     info.Lines.Add('Removing packages:');
     info.Lines.Add(pkgdelstr);
     end;

     if grpaddstr <> '' then
     begin
     info.Lines.Add('Installing group(s):');
     info.Lines.Add(grpaddstr);
     end;

     if grpdelstr <> '' then
     begin
     info.Lines.Add('Removing group(s)::');
     info.Lines.Add(grpdelstr);
     end;

end;

{Apply all user operations}
procedure Tapplyfrm.applybtnClick(Sender: TObject);
begin
     notefrm.info(misc);

     if grpaddstr <> '' then
     begin
     ok:= rootexec('/usr/bin/dnf5 group install -y '+grpaddstr,admin);
     info.Append(outp);
     application.ProcessMessages;
     end;

     if grpdelstr <> '' then
     begin
     ok:= rootexec('/usr/bin/dnf5 group remove -y '+grpaddstr,admin);
     info.Append(outp);
     application.ProcessMessages;
     end;

     if pkgaddstr <> '' then
     begin
     ok:= rootexec('/usr/bin/dnf5 install -y '+pkgaddstr,admin);
     info.Append(outp);
     application.ProcessMessages;
     end;

     if pkgdelstr <> '' then
     begin
     ok:= rootexec('/usr/bin/dnf5 remove -y '+pkgdelstr,admin);
     info.Append(outp);
     application.ProcessMessages;
     end;

     if pkgrinstr <> '' then
     begin
     ok:= rootexec('/usr/bin/dnf5 reinstall -y '+pkgrinstr,admin);
     info.Append(outp);
     application.ProcessMessages;
     end;

     info.Lines.SaveToFile(homedir+'apply.log');

     for i:= 0 to optot - 1 do
     begin
     oprec:= titemrec(oplst.Objects[i]);

     if (oprec.kind = 1) and (oprec.op = 'Install') then
     begin
     markinstalled;
     end
     else
     if (oprec.kind = 1) and (oprec.op = 'Remove') then
     begin
     markremoved;
     end
     else
     if (oprec.kind = 1) and (oprec.op = 'Re-Install') then
     begin
     dm.pkg.RecNo:= oprec.recno;
     dm.pkg.edit;

     dm.pkgInstalled.AsBoolean:= true;
     dm.pkg.Post;
     end;

     end;

     application.ProcessMessages;
     undoall;
     applyok:= true;
     notefrm.Close;
     applybtn.Enabled:= false;;

end;

procedure Tapplyfrm.closebtnClick(Sender: TObject);
begin
     close;
end;

procedure Tapplyfrm.cancelbtnClick(Sender: TObject);
begin
     if messagedlg('Warning','This will abort ALL actions! Continue?',mtwarning,[mbyes,mbno],0) = mryes then
     begin
     undoall;
     applyok:= false;
     close;
     end;

end;

end.

