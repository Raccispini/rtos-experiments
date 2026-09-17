with Production_Workload;
with Ada.Real_Time; use Ada.Real_Time;

package body Background_Load is

   Period : constant Time_Span := Milliseconds (100);

   task body Load is
      Period_Start : Time;
      Busy_Until   : Time;
      Next         : Time;
   begin
      if Duty_Percent >= 100 then
         loop
            Production_Workload.Small_Whetstone (1000);
         end loop;
      else
         Next := Clock;
         loop
            Period_Start := Next;
            Next := Next + Period;

            if Duty_Percent > 0 then
               Busy_Until := Period_Start + Period * Duty_Percent / 100;
               while Clock < Busy_Until loop
                  Production_Workload.Small_Whetstone (50);
               end loop;
            end if;

            while Clock < Next loop
               null;
            end loop;
         end loop;
      end if;
   end Load;
end Background_Load;
