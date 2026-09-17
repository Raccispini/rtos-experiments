with Interfaces;

package Consumer_Channel is
   protected Handler
     with Priority => 3
   is
      procedure Notify;
      entry Wait;
   private
      Barrier : Boolean := False;
   end Handler;
end Consumer_Channel;
