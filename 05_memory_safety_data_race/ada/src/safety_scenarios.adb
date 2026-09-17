with Console;         use Console;
with Ada.Exceptions;  use Ada.Exceptions;

package body Safety_Scenarios is

   type Tiny is range -128 .. 127;

   type Small_Array is array (1 .. 5) of Integer;

   procedure Run_Out_Of_Range_Demo is
      Buf       : Small_Array := (others => 0);

      Bad_Index : Integer := 6
        with Volatile;
   begin
      Buf (Bad_Index) := 42;
      Console.Put_Line
        ("SCENARIO_2_NO_ERROR value=" & Integer'Image (Buf (Bad_Index)));
   exception
      when Error : others =>
         Console.Put_Line ("SCENARIO_2_EXCEPTION=" & Exception_Name (Error));
   end Run_Out_Of_Range_Demo;

   procedure Run_Overflow_Demo is
      X : Tiny := Tiny'Last
        with Volatile;
      Y : Tiny;
   begin
      Y := X + 1;
      Console.Put_Line ("SCENARIO_3_NO_ERROR value=" & Tiny'Image (Y));
   exception
      when Error : others =>
         Console.Put_Line ("SCENARIO_3_EXCEPTION=" & Exception_Name (Error));
   end Run_Overflow_Demo;

end Safety_Scenarios;
