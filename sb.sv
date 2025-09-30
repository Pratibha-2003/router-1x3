class scoreboard extends uvm_scoreboard;
 `uvm_component_utils(scoreboard)

        	
	uvm_tlm_analysis_fifo #(read_xtn) fifo_rdh[];
        uvm_tlm_analysis_fifo #(write_xtn) fifo_wrh;

       env_config m_cfg;

        write_xtn wr_data;
        read_xtn  rd_data;

               bit [1:0]address;

      write_xtn s_cov_data; //for covergroup
          read_xtn d_cov_data; //for covergroup

	int data_verified_count;

	//covergroup for source
	covergroup router_source;
		option.per_instance = 1;
		//address
		ADDR : coverpoint s_cov_data.header[1:0] { bins h1 = {2'b00};
							   bins h2 = {2'b01};
							   bins h3 = {2'b10};}

		//data
		PAYLOAD_SIZE: coverpoint s_cov_data.header[7:2] { bins s_pkt = {[1:20]};
								  bins m_pkt = {[21:40]};
						 		  bins b_pkt = {[41:63]};}

		//bad pkt
		BAD_PKT: coverpoint s_cov_data.err {bins bad_pkt = {1'b1};
						      bins good_pkt = {1'b0};}

		ADDR_PAYLOAD_SIZE: cross ADDR,PAYLOAD_SIZE;
		ADDR_PAYLOAD_SIZE_BAD_PKT: cross ADDR,PAYLOAD_SIZE,BAD_PKT;
	endgroup

	//covergroup for destination
	covergroup router_dest;
		option.per_instance = 1;
		//address
		ADDR: coverpoint d_cov_data.header[1:0] { bins h1 = {2'b00};
							  bins h2 = {2'b01};
							  bins h3 = {2'b10};}

		//data
		PAYLOAD_SIZE: coverpoint d_cov_data.header[7:2] {bins s_pkt = {[1:20]};
								 bins m_pkt = {[21:40]};
								 bins b_pkt = {[41:63]};}

		ADDR_PAYLOAD_SIZE: cross ADDR,PAYLOAD_SIZE;
	endgroup
//------------------------------------------
// Methods
//------------------------------------------

// Standard UVM Methods:
extern function new(string name,uvm_component parent);
extern task run_phase(uvm_phase phase);
extern function void check_data(write_xtn wr_data,read_xtn rd_data);
//extern function void report_phase(uvm_phase phase);

endclass


       	function scoreboard::new(string name,uvm_component parent);
		super.new(name,parent);
         if(!uvm_config_db #(env_config)::get(this,"","env_config",m_cfg))

	             	`uvm_fatal("CONFIG","cannot get() m_cfg from uvm_config_db. Have you set() it?")

         fifo_rdh= new[m_cfg.no_of_read_agents];
         fifo_wrh= new("fifo_wrh",this);

         foreach(fifo_rdh[i])
         fifo_rdh[i]= new($sformatf("fifo_rdh[%0d]",i),this);
                    endfunction

        
        
task scoreboard :: run_phase(uvm_phase phase);
fifo_wrh.get(wr_data);
if(wr_data.header[1:0]== 2'b00)
  begin
  fifo_rdh[0].get(rd_data);
  check_data(wr_data, rd_data);
  end
if(wr_data.header[1:0]== 2'b01)
  begin
  fifo_rdh[1].get(rd_data);
  check_data(wr_data, rd_data);
  end
if(wr_data.header[1:0]== 2'b10)
  begin
   fifo_rdh[2].get(rd_data);
   check_data(wr_data, rd_data);
  end
endtask

function void  scoreboard :: check_data(write_xtn wr_data,read_xtn rd_data);

$display("WRITE: payload=%p, header=%d, parity=%d", wr_data.payload, wr_data.header, wr_data.parity);
$display("READ: payload=%p, header=%d, parity=%d",rd_data.payload, rd_data.header, rd_data.parity);

if(wr_data.header == rd_data.header)
$display("HEADER IS MATCHED");
else $display("HEADER NOT MATCHED");

if(wr_data.payload == rd_data.payload)
$display("PAYLOAD IS MATCHED");
else
$display("PAYLOAD IS NOT MATCHED");

if(wr_data.parity == rd_data.parity)
$display("PARITY IS MATCHED");
else
$display("PARITY IS NOT MATCHED");
endfunction
/*
    function void scoreboard::report_phase(uvm_phase phase);
   // Displays the final report of test using scoreboard stistics
   `uvm_info(get_type_name(), $sformatf("MSTB: Simulation Report from ScoreBoard \n Number of Read Transactions from Read agt_top : %0d \n Number of Write Transactions from write agt_top : %0d \n Number of Read Transactions Dropped : %0d \n Number of Read Transactions compared : %0d \n\n",rd_xtns_in, wr_xtns_in, xtns_dropped, xtns_compared), UVM_LOW)
 endfunction 
*/



