with Console;
with Gpiote_Driver;

package body Button_Monitor is
   protected body Handler is
      procedure Signal is
      begin
         Gpiote_Driver.Clear_Event;
         Console.Put_Line ("BUTTON_EVENT");
      end Signal;
   end Handler;
end Button_Monitor;
