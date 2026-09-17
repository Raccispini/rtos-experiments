with Ada.Real_Time; use Ada.Real_Time;
with Console;
with Priority_Inversion;
with Low_Task;
with Medium_Task;
with High_Task;

pragma Unreferenced (Priority_Inversion, Low_Task, Medium_Task, High_Task);
procedure Main is
   Next : Time := Clock;
begin
   Console.Put_Line ("READY");
   loop
      Next := Next + Seconds (60);
      delay until Next;
   end loop;
end Main;
