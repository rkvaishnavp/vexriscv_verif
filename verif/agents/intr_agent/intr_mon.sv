class intr_mon extends uvm_monitor;

  virtual intrBus_if.mon vif;
  intrBus_tx rx_item;

  `uvm_component_utils(intr_mon)

  covergroup intr_cg @(posedge vif.clk);
    coverpoint vif.timerInterrupt {bins low = {0}; bins high = {1};}
    coverpoint vif.softwareInterrupt {bins low = {0}; bins high = {1};}
    coverpoint vif.externalInterrupt {bins low = {0}; bins high = {1};}

    cross timerInterrupt, softwareInterrupt, externalInterrupt;
  endgroup


  function new(string name = "intr_mon", uvm_component parent = null);
    super.new(name, parent);
    intr_cg = new();
  endfunction  //new()

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual intrBus_if.mon)::get(this, "", "vif", vif)) begin
      `uvm_fatal(get_type_name(), "Virtual interface must be set for intrBus_if")
    end
  endfunction  //build_phase()

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    phase.raise_objection(this);
    forever begin
      @(posedge vif.clk);
      rx_item = intrBus_tx::type_id::create("rx_item", this);
      rx_item.timerInterrupt = vif.timerInterrupt;
      rx_item.softwareInterrupt = vif.softwareInterrupt;
      rx_item.externalInterrupt = vif.externalInterrupt;
      `uvm_info(get_type_name(), $sformatf(
                "Monitoring interrupts: timer=%0b software=%0b external=%0b",
                rx_item.timerInterrupt,
                rx_item.softwareInterrupt,
                rx_item.externalInterrupt
                ), UVM_LOW)
      intr_cg.sample();
    end
    phase.drop_objection(this);
  endtask  //run_phase()

endclass  //intr_mon extends uvm_monitor
