with Interfaces; use Interfaces;
with Ada.Synchronous_Task_Control; use Ada.Synchronous_Task_Control;
with Priority_Inversion;
with Cycle_Counter;
with Console;
with Auxiliary;

package body Medium_Task is
   task body Medium is
   begin
      loop
         Suspend_Until_True (Priority_Inversion.Medium_Go);
         declare
            Now : constant Unsigned_32 := Cycle_Counter.Get;
         begin
            Console.Put_Line
              ("MEDIUM_DELAY=" &
               Auxiliary.Cycles_Image (Now - Priority_Inversion.T_Ready));
         end;
      end loop;
   end Medium;
end Medium_Task;
