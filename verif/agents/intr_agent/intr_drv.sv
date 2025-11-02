class intr_drv extends uvm_driver #(intrBus_tx);

  virtual intrBus_if.drv vif;
  `uvm_component_utils(intr_drv)
  function new(string name = "intr_drv", uvm_component parent = null);
    super.new(name, parent);
  endfunction  //new()

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual intrBus_if.drv)::get(this, "", "vif", vif)) begin
      `uvm_fatal(get_type_name(), "Virtual interface must be set for intrBus_if")
    end
  endfunction  //build_phase()

  function void run_phase(uvm_phase phase);
    super.run_phase(phase);
    intrBus_tx req;
    phase.raise_objection(this);
    forever begin
      seq_item_port.get_next_item(req);
      @(posedge vif.clk);
      vif.timerInterrupt <= req.timerInterrupt;
      vif.softwareInterrupt <= req.softwareInterrupt;
      vif.externalInterrupt <= req.externalInterrupt;
      `uvm_info(get_type_name(), $sformatf(
                "Driving interrupts: timer=%0b software=%0b external=%0b",
                req.timerInterrupt,
                req.softwareInterrupt,
                req.externalInterrupt
                ), UVM_LOW)
      seq_item_port.item_done();
    end
    phase.drop_objection(this);
  endfunction  //run_phase()
endclass  //intr_drv extends uvm_driver
