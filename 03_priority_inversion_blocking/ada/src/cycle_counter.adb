with System;

package body Cycle_Counter is

   DEMCR_Addr      : constant System.Address := System'To_Address (16#E000_EDFC#);
   DWT_CTRL_Addr   : constant System.Address := System'To_Address (16#E000_1000#);
   DWT_CYCCNT_Addr : constant System.Address := System'To_Address (16#E000_1004#);

   DEMCR      : Unsigned_32 with Volatile, Address => DEMCR_Addr;
   DWT_CTRL   : Unsigned_32 with Volatile, Address => DWT_CTRL_Addr;
   DWT_CYCCNT : Unsigned_32 with Volatile, Address => DWT_CYCCNT_Addr;

   TRCENA    : constant Unsigned_32 := 16#0100_0000#;
   CYCCNTENA : constant Unsigned_32 := 16#0000_0001#;

   procedure Enable is
   begin
      DEMCR      := DEMCR or TRCENA;
      DWT_CYCCNT := 0;
      DWT_CTRL   := DWT_CTRL or CYCCNTENA;
   end Enable;

   function Get return Unsigned_32 is
   begin
      return DWT_CYCCNT;
   end Get;

begin
   Enable;
end Cycle_Counter;
