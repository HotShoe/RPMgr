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
