package body Dispatch_Channel is
   protected body Handler is
      procedure Signal (Before : Interfaces.Unsigned_32) is
      begin
         Stored_Before := Before;
         Barrier := True;
      end Signal;

      entry Wait (Before : out Interfaces.Unsigned_32) when Barrier is
      begin
         Before := Stored_Before;
         Barrier := False;
      end Wait;
   end Handler;
end Dispatch_Channel;
