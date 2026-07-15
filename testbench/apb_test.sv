class apb_test;
  apb_env env;
  virtual apb_if vif;
  function new(virtual apb_if vif);
    this.vif = vif;
  endfunction
  
  task run();
    env = new(vif);
    env.run();
  endtask
  
endclass
