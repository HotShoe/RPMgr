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

Program rpmgr;

{$mode objfpc}{$H+}

Uses
    {$IFDEF UNIX}
      cthreads,
      clocale,
    {$ENDIF}
    {$IFDEF HASAMIGA}
      athreads,
    {$ENDIF}
    Interfaces, // this includes the LCL widgetset
    Forms,
    lhelpcontrolpkg,
    lcltranslator,
    main,
    Data,
    notes,
    globs,
    updates,
    files,
    installed,
    search,
    config,
    about,
    apply,
    actions,
    binexec,
    license,
    repo,
    addrepo;

    {$R *.res}

Begin
    RequireDerivedFormResource := True;
  Application.Scaled:= True;
    Application.Initialize;
    Application.CreateForm(Tmainfrm , mainfrm);
    Application.CreateForm(Tdm , dm);
    Application.CreateForm(Tcfgfrm , cfgfrm);
    Application.CreateForm(Tnotefrm , notefrm);
    Application.CreateForm(Tupfrm , upfrm);
    Application.CreateForm(Tfilefrm , filefrm);
    Application.CreateForm(Tinstfrm , instfrm);
    Application.CreateForm(Tsrchfrm , srchfrm);
    Application.CreateForm(Taboutfrm , aboutfrm);
    Application.CreateForm(Tapplyfrm , applyfrm);
    Application.CreateForm(Tactfrm , actfrm);
    Application.CreateForm(Tloginfrm , loginfrm);
    Application.CreateForm(Tlicfrm , licfrm);
    Application.CreateForm(Trepofrm , repofrm);
    Application.CreateForm(Taddrepofrm , addrepofrm);
    Application.Run;
End.
