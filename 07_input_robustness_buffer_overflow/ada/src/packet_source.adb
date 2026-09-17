with Ada.Real_Time; use Ada.Real_Time;
with Interfaces;    use Interfaces;
with Packet_Channel;

package body Packet_Source is
   task body Source is
      Period    : constant Time_Span := Milliseconds (200);
      Next      : Time := Clock + Period;
      N_Packets : constant := 100;
      P         : Packet_Channel.Packet;
   begin
      for I in 1 .. N_Packets loop
         delay until Next;
         Next := Next + Period;

         P.Data := (others => Unsigned_8 (I mod 256));

         if I mod 5 = 0 then
            P.Len := Packet_Channel.Cap + 4;
         else
            P.Len := Packet_Channel.Cap - 2;
         end if;

         Packet_Channel.Handler.Send (P);
      end loop;

      loop
         delay until Clock + Seconds (3600);
      end loop;
   end Source;
end Packet_Source;
