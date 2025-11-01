class VexRiscv_env extends uvm_env;

  dbus_agent  dbus_agnt;
  ibus_agent  ibus_agnt;
  intr_agent  intr_agnt;
  debug_agent debug_agnt;

  `uvm_component_utils(VexRiscv_env)
  function new(string name = "VexRiscv_env", uvm_component parent = null);
    super.new(name, parent);
  endfunction  //new()

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    dbus_agnt  = dbus_agent::type_id::create("dbus_agnt", this);
    ibus_agnt  = ibus_agent::type_id::create("ibus_agnt", this);
    intr_agnt  = intr_agent::type_id::create("intr_agnt", this);
    debug_agnt = debug_agent::type_id::create("debug_agnt", this);
  endfunction  //build_phase()

endclass  //VexRiscv_env extends uvm_env
