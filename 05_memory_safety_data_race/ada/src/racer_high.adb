with Ada.Real_Time; use Ada.Real_Time;
with Interfaces;    use Interfaces;
with Race_State;
with Console;
with Auxiliary;

package body Racer_High is
   task body High is
      Period   : constant Time_Span := Milliseconds (20);
      Next     : Time := Clock + Period;
      N_High   : constant := 50;
      N_Low    : constant := 300_000;
      Expected : constant Unsigned_32 := Unsigned_32 (N_Low + N_High);
   begin
      for I in 1 .. N_High loop
         delay until Next;
         Next := Next + Period;
         Race_State.Shared_Counter := Race_State.Shared_Counter + 1;
      end loop;
      Console.Put_Line
        ("SHARED_COUNTER_FINAL=" & Auxiliary.Cycles_Image (Race_State.Shared_Counter)
         & " EXPECTED=" & Auxiliary.Cycles_Image (Expected));
      loop
         delay until Clock + Seconds (3600);
      end loop;
   end High;
end Racer_High;
