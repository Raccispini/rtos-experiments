package body Packet_Channel is
   protected body Handler is
      procedure Send (P : Packet) is
      begin
         Stored := P;
         Barrier := True;
      end Send;

      entry Receive (P : out Packet) when Barrier is
      begin
         P := Stored;
         Barrier := False;
      end Receive;
   end Handler;
end Packet_Channel;
