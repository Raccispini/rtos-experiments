package body Shared_Value is
   protected body Store is
      procedure Set (V : Interfaces.Unsigned_32) is
      begin
         Value := V;
      end Set;

      function Get return Interfaces.Unsigned_32 is
      begin
         return Value;
      end Get;
   end Store;
end Shared_Value;
