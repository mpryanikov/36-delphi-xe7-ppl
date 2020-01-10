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
   //Создаём задачу.
   task := TTask.Create(procedure ()
      begin
         //Выполняем задачу 3 секунды.
         Sleep(3000);
         //Задача выполнена!
         ShowMessage('Задача выполнена!');
      end);
   //Запускаем задачу.
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
               //Выполняем задачу 5 секунд.
               Sleep(5000);
               //Добавляем к результату 5000.
               TInterlocked.Add(value, 5000);
            end
         ),
         TTask.Create(procedure()
            begin
               //Выполняем задачу 3 секунды.
               Sleep(3000);
               //Добавляем к результату 3000.
               TInterlocked.Add(value, 3000);
            end
         )
      ];
   end;

begin
   //Создаём задачи и инициализируем переменную value.
   CreateTasks;
   //Запускаем все задачи в массиве.
   for task in tasks do
      task.Start;
   //Ждём выполнение всех задач.
   TTask.WaitForAll(tasks);
   //Результат будет 8000.
   ShowMessage('Все задания выполнены. Результат: ' + IntToStr(value));
   //Создаём задачи и инициализируем переменную value.
   CreateTasks;
   //Запускаем все задачи в массиве.
   for task in tasks do
      task.Start;
   //Ждём выполнение любой из задач.
   TTask.WaitForAny(tasks);
   //Результат будет 3000.
   ShowMessage('Все задания выполнены. Результат: ' + IntToStr(value));
end;

end.
