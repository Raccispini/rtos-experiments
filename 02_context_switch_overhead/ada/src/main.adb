with Ada.Real_Time; use Ada.Real_Time;
with Console;
with Dispatch_Signaler;
with Dispatch_Target;

pragma Unreferenced (Dispatch_Signaler, Dispatch_Target);
procedure Main is
   Next : Time := Clock;
begin
   Console.Put_Line ("READY");
   loop
      Next := Next + Seconds (60);
      delay until Next;
   end loop;
end Main;
