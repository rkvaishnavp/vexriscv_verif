`timescale 1ns / 1ps

module VexRiscv_wrapper (
    input clk,
    input reset,
    input debugReset,
    dBus_if.proc dBus,
    iBus_if.proc iBus,
    debugBus_if.proc debugBus,
    intrBus_if.proc intrBus
);

  VexRiscv u_VexRiscv (
      .clk(clk),
      .reset(reset),
      .dBus_cmd_valid(dBus.cmd_valid),
      .dBus_cmd_ready(dBus.cmd_ready),
      .dBus_cmd_payload_wr(dBus.cmd_payload_wr),
      .dBus_cmd_payload_uncached(dBus.cmd_payload_uncached),
      .dBus_cmd_payload_address(dBus.cmd_payload_address),
      .dBus_cmd_payload_data(dBus.cmd_payload_data),
      .dBus_cmd_payload_mask(dBus.cmd_payload_mask),
      .dBus_cmd_payload_size(dBus.cmd_payload_size),
      .dBus_cmd_payload_last(dBus.cmd_payload_last),
      .dBus_rsp_valid(dBus.rsp_valid),
      .dBus_rsp_payload_last(dBus.rsp_payload_last),
      .dBus_rsp_payload_data(dBus.rsp_payload_data),
      .dBus_rsp_payload_error(dBus.rsp_payload_error),
      .timerInerrupt(intrBus.timerInterrupt),
      .externalInterrupt(intrBus.externalInterrupt),
      .softwareInterrupt(intrBus.softwareInterrupt),
      .debug_bus_cmd_valid(debugBus.cmd_valid),
      .debug_bus_cmd_ready(debugBus.cmd_ready),
      .debug_bus_cmd_payload_wr(debugBus.cmd_payload_wr),
      .debug_bus_cmd_payload_address(debugBus.cmd_payload_address),
      .debug_bus_cmd_payload_data(debugBus.cmd_payload_data),
      .debug_bus_rsp_data(debugBus.rsp_data),
      .debug_resetOut(debugBus.resetOut),
      .iBus_cmd_valid(iBus.cmd_valid),
      .iBus_cmd_ready(iBus.cmd_ready),
      .iBus_cmd_payload_address(iBus.cmd_payload_address),
      .iBus_cmd_payload_size(iBus.cmd_payload_size),
      .iBus_rsp_valid(iBus.rsp_valid),
      .iBus_rsp_payload_data(iBus.rsp_payload_data),
      .iBus_rsp_payload_error(iBus.rsp_payload_error),
      .debugReset(debugReset)
  );

endmodule
