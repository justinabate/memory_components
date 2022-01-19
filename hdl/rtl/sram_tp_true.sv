//------------------------------------------------------------------------------
// Originally: 
// true_dual_port_write_first_2_clock_ram.sv
// Konstantin Pavlov, pavlovconst@gmail.com
// https://github.com/pConst/basic_verilog/blob/master/fifo_single_clock_ram.sv
//------------------------------------------------------------------------------

// INFO ------------------------------------------------------------------------

// two ports, "true" dual port configuration
// write first

module sram_tp_true #(
  parameter int G_D = 512, // depth
  parameter int G_W = 16, // width
  parameter string INIT_FILE = ""
)(
  input clka,
  input [clogb2(G_D-1)-1:0] addra,
  input ena,
  input wea,
  input [G_W-1:0] dina,
  output [G_W-1:0] douta,

  input clkb,
  input [clogb2(G_D-1)-1:0] addrb,
  input enb,
  input web,
  input [G_W-1:0] dinb,
  output [G_W-1:0] doutb
);

  reg [G_W-1:0] BRAM [G_D]; // G_D-1:0
  reg [G_W-1:0] ram_data_a = {G_W{1'b0}};
  reg [G_W-1:0] ram_data_b = {G_W{1'b0}};

  // either initializes the memory values to a specified file or to all zeros
  //   to match hardware
  generate
    if (INIT_FILE != "") begin: g_init_with_file
      initial
        $readmemh(INIT_FILE, BRAM, 0, G_D-1);
    end else begin: g_init_with_zeroes
      integer ram_index;
      initial
        for (ram_index = 0; ram_index < G_D; ram_index = ram_index + 1)
          BRAM[ram_index] = {G_W{1'b0}};
    end
  endgenerate

  always @(posedge clka)
    if (ena)
      if (wea) begin
        BRAM[addra] <= dina;
        ram_data_a <= dina;
      end else
        ram_data_a <= BRAM[addra];

  always @(posedge clkb)
    if (enb)
      if (web) begin
        BRAM[addrb] <= dinb;
        ram_data_b <= dinb;
      end else
        ram_data_b <= BRAM[addrb];

  // no output register
  assign douta = ram_data_a;
  assign doutb = ram_data_b;

  // calculates the address width based on specified RAM depth
  function automatic integer clogb2;
    input integer depth;
      for (clogb2=0; depth>0; clogb2=clogb2+1)
        depth = depth >> 1;
  endfunction

endmodule
