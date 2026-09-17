with Interfaces;

package Packet_Channel is

   Cap : constant := 8;

   type Byte_Array is array (1 .. Cap) of Interfaces.Unsigned_8;

   type Packet is record
      Len  : Natural;
      Data : Byte_Array;
   end record;

   protected Handler
     with Priority => 5
   is
      procedure Send (P : Packet);
      entry Receive (P : out Packet);
   private
      Stored  : Packet := (Len => 0, Data => (others => 0));
      Barrier : Boolean := False;
   end Handler;

end Packet_Channel;
