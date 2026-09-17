with System;
with Interfaces.NRF52.GPIO;

package body Gpiote_Driver is

   GPIOTE_Base : constant := 16#4000_6000#;

   CONFIG0_Addr    : constant System.Address :=
     System'To_Address (GPIOTE_Base + 16#510#);
   INTENSET_Addr   : constant System.Address :=
     System'To_Address (GPIOTE_Base + 16#304#);
   EVENTS_IN0_Addr : constant System.Address :=
     System'To_Address (GPIOTE_Base + 16#100#);

   CONFIG0    : Unsigned_32 with Volatile, Address => CONFIG0_Addr;
   INTENSET   : Unsigned_32 with Volatile, Address => INTENSET_Addr;
   EVENTS_IN0 : Unsigned_32 with Volatile, Address => EVENTS_IN0_Addr;

   CONFIG0_Value : constant Unsigned_32 := 16#0002_0B01#;

   INTEN_CH0 : constant Unsigned_32 := 1;

   procedure Init is
   begin
      Interfaces.NRF52.GPIO.P0_Periph.PIN_CNF (11) :=
        (DIR    => Interfaces.NRF52.GPIO.Input,
         INPUT  => Interfaces.NRF52.GPIO.Connect,
         PULL   => Interfaces.NRF52.GPIO.Pullup,
         DRIVE  => Interfaces.NRF52.GPIO.S0S1,
         SENSE  => Interfaces.NRF52.GPIO.Disabled,
         others => <>);

      CONFIG0  := CONFIG0_Value;
      INTENSET := INTEN_CH0;
   end Init;

   procedure Clear_Event is
   begin
      EVENTS_IN0 := 0;
   end Clear_Event;

begin
   Init;
end Gpiote_Driver;
