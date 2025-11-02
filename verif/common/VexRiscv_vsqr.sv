class VexRiscv_vsqr extends uvm_sequencer;

  intr_sqr  u_intr_sqr;
  ibus_sqr  u_ibus_sqr;
  dbus_sqr  u_dbus_sqr;
  debug_sqr u_debug_sqr;

  `uvm_component_utils(VexRiscv_vsqr)
  function new(string name = "VexRiscv_vsqr", uvm_component parent = null);
    super.new(name, parent);
  endfunction  //new()

endclass  //VexRiscv_vsqr extends uvm_sequencer
