with Interfaces;

package Race_State is
   Shared_Counter : Interfaces.Unsigned_32 := 0 with Volatile;
end Race_State;
