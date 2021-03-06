unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, System.Threading, System.SyncObjs,
  Vcl.ComCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    btnStart: TButton;
    btnCancel: TButton;
    Label1: TLabel;
    ProgressBar1: TProgressBar;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure btnStartClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    task: ITask;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.btnCancelClick(Sender: TObject);
begin
  //�������� ���������� �������.
  if Assigned(task) then
    task.Cancel;
end;

procedure TForm1.btnStartClick(Sender: TObject);
begin
  //���� ������� ��� ���� � ��� �����������, ������������� ���.
  if Assigned(task) and (task.Status = TTaskStatus.Running) then
    task.Cancel;
  //������ ����� �������.
  task := TTask.Create(procedure()
    var
       task: ITask;
       stopwatch, curPos, maxPos: integer;
    begin
       //��������� ������ �� ��������� ITask � ��������� ����������.
       task := self.task;
       //�������� ����������.
       stopwatch := 0;
       //�������� � ���������� ����� ����� �� �������� ������,
       //������� ���������� ����� TThread.Synchronize ��� ����������� ��������������
       //��� TThread.Queue - ��� ������������.
       TThread.Synchronize(nil,
          procedure()
          begin
             //��������� ������������ �������� �������� ���� � ��������� ����������.
             maxPos := Progressbar1.Max;
             //���������� ������� ��������� �������� ���� � Progressbar1.Min.
             curPos := Progressbar1.Min;
             Progressbar1.Position := Progressbar1.Min;
             //���������� ��������� �����������.
             Label1.Caption := '0';
          end
       );
       //��������� ����, ���� �� ����� �� Progressbar1.Max.
       while curPos < maxPos do
       begin
          //����������� ���������� ������ � �����������.
          //���������� stopwatch ���������, ������� TInterlocked.Add �� ����������.
          Inc(stopwatch, 2);
          //����������� ��������.
          //���������� curPos ���������, ������� TInterlocked.Add �� ����������.
          Inc(curPos);
          TThread.Synchronize(nil,
             procedure()
             begin
                //���������� ���������� ���������� ������.
                Label1.Caption := stopwatch.ToString;
                //���������� ��������.
                Progressbar1.Position := curPos;
             end
          );
          //���� 2 �������.
          Sleep(2000);
          //���������, �� �������� �� �������.
          if task.Status = TTaskStatus.Canceled then
             //���� ��������, ������� �� �����.
             break;
       end;
    end
  );
  //�������� ��������� �������.
  task.Start;
end;

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

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  //���� ����� ���������, �� �������� ���������� �������, ���� ������� ���� � ��� �����������.
  if Assigned(task) and (task.Status = TTaskStatus.Running) then
    task.Cancel;
end;

end.
