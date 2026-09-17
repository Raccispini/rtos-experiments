with Shared_Value;
with Consumer_Channel;
with Auxiliary;
with Console;

package body Periodic_Consumer is
   task body Consumer is
   begin
      loop
         Consumer_Channel.Handler.Wait;
         Console.Put_Line
           ("CONSUMER_READ=" & Auxiliary.Cycles_Image (Shared_Value.Store.Get));
      end loop;
   end Consumer;
end Periodic_Consumer;
