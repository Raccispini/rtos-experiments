with Ada.Real_Time; use Ada.Real_Time;
with Interfaces;    use Interfaces;
with Race_State;

package body Racer_Low is
   task body Low is
      N_Low : constant := 300_000;
   begin
      for I in 1 .. N_Low loop
         Race_State.Shared_Counter := Race_State.Shared_Counter + 1;
      end loop;
      loop
         delay until Clock + Seconds (3600);
      end loop;
   end Low;
end Racer_Low;
