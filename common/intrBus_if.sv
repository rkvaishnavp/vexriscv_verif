interface intrBus_if (
    input clk,
    input reset
);
  logic timerInterrupt;
  logic externalInterrupt;
  logic softwareInterrupt;
  modport proc(
      input clk,
      input reset,
      input timerInterrupt,
      input externalInterrupt,
      input softwareInterrupt
  );
  modport drv(
      input clk,
      input reset,
      output timerInterrupt,
      output externalInterrupt,
      output softwareInterrupt
  );
  modport mon(
      input clk,
      input reset,
      input timerInterrupt,
      input externalInterrupt,
      input softwareInterrupt
  );
endinterface  //intrBus_if
