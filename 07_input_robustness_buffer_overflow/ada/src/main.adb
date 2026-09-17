with Ada.Real_Time; use Ada.Real_Time;
with Console;
with Packet_Source;
with Packet_Consumer;

pragma Unreferenced (Packet_Source, Packet_Consumer);
procedure Main is
   Next : Time := Clock;
begin
   Console.Put_Line ("READY");
   loop
      Next := Next + Seconds (60);
      delay until Next;
   end loop;
end Main;
