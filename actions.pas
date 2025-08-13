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

unit actions;

{$mode ObjFPC}{$H+}

interface

uses
 Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
 Grids, Menus, LazHelpCHM, BCButton, Types;

type

 { Tactfrm }

 Tactfrm = class(TForm)
  actmnu: TPopupMenu;
  applybtn: TBCButton;
  closebtn: TBCButton;
  mnuall: TMenuItem;
  mnuapply: TMenuItem;
  mnuundo: TMenuItem;
  Panel1: TPanel;
  actgrid: TStringGrid;
  PopupMenu1: TPopupMenu;
  procedure actmnuPopup(Sender: TObject);
  procedure applybtnClick(Sender: TObject);
  procedure closebtnClick(Sender: TObject);
  procedure FormCreate(Sender: TObject);
  procedure mnuallClick(Sender: TObject);
  procedure mnuapplyClick(Sender: TObject);
  procedure mnuundoClick(Sender: TObject);
 private

 public

 end;

var
 actfrm: Tactfrm;

implementation
uses
    main,
    data,
    globs;
{$R *.lfm}

{ Tactfrm }

procedure Tactfrm.applybtnClick(Sender: TObject);
begin
     applyall;
     actgrid.Clean([gznormal]);
     closebtnclick(nil);
end;

procedure Tactfrm.actmnuPopup(Sender: TObject);
begin
     if oplst.Count > 0 then
     begin
     mnuundo.Enabled:= true;
     mnuall.Enabled:= true;
     mnuapply.Enabled:= true;
     end
     else
     begin
     mnuundo.Enabled:= false;
     mnuall.Enabled:= false;
     mnuapply.Enabled:= false;
     end;
end;

procedure Tactfrm.closebtnClick(Sender: TObject);
begin
     mainfrm.Width:= 1572;
     mainfrm.Left:= 220;
     application.ProcessMessages;
     sleep(100);
     application.ProcessMessages;
     close;
end;

procedure Tactfrm.FormCreate(Sender: TObject);
begin
     actfrm.left:= 1;
     actfrm.top:= 40;
end;

procedure Tactfrm.mnuallClick(Sender: TObject);
begin
     undoall;
     actgrid.Clean([gznormal]);
     actgrid.RowCount:= 1;

     mainfrm.Width:= 1572;
     mainfrm.Left:= 220;
     application.ProcessMessages;
     sleep(100);
     application.ProcessMessages;
     close;
end;

procedure Tactfrm.mnuapplyClick(Sender: TObject);
begin
     applyall;
     actgrid.Clean([gznormal]);
     actgrid.RowCount:= 1;

     mainfrm.Width:= 1572;
     mainfrm.Left:= 220;
     application.ProcessMessages;
     sleep(100);
     application.ProcessMessages;
     close;
end;

procedure Tactfrm.mnuundoClick(Sender: TObject);
var
   tc,
   rc : longint;

begin
     tc:= actgrid.RowCount;
     rc:= actgrid.row;

     actgrid.DeleteRow(rc);
     dec(tc);
     actgrid.RowCount:= tc;

     oplst.Objects[rc-1].free;
     oplst.Objects[rc-1]:= nil;
     oplst.Delete(rc-1);
     application.ProcessMessages;
     sleep(100);
     application.ProcessMessages;

end;

end.

