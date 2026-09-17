package Packet_Consumer is
   Use_Validation : constant Boolean := False;
   task Consumer with Priority => 5;
end Packet_Consumer;
