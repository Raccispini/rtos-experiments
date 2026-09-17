package Production_Workload is

  Workload_Failure : exception;

  procedure Small_Whetstone(Kilo_Whets : Positive) with Inline => True;

end Production_Workload;
