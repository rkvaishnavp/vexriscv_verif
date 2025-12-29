interface debugBus_if (
    input clk,
    input reset
);
  logic        cmd_valid;
  logic        cmd_ready;
  logic        cmd_payload_wr;
  logic [ 7:0] cmd_payload_address;
  logic [31:0] cmd_payload_data;
  logic [31:0] rsp_data;
  logic        resetOut;

  modport proc(
      input clk,
      input reset,
      input cmd_valid,
      output cmd_ready,
      input cmd_payload_wr,
      input cmd_payload_address,
      input cmd_payload_data,
      output rsp_data,
      output resetOut
  );
  modport drv(
      input clk,
      input reset,
      output cmd_valid,
      input cmd_ready,
      output cmd_payload_wr,
      output cmd_payload_address,
      output cmd_payload_data,
      input rsp_data,
      input resetOut
  );
  modport mon(
      input clk,
      input reset,
      input cmd_valid,
      input cmd_ready,
      input cmd_payload_wr,
      input cmd_payload_address,
      input cmd_payload_data,
      input rsp_data,
      input resetOut
  );

endinterface  //iBus_if
