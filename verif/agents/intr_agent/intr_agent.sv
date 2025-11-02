class intr_agent extends uvm_agent;

  intr_drv drv;
  intr_sqr sqr;
  intr_cov cov;
  virtual intrBus_if vif;

  `uvm_component_utils(intr_agent)
  function new(string name = "intr_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction  //new()

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    drv = intr_drv::type_id::create("drv", this);
    sqr = intr_sqr::type_id::create("sqr", this);

    drv.vif = vif.drv;
    mon.vif = vif.mon;
  endfunction  //build_phase()

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    drv.seq_item_port.connect(sqr.seq_item_export);
  endfunction  //connect_phase()

endclass  //intr_agent extends uvm_agent
