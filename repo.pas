unit repo;

{$mode ObjFPC}{$H+}

interface

uses
    Classes,
    SysUtils,
    Forms,
    Controls,
    Graphics,
    Dialogs,
    DBCtrls,
    ExtCtrls,
    DBGrids,
    StdCtrls,
    BCButton;

type

 { Trepofrm }

    Trepofrm = class(TForm)
     addbtn: TBCButton;
     statbox: TCheckBox;
     removebtn: TBCButton;
     changebtn: TBCButton;
     closebtn: TBCButton;
     nametxt: TDBEdit;
     basetxt: TDBEdit;
     cfgtxt: TDBEdit;
     metatxt: TDBEdit;
     keytxt: TDBEdit;
     repotxt: TDBEdit;
     pkgtxt: TDBEdit;
     repogrid: TDBGrid;
     infomemo: TDBMemo;
     Label1: TLabel;
     Label11: TLabel;
     Label2: TLabel;
     Label5: TLabel;
     Label6: TLabel;
     Label7: TLabel;
     Label8: TLabel;
     Label9: TLabel;
     Panel1: TPanel;
     procedure addbtnClick(Sender: TObject);
     procedure changebtnClick(Sender: TObject);
     procedure closebtnClick(Sender: TObject);
     procedure nametxtChange(Sender: TObject);
     procedure FormShow(Sender: TObject);
     procedure removebtnClick(Sender: TObject);
     procedure statboxMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X,Y: Integer);
    private

    public

    end;

var
 repofrm: Trepofrm;

implementation
uses
    data,
    binexec,
    globs,
    mlstr,
    addrepo;

{$R *.lfm}

{ Trepofrm }

procedure Trepofrm.addbtnClick(Sender: TObject);
begin
     addrepofrm.show;
end;

procedure Trepofrm.changebtnClick(Sender: TObject);
var
   repoid : string;

begin
     repoid:= dm.reposRepoID.Text;
     ok:= rootexec('/bin/dnf5 config-manager setopt'+ repoid + '.enabled = 0',admin);

     if ok then
     ShowMessage('Status Updated.')
     else
     ShowMessage('Could not update stutus. Error '+i2str(errnum)+' '+errstr);

end;

procedure Trepofrm.closebtnClick(Sender: TObject);
begin
     close;
end;

procedure Trepofrm.nametxtChange(Sender: TObject);
begin
     if dm.reposstatus.Text = 'Enabled' then
     statbox.Checked:= true
     else
     statbox.Checked:= false;
end;

procedure Trepofrm.FormShow(Sender: TObject);
begin
     changebtn.Visible:= false;
end;

procedure Trepofrm.removebtnClick(Sender: TObject);
var
   repoid : string;

begin
     repoid:= dm.reposRepoID.Text;

     if questiondlg('WARNING!','Permanaently remove the repository ' + repoid + '?',mtwarning,[mbyes,mbno],0) = mryes then
     rootexec('/usr/bin/rm /etc/yum.repos.d/'+repoid + '.repo',admin);

end;

procedure Trepofrm.statboxMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X,Y: Integer);
begin
     changebtn.Visible:= true;
end;

end.

