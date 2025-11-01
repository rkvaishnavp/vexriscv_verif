class dbus_agent extends uvm_agent;

  dbus_sqr sqr;
  dbus_drv drv;
  dbus_mon mon;
  dbus_cov cov;

  `uvm_component_utils(dbus_agent)
  function new(string name = "dbus_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction  //new()


endclass  //dbus_agent extends uvm_agent
