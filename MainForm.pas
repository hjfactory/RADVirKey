unit MainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Touch.Keyboard, Vcl.StdCtrls;

type
  TfrmMain = class(TForm)
    btnF9: TButton;
    btnClose: TButton;
    btnF12: TButton;
    btnCF9: TButton;
    btnSF9: TButton;
    btnCF2: TButton;
    procedure btnVirKeyClick(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure btnCloseClick(Sender: TObject);
  private
    { Private declarations }
    procedure VirtualKeyPress(Keys: TArray<Byte>);
    procedure WMActivate(var Message: TWMActivate); message WM_ACTIVATE;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

{ TForm3 }

procedure TfrmMain.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmMain.btnVirKeyClick(Sender: TObject);

var
  Keys: TArray<Byte>;
begin
  var S: string := TButton(Sender).Caption;
  var SKeys := S.Split(['+']);

  SetLength(Keys, Length(SKeys));

  var SKeyToKey: TFunc<string, Byte> := function(S: string): Byte
    begin
      case S[1] of
      'S': Exit(VK_SHIFT);
      'C': Exit(VK_CONTROL);
      'F':
        begin
          var N: Integer := StrToIntDef(S.Substring(1), 0)-1;
          if N < 0 then
            raise Exception.Create('Incorrect Key');

          Exit(VK_F1 + N);
        end;
      end;
    end;

  for var I := Low(SKeys) to High(SKeys) do
    Keys[I] := SKeyToKey(SKeys[I]);

  VirtualKeyPress(Keys);
end;

procedure TfrmMain.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
  begin
    ExStyle   := ExStyle or WS_EX_NOACTIVATE;
    WndParent := GetDesktopwindow;
  end;
end;

procedure TfrmMain.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  ReleaseCapture;
  Perform(WM_SYSCOMMAND, $f012, 0);
end;

procedure TfrmMain.VirtualKeyPress(Keys: TArray<Byte>);
var
  Key: Byte;
begin
  for Key in Keys do
  begin
    Keybd_Event(Key, MapVirtualKey(Key, 0), 0, 0);
    OutputDebugString(PChar(Format('KeyDown: %d', [Key])));
  end;

  for var I := High(Keys) downto Low(Keys) do
  begin
    Key := Keys[I];
    Keybd_Event(Key, MapVirtualKey(Key, 0), KEYEVENTF_KEYUP, 0);
    OutputDebugString(PChar(Format('KeyUp: %d', [Key])));
  end;
end;

procedure TfrmMain.WMActivate(var Message: TWMActivate);
begin
  inherited;

  with Self do
    SetWindowPos(Handle, HWND_TOPMOST, Left, Top, Width, Height, SWP_NOACTIVATE);
end;

end.
