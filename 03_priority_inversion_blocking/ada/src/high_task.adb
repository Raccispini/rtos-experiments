with Interfaces; use Interfaces;
with Ada.Synchronous_Task_Control; use Ada.Synchronous_Task_Control;
with Priority_Inversion;
with Cycle_Counter;
with Console;
with Auxiliary;

package body High_Task is
   task body High is
   begin
      loop
         Suspend_Until_True (Priority_Inversion.High_Go);
         Priority_Inversion.Resource.Quick_Op;
         declare
            Now : constant Unsigned_32 := Cycle_Counter.Get;
         begin
            Console.Put_Line
              ("HIGH_BLOCKING=" &
               Auxiliary.Cycles_Image (Now - Priority_Inversion.T_Ready));
         end;
      end loop;
   end High;
end High_Task;
