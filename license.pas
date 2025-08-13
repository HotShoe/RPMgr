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

unit license;

{$mode ObjFPC}{$H+}

interface

uses
 Classes,SysUtils,Forms,Controls,Graphics,Dialogs,StdCtrls,ExtCtrls,BCButton;

type

 { Tlicfrm }

 Tlicfrm = class(TForm)
  BCButton1: TBCButton;
  Memo1: TMemo;
  Panel1: TPanel;
  procedure BCButton1Click(Sender: TObject);
  procedure FormCreate(Sender: TObject);
 private

 public

 end;

var
 licfrm: Tlicfrm;

implementation

{$R *.lfm}

{ Tlicfrm }

procedure Tlicfrm.BCButton1Click(Sender: TObject);
begin
     close;
end;

procedure Tlicfrm.FormCreate(Sender: TObject);
begin
     memo1.Lines.LoadFromFile('/usr/share/licenses/rpmgr/LICENSE');
end;

end.

