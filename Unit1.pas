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
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure btnStartClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
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

function IsPrime (n: Integer): boolean;
var
   test: integer;
begin
   //Считаем, что число по умолчанию простое.
   IsPrime := true;
   //Пробуем делить число на другие числа.
   for test := 2 to n - 1 do
      if (n mod test) = 0 then
      begin
         //Если число делится на другое число (кроме 1 или n) без остатка,
         //то число не является простым.
         IsPrime := false;
         //Выходим из цикла.
         break;
      end;
end;

procedure TForm1.btnCancelClick(Sender: TObject);
begin
  //Отменяем выполнение задания.
  if Assigned(task) then
    task.Cancel;
end;

procedure TForm1.btnStartClick(Sender: TObject);
begin
  //Если задание уже есть и оно выполняется, останавливаем его.
  if Assigned(task) and (task.Status = TTaskStatus.Running) then
    task.Cancel;
  //Создаём новое задание.
  task := TTask.Create(procedure()
    var
       task: ITask;
       stopwatch, curPos, maxPos: integer;
    begin
       //Сохраняем ссылку на интерфейс ITask в локальной переменной.
       task := self.task;
       //Обнуляем секундомер.
       stopwatch := 0;
       //Работать с контролами формы нужно из главного потока,
       //поэтому используем метод TThread.Synchronize для синхронного взаимодействия
       //или TThread.Queue - для асинхронного.
       TThread.Synchronize(nil,
          procedure()
          begin
             //Сохраняем максимальное значение прогресс бара в локальной переменной.
             maxPos := Progressbar1.Max;
             //Сбрасываем текущее положение прогресс бара в Progressbar1.Min.
             curPos := Progressbar1.Min;
             Progressbar1.Position := Progressbar1.Min;
             //Сбрасываем показания секундомера.
             Label1.Caption := '0';
          end
       );
       //Выполняем цикл, пока не дойдём до Progressbar1.Max.
       while curPos < maxPos do
       begin
          //Увеличиваем количество секунд в секундомере.
          //Переменная stopwatch локальная, поэтому TInterlocked.Add не используем.
          Inc(stopwatch, 2);
          //Увеличиваем прогресс.
          //Переменная curPos локальная, поэтому TInterlocked.Add не используем.
          Inc(curPos);
          TThread.Synchronize(nil,
             procedure()
             begin
                //Показываем количество пройденных секунд.
                Label1.Caption := stopwatch.ToString;
                //Показываем прогресс.
                Progressbar1.Position := curPos;
             end
          );
          //Спим 2 секунды.
          Sleep(2000);
          //Проверяем, не отменили ли задание.
          if task.Status = TTaskStatus.Canceled then
             //Если отменили, выходим из цикла.
             break;
       end;
    end
  );
  //Стартуем созданное задание.
  task.Start;
end;

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

procedure TForm1.Button3Click(Sender: TObject);
const
  max = 50000;
var
  i, total: integer;
begin
  total := 0;
  for i := 1 to max do
    if IsPrime(i) then
       Inc(total);
  ShowMessage('Количество найденных простых чисел: ' + IntToStr(total));
end;

procedure TForm1.Button4Click(Sender: TObject);
const
  max = 50000;
var
  i, total: integer;
begin
  total := 0;
  TParallel.For(1, max, procedure(i: integer; loopState: TParallel.TLoopState)
     begin
        if IsPrime(i) then
        begin
           System.TMonitor.Enter(self);
           try
              Inc(total);
              if total > 1000 then
                 loopState.Break;
           finally
              System.TMonitor.Exit(self);
           end;
        end;
     end
  );
  ShowMessage('Количество найденных простых чисел: ' + IntToStr(total));;
end;

procedure TForm1.Button5Click(Sender: TObject);
var
  future: IFuture<integer>;
begin
  //Создаём задачу.
  future := TTask.Future<integer>(function: integer
     begin
        Sleep(3000);
        Result := 10;
     end
  );
  //Запускаем задачу.
  future.Start;
  //Узнать результат получится только после завершения задачи: через 3 секунды.
  ShowMessage('Результат: ' + IntToStr(future.Value));
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  //Если форма закрылась, то отменяем выполнение задания, если задание есть и оно выполняется.
  if Assigned(task) and (task.Status = TTaskStatus.Running) then
    task.Cancel;
end;

end.
