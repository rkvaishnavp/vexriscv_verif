class VexRiscv_base_test extends uvm_test;

  VexRiscv_env env;
  `uvm_component_utils(VexRiscv_base_test)
  function new(string name = "VexRiscv_base_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction  //new()

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = VexRiscv_env::type_id::create("env", this);
  endfunction  //build_phase()

endclass  //VexRiscv_base_test extends uvm_test
