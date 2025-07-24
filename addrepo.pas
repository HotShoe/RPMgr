unit addrepo;

{$mode ObjFPC}{$H+}

interface

uses
 Classes, SysUtils, Forms, Controls, Graphics, Dialogs,StdCtrls,BCButton;

type

 { Taddrepofrm }

 Taddrepofrm = class(TForm)
  addbtn: TBCButton;
  cancelbtn: TBCButton;
  enbox: TCheckBox;
  repotxt: TEdit;
  basetxt: TEdit;
  Label1: TLabel;
  Label2: TLabel;
  procedure addbtnClick(Sender: TObject);
  procedure basetxtExit(Sender: TObject);
  procedure cancelbtnClick(Sender: TObject);
 private

 public

 end;

var
 addrepofrm: Taddrepofrm;

implementation
uses
    binexec,
    globs,
    mlstr;

{$R *.lfm}

{ Taddrepofrm }

procedure Taddrepofrm.addbtnClick(Sender: TObject);
var
   enb: string;

begin
     if enbox.Checked then
     enb:= '1'
     else
     enb:= '0';

     ok:= rootexec('/usr/bin/dnf5 config-manager addrepo --set=baseurl='+
               basetxt.Text + ' --set=id=' + repotxt.Text +
               ' --set=enabled=' + enb,admin);

     if ok then
     begin
     showmessage('Repo has been added');
     close;
     end
     else
     showmessage('Could not add repo. Error '+i2str(errnum)+' '+errstr);

end;

procedure Taddrepofrm.basetxtExit(Sender: TObject);
begin
     repotxt.Text:= basetxt.Text;
end;

procedure Taddrepofrm.cancelbtnClick(Sender: TObject);
begin
     close;
end;

end.

