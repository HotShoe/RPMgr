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

unit notes;
{$mode ObjFPC}{$H+}
interface

uses
 Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, BCButton;

const
     firstime = 'RPManager needs to build its database when first run. This process may take up to 2 minutes to complete depending upon your computer speed. This process only needs to be done the first time RPManager is run. This dialog will close when the process is complete.';
     misc = 'The requested action is being completed. This dialog will close when it is completed.';
     upgrade = 'The system packages are being upgraded. This dialog will close when the process is completed.';
     install = 'The item(s) requested and their dependancies are being installed. This dialog will close when the operation is completed.';
     remove = 'The package(s) marked for removal are being removed from the system. This dialog will close when the operation is completed.';
     lists = 'RPManager is gathering package and group lists. Please wait a moment. This dialog will close when the operation is completed.';
     error ='RPManger has expeienced a GTU (Going Tits Up) and will now close. The specific error will be displayed in the following information dialog. Please report this to : jem@mlsoft.org';
     upgrades = 'Checking for upgraded packages. This will take a few moments.';

type
 { Tnotefrm }

 Tnotefrm = class(TForm)
  okbtn: TBCButton;
  msg: TLabel;
  procedure okbtnClick(Sender: TObject);
 private

 public
  procedure error(mesg : string);
  procedure info(mesg : string);
  procedure normal(mesg : string);
 end;

var
 notefrm: Tnotefrm;

implementation

{$R *.lfm}

procedure Tnotefrm.okbtnClick(Sender: TObject);
begin
     close;
end;

procedure Tnotefrm.error(mesg : string);
begin
     if notefrm.Showing then
     notefrm.Close;

     application.ProcessMessages;
     msg.Caption:= mesg;
     msg.Color:= clred;
     okbtn.Visible:= true;

     showmodal;

     sleep(300);
     application.ProcessMessages;

end;

procedure Tnotefrm.info(mesg : string);
begin
     if notefrm.Showing then
     notefrm.Close;

     msg.Caption:= mesg;
     msg.Color:= clnavy;
     okbtn.Visible:= false;

     show;
     application.ProcessMessages;
     sleep(300);
     application.ProcessMessages;
end;

procedure Tnotefrm.normal(mesg : string);
begin
     if notefrm.Showing then
     notefrm.Close;

     application.ProcessMessages;
     msg.Caption:= mesg;
     msg.Color:= clnavy;
     okbtn.Visible:= true;

     showmodal;

     sleep(300);
     application.ProcessMessages;
end;

end.

