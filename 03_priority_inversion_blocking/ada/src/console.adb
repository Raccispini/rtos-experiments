with System.Storage_Elements; use System.Storage_Elements;
with Interfaces;              use Interfaces;

package body Console is

   UART0_Base : constant := 16#4000_2000#;

   Enable        : Unsigned_32 with Address => To_Address (UART0_Base + 16#500#), Volatile;
   Psel_Txd      : Unsigned_32 with Address => To_Address (UART0_Base + 16#50C#), Volatile;
   Tasks_Starttx : Unsigned_32 with Address => To_Address (UART0_Base + 16#008#), Volatile;
   Events_Txdrdy : Unsigned_32 with Address => To_Address (UART0_Base + 16#11C#), Volatile;
   Txd           : Unsigned_32 with Address => To_Address (UART0_Base + 16#51C#), Volatile;

   Initialized : Boolean := False;

   procedure Init is
   begin
      Psel_Txd      := 6;
      Enable        := 4;
      Tasks_Starttx := 1;
      Initialized   := True;
   end Init;

   procedure Put_Char (C : Character) is
   begin
      if not Initialized then
         Init;
      end if;
      Txd := Character'Pos (C);
      loop
         exit when Events_Txdrdy = 1;
      end loop;
      Events_Txdrdy := 0;
   end Put_Char;

   procedure Put_String (S : String) is
   begin
      for C of S loop
         Put_Char (C);
      end loop;
   end Put_String;

   procedure Put_Line (S : String) is
   begin
      Put_String (S);
      Put_Char (ASCII.CR);
      Put_Char (ASCII.LF);
   end Put_Line;
begin
   Psel_Txd      := 6;
   Enable        := 4;
   Tasks_Starttx := 1;
end Console;
