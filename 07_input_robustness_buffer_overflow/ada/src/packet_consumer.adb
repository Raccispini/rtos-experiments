with Interfaces;    use Interfaces;
with Packet_Channel;
with Cycle_Counter;
with Console;
with Auxiliary;

package body Packet_Consumer is
   task body Consumer is
      P             : Packet_Channel.Packet;
      Local_Buf     : Packet_Channel.Byte_Array := (others => 0);
      Effective_Len : Natural;
      T0, T1        : Unsigned_32;
   begin
      loop
         Packet_Channel.Handler.Receive (P);
         T0 := Cycle_Counter.Get;

         if Use_Validation then
            Effective_Len := Natural'Min (P.Len, Packet_Channel.Cap);
         else
            Effective_Len := P.Len;
         end if;

         for I in 1 .. Effective_Len loop
            Local_Buf (I) := P.Data (I);
         end loop;

         T1 := Cycle_Counter.Get;
         Console.Put_Line ("PACKET_OK cost=" & Auxiliary.Cycles_Image (T1 - T0));
      end loop;
   end Consumer;
end Packet_Consumer;
