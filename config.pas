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
    files;

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

end;

procedure Tcfgfrm.cancelbtnClick(Sender: TObject);
begin
     close;
end;

end.

