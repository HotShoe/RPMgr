unit passwd;

{$mode ObjFPC}{$H+}

interface

uses
      Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, BCButton,
      process;

type

	  { Tpwfrm }

      Tpwfrm = class(TForm)
			pwbtn: TBCButton;
			pwtxt: TEdit;
			Label1: TLabel;
			procedure pwbtnClick(Sender: TObject);
      private

      public

      end;

var
      pwfrm: Tpwfrm;

implementation

{$R *.lfm}

{ Tpwfrm }

procedure Tpwfrm.pwbtnClick(Sender: TObject);
begin
      //runcommand('/usr/bin/sudo -a',o)
end;

end.

