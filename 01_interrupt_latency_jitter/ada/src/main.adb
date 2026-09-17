with Ada.Real_Time; use Ada.Real_Time;
with Console;
with Background_Load;
with Latency_Monitor;

pragma Unreferenced (Background_Load, Latency_Monitor);
procedure Main is
   Next : Time := Clock;
begin
   Console.Put_Line ("READY");
   loop
      Next := Next + Seconds (60);
      delay until Next;
   end loop;
end Main;
