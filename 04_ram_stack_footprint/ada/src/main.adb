with Ada.Real_Time; use Ada.Real_Time;
with Console;
with Footprint_Tasks;

pragma Unreferenced (Footprint_Tasks);
procedure Main is
   Next : Time := Clock;
begin
   Console.Put_Line ("READY");
   loop
      Next := Next + Seconds (60);
      delay until Next;
   end loop;
end Main;
