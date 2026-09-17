with Ada.Real_Time; use Ada.Real_Time;
with Cycle_Counter;
with Dispatch_Channel;

package body Dispatch_Signaler is
   task body Signaler is
      Period : constant Time_Span := Milliseconds (100);
      Next   : Time := Clock + Period;
   begin
      loop
         delay until Next;
         Next := Next + Period;
         Dispatch_Channel.Handler.Signal (Cycle_Counter.Get);
      end loop;
   end Signaler;
end Dispatch_Signaler;
