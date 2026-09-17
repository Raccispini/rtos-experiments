with Ada.Real_Time; use Ada.Real_Time;
with Console;
with Periodic_Producer;
with Periodic_Consumer;
with Button_Monitor;

pragma Unreferenced (Periodic_Producer, Periodic_Consumer, Button_Monitor);
procedure Main is
   Next : Time := Clock;
begin
   Console.Put_Line ("READY");
   loop
      Next := Next + Seconds (60);
      delay until Next;
   end loop;
end Main;
