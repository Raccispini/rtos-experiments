with Cycle_Counter;
with Production_Workload;
with Ada.Synchronous_Task_Control; use Ada.Synchronous_Task_Control;

package body Priority_Inversion is
   protected body Resource is

      procedure Do_Long_Op is
      begin
         T_Ready := Cycle_Counter.Get;
         Set_True (Medium_Go);
         Set_True (High_Go);
         Production_Workload.Small_Whetstone (50);
      end Do_Long_Op;

      procedure Quick_Op is
      begin
         null;
      end Quick_Op;

   end Resource;
end Priority_Inversion;
