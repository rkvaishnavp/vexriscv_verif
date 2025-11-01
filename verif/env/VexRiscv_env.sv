class VexRiscv_env extends uvm_env;

  dbus_agent  dbus_agnt;
  ibus_agent  ibus_agnt;
  intr_agent  intr_agnt;
  debug_agent debug_agnt;

  `uvm_component_utils(VexRiscv_env)
  function new(string name = "VexRiscv_env", uvm_component parent = null);
    super.new(name, parent);
  endfunction  //new()

endclass  //VexRiscv_env extends uvm_env
