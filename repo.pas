{Copyright 2025 Jim Miller

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.}

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
     repochanged : boolean;

    end;

var
 repofrm: Trepofrm;

implementation
uses
    data,
    binexec,
    globs,
    mlstr,
    notes,
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

     if statbox.Checked then
     begin
     repoid:= repoid+'.enabled=1';
     ok:= rootexec(dnf+' config-manager setopt '+ repoid,admin);
     end
     else
     begin
     repoid:= repoid+'.enabled=0';
     ok:= rootexec(dnf+' config-manager setopt '+ repoid,admin);
     end;

     if ok then
     ShowMessage('Status Updated.')
     else
     ShowMessage('Could not update stutus. Error '+i2str(errnum)+' '+errstr);

     repochanged:= true;
end;

procedure Trepofrm.closebtnClick(Sender: TObject);
begin
     if repochanged then
     begin
     notefrm.info('Updating repositories');
     import_repos;
     notefrm.Close;
     end;

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
     repochanged:= false;
end;

procedure Trepofrm.removebtnClick(Sender: TObject);
var
   repoid : string;

begin
     repoid:= dm.reposRepoID.Text;

     if questiondlg('WARNING!','Permanaently remove the repository ' + repoid + '?',mtwarning,[mbyes,mbno],0) = mryes then
     begin
     rootexec(cmd+'rm /etc/yum.repos.d/'+repoid + '.repo',admin);
     repochanged:= true;
     end;

end;

procedure Trepofrm.statboxMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X,Y: Integer);
begin
     changebtn.Visible:= true;
end;

end.

