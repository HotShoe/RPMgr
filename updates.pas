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

Unit updates;

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
    Grids,
    BCButton;

Type

    { Tupfrm }

    Tupfrm = Class(TForm)
      upmem :      TMemo;
      quitbtn :    TBCButton;
      installbtn : TBCButton;
      Label1 :     TLabel;
      Panel1 :     TPanel;
      upgrid :     TStringGrid;
      Procedure quitbtnClick(Sender : TObject);
      Procedure installbtnClick(Sender : TObject);
      Procedure FormShow(Sender : TObject);
    private

    public

    End;

Var
    upfrm : Tupfrm;

Implementation

Uses
    Data,
    globs,
    notes,
    mlstr,
    binexec;

    {$R *.lfm}

    { Tupfrm }

{Show available updates}
Procedure Tupfrm.FormShow(Sender : TObject);
Var
    r,
    rc : Longint;

Begin
    upgrid.Clean([gznormal]);
    installbtn.Enabled:= True;

    If uptot = 0 Then
    Begin
      upgrid.Cells[0, 1]:= 'No updates found.';
      exit;
    End;

    rc:= 0;
    r:= 1;
    upgrid.RowCount:= uptot + 1;

    While rc < uptot Do
    Begin
      line:= uplst[rc];
      upgrid.Cells[0, r]:= stripto(line, ' ');
      line:= trimleft(remainder);
      line:= stripto(line, ' ');
      upgrid.Cells[1, r]:= line;

      Inc(rc);
      inc(r);
    End;

    upgrid.RowCount:= r;
    label1.Caption:= 'Upgrades are ready to be installed for '+i2str(uptot)+' packages';
End;

Procedure Tupfrm.quitbtnClick(Sender : TObject);
Begin
    Close;
End;

{Apply all updates}
Procedure Tupfrm.installbtnClick(Sender : TObject);
Var
    z :   Longint;
    sql,
    nam,
    ver : String;

Begin
    upmem.Clear;
    application.ProcessMessages;

    If offline Then
      ok:= rootexec('dnf5 upgrade --offline -y', admin, upmem)
    Else
      ok:= rootexec('dnf5 upgrade -y', admin, upmem);

    If not ok Then
    Begin
      ShowMessage('An error occured during the update process. The error is: ' +
        i2str(errnum) + ' : ' + errstr);
      exit;
    End;

    installbtn.Enabled:= False;

    z:= 0;
    upmem.Append(#10 + 'Updating databases' + #10);

    Repeat
      line:= uplst[z];
      nam:= stripto(line, ' ');
      line:= trimleft(line);
      ver:= stripto(line, ' ');

      sql:= 'update packages set version = ' +
      	  #39 + 'true' + #39 +
            #39 + ver + #39 +
            ' , Installed=True' +
            ' where name = ' +
            #39 + nam + #39 + ';';

      dm.rcon.ExecuteDirect(sql);
      Inc(z);
    Until z = uptot;

    upgrid.Clean;
    upgrid.RowCount:= 2;
    upmem.Append(i2str(z) + 'transactions completed' + #10);
    upmem.Append(#10 + 'Updating databases complete' + #10);
    application.ProcessMessages;

    upmem.Lines.SaveToFile(homedir+'update.log');
    outp:= '';

    If uptot > 0 Then
      If (offline = False) Then
      Begin
        ok:= exec('/usr/bin/dnf5', ['needs-restarting']);

        If pos('reboot is required', outp) > 0 Then
          If messagedlg('Question',
            'A reboot is REQUIRED before these updates will take effect. Reboot the system now?',
            mtConfirmation, [mbYes, mbNo], 0) = mrYes Then
          Begin
            dm.closedb;
            rootexec('/usr/bin/reboot', admin);
          End
          Else
          If messagedlg('Question',
            'A reboot is NOT required for these updates, but WILL be required before some of the new updates will take effect. would you like to reboot the system now anyway?', mtConfirmation, [mbYes, mbNo], 0) = mrYes Then
          Begin
            dm.closedb;
            rootexec('/usr/bin/reboot', admin);
          End;

      End
      Else
      If messagedlg('Question',
        'A reboot is REQUIRED for updates to be installed. The system will now Reboot.',
        mtConfirmation, [mbok], 0) = mrok Then
      Begin
        dm.closedb;
        rootexec('/usr/bin/dnf5 offline reboot -y', admin);
      End;

End;

End.
