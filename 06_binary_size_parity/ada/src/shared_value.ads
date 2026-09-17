with Interfaces;

package Shared_Value is
   protected Store
     with Priority => 3
   is
      procedure Set (V : Interfaces.Unsigned_32);
      function Get return Interfaces.Unsigned_32;
   private
      Value : Interfaces.Unsigned_32 := 0;
   end Store;
end Shared_Value;
