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

Unit files;

{$mode ObjFPC}{$H+}

Interface

Uses
    Classes,
    SysUtils,
    Forms,
    Controls,
    Graphics,
    Dialogs,
    ExtCtrls,
    StdCtrls,
    BCButton;

Type

    { Tfilefrm }

    Tfilefrm = Class(TForm)
      closebtn: TBCButton;
      filememo: TMemo;
      Panel1: TPanel;
      Procedure closebtnClick(Sender: TObject);
      Procedure FormShow(Sender: TObject);
    private

    public

    End;

Var
    filefrm: Tfilefrm;

Implementation

Uses
    globs,
    Data,
    notes;

    {$R *.lfm}

    { Tfilefrm }

Procedure Tfilefrm.closebtnClick(Sender: TObject);
Begin
    Close;
End;

Procedure Tfilefrm.FormShow(Sender: TObject);
Begin
    ok:= list_files(curpkg);

    If not ok Then
    Begin
      notefrm.normal(curpkg+
        ' is not installed. Only installed packages can have their contents displayed.');
      Close;
      exit;
    End;

    filememo.Clear;
    filememo.Text:= filelst.Text;
End;

End.
