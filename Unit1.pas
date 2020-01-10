unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, System.Threading, System.SyncObjs;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
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

procedure TForm1.Button2Click(Sender: TObject);
var
   tasks: array of ITask;
   task: ITask;
   value: integer;

   procedure CreateTasks;
   begin
      value := 0;
      tasks := [
         TTask.Create(procedure()
            begin
               //��������� ������ 5 ������.
               Sleep(5000);
               //��������� � ���������� 5000.
               TInterlocked.Add(value, 5000);
            end
         ),
         TTask.Create(procedure()
            begin
               //��������� ������ 3 �������.
               Sleep(3000);
               //��������� � ���������� 3000.
               TInterlocked.Add(value, 3000);
            end
         )
      ];
   end;

begin
   //������ ������ � �������������� ���������� value.
   CreateTasks;
   //��������� ��� ������ � �������.
   for task in tasks do
      task.Start;
   //��� ���������� ���� �����.
   TTask.WaitForAll(tasks);
   //��������� ����� 8000.
   ShowMessage('��� ������� ���������. ���������: ' + IntToStr(value));
   //������ ������ � �������������� ���������� value.
   CreateTasks;
   //��������� ��� ������ � �������.
   for task in tasks do
      task.Start;
   //��� ���������� ����� �� �����.
   TTask.WaitForAny(tasks);
   //��������� ����� 3000.
   ShowMessage('��� ������� ���������. ���������: ' + IntToStr(value));
end;

end.
