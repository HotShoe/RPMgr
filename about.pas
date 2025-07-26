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

unit about;

{$mode ObjFPC}{$H+}

interface

uses
 Classes,SysUtils,Forms,Controls,Graphics,Dialogs,StdCtrls,ExtCtrls,ComCtrls,
 BCButton;

type

 { Taboutfrm }

 Taboutfrm = class(TForm)
  licbtn: TBCButton;
  closebtn: TBCButton;
  Memo1: TMemo;
  Memo2: TMemo;
  Pages: TPageControl;
  Panel1: TPanel;
  Tab1: TTabSheet;
  Tab2: TTabSheet;
  procedure closebtnClick(Sender: TObject);
  procedure FormShow(Sender: TObject);
  procedure licbtnClick(Sender: TObject);
 private

 public

 end;

var
 aboutfrm: Taboutfrm;

implementation
uses
    license;

{$R *.lfm}

{ Taboutfrm }

procedure Taboutfrm.closebtnClick(Sender: TObject);
begin
     close;
end;

procedure Taboutfrm.FormShow(Sender: TObject);
begin
     pages.ActivePage:= Tab1;
end;

procedure Taboutfrm.licbtnClick(Sender: TObject);
begin
     licfrm.ShowModal;
end;

end.

