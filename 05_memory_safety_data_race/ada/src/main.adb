with Ada.Real_Time; use Ada.Real_Time;
with Console;
with Safety_Scenarios;
with Racer_Low;
with Racer_High;

pragma Unreferenced (Racer_Low, Racer_High);
procedure Main is
   Next : Time := Clock;
begin
   Console.Put_Line ("READY");
   Safety_Scenarios.Run_Out_Of_Range_Demo;
   Safety_Scenarios.Run_Overflow_Demo;
   loop
      Next := Next + Seconds (60);
      delay until Next;
   end loop;
end Main;
