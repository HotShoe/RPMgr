Program rpmgr;

{$mode objfpc}{$H+}

Uses
    {$IFDEF UNIX}
      cthreads,
    {$ENDIF}
    {$IFDEF HASAMIGA}
      athreads,
    {$ENDIF}
    Interfaces, // this includes the LCL widgetset
    Forms,
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
