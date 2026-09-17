with Ada.Real_Time; use Ada.Real_Time;
with Priority_Inversion;

package body Low_Task is
   task body Low is
      Period : constant Time_Span := Milliseconds (500);
      Next   : Time := Clock + Period;
   begin
      loop
         delay until Next;
         Next := Next + Period;
         Priority_Inversion.Resource.Do_Long_Op;
      end loop;
   end Low;
end Low_Task;
