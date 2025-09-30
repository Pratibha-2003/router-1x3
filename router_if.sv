interface router_if(input bit clock);

	logic [7:0]data_in;
	logic [7:0]data_out;
	logic read_enb;
	logic vld_out;
	logic err,busy,pkt_valid;
	logic resetn;

	//source driver 
	clocking write_driver_cb @(posedge clock);
		default input #1 output #1;
		output data_in;
		output resetn;
		output pkt_valid;
		input busy;
	endclocking

	//source monitor
	clocking write_monitor_cb @(posedge clock);
		default input #1 output #1;
		input data_in;
		input busy;
		input err;
		input pkt_valid;
		input resetn;
	endclocking

	//destination driver
	clocking read_driver_cb @(posedge clock);
		default input #1 output #1;
		output read_enb;
		input vld_out;
	endclocking

	//destination monitor
	clocking read_monitor_cb @(posedge clock);
		default input #1 output #1;
		input read_enb;
		input data_out;
		input vld_out;
	endclocking

	//modport declaration
	modport WDR_MP (clocking write_driver_cb);
	modport WMON_MP (clocking write_monitor_cb);
	
	modport RDR_MP (clocking read_driver_cb);
	modport RMON_MP (clocking read_monitor_cb);
		
endinterface
