//! File list for SVunit
`include "svunit_defines.svh"
`include "fifo_sync_sram_based.sv"
`include "sram_tp_true.sv"


module fifo_sync_sram_based_unit_test;

  import svunit_pkg::svunit_testcase;

  string name = "fifo_sync_sram_based_ut";
  svunit_testcase svunit_ut;


  // Parameters, regs, wires
  parameter CLK_HALF_PER = 6.4/2; // 156.25 MHz 

  parameter g_D = 512; // FIFO depth
  parameter g_W = 32; // input word size 
  
  // Clock and Reset signals
  reg                     w_rst_n = 1'b1; // init to high
  reg                     w_clk = 1'b0;

  // wires to/from DUT
  logic [g_W-1:0]         w_wdat = '0;
  logic [g_W-1:0]         w_rdat;

  logic                   w_wena = '0;
  logic                   w_rena = '0;
  logic                   w_full, w_empt, w_werr, w_rerr;
  logic [$clog2(g_D)-0:0] w_flvl;
    

  //===================================
  // This is the UUT that we're running the Unit Tests on
  //===================================

  fifo_sync_sram_based #(
    .g_D( g_D ),
    .g_W( g_W )
  ) i_fifo (
    .i_clk  ( w_clk ),
    .i_rst_n( w_rst_n ),

    .i_wena( w_wena ),
    .i_wdat( w_wdat ),
    .o_werr( w_werr ),

    .i_rena( w_rena ),
    .o_rdat( w_rdat ),
    .o_rerr( w_rerr ),

    .o_full( w_full ),
    .o_empt( w_empt ),
    .o_flvl( w_flvl ) 
  );

  //===================================
  // BFMs, monitors
  //===================================


  //===================================
  // SVunit tasks
  //===================================
  function void build();
    svunit_ut = new(name);
  endfunction

  task setup();
    svunit_ut.setup(); // Setup for running the Unit Tests

  endtask

  task teardown();
    svunit_ut.teardown(); // deconstruct anything we need after running the Unit Tests
  endtask

  //===================================
  // Custom tasks
  //===================================
  task t_reset();
    @(posedge w_clk);
      w_rst_n = ~w_rst_n;
    repeat (4) @(posedge w_clk);
      w_rst_n = ~w_rst_n;
  endtask


  //! clock driver
  always #(CLK_HALF_PER) w_clk = ~w_clk;



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