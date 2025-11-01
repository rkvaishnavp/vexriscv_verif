interface dBus_if (
    input clk,
    input reset
);
  logic        cmd_valid;
  logic        cmd_ready;
  logic        cmd_payload_wr;
  logic        cmd_payload_uncached;
  logic [31:0] cmd_payload_address;
  logic [31:0] cmd_payload_data;
  logic [ 3:0] cmd_payload_mask;
  logic [ 2:0] cmd_payload_size;
  logic        cmd_payload_last;
  logic        rsp_valid;
  logic        rsp_payload_last;
  logic [31:0] rsp_payload_data;
  logic        rsp_payload_error;

  modport drv(
      input clk,
      input reset,
      input cmd_valid,
      output cmd_ready,
      input cmd_payload_wr,
      input cmd_payload_uncached,
      input cmd_payload_address,
      input cmd_payload_data,
      input cmd_payload_mask,
      input cmd_payload_size,
      input cmd_payload_last,
      output rsp_valid,
      output rsp_payload_last,
      output rsp_payload_data,
      output rsp_payload_error
  );
  modport proc(
      input clk,
      input reset,
      output cmd_valid,
      input cmd_ready,
      output cmd_payload_wr,
      output cmd_payload_uncached,
      output cmd_payload_address,
      output cmd_payload_data,
      output cmd_payload_mask,
      output cmd_payload_size,
      output cmd_payload_last,
      input rsp_valid,
      input rsp_payload_last,
      input rsp_payload_data,
      input rsp_payload_error
  );
  modport mon(
      input clk,
      input reset,
      input cmd_valid,
      input cmd_ready,
      input cmd_payload_wr,
      input cmd_payload_uncached,
      input cmd_payload_address,
      input cmd_payload_data,
      input cmd_payload_mask,
      input cmd_payload_size,
      input cmd_payload_last,
      input rsp_valid,
      input rsp_payload_last,
      input rsp_payload_data,
      input rsp_payload_error
  );
endinterface  //dBus_if
