with Ada.Real_Time; use Ada.Real_Time;
with Interfaces;    use Interfaces;
with Production_Workload;
with Cycle_Counter;
with Shared_Value;
with Consumer_Channel;
with Auxiliary;
with Console;

package body Periodic_Producer is
   task body Producer is
      Period : constant Time_Span := Milliseconds (1000);
      Next   : Time := Clock + Period;
      T0, T1 : Interfaces.Unsigned_32;
   begin
      loop
         delay until Next;
         Next := Next + Period;
         T0 := Cycle_Counter.Get;
         Production_Workload.Small_Whetstone (50);
         T1 := Cycle_Counter.Get;
         Shared_Value.Store.Set (T1 - T0);
         Console.Put_Line ("PRODUCER_COST=" & Auxiliary.Cycles_Image (T1 - T0));
         if Auxiliary.Check_Due then
            Consumer_Channel.Handler.Notify;
         end if;
      end loop;
   end Producer;
end Periodic_Producer;
