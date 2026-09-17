package Background_Load is

   Duty_Percent : constant := 100;

   task Load with Priority => 2;
end Background_Load;
