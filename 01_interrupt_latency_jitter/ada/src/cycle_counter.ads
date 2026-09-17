with Interfaces; use Interfaces;

package Cycle_Counter is

   function Get return Unsigned_32;
   pragma Inline (Get);

private

   procedure Enable;

end Cycle_Counter;
