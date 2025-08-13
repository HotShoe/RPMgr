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

Unit config;

{$mode ObjFPC}{$H+}

Interface

Uses
    Classes,
    SysUtils,
    Forms,
    Controls,
    Graphics,
    Dialogs,
    StdCtrls,
    ExtCtrls,
    BCButton;

Type

    { Tcfgfrm }

    Tcfgfrm = Class(TForm)
      dpitxt :    TEdit;
      Label10 :   TLabel;
      savebtn :   TBCButton;
      cancelbtn : TBCButton;
      updatechk : TCheckBox;
      frmbgbtn :  TColorButton;
      frmfgbtn :  TColorButton;
      txtbgbtn :  TColorButton;
      txtfgbtn :  TColorButton;
      dscbgbtn :  TColorButton;
      dscfgbtn :  TColorButton;
      hdgbgbtn :  TColorButton;
      hdgfgbtn :  TColorButton;
      Label1 :    TLabel;
      Label2 :    TLabel;
      Label3 :    TLabel;
      Label4 :    TLabel;
      Label5 :    TLabel;
      Label6 :    TLabel;
      Label7 :    TLabel;
      Label8 :    TLabel;
      Label9 :    TLabel;
      Panel1 :    TPanel;
      Procedure cancelbtnClick(Sender : TObject);
      Procedure savebtnClick(Sender : TObject);
    private

    public
      Procedure Change_Colors;

    End;

Var
    cfgfrm : Tcfgfrm;

Implementation

Uses
    globs,
    mlstr,
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

Procedure Tcfgfrm.savebtnClick(Sender : TObject);
Begin
    crec.dscbg := dscbgbtn.ButtonColor;
    crec.dscfg := dscfgbtn.ButtonColor;
    crec.frmbg := frmbgbtn.ButtonColor;
    crec.frmfc := frmfgbtn.ButtonColor;
    crec.hdgbg := hdgbgbtn.ButtonColor;
    crec.hdgfc := hdgfgbtn.ButtonColor;
    crec.grdbg := txtbgbtn.ButtonColor;
    crec.grdfc := txtfgbtn.ButtonColor;
    crec.offline := updatechk.Checked;
    crec.dpi:= s2int(dpitxt.Text);

    savecfg;
    Change_Colors;
    Close;
End;

Procedure Tcfgfrm.Change_Colors;
Begin
    cfgfrm.color := crec.frmbg;
    cfgfrm.Font.color := crec.frmfc;

    mainfrm.color := crec.frmbg;
    mainfrm.Font.color := crec.frmfc;
    mainfrm.grpgrid.color := crec.grdbg;
    mainfrm.grpgrid.Font.color := crec.grdfc;
    mainfrm.grpgrid.FixedColor := crec.hdgbg;
    mainfrm.grpgrid.TitleFont.color := crec.hdgfc;
    mainfrm.pkggrid.color := crec.grdbg;
    mainfrm.pkggrid.Font.color := crec.grdfc;
    mainfrm.pkggrid.FixedColor := crec.hdgbg;
    mainfrm.pkggrid.TitleFont.color := crec.hdgfc;
    mainfrm.desc.color := crec.dscbg;
    mainfrm.Font.color := crec.dscfg;
    mainfrm.PixelsPerInch:= crec.dpi;

    filefrm.color := crec.frmbg;
    filefrm.Font.color := crec.frmfc;
    filefrm.filememo.color := crec.grdbg;
    filefrm.filememo.Font.color := crec.grdfc;
    filefrm.PixelsPerInch:= crec.dpi;

    instfrm.color := crec.frmbg;
    instfrm.Font.color := crec.frmfc;
    instfrm.ingrid.color := crec.grdbg;
    instfrm.ingrid.Font.color := crec.grdfc;
    instfrm.ingrid.FixedColor := crec.hdgbg;
    instfrm.ingrid.TitleFont.color := crec.hdgfc;
    instfrm.desc.color := crec.dscbg;
    instfrm.desc.Font.color := crec.dscfg;
    instfrm.PixelsPerInch:= crec.dpi;

    upfrm.color := crec.frmbg;
    upfrm.Font.color := crec.frmfc;
    upfrm.upgrid.color := crec.grdbg;
    upfrm.upgrid.Font.color := crec.grdfc;
    upfrm.upgrid.FixedColor := crec.hdgbg;
    upfrm.upgrid.TitleFont.color := crec.hdgfc;
    upfrm.PixelsPerInch:= crec.dpi;

    srchfrm.color := crec.frmbg;
    srchfrm.Font.color := crec.frmfc;
    srchfrm.srchgrid.color := crec.grdbg;
    srchfrm.srchgrid.Font.color := crec.grdfc;
    srchfrm.srchgrid.FixedColor := crec.hdgbg;
    srchfrm.srchgrid.TitleFont.color := crec.hdgfc;
    srchfrm.desc.color := crec.dscbg;
    srchfrm.desc.Font.color := crec.dscfg;
    srchfrm.PixelsPerInch:= crec.dpi;

    repofrm.color := crec.frmbg;
    repofrm.Font.color := crec.frmfc;
    repofrm.repogrid.color := crec.grdbg;
    repofrm.repogrid.Font.color := crec.grdfc;
    repofrm.repogrid.FixedColor := crec.hdgbg;
    repofrm.repogrid.TitleFont.color := crec.hdgfc;
    repofrm.infomemo.color := crec.dscbg;
    repofrm.infomemo.Font.color := crec.dscfg;
    repofrm.PixelsPerInch:= crec.dpi;

    actfrm.color := crec.frmbg;
    actfrm.Font.color := crec.frmfc;
    actfrm.actgrid.color := crec.grdbg;
    actfrm.actgrid.Font.color := crec.grdfc;
    actfrm.actgrid.FixedColor := crec.hdgbg;
    actfrm.actgrid.TitleFont.color := crec.hdgfc;
    actfrm.PixelsPerInch:= crec.dpi;

    addrepofrm.color := crec.frmbg;
    addrepofrm.Font.color := crec.frmfc;
    addrepofrm.PixelsPerInch:= crec.dpi;

End;

Procedure Tcfgfrm.cancelbtnClick(Sender : TObject);
Begin
    Close;
End;

End.
