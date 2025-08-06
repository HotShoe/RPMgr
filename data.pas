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

Unit Data;

{$mode ObjFPC}{$H+}

Interface

Uses
    Classes,
    SysUtils,
    fileutil,
    Dialogs,
    forms,
    DB,
    SQLite3Conn,
    ZConnection,
    ZDataset,
    ZAbstractRODataset,
    ZSqlProcessor;

Type

    { Tdm }

    Tdm = Class(TDataModule)
      reposBaseURL : TZRawStringField;
      reposConfig : TZRawStringField;
      reposInfo : TZRawStringField;
      reposKeys : TZRawStringField;
      reposMetaLink : TZRawStringField;
      reposName : TZRawStringField;
      reposrc : TDataSource;
      inst :    TZQuery;
      instsrc : TDataSource;
      pkgArch : TZRawStringField;
      pkgDesc : TZRawStringField;
      pkgGrp :  TZRawStringField;
      pkgInstalled : TZBooleanField;
      pkgisize : TZRawStringField;
      pkgName : TZRawStringField;
      pkgpsize : TZRawStringField;
      pkgVersion : TZRawStringField;
      psrcArch : TZRawStringField;
      psrcDesc : TZRawStringField;
      psrcGrp : TZRawStringField;
      psrcInstalled : TZBooleanField;
      psrcName : TZRawStringField;
      psrcVersion : TZRawStringField;
      reposRepoID : TZRawStringField;
      reposStatus : TZRawStringField;
      reposType : TZRawStringField;
      reposVerifyPkg : TZBooleanField;
      reposVerifyRepo : TZBooleanField;
      ssrc :    TDataSource;
      qs :      TDataSource;
      grpdesc : TZRawStringField;
      grpinstalled : TZBooleanField;
      grpname : TZRawStringField;
      grpsrc :  TDataSource;
      pkgsrc :  TDataSource;
      rcon :    TZConnection;
      grp :     TZTable;
      query :   TZQuery;
      pkg :     TZTable;
      psrc :    TZQuery;
      repos :   TZTable;
      Procedure DataModuleCreate(Sender: TObject);
      Procedure grpsrcDataChange(Sender: TObject; Field: TField);
      Procedure pkgsrcDataChange(Sender: TObject; Field: TField);
    private

    public
      //Procedure createdb;
      procedure initdb;
      Procedure resetdb;
      Procedure closedb;
      procedure newdb;
    End;

Var
    dm :     Tdm;
    sqlstr : String;

Implementation

Uses
    globs,
    mlstr,
    binexec;

    {$R *.lfm}

    { Tdm }

Procedure Tdm.DataModuleCreate(Sender: TObject);
Begin

End;

procedure Tdm.initdb;
begin
    if not directoryexists(dbdir) then
     newdb;

     rcon.Database:= dbdir+'rpmgr.db';
     rcon.DesignConnection:= false;
     rcon.Connect;

    rcon.ExecuteDirect('PRAGMA journal_mode = WAL');
    rcon.ExecuteDirect('PRAGMA syncronous = NORMAL;');
    rcon.ExecuteDirect('PRAGMA cache_size = 1024000;');
    rcon.ExecuteDirect('PRAGMA locking_mode = NORMAL;');
    rcon.ExecuteDirect('PRAGMA temp_store = DAFAULT;');

    pkg.Active:= True;
    tot:= pkg.RecordCount;
    grp.Active:= True;
    repos.Active:= True;
    query.Active:= True;

end;

Procedure Tdm.grpsrcDataChange(Sender: TObject; Field: TField);
Begin
    curgrp:= grpname.Text;
    pkg.First;
End;

Procedure Tdm.pkgsrcDataChange(Sender: TObject; Field: TField);
Begin
    curpkg:= pkgname.Text;
End;

Procedure Tdm.resetdb;
Begin
    rcon.AutoCommit:= True;
    rcon.Connected:= False;
    rcon.Connected:= True;

    rcon.ExecuteDirect('PRAGMA journal_mode = WAL');
    rcon.ExecuteDirect('PRAGMA syncronous = NORMAL;');
    rcon.ExecuteDirect('PRAGMA cache_size = 1024000;');
    rcon.ExecuteDirect('PRAGMA locking_mode = NORMAL;');
    rcon.ExecuteDirect('PRAGMA temp_store = DAFAULT;');

    pkg.Active:= True;
    grp.Active:= True;
    repos.Active:= True;
End;

Procedure Tdm.closedb;
Begin
    rcon.Connected:= False;
End;

procedure Tdm.newdb;
var
    dbfile,
    dropsql,
    tblsql : ansistring;

begin
    //dbfile:= '/usr/share/rpmgr/rpmgr.db';
    //dropsql:= 'BEGIN TRANSACTION' +
    //'DROP TABLE "groups";' +
    //'DROP TABLE "packages";' +
    //'DROP TABLE "repo";' +
    //'COMMIT;';
    //
    //tblsql:= 'BEGIN TRANSACTION;' +
    //'CREATE TABLE IF NOT EXISTS "groups" (' +
    //	'"name"	varchar(100) NOT NULL UNIQUE,' +
    //	'"desc"	varchar(1000) NOT NULL,'+
    //	'"installed"	boolean NOT NULL DEFAULT '+'''false'',' +
    //	'PRIMARY KEY("name","installed")' +
    //');' +
    //'CREATE TABLE IF NOT EXISTS "packages" (' +
    //	'"Installed"	boolean NOT NULL DEFAULT '+'''false'',' +
    //	'"Name"	varchar(100) NOT NULL UNIQUE,' +
    //	'"Version"	varchar(100) NOT NULL,' +
    //	'"Desc"	varchar(1000) NOT NULL,' +
    //	'"Arch"	varchar(50) NOT NULL DEFAULT '+'''noarch'',' +
    //	'"Grp"	varchar(100),' +
    //	'"isize"	varchar(20) NOT NULL DEFAULT '+'''0.0 Kib'',' +
    //	'"psize"	varchar(20) NOT NULL DEFAULT '+'''0.0 Kib'',' +
    //	'PRIMARY KEY("Name")' +
    //');' +
    //'CREATE TABLE IF NOT EXISTS "repo" (' +
    //	'"RepoID"	varchar(200) NOT NULL UNIQUE,' +
    //	'"Name"	varchar(500) NOT NULL UNIQUE,' +
    //	'"Status"	varchar(20) NOT NULL DEFAULT '+'''Enabled'',' +
    //	'"Type"	varchar(25) NOT NULL DEFAULT '+'''Available'',' +
    //	'"Config"	varchar(400) NOT NULL,' +
    //	'"BaseURL"	varchar(1000) NOT NULL,' +
    //	'"MetaLink"	varchar(1000),' +
    //	'"Keys"	varchar(1000) NOT NULL,' +
    //	'"VerifyRepo"	boolean NOT NULL DEFAULT '+'''False'',' +
    //	'"VerifyPkg"	boolean NOT NULL DEFAULT '+'''True'',' +
    //	'"Info"	varchar(1000),' +
    //	'PRIMARY KEY("Name","RepoID")' +
    //');' +
    //'COMMIT;';

    if not directoryexists(dbdir) then
     begin
      ok:= rootexec(cmd+'mkdir '+dbdir,admin);
     end;

    if not ok then
      begin
        showmessage('Cannot create the rpmgr database. Error #'+i2str(errnum)+' '+errstr+' Run setup?');

        halt(errnum);
      end;

end;

initialization

    i:= lastpos('/',application.Params[0]);

    homedir:= application.EnvironmentVariable['HOME'] + '/';
    mydir:= getcurrentdir + '/';
    cfgdir:= homedir + '.config/rpmgr/';
    dbdir:= '/usr/share/rpmgr/';

    if loginfrm = nil then
    loginfrm:= Tloginfrm.Create(nil);

    loginfrm.ShowModal;

    If not directoryexists(dbdir) Then
    ok:= rootexec(cmd+'mkdir '+dbdir,admin);

    if not fileexists(dbdir+'rpmgr.db') then
      dm.newdb;

End.
