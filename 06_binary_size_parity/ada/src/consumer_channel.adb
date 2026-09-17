package body Consumer_Channel is
   protected body Handler is
      procedure Notify is
      begin
         Barrier := True;
      end Notify;

      entry Wait when Barrier is
      begin
         Barrier := False;
      end Wait;
   end Handler;
end Consumer_Channel;
