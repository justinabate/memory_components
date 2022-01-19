//! File list for SVunit
`include "svunit_defines.svh"
`include "fifo_sync.sv"
`include "fifo_sync_sram_based.sv"
`include "sram_tp_true.sv"


module fifo_sync_sram_based_unit_test;

  import svunit_pkg::svunit_testcase;

  string name = "fifo_sync_sram_based_ut";
  svunit_testcase svunit_ut;

  parameter               CLK_HALF_PER = 6.4/2; // 156.25 MHz               
  parameter int G_D = 256; // FIFO depth
  parameter int G_W = 32; // input word size 
  
  reg                     w_rst_n = 1'b1; // init to high
  reg                     w_clk = 1'b0;

  logic [G_W-1:0]         w_wdat = '0;
  logic [G_W-1:0]         w_rdat;

  logic                   w_wena = '0;
  logic                   w_rena = '0;
  logic                   w_full, w_empt, w_werr, w_rerr;
  logic [$clog2(G_D)-0:0] w_flvl;
    

  fifo_sync #(
    .G_D( G_D ),
    .G_W( G_W )
  ) i_fifo_fwft (
    .i_clk   ( w_clk ),
    .i_arst_n( w_rst_n ),
    .i_sclr  (1'b0),

    .i_wena  ( w_wena ),
    .i_wdat  ( w_wdat ),
  
    .i_rena  ( w_rena ),
    .o_rdat  ( w_rdat ),
  
    .o_full  ( w_full ),
    .o_empt  ( w_empt ),
    .o_flvl  ( w_flvl ) 
  );


  fifo_sync_sram_based #(
    .G_D( G_D ),
    .G_W( G_W )
  ) i_fifo_basic (
    .i_clk   ( w_clk ),
    .i_srst_n( w_rst_n ),

    .i_wena  ( w_wena ),
    .i_wdat  ( w_wdat ),
    .o_werr  (  ),
  
    .i_rena  ( w_rena ),
    .o_rdat  (  ),
    .o_rerr  (  ),
  
    .o_full  (  ),
    .o_empt  (  ),
    .o_flvl  (  ) 
  );


  function void build();
    svunit_ut = new(name);
  endfunction

  task setup();
    svunit_ut.setup(); // Setup for running the Unit Tests
  endtask

  task teardown();
    svunit_ut.teardown(); // deconstruct anything we need after running the Unit Tests
  endtask

  task t_reset();
    @(posedge w_clk);
      w_rst_n = ~w_rst_n;
    repeat (4) @(posedge w_clk);
      w_rst_n = ~w_rst_n;
  endtask

  
  always #(CLK_HALF_PER) w_clk = ~w_clk; //! clock driver



  //===================================
  // Unit test definitions
  //===================================
  `SVUNIT_TESTS_BEGIN
  $display("\n");
	

  `SVTEST(test_reset) 
    $display("INFO:  Testing w_rst_n");
		t_reset();
		`FAIL_IF(w_rst_n != 1'b1);
  `SVTEST_END
  $display(" ");


  `SVTEST(test_write) 
    $display("INFO:  Writing a single data word to the FIFO");

    //! wait until reset goes high
		while (!w_rst_n) @(posedge w_clk); 
    
    //! drive a data word on the next clock
    @(posedge w_clk);
    w_wena = 1'b1;
    w_wdat = 32'hBAD4_BADF;
    //! deassert write enable
    @(posedge w_clk);
    w_wena = 1'b0;

    //! check results
    repeat (1) @(posedge w_clk);
		`FAIL_IF(w_empt == 1'b1); //! FIFO empty must deassert on next cycle
    $display("PASS:  Empty signal asserted successfully");
		`FAIL_IF(w_flvl == '0); //! fill level must change from zero
    $display("PASS:  Fill level succesfully changed");

  `SVTEST_END
  $display(" ");


  `SVTEST(test_read) 
    $display("INFO:  Reading a single data word to the FIFO");

		while (w_empt) @(posedge w_clk); //! wait until empty goes low
    
    @(posedge w_clk);
    w_rena = 1'b1; //! drive a read enable on the next clock
    @(posedge w_clk);
    w_rena = 1'b0; //! deassert read enable

    //! check results
    repeat (1) @(posedge w_clk);
		`FAIL_IF(w_empt == 1'b0); //! FIFO empty must deassert on next cycle
    $display("PASS:  Empty signal deasserted successfully");
		`FAIL_IF(w_flvl == 1); //! fill level must change from zero
    $display("PASS:  Fill level succesfully changed");
    repeat (10) @(posedge w_clk);

  `SVTEST_END
  $display(" ");

  // `SVTEST(test_concurrent) 
  //   $display("INFO:  ");

  //   fork
  // 	  begin //! thread 1: Port A
  //     end
  //     begin //! thread 2: Port B
  //     end
  //     begin //! thread 3: sporadic backpressure
  //     end

  //   join

	// 	`FAIL_IF(w_av_st_a_eop != w_av_st_c_eop);
  // `SVTEST_END
  // $display(" ");


  `SVUNIT_TESTS_END

endmodule