{Binexec was written by Jem Miller of Missing Link Software in 2025 for the RPMgr
package manager program. This unit was loosely based upon an example in the
Lazarus wiki at: https://wiki.freepascal.org/Executing_External_Programs.

This version has been optimized to use threads for external process execution,
preventing the main application thread from freezing.

You are welcome to modify, distribute, or use these routines as you see fit.
I do want to keep the credits displayed for those that came before you.
}
Unit binexec;

{$mode objfpc}{$H+}

Interface

Uses
  Classes,
  SysUtils,
  Process,
  Forms,
  Controls,
  Graphics,
  Dialogs,
  StdCtrls,
  Math,
  SyncObjs; // Required for TThread and synchronization methods

Const
  BUF_SIZE = 16384; // Buffer size for reading the output in chunks

Type
  opt = Array Of String;

  // A callback procedure type for asynchronous execution results.
  // The sender is the thread that completed, and the exitCode is the process's exit code.
  TExecCompleteEvent = Procedure(Sender: TObject; exitCode: Integer);

  { Tloginfrm }
  Tloginfrm = Class(TForm)
    okbtn : TButton;
    cancelbtn : TButton;
    pwtxt : TEdit;
    Label1 : TLabel;
    Label2 : TLabel;
    logtxt : TLabel;
    Procedure FormShow(Sender : TObject);
    Procedure okbtnClick(Sender : TObject);
    Procedure cancelbtnClick(Sender : TObject);
    Procedure pwtxtKeyPress(Sender : TObject; Var Key : Char);
  Private
  Public
  End;

  { TExecThread }
  // This thread class handles the external process execution in the background.
  TExecThread = Class(TThread)
  private
    FProgram: String;
    FOptions: opt;
    FRootPw: Shortstring;
    FOutputMemo: TMemo;
    FOnComplete: TExecCompleteEvent;

    // Use a critical section for thread-safe access to globals if necessary,
    // although Synchronize() handles this for most UI updates.
    FCriticalSection: TCriticalSection;

    // Procedure to safely update the UI from the thread
    Procedure UpdateMemo;
  protected
    // The main execution method of the thread
    Procedure Execute; override;
  public
    // Constructor to pass all necessary parameters to the thread
    Constructor Create(const AProgram: String; const AOptions: opt;
                       const ARootPw: Shortstring; AOutputMemo: TMemo;
                       const AOnComplete: TExecCompleteEvent);
    procedure OnComplete;
  End;

Var
  loginfrm : Tloginfrm;
  {Errstr and OutP are text output from each call to an exec process. These globals
  are now only populated by the synchronous exec routine.}
  ErrStr,
  OutP : AnsiString;
  admin : shortstring;
  root : Boolean = False;
  user : String;
  errnum : Longint;

{exec is a synchronous, blocking function. It is suitable for short-lived
processes where you want to wait for the result before proceeding, like a login check.}
Function Exec(Pname : String; opts : opt; RootPw : Shortstring = ''; outmem : Tmemo = nil) : Boolean;

{RootExecAsync is an asynchronous, non-blocking procedure. It is the preferred method
for most external process calls, as it keeps the UI responsive. It does not return
a value; instead, it uses a callback to notify the caller upon completion.}
Procedure ExecAsync(Pname : String; opts : opt; RootPw : Shortstring = ''; outmem : Tmemo = nil;
                        OnComplete: TExecCompleteEvent = nil);

Implementation

Uses
  mlstr;

{$R *.lfm}

Var
  ercnt : Byte;
  ok : Boolean;

Procedure Tloginfrm.cancelbtnClick(Sender : TObject);
Begin
  root := False;
  halt(1);
End;

Procedure Tloginfrm.pwtxtKeyPress(Sender : TObject; Var Key : Char);
Begin
  If Key = #13 Then
  Begin
    okbtnClick(nil);
    Key := #0;
  End;
End;

Procedure Tloginfrm.okbtnClick(Sender : TObject);
Begin
  admin := pwtxt.Text;

  // Use the synchronous function for the login check
  ok := exec('ls', ['/root'], admin);

  If Not ok Then
  Begin
    Inc(ercnt);
    ShowMessage('The administrator password is incorrect. ' + I2Str(3 - ercnt) +
      ' tries remaining.');

    If ercnt >= 3 Then
    Begin
      ShowMessage('Password retries exhausted.');
      halt(1);
    End;

    exit;
  End;

  root := True;
  Close;
End;

Procedure Tloginfrm.FormShow(Sender : TObject);
Begin
  // Use the synchronous function for a quick check of the current user
  ok := exec('env', ['whoami']);
  OutP := trim(OutP);
  user := OutP;

  ercnt := 0;
  admin := '';
  root := False;

  If ok Then
    logtxt.Caption := user;

  pwtxt.SetFocus;
End;

//-------------------------------------------------------------
// TExecThread Implementation
//-------------------------------------------------------------

Constructor TExecThread.Create(const AProgram: String; const AOptions: opt;
                               const ARootPw: Shortstring; AOutputMemo: TMemo;
                               const AOnComplete: TExecCompleteEvent);
Begin
  inherited Create(True); // Create the thread in a suspended state
  FreeOnTerminate := True; // The thread will be freed automatically upon completion

  FProgram := AProgram;
  FOptions := AOptions;
  FRootPw := ARootPw;
  FOutputMemo := AOutputMemo;
  FOnComplete := AOnComplete;
end;

// This procedure is called by Synchronize to safely update the UI from the thread.
Procedure TExecThread.UpdateMemo;
Begin
  if Assigned(FOutputMemo) then
  begin
    // Append the global output strings to the memo
    FOutputMemo.Append(OutP);
    FOutputMemo.Append(ErrStr);
  end;
end;

procedure TExecThread.OnComplete;
    begin
      if Assigned(FOnComplete) then
      FOnComplete(Self, errnum);
end;

// This is the main execution loop for the thread.
Procedure TExecThread.Execute;
Var
  AProc : TProcess;
  BytesRead, ErrCnt: Longint;
  Tmp : AnsiString;
  Buffer : Array[1..BUF_SIZE] Of Char;
  ErrBuf : Array[1..BUF_SIZE] Of Char;
  line : string;

Begin
  // Clear the global output variables before starting.
  OutP := '';
  ErrStr := '';
  errnum := 0;

  AProc := TProcess.Create(nil);
  Try
    AProc.Options := [poUsePipes];

    // Safer approach for sudo using TProcess's STDIN
    if FRootPw <> '' then
    begin
      Aproc.Executable := '/bin/sh';
      Aproc.Parameters.Add('-c');
      AProc.Parameters.Add('sudo -S ' + Fprogram);

      for Tmp In FOptions do
        AProc.Parameters.Add(Tmp);
    end
    else
    begin
      AProc.Executable := FProgram;

      for Tmp In FOptions do
        AProc.Parameters.Add(Tmp);
    end;

    // Execute the process
    AProc.Execute;

    // If using sudo, write the password to STDIN
    if FRootPw <> '' then
    begin
      FRootPw:= FRootPw + #10;
      AProc.Input.Write(FRootPw[1], Length(FRootPw) + 1);
    end;

    sleep(30); //sleepy time

    // Main loop to capture output and errors
    repeat
      // Read standard output
      if AProc.Output.NumBytesAvailable > 0 then
      begin
        BytesRead := AProc.Output.Read(Buffer[1], Min(AProc.Output.NumBytesAvailable, BUF_SIZE));
        Tmp := copy(Buffer, 1, BytesRead);
        OutP := OutP + Tmp;
      end;

      // Read standard error
      if AProc.Stderr.NumBytesAvailable > 0 then
      begin
        ErrCnt := AProc.Stderr.Read(ErrBuf[1], Min(AProc.Stderr.NumBytesAvailable, BUF_SIZE));
        Tmp := copy(ErrBuf, 1, ErrCnt);
        ErrStr := ErrStr + Tmp;

        if pos('sudo',tmp) > 0 then
        line:= stripto(tmp,':');
      end;

      // If a memo is assigned, safely update it on the main thread
      if Assigned(FOutputMemo) and
         ((length(OutP) > 0) or (length(ErrStr) > 0)) then
      begin
        Synchronize(@UpdateMemo);
      end;

      Sleep(30); // Yield to other threads and processes

    Until (AProc.Running = false) or
    (AProc.Output.NumBytesAvailable < 1) or
    (AProc.Stderr.NumBytesAvailable < 1);

  Finally
    errnum := AProc.ExitCode;
    AProc.Free;
    AProc := nil;

    // Call the completion callback on the main thread
    if Assigned(FOnComplete) then
      Synchronize(@OnComplete);

  End;

End;


//-------------------------------------------------------------
// RootExec routines
//-------------------------------------------------------------

Function Exec(Pname : String; opts : opt; RootPw : Shortstring = ''; outmem : Tmemo = nil) : Boolean;
Var
  AProc: TProcess;
  Tmp: AnsiString;
  BytesRead,
  bytes,
  ErrCnt: Longint;
  Buffer: array[1..BUF_SIZE] of Char;
  ErrBuf: array[1..BUF_SIZE] of Char;
  line : string;

Begin
  OutP := '';
  ErrStr := '';
  errnum := 0;

  AProc := TProcess.Create(nil);
  try
    AProc.Options := [poUsePipes];

    // Safer approach for sudo using TProcess's STDIN
    if RootPw <> '' then
    begin
      Aproc.Executable := '/bin/sh';
      Aproc.Parameters.Add('-c');
      AProc.Parameters.Add('sudo -S ' + pname);
      //AProc.Parameters.Add('-S');
      //AProc.Parameters.Add(Pname);

      for Tmp In opts do
        AProc.Parameters.Add(Tmp);
    end
    else
    begin
      AProc.Executable := Pname;

      for Tmp In opts do
        AProc.Parameters.Add(Tmp);
    end;

    AProc.Execute;

    if RootPw <> '' then
    begin
      RootPw:= RootPw + #10;
      AProc.Input.Write(RootPw[1], Length(RootPw));
      sleep(1000);
    end;

    sleep(30);

    repeat
      // Read standard output
      bytes:= AProc.Output.NumBytesAvailable;

      if bytes > 0 then
      begin
        BytesRead := AProc.Output.Read(Buffer[1], Min(bytes, BUF_SIZE));
        Tmp := copy(Buffer, 1, BytesRead);
        OutP := OutP + Tmp;

        if Assigned(outmem) then
          outmem.Append(Tmp);
      end;

      until (bytes < 1);

      repeat
      // Read standard error
      errcnt:= AProc.Stderr.NumBytesAvailable;

      if errcnt > 0 then
      begin
        ErrCnt := AProc.Stderr.Read(ErrBuf[1], Min(errcnt, BUF_SIZE));
        Tmp := copy(ErrBuf, 1, ErrCnt);

        if pos('sudo',tmp) > 0 then
        line:= stripto(tmp,':');

        ErrStr := ErrStr + tmp;
        outp:= outp + errstr;

        if Assigned(outmem) then
          outmem.Append(Tmp);
      end;

      until (errcnt < 1);

      Application.ProcessMessages;
      Sleep(30);

  finally
    errnum := AProc.ExitCode;
    AProc.Free;
    aproc:= nil;
  end;

  // The result is based solely on the exit code
  Result := (errnum = 0); // or (outp <> '');
End;

Procedure ExecAsync(Pname : String; opts : opt; RootPw : Shortstring = ''; outmem : Tmemo = nil;
                        OnComplete: TExecCompleteEvent = nil);
Var
  Thread: TExecThread;
Begin
  Thread := TExecThread.Create(Pname, opts, RootPw, outmem, OnComplete);
  Thread.Start;
End;

End.
