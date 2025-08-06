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

unit config;

{$mode ObjFPC}{$H+}

interface

uses
 Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
 BCButton;

type

 { Tcfgfrm }

 Tcfgfrm = class(TForm)
  savebtn: TBCButton;
  cancelbtn: TBCButton;
  updatechk: TCheckBox;
  frmbgbtn: TColorButton;
  frmfgbtn: TColorButton;
  txtbgbtn: TColorButton;
  txtfgbtn: TColorButton;
  dscbgbtn: TColorButton;
  dscfgbtn: TColorButton;
  hdgbgbtn: TColorButton;
  hdgfgbtn: TColorButton;
  Label1: TLabel;
  Label2: TLabel;
  Label3: TLabel;
  Label4: TLabel;
  Label5: TLabel;
  Label6: TLabel;
  Label7: TLabel;
  Label8: TLabel;
  Label9: TLabel;
  Panel1: TPanel;
  procedure cancelbtnClick(Sender: TObject);
  procedure savebtnClick(Sender: TObject);
 private

 public
  procedure Change_Colors;

 end;

var
 cfgfrm: Tcfgfrm;

implementation
uses
    globs,
    main,
    updates,
    search,
    installed,
    files,
    actions,
    repo,
    addrepo;

{$R *.lfm}

{ Tcfgfrm }

procedure Tcfgfrm.savebtnClick(Sender: TObject);
begin
     crec.dscbg:= dscbgbtn.ButtonColor;
     crec.dscfg:= dscfgbtn.ButtonColor;
     crec.frmbg:= frmbgbtn.ButtonColor;
     crec.frmfc:= frmfgbtn.ButtonColor;
     crec.hdgbg:= hdgbgbtn.ButtonColor;
     crec.hdgfc:= hdgfgbtn.ButtonColor;
     crec.grdbg:= txtbgbtn.ButtonColor;
     crec.grdfc:= txtfgbtn.ButtonColor;
     crec.offline:= updatechk.Checked;

     savecfg;
     change_colors;
     close;
end;

procedure Tcfgfrm.change_colors;
begin
     cfgfrm.color:= crec.frmbg;
     cfgfrm.Font.Color:= crec.frmfc;

     mainfrm.Color:= crec.frmbg;
     mainfrm.Font.Color:= crec.frmfc;
     mainfrm.grpgrid.Color:= crec.grdbg;
     mainfrm.grpgrid.Font.Color:= crec.grdfc;
     mainfrm.grpgrid.FixedColor:= crec.hdgbg;
     mainfrm.grpgrid.TitleFont.Color:= crec.hdgfc;
     mainfrm.pkggrid.Color:= crec.grdbg;
     mainfrm.pkggrid.Font.Color:= crec.grdfc;
     mainfrm.pkggrid.FixedColor:= crec.hdgbg;
     mainfrm.pkggrid.TitleFont.Color:= crec.hdgfc;
     mainfrm.desc.Color:= crec.dscbg;
     mainfrm.Font.Color:= crec.dscfg;

     filefrm.Color:= crec.frmbg;
     filefrm.Font.Color:= crec.frmfc;
     filefrm.filememo.Color:= crec.grdbg;
     filefrm.filememo.Font.Color:= crec.grdfc;

     instfrm.Color:= crec.frmbg;
     instfrm.Font.Color:= crec.frmfc;
     instfrm.ingrid.Color:= crec.grdbg;
     instfrm.ingrid.Font.Color:= crec.grdfc;
     instfrm.ingrid.FixedColor:= crec.hdgbg;
     instfrm.ingrid.TitleFont.Color:= crec.hdgfc;
     instfrm.desc.Color:= crec.dscbg;
     instfrm.desc.Font.Color:= crec.dscfg;

     upfrm.Color:= crec.frmbg;
     upfrm.Font.Color:= crec.frmfc;
     upfrm.upgrid.Color:= crec.grdbg;
     upfrm.upgrid.Font.Color:= crec.grdfc;
     upfrm.upgrid.FixedColor:= crec.hdgbg;
     upfrm.upgrid.TitleFont.Color:= crec.hdgfc;

     srchfrm.Color:= crec.frmbg;
     srchfrm.Font.Color:= crec.frmfc;
     srchfrm.srchgrid.Color:= crec.grdbg;
     srchfrm.srchgrid.Font.Color:= crec.grdfc;
     srchfrm.srchgrid.FixedColor:= crec.hdgbg;
     srchfrm.srchgrid.TitleFont.Color:= crec.hdgfc;
     srchfrm.desc.Color:= crec.dscbg;
     srchfrm.desc.Font.Color:= crec.dscfg;

     repofrm.Color:= crec.frmbg;
     repofrm.Font.Color:= crec.frmfc;
     repofrm.repogrid.Color:= crec.grdbg;
     repofrm.repogrid.Font.Color:= crec.grdfc;
     repofrm.repogrid.FixedColor:= crec.hdgbg;
     repofrm.repogrid.TitleFont.Color:= crec.hdgfc;
     repofrm.infomemo.Color:= crec.dscbg;
     repofrm.infomemo.Font.Color:= crec.dscfg;

     actfrm.Color:= crec.frmbg;
     actfrm.Font.Color:= crec.frmfc;
     actfrm.actgrid.Color:= crec.grdbg;
     actfrm.actgrid.Font.Color:= crec.grdfc;
     actfrm.actgrid.FixedColor:= crec.hdgbg;
     actfrm.actgrid.TitleFont.Color:= crec.hdgfc;

     addrepofrm.Color:= crec.frmbg;
     addrepofrm.Font.Color:= crec.frmfc;

end;

procedure Tcfgfrm.cancelbtnClick(Sender: TObject);
begin
     close;
end;

end.

