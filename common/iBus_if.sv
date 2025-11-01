interface iBus_if (
    input clk,
    input reset
);
  logic        cmd_valid;
  logic        cmd_ready;
  logic [31:0] cmd_payload_address;
  logic [ 2:0] cmd_payload_size;
  logic        rsp_valid;
  logic [31:0] rsp_payload_data;
  logic        rsp_payload_error;

  modport proc(
      input clk,
      input reset,
      output cmd_valid,
      input cmd_ready,
      output cmd_payload_address,
      output cmd_payload_data,
      input rsp_valid,
      input rsp_payload_data,
      input rsp_payload_error
  );

  modport drv(
      input clk,
      input reset,
      input cmd_valid,
      output cmd_ready,
      input cmd_payload_address,
      input cmd_payload_data,
      output rsp_valid,
      output rsp_payload_data,
      output rsp_payload_error
  );

  modport mon(
      input clk,
      input reset,
      input cmd_valid,
      input cmd_ready,
      input cmd_payload_address,
      input cmd_payload_data,
      input rsp_valid,
      input rsp_payload_data,
      input rsp_payload_error
  );
endinterface  //iBus_if
