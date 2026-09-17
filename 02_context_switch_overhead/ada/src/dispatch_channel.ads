with System;
with Interfaces;

package Dispatch_Channel is
   protected Handler
     with Priority => 5
   is
      procedure Signal (Before : Interfaces.Unsigned_32);
      entry Wait (Before : out Interfaces.Unsigned_32);
   private
      Stored_Before : Interfaces.Unsigned_32 := 0;
      Barrier       : Boolean := False;
   end Handler;
end Dispatch_Channel;
