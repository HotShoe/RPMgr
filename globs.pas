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

Unit globs;
{$mode ObjFPC}{$H+}
Interface

Uses
    Classes,
    SysUtils,
    strutils,
    unix,
    process,
    DB,
    Controls,
    Graphics,
    Forms,
    Dialogs;

Const
    ver = '1.0.0';

Type
    Titemrec = Class
      Name,
      op,
      ver : String;
      kind : Byte; // 0 = pkg, 1 = grp
      recno : Longint;
    End;

    configrec = Record
      dscfg,
      dscbg,
      frmbg,
      frmfc,
      grdbg,
      grdfc,
      hdgbg,
      hdgfc : tcolor;
      offline : Boolean;
      dnf,
      rpm,
      cmd : shortstring;
      dpi : word;
    End;

Var
    //ops : array [0..499] of itemrec;
    crec: configrec;
    oplst,
    filelst,
    uplst,
    pkglst,
    grplst,
    instlst,
    leaflst: TStringList;
    oprec: Titemrec;
    pkgaddstr,
    pkgdelstr,
    pkgrinstr,
    grpaddstr,
    grpdelstr,
    myarch,
    mydir,
    me,
    dnf,
    rpm,
    cmd,
    cfgdir,
    dbdir,
    curpkg,
    curgrp,
    tmp,
    tmp1,
    line,
    tst,
    st: String;
    exstat,
    ercode,
    stat,
    errnum: Integer;
    optot,
    untot,
    gi,
    x,
    i,
    grptot,
    pkgtot,
    infotot,
    insttot,
    grpidx,
    pkgidx,
    repotot,
    lvtot,
    uptot,
    ln,
    ln2,
    tot,
    sz: Longint;
    Offline,
    ok: Boolean;

Procedure getcfg;
Procedure savecfg;
Function run(what, prog, cmdln, lname : String) : Boolean;
Procedure checkup;
Procedure gtu(e : Exception);
Procedure getinstalled;
Function installed(ln : String) : Longint;
Procedure do_version;
Function getdesc(Var ln : Longint) : String;
Procedure import_pkg;
Procedure import_grp;
Procedure Import_repos;
Procedure getleaves;
Function list_files(pname : String) : Boolean;
Procedure getrepo;
Procedure applyall;
procedure markinstalled;
procedure markremoved;
Procedure undolast;
Procedure undoall;

Implementation

Uses
    Data,
    main,
    config,
    mlstr,
    repo,
    notes,
    apply,
    binexec;

Procedure getcfg;
Var
    cfile: File Of configrec;

Begin
    assignfile(cfile, cfgdir + 'rpmgr.cfg');

    Try
      reset(cfile);

      Read(cfile, crec);
      Close(cfile);

    Except
      With crec Do
      Begin
        dscfg:= clblack;
        dscbg:= claqua;
        frmbg:= $00C2D3DF;
        frmfc:= clblack;
        grdbg:= clwhite;
        grdfc:= clblack;
        hdgbg:= $00C2D3DF;
        hdgfc:= clblack;
        offline:= True;

        ok:= exec('','which','cp');
        cmd:= copy(outp,1,lastpos('/',outp));

        ok:= exec('','which','rpm');
        rpm:= trim(outp);

        ok:= exec('','which','dnf5');
        dnf:= trim(outp);

      End;

      savecfg;
    End;

    if cfgfrm = nil then
    cfgfrm:= tcfgfrm.Create(nil);

    With cfgfrm Do
    Begin //set up defaults
      frmbgbtn.ButtonColor:= crec.frmbg;
      frmfgbtn.ButtonColor:= crec.frmfc;
      txtbgbtn.ButtonColor:= crec.grdbg;
      txtfgbtn.ButtonColor:= crec.grdfc;
      dscbgbtn.ButtonColor:= crec.dscbg;
      dscfgbtn.ButtonColor:= crec.dscfg;
      hdgbgbtn.ButtonColor:= crec.hdgbg;
      hdgfgbtn.ButtonColor:= crec.hdgfc;
      updatechk.Checked:= crec.offline;
      offline:= crec.offline;

    End;

    cmd:= crec.cmd;
    rpm:= crec.rpm;
    dnf:= crec.dnf;

    cfgfrm.Change_Colors;

End;

Procedure savecfg;
Var
    cfile: File Of configrec;

Begin
    if not directoryexists(cfgdir) then
    mkdir(cfgdir);

    Assign(cfile, cfgdir + 'rpmgr.cfg');

    rewrite(cfile);
    Write(cfile, crec);
    Close(cfile);

End;

{Apply all operations}
Procedure applyall;
Var
    i: Longint;

Begin
    pkgaddstr:= '';
    pkgdelstr:= '';
    pkgrinstr:= '';
    grpaddstr:= '';
    grpdelstr:= '';

    For i:= 0 To optot - 1 Do
    Begin
      oprec:= titemrec(oplst.Objects[i]);

      If oprec.kind = 1 Then //1 = packages
        If oprec.op = 'Install' Then
          pkgaddstr:= pkgaddstr + ' ' + oprec.Name
        Else
        If oprec.op = 'Re-Install' Then
          pkgrinstr:= pkgrinstr + ' ' + oprec.Name
        Else
        If oprec.op = 'Remove' Then
          pkgdelstr:= pkgdelstr + ' ' + oprec.Name;

      If oprec.kind = 0 Then //0 = groups
        If oprec.op = 'Install' Then
          grpaddstr:= grpaddstr + ' ' + oprec.Name
        Else
          grpdelstr:= grpdelstr + ' ' + oprec.Name;

    End;

    applyfrm.Showmodal;

End;

procedure markinstalled;
var
    mlst : tstringlist;
    num : longint;
    pname,
    arch,
    sql,
    ver : string;

begin
	if not fileexists(mydir+'apply.log') then
      exit;

    mlst:= tstringlist.Create;
	mlst.LoadFromFile(mydir+'apply.log');

    num:= mlst.Count;
    i:= -1;
    dm.rcon.AutoCommit:= false;

    while i < (num - 5) do
    begin

    repeat
    inc(i);
	line:= mlst[i];
    until line = 'Installing:';

    inc(i);
    line:= mlst[i];
	tmp:= stripto(line,' ');
    pname:= stripto(line,' ');

    line:= mirt(line);
    tmp:= stripto(line,' ');
    arch:= tmp;

    pname:= pname + '.' + arch;

    ver:= stripto(line,' ');

    sql:= 'update packages set version=' +
            #39 + ver + #39 +
            ' , installed= True' +
            ' where name = ' +
            #39 + pname + #39 + ';';

    dm.rcon.ExecuteDirect(sql);

	inc(i,2);

    repeat
	line:= mlst[i];

    if not (line = '') then
    begin
	tmp:= stripto(line,' ');
    pname:= stripto(line,' ');

    line:= mirt(line);
    tmp:= stripto(line,' ');
    arch:= tmp;

    pname:= pname + '.' + arch;

    ver:= stripto(line,' ');

    sql:= 'update packages set version=' +
            #39 + ver + #39 +
            ' , installed= True' +
            ' where name = ' +
            #39 + pname + #39 + ';';

    dm.rcon.ExecuteDirect(sql);
	dm.rcon.Commit;
    end;

    inc(i);
    line:= mlst[i];
    until (wordn(line,1) = 'Installing') or
    	  (line = '');

    if line = 'Installing weak dependencies:' then
    begin
	inc(i);

	repeat
	line:= mlst[i];

    if not (line = '') then
    begin
	tmp:= stripto(line,' ');
    pname:= stripto(line,' ');

    line:= mirt(line);
    tmp:= stripto(line,' ');
    arch:= tmp;

    pname:= pname + '.' + arch;

    ver:= stripto(line,' ');

    sql:= 'update packages set version=' +
            #39 + ver + #39 +
            ' , installed= True' +
            ' where name = ' +
            #39 + pname + #39 + ';';

    dm.rcon.ExecuteDirect(sql);
	dm.rcon.Commit;
    end;

    inc(i);
    line:= mlst[i];
    until (line = '');
    end;

    inc(i);
    end;

    dm.rcon.AutoCommit:= true;
end;

procedure markremoved;
var
    mlst : tstringlist;
    num : longint;
    pname,
    arch,
    sql,
    ver : string;

begin
	if not fileexists(mydir+'apply.log') then
      exit;

    mlst:= tstringlist.Create;
	mlst.LoadFromFile(mydir+'apply.log');

    num:= mlst.Count;
    i:= -1;
    dm.rcon.AutoCommit:= false;

    while i < (num - 6) do
    begin

    repeat
    inc(i);
	line:= mlst[i];
    until line = 'Removing:';

    inc(i);
    line:= mlst[i];
	tmp:= stripto(line,' ');
    pname:= stripto(line,' ');

    line:= mirt(line);
    tmp:= stripto(line,' ');
    arch:= tmp;

    pname:= pname + '.' + arch;

    ver:= stripto(line,' ');

    sql:= 'update packages set version=' +
            #39 + ver + #39 +
            ' , installed= False' +
            ' where name = ' +
            #39 + pname + #39 + ';';

    dm.rcon.ExecuteDirect(sql);

	inc(i);
	line:= mlst[i];

    if line = 'Removing unused dependencies:' then
    begin
	inc(i);

	repeat
	line:= mlst[i];

    if not (line = '') then
    begin
	tmp:= stripto(line,' ');
    pname:= stripto(line,' ');

    line:= mirt(line);
    tmp:= stripto(line,' ');
    arch:= tmp;

    pname:= pname + '.' + arch;

    ver:= stripto(line,' ');

    sql:= 'update packages set version=' +
            #39 + ver + #39 +
            ' , installed= False' +
            ' where name = ' +
            #39 + pname + #39 + ';';

    dm.rcon.ExecuteDirect(sql);
    end;

    inc(i);
    line:= mlst[i];
    until (line = '');
    end;

    inc(i);
    end;

    dm.rcon.Commit;
    dm.rcon.AutoCommit:= true;

end;

Procedure undolast;
Begin
    oprec:= titemrec(oplst.Objects[optot - 1]);

    If messagedlg('Question', 'Undo the action for ' + oprec.Name + '?', mtConfirmation,
      [mbYes, mbNo], 0) = mrYes Then
    Begin
      oplst.Objects[optot - 1].Free;
      oplst.Objects[optot - 1]:= nil;
      oplst.Delete(optot - 1);

      Dec(optot);
    End;

End;

Procedure undoall;
Begin
    For i:= 0 To optot - 1 Do
    Begin
      oplst.Objects[i].Free;
      oplst.Objects[i]:= nil;
    End;

    oplst.Clear;
    optot:= 0;
    pkgaddstr:= '';
    pkgdelstr:= '';
    pkgrinstr:= '';
    grpaddstr:= '';
    grpdelstr:= '';

End;

Function run(what, prog, cmdln, lname : String) : Boolean;
Var
    cmd: String;
Begin
    If what <> '' Then
    Begin
      notefrm.info(what);
      notefrm.Show;
    End;

    If lname <> '' Then
    begin
      lname:= cfgdir + lname + '.lst';
      outp:= '';

      cmd:= '/bin/sh -c ' + prog + ' ' + cmdln + ' > ' + lname;
      errnum:= fpsystem(cmd);

    end
    else
    begin
    outp:= '';
    cmd:= prog + ' ' + cmdln+'> '+outp;

    errnum:= fpsystem(cmd);
    end;

    //runcommand(prog, outp);

    Result:= errnum = 0;

    notefrm.Close;

End;

procedure log(lstr : string);
var
    t : textfile;
    logfile : string;

begin
    logfile:= mydir+'rpmgr.log';

    assignfile(t,logfile);

    if fileexists(logfile) then
    reset(t)
    else
    rewrite(t);

    writeln(t,lstr);

    closefile(t);

end;

{GTU error (Going Tits Up) - always fatal}
Procedure gtu(e : Exception);
var
  err : string;

Begin
  err:= 'RPManager has caused a GTU error and will now close. ' +
      'The error is:' + #10 + e.Message;

    notefrm.error(err);

    //log(err);

    application.ProcessMessages;
    halt(stat);
End;

{Check for updates}
Procedure checkup;
Begin
    uptot:= 0;
    ok:= exec('Checking for updates.',dnf+' check-upgrade','',2000);

    If (outp = '') Then
    Begin
      ShowMessage('An error occured whiled checking for updates. ' + errstr);
      exit;
    End;

      uplst.Text:= outp;

      //deletefile(cfgdir+'up.lst');

      If uplst.Count > 0 Then
      Begin
        uptot:= uplst.Count;
        application.ProcessMessages;
      End;

    notefrm.Close;
End;

Procedure getrepo;
Begin

End;

{Build a list of all packages installed on the system}
Procedure getinstalled;
var
    lx : longint;

Begin

    If instlst = nil Then
      instlst:= TStringList.Create;

    instlst.Clear;
    outp:= '';
    lx:= 0;

    ok:= exec('Checking installed packages',dnf+' list --installed','',1000);
    //ok:= exec(dnf,['list', '--installed', '> '+cfgdir+'inst.lst']);
    instlst.text:= outp;
    insttot:= instlst.Count;
    instlst.Sorted:= True;
    //deletefile(cfgdir+'inst.lst');

    while lx < insttot do
    begin
    line:= instlst[lx];
    st:= stripto(line,' ');
    outp:= outp +st+#10;

    inc(lx);
    end;

    instlst.Clear;
    instlst.Text:= outp;
    insttot:= instlst.Count;
    instlst.SaveToFile(mydir+'inst.lst');

End;

{Ckecks to see if a package is installed
returns the index to the package in instlst if found, or -1 if not found}
Function installed(ln : String) : Longint;
Var
    cl: Longint;

Begin
    ok:= False;
    cl:= 0;
    ok:= instlst.Find(ln,cl);

    if ok then
    result:= cl
    else
    Result:= -1;

End;

{Returns the long description of a package
ln is the index number in pkglst
Returns the description as a string}
Function getdesc(Var ln : Longint) : ansiString;
Var
    nl,
    dl: Longint;
    dline,
    ck: ansiString;

Begin
    nl:= ln;

    For nl:= ln To pkgtot - 1 Do
    Begin
      ck:= pkglst[nl];
      dline:= '';

      If wordn(ck, 1) = 'Description' Then
        break;
    End;

    For dl:= nl To pkgtot - 1 Do
    Begin
      If wordn(pkglst[dl], 1) = 'Vendor' Then
        break;

      If wordn(ck, 1) = 'Description' Then
        tmp:= stripto(ck, ':')
      Else
      Begin
        ck:= pkglst[dl];
        tmp:= stripto(ck, ':');
      End;

      If (ck = ' ') and (dline <> '') Then
        ck:= #10 + #10;

      dline:= dline + ck;
    End;

    ln:= dl;
    Result:= dline;

End;

{Lists files contained inside of a package}
Function list_files(pname : String) : Boolean;
Begin
    If filelst = nil Then
      filelst:= TStringList.Create;

    ok:= run('',rpm, '-ql ' + pname,'flist');
    filelst.LoadFromFile(cfgdir+'flist.lst');

    Result:= ok;
End;

{Retrieves a list of all packages in all current repos. Then compiles that list
nto the rpmgr database. this is why it takes a while to run rpmgr the first
time.}
//Procedure import_pkg;
//Var
//    pnum,
//    xl,
//    r: Longint;
//    sql,
//    dl,
//    sz,
//    arch,
//    pname,
//    ins,
//    ver,
//    epoch,
//    isz,
//    dlsz,
//    desc: String;
//
//Begin
//    if pkglst = nil then
//    pkglst:= TStringList.Create;
//
//    pkglst.Clear;
//    pkgtot:= 0;
//    pnum:= 0;
//
//    dm.pkg.DisableControls;
//    dm.grp.Active:= False;
//    pkglst.Delimiter:= #10;
//
//    ok:= run('Importing Package list. This will take several moments.',dnf,'info --available','pkg');
//    //ok:= exec(dnf+' info --available > '+cfgdir+'pkg.lst',[], admin);
//    //pkglst.LoadFromFile(cfgdir+'pkg.lst');
//    pkglst.Text:= outp;
//    //outp:= pkglst.Text;
//    //pkglst.SaveToFile(mydir+'pkg.lst');
//    pkgtot:= pkglst.Count;
//    //deletefile(cfgdir+'pkg.lst');
//
//    If pkgtot < 1 Then
//      exit;
//
//    dm.query.Close;
//    dm.query.SQL.Clear;
//    dm.query.SQL.Text:= 'delete from packages;';
//    dm.query.ExecSQL;
//
//    xl:= 1;
//    r:= 1;
//    dm.rcon.AutoCommit:= False;
//    dm.rcon.ExecuteDirect('end transaction;');
//
//    dm.rcon.ExecuteDirect('PRAGMA journal_mode = off');
//    dm.rcon.ExecuteDirect('PRAGMA synchronous = 0;');
//    dm.rcon.ExecuteDirect('PRAGMA cache_size = -204800;');
//    dm.rcon.ExecuteDirect('PRAGMA locking_mode = EXCLUSIVE;');
//    dm.rcon.ExecuteDirect('PRAGMA temp_store = MEMORY;');
//
//    dm.rcon.ExecuteDirect('begin transaction;');
//
//    While xl < pkgtot - 4 Do
//    Begin
//      line:= pkglst[xl];
//      line:= stripto(line, ':');
//      st:= remainder;
//      st:= strip(st, ' ');
//      pname:= st;
//
//      Inc(xl);
//      line:= pkglst[xl];
//      line:= stripto(line, ':');
//      epoch:= remainder;
//      epoch:= strip(epoch, ' ');
//
//      Inc(xl);
//      line:= pkglst[xl];
//      line:= stripto(line, ':');
//      ver:= remainder;
//      ver:= strip(ver, ' ');
//
//      Inc(xl);
//      line:= pkglst[xl];
//      line:= stripto(line, ':');
//      ver:= ver + '-' + remainder;
//      ver:= strip(ver, ' ');
//
//      Inc(xl);
//      line:= pkglst[xl];
//      line:= stripto(line, ':');
//      arch:= remainder;
//      arch:= strip(arch, ' ');
//
//      Inc(xl);
//      line:= pkglst[xl];
//      dl:= line;
//      dlsz:= stripto(line, ':');
//      line:= trimleft(line);
//      dlsz:= line;
//      dlsz:= trim(dlsz);
//
//      Inc(xl);
//      line:= pkglst[xl];
//      sz:= line;
//      isz:= stripto(line, ':');
//      line:= trimleft(line);
//      isz:= line;
//      isz:= trim(isz);
//
//      If pname = '' Then
//        break;
//
//      Inc(xl, 6);
//
//      desc:= getdesc(xl);
//      tmp:= sz + #10 + dl + #10;
//      desc:= tmp + desc;
//      desc:= quotedstr(desc);
//      Inc(xl);
//
//      pname:= pname + '.' + arch;
//
//      ln2:= installed(pname);
//
//      If ok Then
//        ins:= 'True'
//      Else
//        ins:= 'False';
//        tmp:= 'none';
//
//      Try
//        sql:= 'insert into packages values(' +
//          #39 + ins + #39 + ',' +
//          #39 + pname + #39 + ',' +
//          #39 + ver + #39 + ',' +
//          desc + ',' +
//          #39 + arch + #39 + ',' +
//          #39 + tmp + #39 + ',' +
//          #39 + isz + #39 + ',' +
//          #39 + dlsz + #39 + ');';
//
//        dm.rcon.ExecuteDirect(sql);
//
//      Except
//        on e : exception do
//        begin
//        showmessage(e.Message);
//
//        Inc(xl);
//        continue;
//        end;
//
//      End;
//
//      If r > 2000 Then
//      Begin
//        dm.rcon.Commit;
//        r:= 1;
//        application.ProcessMessages;
//
//      End;
//
//      Inc(pnum);
//      Inc(xl);
//      Inc(r);
//    End;
//
//    dm.rcon.AutoCommit:= True;
//    dm.rcon.ExecuteDirect('PRAGMA journal_mode = WAL');
//    dm.rcon.ExecuteDirect('PRAGMA synchronous = NORMAL;');
//    dm.rcon.ExecuteDirect('PRAGMA cache_size = 1024000;');
//    dm.rcon.ExecuteDirect('PRAGMA locking_mode = NORMAL;');
//    dm.rcon.ExecuteDirect('PRAGMA temp_store = DEFAULT;');
//
//    pkglst.Free;
//    dm.grp.Active:= True;
//    dm.pkg.EnableControls;
//
//End;

procedure import_pkg;
var
  pnum, xl, r: Longint;
  sql, dl, sz, arch, pname, ins, ver, epoch, isz, dlsz, desc: string;
begin
  if pkglst = nil then
    pkglst := TStringList.Create;

  pkglst.Clear;
  pkgtot := 0;
  pnum := 0;

  dm.pkg.DisableControls;
  dm.grp.Active := False;
  pkglst.Delimiter := #10;

  ok := exec('Importing packages. This may take some time.', dnf, 'info --available',1000);
  //pkglst.LoadFromFile(cfgdir+'pkg.lst');
  pkglst.Text:= outp;
  pkgtot := pkglst.Count;

  if pkgtot < 1 then
  exit;

  // Drop indexes for speed
  dm.rcon.ExecuteDirect('DROP INDEX IF EXISTS idx_packages_version;');
  dm.rcon.ExecuteDirect('DROP INDEX IF EXISTS idx_packages_arch;');
  dm.rcon.ExecuteDirect('DROP INDEX IF EXISTS idx_packages_name_version;');

  dm.query.Close;
  dm.query.SQL.Text := 'DELETE FROM packages;';
  dm.query.ExecSQL;

  dm.rcon.AutoCommit := False;
  dm.rcon.ExecuteDirect('END TRANSACTION;');
  dm.rcon.ExecuteDirect('PRAGMA journal_mode = OFF;');
  dm.rcon.ExecuteDirect('PRAGMA synchronous = 0;');
  dm.rcon.ExecuteDirect('PRAGMA cache_size = -204800;');
  dm.rcon.ExecuteDirect('PRAGMA locking_mode = EXCLUSIVE;');
  dm.rcon.ExecuteDirect('PRAGMA temp_store = MEMORY;');
  dm.rcon.ExecuteDirect('BEGIN TRANSACTION;');

  dm.query.SQL.Text :=
    'INSERT INTO packages (installed, name, version, desc, arch, grp, isize, psize) ' +
    'VALUES (:ins, :pname, :ver, :desc, :arch, :src, :isz, :dlsz);';
  dm.query.Prepare;

  xl := 1;
  r := 1;

  while xl < pkgtot - 4 do
  begin
  line:= pkglst[xl];
      line:= stripto(line, ':');
      st:= remainder;
      st:= strip(st, ' ');
      pname:= st;

      Inc(xl);
      line:= pkglst[xl];
      line:= stripto(line, ':');
      epoch:= remainder;
      epoch:= strip(epoch, ' ');

      Inc(xl);
      line:= pkglst[xl];
      line:= stripto(line, ':');
      ver:= remainder;
      ver:= strip(ver, ' ');

      Inc(xl);
      line:= pkglst[xl];
      line:= stripto(line, ':');
      ver:= ver + '-' + remainder;
      ver:= strip(ver, ' ');

      Inc(xl);
      line:= pkglst[xl];
      line:= stripto(line, ':');
      arch:= remainder;
      arch:= strip(arch, ' ');

      Inc(xl);
      line:= pkglst[xl];
      dl:= line;
      dlsz:= stripto(line, ':');
      line:= trimleft(line);
      dlsz:= line;
      dlsz:= trim(dlsz);

      Inc(xl);
      line:= pkglst[xl];
      sz:= line;
      isz:= stripto(line, ':');
      line:= trimleft(line);
      isz:= line;
      isz:= trim(isz);

    if pname = '' then break;
    Inc(xl, 6);

    desc := getdesc(xl);
    desc := quotedstr(sz + #10 + dl + #10 + desc);
    Inc(xl);

    pname := pname + '.' + arch;
    ln2 := installed(pname);
    ins := ifthen(ok, 'True', 'False');
    tmp := 'none';

    try
      dm.query.ParamByName('ins').AsString := ins;
      dm.query.ParamByName('pname').AsString := pname;
      dm.query.ParamByName('ver').AsString := ver;
      dm.query.ParamByName('desc').AsString := desc;
      dm.query.ParamByName('arch').AsString := arch;
      dm.query.ParamByName('src').AsString := tmp;
      dm.query.ParamByName('isz').AsString := isz;
      dm.query.ParamByName('dlsz').AsString := dlsz;
      dm.query.ExecSQL;
    except
      on e: Exception do
      begin
        ShowMessage(e.Message);
        Inc(xl);
        Continue;
      end;
    end;

    if r > 2000 then
    begin
      dm.rcon.Commit;
      r := 1;
      Application.ProcessMessages;
    end;

    Inc(pnum);
    Inc(xl);
    Inc(r);
  end;

  dm.rcon.Commit;
  dm.rcon.AutoCommit := True;

  // Restore PRAGMA and indexes
  dm.rcon.ExecuteDirect('PRAGMA journal_mode = WAL;');
  dm.rcon.ExecuteDirect('PRAGMA synchronous = NORMAL;');
  dm.rcon.ExecuteDirect('PRAGMA cache_size = 1024000;');
  dm.rcon.ExecuteDirect('PRAGMA locking_mode = NORMAL;');
  dm.rcon.ExecuteDirect('PRAGMA temp_store = DEFAULT;');

  dm.rcon.ExecuteDirect('CREATE INDEX idx_packages_version ON packages(version);');
  dm.rcon.ExecuteDirect('CREATE INDEX idx_packages_arch ON packages(arch);');
  dm.rcon.ExecuteDirect('CREATE INDEX idx_packages_name_version ON packages(name, version);');

  pkglst.Free;
  dm.grp.Active := True;
  dm.pkg.EnableControls;
end;


{Update package versions}
Procedure do_version;
Var
    cnt,
    x,
    r: Longint;
    line,
    pname,
    ver,
    sql,
    st: String;
    verlst: TStringList;

Begin
    verlst:= TStringList.Create;

    verlst.Delimiter:= #10;

    ok:= exec('Updating package versions',dnf,' list --available',1000);
    verlst.Text:= outp;

    verlst.Delete(0);
    //deletefile(cfgdir+'ver.lst');

    x:= 0;
    r:= 1;
    dm.rcon.AutoCommit:= False;
    dm.rcon.ExecuteDirect('end transaction;');

    dm.rcon.ExecuteDirect('PRAGMA journal_mode = off');
    dm.rcon.ExecuteDirect('PRAGMA synchronous = 0;');
    dm.rcon.ExecuteDirect('PRAGMA cache_size = -204800;');
    dm.rcon.ExecuteDirect('PRAGMA locking_mode = EXCLUSIVE;');
    dm.rcon.ExecuteDirect('PRAGMA temp_store = MEMORY;');

    dm.rcon.ExecuteDirect('begin transaction;');

    cnt:= verlst.Count;

    For x:= 0 To cnt - 1 Do
    Begin
      line:= verlst[x];

      If line = '' Then
        continue;

      pname:= stripto(line, ' ');
      st:= mirt(remainder);
      ver:= stripto(st, ' ');

      Try
        sql:= 'update packages set version = ' +
        #39 + ver + #39 +
        ' where name = ' +
        #39 + pname + #39 + ';';

        dm.rcon.ExecuteDirect(sql);

      Except
        continue;
      End;

      If r > 2000 Then
      Begin
        dm.rcon.Commit;
        r:= 1;
        application.ProcessMessages;

      End;

      Inc(r);
    End;

    verlst.Free;
    verlst:= nil;

    dm.rcon.AutoCommit:= True;
    dm.rcon.ExecuteDirect('PRAGMA journal_mode = WAL');
    dm.rcon.ExecuteDirect('PRAGMA synchronous = NORMAL;');
    dm.rcon.ExecuteDirect('PRAGMA cache_size = 1024000;');
    dm.rcon.ExecuteDirect('PRAGMA locking_mode = NORMAL;');
    dm.rcon.ExecuteDirect('PRAGMA temp_store = DEFAULT;');

End;

{Get a list of all Leaves on the system}
Procedure getleaves;
Var
    sql,
    ver,
    arch,
    pname: String;

Begin
    application.ProcessMessages;
    dm.grp.Active:= False;

    leaflst.Clear;

    ok:= exec('Gathering Leaves',dnf,'leaves',1000);
    leaflst.Text:= outp;
    lvtot:= leaflst.Count;
    leaflst.Sort;
    //deletefile(cfgdir+'leaf.lst');

    x:= 0;
    i:= 0;
    //dm.rcon.Connected:= false;
    dm.rcon.AutoCommit:= False;
    dm.rcon.ExecuteDirect('end transaction;');

    dm.rcon.ExecuteDirect('PRAGMA journal_mode = off');
    dm.rcon.ExecuteDirect('PRAGMA synchronous = 0;');
    dm.rcon.ExecuteDirect('PRAGMA cache_size = -204800;');
    dm.rcon.ExecuteDirect('PRAGMA locking_mode = EXCLUSIVE;');
    dm.rcon.ExecuteDirect('PRAGMA temp_store = MEMORY;');

    //dm.rcon.Connected:= true;
    dm.rcon.ExecuteDirect('begin transaction;');
    dm.pkg.DisableControls;

    While x < lvtot Do
    Begin
      line:= leaflst[x];
      line:= stripto(line, ' ');
      st:= remainder;

      For gi:= pos(':', st) Downto 1 Do
        If st[gi] = '-' Then
          break;

      pname:= copy(st, 1, gi - 1);

      line:= stripto(st, ':');
      st:= remainder;
      gi:= lastpos('.', st);
      ver:= copy(st, 1, gi - 1);
      arch:= copy(st, gi + 1, 255);

      pname:= pname + '.' + arch;

      sql:= 'UPDATE packages SET grp = ''Leaves'', installed = True WHERE name = ' +
        #39 + pname + #39 + ';';

      dm.rcon.ExecuteDirect(sql);

      If i > 1000 Then
      Begin
        dm.rcon.Commit;
        i:= 0;
      End;

      Inc(x);
      Inc(i);
    End;

    dm.rcon.AutoCommit:= True;
    dm.rcon.ExecuteDirect('PRAGMA journal_mode = WAL');
    dm.rcon.ExecuteDirect('PRAGMA synchronous = NORMAL;');
    dm.rcon.ExecuteDirect('PRAGMA cache_size = 1024000;');
    dm.rcon.ExecuteDirect('PRAGMA locking_mode = NORMAL;');
    dm.rcon.ExecuteDirect('PRAGMA temp_store = DEFAULT;');
    //dm.rcon.Connect;

    dm.pkg.EnableControls;
    dm.grp.Active:= True;
    application.ProcessMessages;
End;

{Get a list of all groups in the repos}
Procedure import_grp;
Var
    sql,
    gname,
    fname,
    desc: String;
    x,
    r: Longint;
    inst: Boolean;

Begin
    grplst:= TStringList.Create;
    grplst.Clear;
    grptot:= 0;

    ok:= exec('Importing Group list. This will take several moments.',dnf,' group info',1000);
    //grplst.LoadFromFile(cfgdir+'grp.lst');
    grplst.Text:= outp;
    grptot:= grplst.Count;
    //deletefile(cfgdir+'grp.lst');

    If grptot < 1 Then
      exit;

    dm.query.Close;
    dm.query.SQL.Clear;
    dm.query.SQL.Text:= 'delete from groups;';
    dm.query.ExecSQL;

    dm.grp.DisableControls;

    dm.rcon.AutoCommit:= False;
    dm.rcon.ExecuteDirect('end transaction;');

    dm.rcon.ExecuteDirect('PRAGMA journal_mode = off');
    dm.rcon.ExecuteDirect('PRAGMA synchronous = 0;');
    dm.rcon.ExecuteDirect('PRAGMA cache_size = -204800;');
    dm.rcon.ExecuteDirect('PRAGMA locking_mode = EXCLUSIVE;');
    dm.rcon.ExecuteDirect('PRAGMA temp_store = MEMORY;');

    dm.rcon.ExecuteDirect('begin transaction;');

    x:= 1;
    r:= 1;

    if not dm.grp.Active then
    dm.grp.Active:= true;;

    While x < grptot - 4 Do
    Begin
      line:= grplst[x];

      If line = '' Then
      Begin
        Inc(x);
        continue;
      End;

      line:= stripto(line, ':');
      st:= remainder;
      gname:= trimleft(st);

      If gname = '' Then
        break;

      Inc(x);
      line:= grplst[x];
      line:= stripto(line, ':');
      desc:= remainder;

      Inc(x);

      line:= grplst[x];
      tmp:= stripto(line, ':');
      line:= trimleft(line);

      inst:= line = 'yes';

      Repeat
        Inc(x);
      Until wordn(grplst[x], 1) = 'Repositories';

      Inc(x);
      line:= grplst[x];
      tmp:= stripto(line, ':');
      line:= trimleft(line);
      fname:= line;

      dm.grp.Insert;
      dm.grpdesc.Text:= quotedstr(desc);
      dm.grpname.Text:= gname;

      If inst Then
        dm.grpinstalled.AsString:= 'True'
      Else
        dm.grpinstalled.AsString:= 'False';

      Try
        dm.grp.Post;
        dm.rcon.Commit;
        r:= 1;
      Except
        //dm.grp.Cancel;
        Inc(x);
        continue;
      End;

      //dm.rcon.Commit;

      While grplst[x] <> '' Do
      Begin
        line:= grplst[x];
        tmp:= stripto(line, ':');
        line:= trimleft(line);
        fname:= line;

        ln:= installed(fname+'.'+myarch);

        If (ok = true) Then
        Begin
        fname:= fname+'.'+myarch;

          sql:= 'update packages set grp = ' +
          #39 + gname + #39 +
          ', installed = ''True'' where name = ' +
          #39 + fname + #39 + ';';

          dm.rcon.ExecuteDirect(sql);
        End
        Else
        Begin
        fname:= line;

          dm.query.sql.Clear;
          dm.query.SQL.Text:= 'select * from packages where name like ' + #39 + fname + '%' + #39 + ';';
          dm.query.ExecSQL;
          dm.query.Open;
          dm.query.First;

          Repeat
            tst:= dm.query.FieldByName('name').Text;

            If pos(myarch, tst) > 0 Then
            Begin
              fname:= fname + '.' + myarch;
              break;
            End
            Else
              fname:= fname + '.noarch';

            dm.query.Next;
          Until dm.query.EOF;

          sql:= 'update packages set grp = ' +
          #39 + gname + #39 +
          ', installed = False where name = ' +
          #39 + fname + #39 + ';';

          dm.rcon.ExecuteDirect(sql);
        End;

        If r > 2000 Then
        Begin
          dm.rcon.Commit;
          r:= 0;
          Inc(x);
          continue;
        End;

        Inc(x);
        Inc(r);
      End;

      Inc(x, 2);
    End;

    dm.grp.Insert;
    dm.grpdesc.Text:=
      'These packages are not attached or dependent on a group or package, and are more or less "independant packages" installed by users or administrators to fill specific needs.';
    dm.grpname.Text:= 'Leaves';
    dm.grpinstalled.AsBoolean:= True;
    dm.grp.Post;

    getleaves;
    dm.grp.EnableControls;
    grplst.Free;
    dm.resetdb;

End;

Procedure Import_repos;
Var
    repoid,
    rname,
    infos,
    typ,
    cfgname,
    base,
    meta,
    keys,
    repdat,
    pkgdat: String;
    inst: Boolean;
    repolst : tstringlist;

Begin
    repolst:= TStringList.Create;

    repotot:= 0;
    dm.rcon.AutoCommit:= false;
    dm.rcon.ExecuteDirect('delete from repo;');
    dm.rcon.Commit;

    application.ProcessMessages;

    ok:= exec('Getting Repository list',dnf,'repo info --all',2000);
    //repolst.LoadFromFile(cfgdir+'repo.lst');
    repolst.Text:= outp;
    repotot:= repolst.Count;
    //deletefile(cfgdir+'repo.lst');

    If repotot < 1 Then
      exit;

    x:= 0;

    While x < repotot - 4 Do
    Begin
      line:= repolst[x];

      If line = '' Then
      Begin
        Inc(x);
        continue;
      End;

      dm.repos.Insert;
      line:= stripto(line, ':');
      st:= remainder;
      repoid:= trimleft(st);
      dm.reposrepoid.Text:= repoid;

      inc(x);
      line:= stripto(line, ':');
      st:= remainder;
      rname:= trimleft(st);
      dm.reposname.Text:= rname;

      If rname = '' Then
      begin
        dm.repos.Cancel;
        break;
      end;

      Inc(x);
      line:= repolst[x];
      tmp:= stripto(line, ':');
      line:= trimleft(line);

      inst:= line = 'enabled';

      If inst Then
        dm.reposstatus.AsString:= 'Enabled'
      Else
        dm.reposstatus.AsString:= 'Disabled';

      Inc(x,3);

      line:= repolst[x];
      tmp:= stripto(line, ':');
      line:= trimleft(line);
      typ:= line;
      dm.reposType.Text:= typ;

      inc(x,3);
      line:= repolst[x];
      tmp:= stripto(line, ':');
      line:= trimleft(line);
      cfgname:= line;
      dm.reposConfig.Text:= cfgname;

      inc(x,2);
      line:= repolst[x];
      tmp:= stripto(line, ':');
      line:= trimleft(line);
      base:= line;
      dm.reposBaseURL.Text:= base;

      inc(x);
      line:= repolst[x];
      tmp:= stripto(line, ':');
      tmp:= mirt(tmp);
      line:= mirt(line);

      if wordn(tmp,1) = 'Metalink' then
      begin
      meta:= line;
      dm.reposMetaLink.Text:= meta;
      inc(x);
      end;

      inc(x);
      line:= repolst[x];
      tmp:= stripto(line, ':');
      line:= trimleft(line);
      keys:= line;
      dm.reposKeys.Text:= keys;

      inc(x);
      line:= repolst[x];
      tmp:= stripto(line, ':');
      repdat:= trimleft(line);

      if repdat='true' then
      dm.reposVerifyrepo.AsBoolean:= true
      else
      dm.reposVerifyrepo.AsBoolean:= false;

      inc(x);
      line:= repolst[x];
      tmp:= stripto(line, ':');
      pkgdat:= trimleft(line);

      if pkgdat='true' then
      dm.reposVerifyPkg.AsBoolean:= true
      else
      dm.reposVerifyPkg.AsBoolean:= false;

      infos:= '';

      if inst then
      begin
      inc(x,2);
      line:= repolst[x];
      line:= trimleft(line);
      infos:= infos + line + #10;

      inc(x);
      line:= repolst[x];
      line:= trimleft(line);
      infos:= infos + line + #10;

      inc(x);
      line:= repolst[x];
      line:= trimleft(line);
      infos:= infos + line + #10;

      inc(x);
      line:= repolst[x];
      line:= trimleft(line);
      infos:= infos + line + #10;

      inc(x);
      line:= repolst[x];
      line:= trimleft(line);
      infos:= infos + line;
      end;

      dm.reposinfo.Text:= infos;
      Try
        dm.repos.Post;
      Except
        dm.repos.Cancel;
        Inc(x);
        continue;
      End;

      Inc(x);
    End;

    dm.rcon.Commit;
    repolst.Free;
    dm.rcon.AutoCommit:= true;

    dm.resetdb;
end;

End.
