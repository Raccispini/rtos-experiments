with Ada.Interrupts.Names;
with System;

package Button_Monitor is
   protected Handler
     with Interrupt_Priority => System.Interrupt_Priority'Last
   is
      procedure Signal
        with Attach_Handler => Ada.Interrupts.Names.GPIOTE_Interrupt;
   end Handler;
end Button_Monitor;
