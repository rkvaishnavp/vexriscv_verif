class intr_tx extends uvm_sequence_item;

  bit timer_interrupt;
  bit software_interrupt;
  bit external_interrupt;

  `uvm_object_utils_begin(intr_tx)
    `uvm_field_int(timer_interrupt, UVM_ALL_ON)
    `uvm_field_int(software_interrupt, UVM_ALL_ON)
    `uvm_field_int(external_interrupt, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "intr_tx");
    super.new(name);
  endfunction  //new()
endclass  //intr_tx extends uvm_sequence_item
