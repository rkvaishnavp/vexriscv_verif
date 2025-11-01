
module tb_top;

  `include "uvm_pkg.sv"
  import uvm_pkg::*;
  `include "bus_pkg.sv"

  logic clk;
  logic reset;
  logic debugReset;

  dBus_if dbus_if (
      .clk  (clk),
      .reset(reset)
  );
  iBus_if ibus_if (
      .clk  (clk),
      .reset(reset)
  );
  intrBus_if intrbus_if (
      .clk  (clk),
      .reset(reset)
  );
  debug_if debugbus_if (
      .clk  (clk),
      .reset(reset)
  );


  VexRiscv_wrapper u_VexRiscv_wrapper (
      .clk(clk),
      .reset(reset),
      .debugReset(debugReset),
      .dBus(dbus_if.proc),
      .iBus(ibus_if.proc),
      .intrBus(intrbus_if.proc),
      .debugBus(debugbus_if.proc)
  );

  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  initial begin
    $display("Starting Testbench Top Module");
    uvm_config_db#(virtual dBus_if)::set(null, "uvm_test_top.env.dbus_agent*", "vif", dbus_if);
    uvm_config_db#(virtual iBus_if)::set(null, "uvm_test_top.env.ibus_agent*", "vif", ibus_if);
    uvm_config_db#(virtual intrBus_if)::set(null, "uvm_test_top.env.intr_agent*", "vif",
                                            intrbus_if);
    uvm_config_db#(virtual debugBus_if)::set(null, "uvm_test_top.env.debug_agent*", "vif",
                                             debugbus_if);
    run_test("VexRiscv_base_test");
    $finish;
  end

endmodule
