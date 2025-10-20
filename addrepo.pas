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

unit addrepo;

{$mode ObjFPC}{$H+}

interface

uses
 Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, LazHelpCHM,
 BCButton;

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
    mlstr,
    repo;

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

     ok:= exec('',dnf,'config-manager addrepo --set=baseurl='+
               basetxt.Text + ' --set=id=' + repotxt.Text +
               ' --set=enabled=' + enb, 1000, admin);

     if ok then
     begin
     showmessage('Repo has been added');
     repofrm.repochanged:= true;
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

