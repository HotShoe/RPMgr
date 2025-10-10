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

Unit main;

{$mode objfpc}{$H+}

Interface

Uses
    Classes,
    SysUtils,
    unix,
    fileutil,
    LazHelpCHM,
    Forms,
    Controls,
    Graphics,
    DB,
    Dialogs,
    StdCtrls,
    Buttons,
    Menus,
    DBCtrls,
    DBGrids,
    ExtCtrls,
    BCButton,
    Grids,
    LazHelpHTML,
    Types;

Type

    { Tmainfrm }

    Tmainfrm = Class(TForm)
      distbtn: TBCButton;
      closebtn: TBCButton;
      applybtn: TBCButton;
      mnufixdb : TMenuItem;
      mnutextintegrity : TMenuItem;
      mnufixbroken : TMenuItem;
      Separator5 : TMenuItem;
      rootlbl: TLabel;
      mnuundo: TMenuItem;
      pkggrid: TDBGrid;
      integritybtn: TBCButton;
      desc: TDBMemo;
      grpundo: TMenuItem;
      pkgreinst: TMenuItem;
      pkgundoall: TMenuItem;
      mnucfg: TMenuItem;
      mnuupdates: TMenuItem;
      pkginstall: TMenuItem;
      pkgcnt: TLabel;
      grpgrid: TDBGrid;
      instbtn: TBCButton;
      Label3: TLabel;
      instlbl: TLabel;
      mainmnu: TMainMenu;
      MenuItem1: TMenuItem;
      pkglist: TMenuItem;
      Separator4: TMenuItem;
      pkgapply: TMenuItem;
      pkgundo: TMenuItem;
      pkgremove: TMenuItem;
      MenuItem2: TMenuItem;
      MenuItem3: TMenuItem;
      grpmnu: TPopupMenu;
      grpapply: TMenuItem;
      grpinstall: TMenuItem;
      grpremove: TMenuItem;
      pkgquit: TMenuItem;
      grpquit: TMenuItem;
      Separator3: TMenuItem;
      Separator2: TMenuItem;
      mnuabout: TMenuItem;
      mnuapply: TMenuItem;
      mnudocs: TMenuItem;
      Mnuexit: TMenuItem;
      mnusearch: TMenuItem;
      mnuundoall: TMenuItem;
      packmnu: TPopupMenu;
      pkgpan: TPanel;
      provbtn: TBCButton;
      repbtn: TBCButton;
      updatebtn: TBCButton;
      fixbtn: TBCButton;
      Separator1: TMenuItem;
      Splitter1: TSplitter;
      srchtxt: TEdit;
      Label1: TLabel;
      Label2: TLabel;
      srchbtn: TSpeedButton;
      Procedure distbtnClick(Sender: TObject);
      Procedure closebtnClick(Sender: TObject);
      Procedure applybtnClick(Sender: TObject);
      Procedure descChange(Sender: TObject);
      procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
      Procedure grpapplyClick(Sender: TObject);
      Procedure grpgridMouseDown(Sender: TObject; Button: TMouseButton;
        Shift: TShiftState; X, Y: Integer);
      Procedure grpinstallClick(Sender: TObject);
      Procedure grpmnuPopup(Sender: TObject);
      Procedure grpquitClick(Sender: TObject);
      Procedure grpremoveClick(Sender: TObject);
      Procedure integritybtnClick(Sender: TObject);
      procedure mnufixbrokenClick(Sender : TObject);
      procedure mnutextintegrityClick(Sender : TObject);
      procedure mnufixdbClick(Sender : TObject);
      Procedure mnucfgClick(Sender: TObject);
      Procedure mnuundoClick(Sender: TObject);
      Procedure mnuupdatesClick(Sender: TObject);
      Procedure mnuaboutClick(Sender: TObject);
      Procedure mnuapplyClick(Sender: TObject);
      Procedure mnudocsClick(Sender: TObject);
      Procedure mnusearchClick(Sender: TObject);
      Procedure mnuundoallClick(Sender: TObject);
      Procedure packmnuPopup(Sender: TObject);
      Procedure pkgapplyClick(Sender: TObject);
      Procedure pkginstallClick(Sender: TObject);
      Procedure pkglistClick(Sender: TObject);
      Procedure pkggridClick(Sender: TObject);
      Procedure pkgquitClick(Sender: TObject);
      Procedure pkgreinstClick(Sender: TObject);
      Procedure pkgremoveClick(Sender: TObject);
      Procedure pkgundoallClick(Sender: TObject);
      Procedure pkgundoClick(Sender: TObject);
      Procedure srchbtnClick(Sender: TObject);
      Procedure srchtxtKeyPress(Sender: TObject; Var Key: Char);
      Procedure updatebtnClick(Sender: TObject);
      Procedure fixbtnClick(Sender: TObject);
      Procedure FormCreate(Sender: TObject);
      Procedure FormShow(Sender: TObject);
      Procedure grpgridClick(Sender: TObject);
      Procedure instbtnClick(Sender: TObject);
      Procedure MnuexitClick(Sender: TObject);
      Procedure provbtnClick(Sender: TObject);
      Procedure repbtnClick(Sender: TObject);
    private

    public
      Procedure showinstalled;
      //procedure fillpkg;
    End;

Var
    mainfrm: Tmainfrm;

Implementation

Uses
    Data,
    globs,
    mlstr,
    about,
    notes,
    updates,
    installed,
    search,
    config,
    apply,
    files,
    actions,
    repo,
    binexec;

    {$R *.lfm}

    { Tmainfrm }

Procedure Tmainfrm.FormCreate(Sender: TObject);
Begin
    grplst:= TStringList.Create;
    pkglst:= TStringList.Create;
    instlst:= TStringList.Create;
    leaflst:= TStringList.Create;
    uplst:= TStringList.Create;
    oplst:= TStringList.Create;

    oplst.Sorted:= True;
    oplst.Duplicates:= duperror;

    lvtot:= 0;
    grptot:= 0;
    pkgtot:= 0;
    insttot:= 0;
    uptot:= 0;
    optot:= 0;
    outp:= '';

    loginfrm:= tloginfrm.Create(nil);

End;

Procedure Tmainfrm.updatebtnClick(Sender: TObject);
Begin
    upfrm.Show;

    updatebtn.StateNormal.Background.Color:= clnavy;
End;

Procedure Tmainfrm.closebtnClick(Sender: TObject);
Begin
    halt(0);
End;

{Do a distribution upgrade to a new version of Fedora}
Procedure Tmainfrm.distbtnClick(Sender: TObject);
Var
    t: textfile;

Begin
    notefrm.info('Upgrading Fedora. This process will happen in 3 steps: Updating your current system, Upgrading all packages to the newest version of Fedora, and rebooting your system. This dialog will close and your computer will rebot when the process is complete.');

    ok:= exec(dnf+' --refresh upgrade', [], admin);
    ok:= exec(dnf+' system-upgrade download --allowerasing', [], admin);

    assignfile(t, mydir + 'newsys');
    rewrite(t);
    closefile(t);

    ok:= exec(dnf+ 'system-upgrade reboot',[], admin);

End;

Procedure Tmainfrm.applybtnClick(Sender: TObject);
Begin
    applyall;
End;

Procedure Tmainfrm.descChange(Sender: TObject);
Begin

End;

procedure Tmainfrm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
     if dm.helpcon <> nil then
    dm.helpcon.Destroy;
end;

Procedure Tmainfrm.grpapplyClick(Sender: TObject);
Begin
    applyall;
End;

Procedure Tmainfrm.grpgridMouseDown(Sender: TObject; Button: TMouseButton;
    Shift: TShiftState; X, Y: Integer);
Begin
    dm.pkg.First;
End;

{Install a group}
Procedure Tmainfrm.grpinstallClick(Sender: TObject);
Var
    rc: Longint;

Begin
    oprec:= titemrec.Create;
    oprec.kind:= 0;
    oprec.Name:= curgrp;
    oprec.op:= 'Install';
    oprec.ver:= '';

    oplst.AddObject(curgrp, oprec);
    Inc(optot);

    grpmnu.Items[2].Enabled:= True;
    grpmnu.Items[3].Enabled:= True;

    rc:= actfrm.actgrid.RowCount;
    actfrm.actgrid.RowCount:= rc + 1;
    actfrm.actgrid.Cells[0, rc]:= curgrp;
    actfrm.actgrid.Cells[1, rc]:= 'Install';

    actfrm.Top:= mainfrm.Top;
    actfrm.Left:= 1;
    mainfrm.Width:= 1464;
    mainfrm.Left:= 454;
    application.ProcessMessages;
    sleep(100);
    application.ProcessMessages;

    If not actfrm.Showing Then
      actfrm.Show;

End;

Procedure Tmainfrm.grpmnuPopup(Sender: TObject);
Begin
    If dm.grpInstalled.AsBoolean Then
    Begin
      grpinstall.Enabled:= False;
      grpremove.Enabled:= True;
    End
    Else
    Begin
      grpinstall.Enabled:= True;
      grpremove.Enabled:= False;
    End;

    If optot > 0 Then
    Begin
      grpundo.Enabled:= True;
      grpapply.Enabled:= True;
    End
    Else
    Begin
      grpundo.Enabled:= False;
      grpapply.Enabled:= False;
    End;

End;

Procedure Tmainfrm.grpquitClick(Sender: TObject);
Begin
    halt(0);
End;

{Remove a group}
Procedure Tmainfrm.grpremoveClick(Sender: TObject);
Var
    rc: Longint;

Begin
    oprec:= titemrec.Create;
    oprec.kind:= 0;
    oprec.Name:= curgrp;
    oprec.op:= 'Remove';
    oprec.ver:= '';

    oplst.AddObject(curgrp, oprec);
    Inc(optot);

    grpmnu.Items[2].Enabled:= True;
    grpmnu.Items[3].Enabled:= True;

    rc:= actfrm.actgrid.RowCount;
    actfrm.actgrid.RowCount:= rc + 1;
    actfrm.actgrid.Cells[0, rc]:= curgrp;
    actfrm.actgrid.Cells[1, rc]:= 'Remove';

    actfrm.Top:= mainfrm.Top;
    actfrm.Left:= 1;
    mainfrm.Width:= 1464;
    mainfrm.Left:= 454;
    application.ProcessMessages;
    sleep(100);
    application.ProcessMessages;

    If not actfrm.Showing Then
      actfrm.Show;
End;

Procedure Tmainfrm.integritybtnClick(Sender: TObject);
Begin
    notefrm.info('checking package database. this process will take a while. This dialog will close when the process is completed.');

    ok:= exec(dnf+' check check', [], admin);
    notefrm.Close;

    If not ok Then
      ShowMessage(outp)
    Else
      ShowMessage('No problems were found.');

End;

 procedure Tmainfrm.mnufixbrokenClick(Sender : TObject);
begin
     notefrm.info('Repairing databases, standby...');

     exec(dnf+' repair fix', [], admin);
     notefrm.Close;
end;

 procedure Tmainfrm.mnutextintegrityClick(Sender : TObject);
begin
     integritybtnClick(nil);
end;

 procedure Tmainfrm.mnufixdbClick(Sender : TObject);
begin
      notefrm.info('Synchronizing databases with repositories. This will take a few ' +
               	'moments. This dialog will close when the task is completed.');
      import_pkg;
      import_grp;
      import_repos;
      notefrm.Close;
end;

Procedure Tmainfrm.mnucfgClick(Sender: TObject);
Begin
    cfgfrm.Show;
End;

Procedure Tmainfrm.mnuundoClick(Sender: TObject);
Begin
    undolast;
End;

Procedure Tmainfrm.mnuupdatesClick(Sender: TObject);
Begin
    updatebtnclick(nil);
End;

Procedure Tmainfrm.mnuaboutClick(Sender: TObject);
Begin
    aboutfrm.Show;
End;

Procedure Tmainfrm.mnuapplyClick(Sender: TObject);
Begin
    applyall;
End;

Procedure Tmainfrm.mnudocsClick(Sender: TObject);
Begin

End;

Procedure Tmainfrm.mnusearchClick(Sender: TObject);
Begin
    srchbtnclick(nil);
End;

Procedure Tmainfrm.mnuundoallClick(Sender: TObject);
Begin
    undoall;
End;

Procedure Tmainfrm.packmnuPopup(Sender: TObject);
Begin
    If dm.pkgInstalled.AsBoolean Then
    Begin
      pkginstall.Enabled:= False;
      pkgreinst.Enabled:= True;
      pkgremove.Enabled:= True;
      pkglist.Enabled:= True;
    End
    Else
    Begin
      pkginstall.Enabled:= True;
      pkgreinst.Enabled:= False;
      pkgremove.Enabled:= False;
      pkglist.Enabled:= False;
    End;

    If optot > 0 Then
    Begin
      pkgundo.Enabled:= True;
      pkgapply.Enabled:= True;
      pkgundoall.Enabled:= True;
    End
    Else
    Begin
      pkgundo.Enabled:= False;
      pkgapply.Enabled:= False;
      pkgundoall.Enabled:= False;
    End;

End;

Procedure Tmainfrm.pkgapplyClick(Sender: TObject);
Begin
    applyall;
End;

Procedure Tmainfrm.pkginstallClick(Sender: TObject);
Var
    rc: Longint;

Begin
    oprec:= titemrec.Create;
    oprec.kind:= 1;
    oprec.Name:= curpkg;
    oprec.op:= 'Install';
    oprec.ver:= dm.pkgversion.Text;
    oprec.recno:= dm.pkg.RecNo;

    Try
      oplst.AddObject(curpkg, oprec);
      Inc(optot);

    Except
      ShowMessage('Duplicate package ignored');
      exit;
    End;

    packmnu.Items[4].Enabled:= True;

    rc:= actfrm.actgrid.RowCount;
    actfrm.actgrid.RowCount:= rc + 1;
    actfrm.actgrid.Cells[0, rc]:= curpkg;
    actfrm.actgrid.Cells[1, rc]:= 'Install';

    actfrm.Top:= mainfrm.Top;
    actfrm.Left:= 1;
    mainfrm.Width:= 1464;
    mainfrm.Left:= 454;
    application.ProcessMessages;
    sleep(100);
    application.ProcessMessages;

    If not actfrm.Showing Then
      actfrm.Show;

End;

Procedure Tmainfrm.pkglistClick(Sender: TObject);
Begin
    filefrm.Show;
End;

Procedure Tmainfrm.pkggridClick(Sender: TObject);
Begin
    pkgidx:= pkggrid.SelectedIndex;
    curpkg:= dm.pkgName.Text;

End;

Procedure Tmainfrm.pkgquitClick(Sender: TObject);
Begin
    halt(0);
End;

Procedure Tmainfrm.pkgreinstClick(Sender: TObject);
Var
    rc: Longint;

Begin
    oprec:= titemrec.Create;
    oprec.kind:= 1;
    oprec.Name:= curpkg;
    oprec.op:= 'Re-Install';
    oprec.ver:= dm.pkgversion.Text;
    oprec.recno:= dm.pkg.RecNo;

    Try
      oplst.AddObject(curpkg, oprec);
      Inc(optot);

    Except
      ShowMessage('Duplicate package ignored');
      exit;
    End;

    packmnu.Items[4].Enabled:= True;

    rc:= actfrm.actgrid.RowCount;
    actfrm.actgrid.RowCount:= rc + 1;
    actfrm.actgrid.Cells[0, rc]:= oprec.Name;
    actfrm.actgrid.Cells[1, rc]:= 'Re-Install';

    actfrm.Top:= mainfrm.Top;
    actfrm.Left:= 1;
    mainfrm.Width:= 1464;
    mainfrm.Left:= 454;
    application.ProcessMessages;
    sleep(100);
    application.ProcessMessages;

    If not actfrm.Showing Then
      actfrm.Show;

End;

Procedure Tmainfrm.pkgremoveClick(Sender: TObject);
Var
    rc: Longint;

Begin
    oprec:= titemrec.Create;
    oprec.kind:= 1;
    oprec.Name:= curpkg;
    oprec.op:= 'Remove';
    oprec.ver:= dm.pkgversion.Text;
    oprec.recno:= dm.pkg.RecNo;

    Try
      oplst.AddObject(curpkg, oprec);
      Inc(optot);

    Except
      ShowMessage('Duplicate package ignored');
      exit;
    End;

    packmnu.Items[4].Enabled:= True;

    rc:= actfrm.actgrid.RowCount;
    actfrm.actgrid.RowCount:= rc + 1;
    actfrm.actgrid.Cells[0, rc]:= oprec.Name;
    actfrm.actgrid.Cells[1, rc]:= 'Remove';

    actfrm.Top:= mainfrm.Top;
    actfrm.Left:= 1;
    mainfrm.Width:= 1464;
    mainfrm.Left:= 454;
    application.ProcessMessages;

    If not actfrm.Showing Then
      actfrm.Show;

End;

Procedure Tmainfrm.pkgundoallClick(Sender: TObject);
Begin
    undoall;
End;

Procedure Tmainfrm.pkgundoClick(Sender: TObject);
Begin
    undolast;
End;

Procedure Tmainfrm.srchbtnClick(Sender: TObject);
Begin
    If srchtxt.Text = '' Then
      exit;

    dm.psrc.SQL.Text:= 'select * from packages where name like ' + #39 + '%' +
      srchtxt.Text + '%'#39 + ' or desc like ' + #39 + '%' + srchtxt.Text + '%' + #39 + ';';
    dm.psrc.ExecSQL;
    dm.psrc.Active:= True;

    srchfrm.Show;

End;

Procedure Tmainfrm.srchtxtKeyPress(Sender: TObject; Var Key: Char);
Begin
    If key = #13 Then
    Begin
      srchbtnclick(self);
      key:= #0;
    End;
End;

Procedure Tmainfrm.fixbtnClick(Sender: TObject);
Begin
    notefrm.info('Repairing databases, standby...');

    exec(dnf+' repair fix', [], admin);
    notefrm.Close;
End;

Procedure Tmainfrm.FormShow(Sender: TObject);
Begin
    dm.initdb;

    Try
      if not root then
      loginfrm.showmodal;

      notefrm.info('setting up repos and lists');
      getcfg;

      ok:= exec(cmd+'arch',['']);
      myarch:= outp;
      myarch:= trim(myarch);

      If root Then
        rootlbl.Caption:= 'You have Root access'
      Else
        rootlbl.Caption:= 'You DO NOT have Root access';

      optot:= 0;
      uptot:= 0;

      curgrp:= dm.grpname.Text;
      grpidx:= 1;
      getinstalled;

      {quick tests}
      //import_pkg;
      //import_grp;
      import_repos;
      //halt;

      If fileexists(cfgdir + 'newsys') Then
      Begin
        notefrm.info('A new version of Fedora has been installed. The database and package versions will now be updated. This dialog will close when the operation is completed.');

        do_version;
        deletefile(cfgdir + 'newsys');
      End;

      Caption:= 'RPMgr v.' + ver;

      ln2:= dm.grp.RecordCount;

      If ln2 < 2 Then
      Begin
        notefrm.info(firstime);
        import_pkg;
        import_grp;
        import_repos;
        notefrm.Close;
      End;

      //import_pkg; //test line
      //import_grp; //test line

      outp:= '';

      dm.query.Close;
      dm.query.SQL.Text:= 'select * from packages;';
      dm.query.Active:= true;
      tot:= dm.query.RecordCount;
      dm.query.Active:= false;

      notefrm.Close;

      checkup;

      If uptot > 0 Then
      Begin
        //upfrm.updatelist.Text:= outp;
        updatebtn.StateNormal.Background.Color:= clred;
        ShowMessage('Updates are available.');
      End;

      grpgrid.Enabled:= True;

    Except
      on e: Exception Do
        gtu(e);
    End;

    instlbl.Caption:= 'Installed Packages = ' + i2str(insttot);
    pkgcnt.Caption:= 'Packages = ' + i2str(tot);
    dm.grp.First;
    dm.pkg.First;

    mainfrm.Width:= 1572;
    mainfrm.Left:= 220;
    application.ProcessMessages;
    sleep(100);
    application.ProcessMessages;
End;

Procedure Tmainfrm.grpgridClick(Sender: TObject);
Begin
    If dm.grp.RecordCount < 1 Then
      exit;

    grpidx:= grpgrid.SelectedIndex;

    If dm.grpname.Text = curgrp Then
      exit;

    curgrp:= dm.grpname.Text;

End;

Procedure Tmainfrm.instbtnClick(Sender: TObject);
Begin
    showinstalled;
End;

Procedure Tmainfrm.showinstalled;
Begin
    instfrm.Show;
End;

Procedure Tmainfrm.MnuexitClick(Sender: TObject);
Begin
    Close;
End;

Procedure Tmainfrm.provbtnClick(Sender: TObject);
Begin
    filefrm.Show;
End;

Procedure Tmainfrm.repbtnClick(Sender: TObject);
Begin
     repofrm.Show;
End;

initialization

    if loginfrm = nil then
    loginfrm:= Tloginfrm.Create(nil);

    If not directoryexists(cfgdir) Then
      forcedirectories(cfgdir);

End.
