with Ada.Real_Time; use Ada.Real_Time;

package body Footprint_Tasks is

   task body Task_A is
      Next : Time := Clock;
   begin
      loop
         Next := Next + Seconds (1);
         delay until Next;
      end loop;
   end Task_A;

   task body Task_B is
      Next : Time := Clock;
   begin
      loop
         Next := Next + Seconds (1);
         delay until Next;
      end loop;
   end Task_B;

   task body Task_C is
      Next : Time := Clock;
   begin
      loop
         Next := Next + Seconds (1);
         delay until Next;
      end loop;
   end Task_C;

   task body Task_D is
      Next : Time := Clock;
   begin
      loop
         Next := Next + Seconds (1);
         delay until Next;
      end loop;
   end Task_D;

end Footprint_Tasks;
