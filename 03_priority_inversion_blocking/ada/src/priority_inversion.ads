with Interfaces;
with Ada.Synchronous_Task_Control;

package Priority_Inversion is

   T_Ready : Interfaces.Unsigned_32 := 0;

   Medium_Go : Ada.Synchronous_Task_Control.Suspension_Object;
   High_Go   : Ada.Synchronous_Task_Control.Suspension_Object;

   protected Resource
     with Priority => 3
   is
      procedure Do_Long_Op;
      procedure Quick_Op;
   end Resource;

end Priority_Inversion;
