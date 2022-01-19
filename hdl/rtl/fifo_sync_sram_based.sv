//------------------------------------------------------------------------------
// fifo_sync_sram_based.sv
// Konstantin Pavlov, pavlovconst@gmail.com
// https://github.com/pConst/basic_verilog/blob/master/fifo_single_clock_ram.sv
//------------------------------------------------------------------------------

// INFO ------------------------------------------------------------------------
//  Single-clock FIFO buffer implementation, also known as "queue"
//
//  This fifo variant should synthesize into block RAM seamlessly, both for
//    Altera and for Xilinx chips. Simulation is also consistent.
//  Use this fifo when you need cross-vendor and sim/synth compatibility.
//
//  Features:
//  - single clock operation
//  - configurable depth and data width
//  - only "normal" mode is supported here (no FWFT mode)
//  - protected against overflow and underflow
//


/* --- INSTANTIATION TEMPLATE BEGIN ---
fifo_sync_sram_based #(
  .G_D( 512 ),
  .G_W( 32 )
) i_fifo (
  .i_clk( i_clk ),
  .i_srst_n( 1'b1 ),
  .i_wena(  ),
  .i_wdat(  ),
  .o_werr(  ),
  .i_rena(  ),
  .o_rdat(  ),
  .o_rerr(  ),
  .o_full(  ),
  .o_empt(  ),
  .o_flvl(  ),
);
--- INSTANTIATION TEMPLATE END ---*/


module fifo_sync_sram_based #(

  parameter string FWFT_MODE = "FALSE", // "FALSE" - normal fifo mode     
                                 // "TRUE"  - first word fall-through" mode (note: not supported)
                                    

  parameter int G_D = 512,                // fifo word depth; power of 2
  parameter int G_W = 72,                 // fifo word width

  parameter int G_D_SIZE = $clog2(G_D)+1  // elements counter width, extra bit to store
                                      // "fifo full" state, see o_flvl[] variable comments

)(

  input                       i_clk,
  input                       i_srst_n, // inverted reset

  // write port           
  input                       i_wena,
  input [G_W-1:0]             i_wdat,
  output logic                o_werr,

  // read port            
  input                       i_rena,
  output [G_W-1:0]            o_rdat,
  output logic                o_rerr,

  // helper ports
  output logic                o_full,
  output logic                o_empt,
  output logic [G_D_SIZE-1:0] o_flvl = '0 // fill level
);


// read and write pointers
logic [G_D_SIZE-1:0] w_ptr = '0;
logic [G_D_SIZE-1:0] r_ptr = '0;

// filtered requests
logic w_req_f;
assign w_req_f = i_wena && ~o_full;

logic r_req_f;
assign r_req_f = i_rena && ~o_empt;


//! use SRAM block as 'simple' dual port:
//! port A for writing, port B for reading
sram_tp_true #(
  .G_D( G_D ),
  .G_W( G_W ),
  .INIT_FILE( "" )
) data_ram (
  .clka( i_clk ),
  .addra( w_ptr[G_D_SIZE-2:0] ), // prev -1; got vsim-3015
  .ena( w_req_f ),
  .wea( 1'b1 ),
  .dina( i_wdat[G_W-1:0] ),
  .douta(  ),

  .clkb( i_clk ),
  .addrb( r_ptr[G_D_SIZE-2:0] ),
  .enb( r_req_f ),
  .web( 1'b0 ),
  .dinb( '0 ),
  .doutb( o_rdat[G_W-1:0] )
);


function automatic [G_D_SIZE-1:0] inc_ptr (
  input logic [G_D_SIZE-1:0] ptr
);

  if( ptr[G_D_SIZE-1:0] == G_D-1 ) begin
    inc_ptr[G_D_SIZE-1:0] = '0;
  end else begin
    inc_ptr[G_D_SIZE-1:0] = ptr[G_D_SIZE-1:0] + 1'b1;
  end
endfunction


always_ff @(posedge i_clk) begin
  if ( ~i_srst_n ) begin
    w_ptr[G_D_SIZE-1:0] <= '0;
    r_ptr[G_D_SIZE-1:0] <= '0;

    o_flvl[G_D_SIZE-1:0] <= '0;
  end else begin

    if( w_req_f ) begin
      w_ptr[G_D_SIZE-1:0] <= inc_ptr(w_ptr[G_D_SIZE-1:0]);
    end

    if( r_req_f ) begin
      r_ptr[G_D_SIZE-1:0] <= inc_ptr(r_ptr[G_D_SIZE-1:0]);
    end

    if( w_req_f && ~r_req_f ) begin
      o_flvl[G_D_SIZE-1:0] <= o_flvl[G_D_SIZE-1:0] + 1'b1;
    end else if( ~w_req_f && r_req_f ) begin
      o_flvl[G_D_SIZE-1:0] <= o_flvl[G_D_SIZE-1:0] - 1'b1;
    end

  end
end

always_comb begin
  o_empt = ( o_flvl[G_D_SIZE-1:0] == '0 );
  o_full =  ( o_flvl[G_D_SIZE-1:0] == G_D );

  o_rerr = ( o_empt && i_rena );
  o_werr = ( o_full  && i_wena );
end

endmodule
