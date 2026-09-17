with Ada.Numerics.Elementary_Functions;
use Ada.Numerics.Elementary_Functions;

with Ada.Exceptions; use Ada.Exceptions;
with Console;

package body Production_Workload is

  subtype Whet_Float is Float;

  procedure Small_Whetstone(Kilo_Whets : in Positive) is

    T  : constant := 0.499975;
    T1 : constant := 0.50025;
    T2 : constant := 2.0;

    N8 : constant := 10;
    N9 : constant :=  7;

    Value     : constant := 0.941377;
    Tolerance : constant := 0.00001;

    I   : Integer;
    IJ  : Integer := 1;
    IK  : Integer := 2;
    IL  : Integer := 3;

    Y   : constant Whet_Float := 1.0;
    Z   : Whet_Float;
    Sum : Whet_Float := 0.0;

    subtype Index is Integer range 1..N9;
    E1  : array (Index) of Whet_Float;

      procedure Clear_Array is
      begin
         for Loop_Var in E1'Range loop
            E1(Loop_Var) := 0.0;
         end loop;
      end Clear_Array;

      procedure P0 is
      begin
         if (IJ < 1) or (IK < 1) or (IL < 1) then
            Console.Put_Line ("Parameter error 1 at line 216");
            IJ := 1; IK := 1; IL := 1;
         elsif (IJ > N9) or (IK > N9) or (IL > N9) then
            Console.Put_Line ("Parameter error 2 at line 216");
            IJ := N9; IK := N9; IL := N9;
         end if;
         E1(IJ) := E1(IK);
         E1(IK) := E1(IL);
         E1(I)  := E1(IJ);
      end P0;

    procedure P3(X : Whet_Float;
                 Y : Whet_Float;
                 Z : out Whet_Float) is
      Xtemp: constant Whet_Float := T * (Z + X);
      Ytemp: constant Whet_Float := T * (Xtemp + Y);
    begin
      Z := (Xtemp + Ytemp) / T2;
    end P3;

  begin

    for Outer_Loop_Var in 1..Kilo_Whets loop

      Clear_Array;

         IJ := (IK - IJ) * (IL - IK);
         IK := IL - (IK - IJ);
         IL := (IL - IK) * (IK + IL);
         if (IK - 1) < 1 or (IL -1) < 1 then
            Console.Put_Line ("Parameter error 3 at line 244");
            IK := 2; IL := 2;
         elsif (IK - 1) > N9 or (IL - 1) > N9 then
            Console.Put_Line ("Parameter error 4 at line 244");
            IK := N9 + 1; IL := N9 + 1;
         end if;
         E1(IL - 1) := Whet_Float(IJ + IK + IL);
         E1(IK - 1) := Sin( Whet_Float(IL) );

      Z := E1(4);
      for Inner_Loop_Var in 1..N8 loop
        P3( Y * Whet_Float(Inner_Loop_Var), Y + Z, Z );
      end loop;

         IJ := IL - (IL - 3) * IK;
         IL := (IL - IK) * (IK - IJ);
         IK := (IL - IK) * IK;
         if (IL - 1) < 1 then
            Console.Put_Line ("Parameter error 5 at line 264");
            IL := 2;
         elsif (IL -1) > N9 then
            Console.Put_Line ("Parameter error 6 at line 264");
            IL := N9 + 1;
         end if;
         E1(IL - 1) := Whet_Float(IJ + IK + IL);

         if (IK + 1) > N9 then
            Console.Put_Line ("Parameter error 7 at line 272");
            IK := N9 - 1;
         elsif (IK + 1) < 1 then
            Console.Put_Line ("Parameter error 8 at line 272");
            IK := 0;
         end if;
         E1(IK + 1) := Abs( Cos(Z) );

      I := 1;
      while I <= N9 loop
        P0;
        I := I + 1;
      end loop;

      Z := Sqrt( Exp( Log(E1(N9)) / T1 ) );

      Sum := Sum + Z;

      if abs(Z - Value) > Tolerance then
        Sum := 2.0 * Sum;
        IJ := IJ + 1;
      end if;

    end loop;

   exception
      when Error : others =>
		 null;
   end Small_Whetstone;

end Production_Workload;
