//============================================================
// Synchronous FIFO 
// https://github.com/joshchengwk/sync_fifo/blob/master/rtl/sync_fifo.sv
// Features:
//	1. Asynchronous and synchronous reset
//	2. Configurable data width
//	3. Configurable depth in power of 2 (round to address width)
//	4. Configurable almost-o_full and almost-o_empt level
//	5. Configurable Look-ahead or read-request architecture
//	6. Concurrent used word indication
//	7. Implementation using D-FF or Memory hard-macro
//
// Designer: Josh Cheng
// GNU General Public License v3.0 
//============================================================
module fifo_sync #(
      parameter g_D = 512, //! depth
			parameter	g_W = 72, //! width
			parameter	AFULL_LEVEL = 248,
			parameter	AEMPTY_LEVEL = 8,
			parameter	LOOKAHEAD = 1,
      parameter ADDR_WIDTH = $clog2(g_D)
)(
		input	      			     i_clk,	// Clock input
		input	      			     i_arst_n,	// Active low reset
		input	      			     i_sclr,	// FIFO synchronous clear

		input	      			     i_wena,	// Write Enable
		input	       [g_W-1:0] i_wdat,	// Data input
		
    input	      			     i_rena,	// Read enable
		output       [g_W-1:0] o_rdat,	// Data Output
		
    output       				   o_empt,	// FIFO empty
		output       				   o_full,	// FIFO full

		output       				   o_almf,	// FIFO almost empty
		output       				   o_alme,	// FIFO almost full
		output	[ADDR_WIDTH:0] o_flvl	  // FIFO used word
);
 



logic	[ADDR_WIDTH-1:0] 	wr_pointer;
logic	[ADDR_WIDTH-1:0]	rd_pointer;
logic	[ADDR_WIDTH :0]		word_cnt;
logic	[g_W-1:0]	ram_q;
logic	[g_W-1:0]	data_ram;

logic				ram_wren;
logic				ram_rden;
logic	[ADDR_WIDTH-1:0]	ram_wraddr;
logic	[ADDR_WIDTH-1:0]	ram_rdaddr;

assign o_full = (word_cnt == (ADDR_WIDTH+1)'(g_D));
assign o_empt = (word_cnt == (ADDR_WIDTH+1)'(0));
assign o_almf = (word_cnt >= (ADDR_WIDTH+1)'(AFULL_LEVEL));
assign o_alme = (word_cnt <= (ADDR_WIDTH+1)'(AEMPTY_LEVEL));



//Write pointer
always_ff@(posedge i_clk or negedge i_arst_n)
begin
	if (~i_arst_n) 
		wr_pointer <= (ADDR_WIDTH)'(0);
	else if (i_sclr)
		wr_pointer <= (ADDR_WIDTH)'(0);
	else if (i_wena & (~o_full | i_rena) ) 	//overflow protect, but allow o_full write if read at same time
		wr_pointer <= wr_pointer + (ADDR_WIDTH)'(1);
end

//Read pointer
generate 
if (LOOKAHEAD)
begin
	always_ff@(posedge i_clk or negedge i_arst_n)
	begin
		if (~i_arst_n)
			rd_pointer <= (ADDR_WIDTH)'(1);		//init to 1 for lookahead architecture
		else if (i_sclr)
			rd_pointer <= (ADDR_WIDTH)'(1);
		else if (i_rena & ~o_empt) //underflow protect
			rd_pointer <= rd_pointer + (ADDR_WIDTH)'(1);
	end
end
else
begin
	always_ff@(posedge i_clk or negedge i_arst_n)
	begin
		if (~i_arst_n)
			rd_pointer <= (ADDR_WIDTH)'(0);
		else if (i_sclr)
			rd_pointer <= (ADDR_WIDTH)'(0);
		else if (i_rena & ~o_empt) //underflow protect
			rd_pointer <= rd_pointer + (ADDR_WIDTH)'(1);
	end
end
endgenerate

//Word counter
always_ff@ (posedge i_clk or negedge i_arst_n)
begin
	if (~i_arst_n) 
		word_cnt <= (ADDR_WIDTH+1)'(0);
	else if (i_sclr)
		word_cnt <= (ADDR_WIDTH+1)'(0);
	else if (i_rena & ~i_wena & ~o_empt)
		word_cnt <= word_cnt - (ADDR_WIDTH+1)'(1);
	else if (i_wena & ~i_rena & ~o_full)
		word_cnt <= word_cnt + (ADDR_WIDTH+1)'(1);
	else if (i_wena & i_rena & o_empt) //if write & read same time during o_empt, write is still valid
		word_cnt <= word_cnt + (ADDR_WIDTH+1)'(1);		
end 


//RAM control
assign ram_wren = i_wena & (~o_full | i_rena);
assign ram_rden = i_rena & ~o_empt;
assign ram_rdaddr = rd_pointer;
assign ram_wraddr = wr_pointer;

//=========================================================================================
// Memory instantiation
// Replace a RAM macro here if available. RTL model is shown below and D-FF will be used
// Example instance:
// RAM_XX	macro0 (
//		.i_clk		(i_clk),
//		.rdaddr		(ram_rdaddr),
//		.wraddr		(ram_wraddr),
//		.rddata		(i_wdat),
//		.wrdata		(ram_q),
//		.rden		(ram_wren),
//		.wren		(ram_rden));
//
//*****************************************************************************************
//Memory by D-FF
logic	[g_W-1:0]	mem[0:g_D-1];

always_ff@(posedge i_clk)
begin
	if (ram_wren)
		mem[ram_wraddr] <= i_wdat;
end

//Memory Output MUX & register
always_ff@(posedge i_clk)
begin
	if (ram_rden)                
                ram_q <= mem[ram_rdaddr];
end

//========================================================================================


//===========================================================================================
// Logic for LOOKAHEAD
//*******************************************************************************************
generate 
if (LOOKAHEAD)
begin
	logic				use_buffer;
	logic	[g_W-1:0]	word_buffer;
	logic				use_buffer_next;
	
	assign use_buffer_next = ((i_wena & o_empt) |				//Write into o_empt FIFO
			 (i_wena & i_rena & rd_pointer == wr_pointer));		//Read/write at the same time
	
	
	//First word MUX
	always_ff@(posedge i_clk or negedge i_arst_n)
	begin
		if (~i_arst_n)
			use_buffer <= 1'b0;
		else if (use_buffer_next)
			use_buffer <= 1'b1;
		else if (i_rena)
			use_buffer <= 1'b0;
	end
         
	//First word buffer
	always_ff@(posedge i_clk or negedge i_arst_n)
	begin
		if (~i_arst_n)
			word_buffer <= (g_W)'(0);
		else if (use_buffer_next)
			word_buffer <= i_wdat;
	end
	
	assign data_ram = (use_buffer)? word_buffer: ram_q;

end
else
begin
	assign data_ram = ram_q;

end
endgenerate
//========================================================================================


//===========================================================================================
// Output assignment
//*******************************************************************************************
assign o_flvl = word_cnt;
assign o_rdat = data_ram;
//===========================================================================================



endmodule