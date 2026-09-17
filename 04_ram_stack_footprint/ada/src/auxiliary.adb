package body Auxiliary is
   Request_Counter : Range_Counter := 0;
   Run_Count : Run_Counter := 0;
   function Due_Activation (Param : Range_Counter) return Boolean is
   begin
      Request_Counter := Request_Counter + 1;

      return (Request_Counter = Param);
   end Due_Activation;
   function Check_Due return Boolean is
      Divisor : Natural;
   begin
      Run_Count := Run_Count + 1;
      Divisor := Natural (Run_Count) / Factor;
      return ((Divisor * Factor) = Natural (Run_Count));
   end Check_Due;

   function Cycles_Image (Value : Interfaces.Unsigned_32) return String is
      use Interfaces;
      Digits_Buffer : String (1 .. 10);
      Last_Index    : Natural := Digits_Buffer'Last;
      V             : Unsigned_32 := Value;
   begin
      if V = 0 then
         return "0";
      end if;
      while V > 0 loop
         Digits_Buffer (Last_Index) :=
           Character'Val (Character'Pos ('0') + Natural (V mod 10));
         V := V / 10;
         Last_Index := Last_Index - 1;
      end loop;
      return Digits_Buffer (Last_Index + 1 .. Digits_Buffer'Last);
   end Cycles_Image;
end Auxiliary;
