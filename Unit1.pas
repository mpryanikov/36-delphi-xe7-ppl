unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, System.Threading;

type
  TForm1 = class(TForm)
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
var
   task: ITask;
begin
   //������ ������.
   task := TTask.Create(procedure ()
      begin
         //��������� ������ 3 �������.
         Sleep(3000);
         //������ ���������!
         ShowMessage('������ ���������!');
      end);
   //��������� ������.
   task.Start;
end;

end.
