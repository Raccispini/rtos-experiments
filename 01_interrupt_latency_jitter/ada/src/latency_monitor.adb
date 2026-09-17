with Interfaces; use Interfaces;
with Cycle_Counter;
with Console;
with Auxiliary;
with Gpiote_Driver;

package body Latency_Monitor is
   protected body Handler is
      procedure Signal is
         Cycles : constant Unsigned_32 := Cycle_Counter.Get;
      begin
         Gpiote_Driver.Clear_Event;
         Console.Put_Line ("CYCLES=" & Auxiliary.Cycles_Image (Cycles));
      end Signal;
   end Handler;
end Latency_Monitor;
