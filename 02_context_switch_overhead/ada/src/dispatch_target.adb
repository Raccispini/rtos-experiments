with Interfaces; use Interfaces;
with Dispatch_Channel;
with Cycle_Counter;
with Console;
with Auxiliary;

package body Dispatch_Target is
   task body Target is
      Before : Unsigned_32;
      Now    : Unsigned_32;
   begin
      loop
         Dispatch_Channel.Handler.Wait (Before);
         Now := Cycle_Counter.Get;
         Console.Put_Line ("CYCLES=" & Auxiliary.Cycles_Image (Now - Before));
      end loop;
   end Target;
end Dispatch_Target;
