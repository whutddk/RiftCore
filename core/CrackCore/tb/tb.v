

module Crack_FrontEnd_TB();

	reg  CKL;
	reg  RSTn;


	`define ITCM `s_frontEnd.i_pcGenerate.i_itcm


	initial begin
		#40000000
				$display("Time Out !!!");
		 $finish;
	end

	always
	begin 
		 #2 clk <= ~clk;
	end




	localparam  ITCM_DP = 2**14;
	integer i;

		reg [7:0] itcm_mem [0:(ITCM_DP-1)*8];
		initial begin
			$readmemh({testcase, ".verilog"}, itcm_mem);

			for ( i = 0; i < ITCM_DP; i = i + 1 ) begin
					`ITCM.ram[i][00+7:00] = itcm_mem[i*8+0];
					`ITCM.ram[i][08+7:08] = itcm_mem[i*8+1];
					`ITCM.ram[i][16+7:16] = itcm_mem[i*8+2];
					`ITCM.ram[i][24+7:24] = itcm_mem[i*8+3];
					`ITCM.ram[i][32+7:32] = itcm_mem[i*8+4];
					`ITCM.ram[i][40+7:40] = itcm_mem[i*8+5];
					`ITCM.ram[i][48+7:48] = itcm_mem[i*8+6];
					`ITCM.ram[i][56+7:56] = itcm_mem[i*8+7];
			end

				$display("ITCM 0x00: %h", `ITCM.ram[8'h00]);
				$display("ITCM 0x01: %h", `ITCM.ram[8'h01]);
				$display("ITCM 0x02: %h", `ITCM.ram[8'h02]);
				$display("ITCM 0x03: %h", `ITCM.ram[8'h03]);
				$display("ITCM 0x04: %h", `ITCM.ram[8'h04]);
				$display("ITCM 0x05: %h", `ITCM.ram[8'h05]);
				$display("ITCM 0x06: %h", `ITCM.ram[8'h06]);
				$display("ITCM 0x07: %h", `ITCM.ram[8'h07]);
				$display("ITCM 0x16: %h", `ITCM.ram[8'h16]);
				$display("ITCM 0x20: %h", `ITCM.ram[8'h20]);

		end 




wire instrFifo_push;
wire instrFifo_full;
wire [DECODE_INFO_DW-1:0] decode_microInstr;


frontEnd s_frontEnd(

	.instrFifo_full(instrFifo_full)
	.instrFifo_push(instrFifo_push)
	.decode_microInstr(decode_microInstr)

	.CLK(CLK),
	.RSTn(RSTn)
	
);


gen_fifo # (.DW(DECODE_INFO_DW),.AW(4)) 
	instr_fifo (
		.fifo_pop(1'b0),
		.fifo_push(instrFifo_push),

		.data_push(decode_microInstr),
		.data_pop(),

		.fifo_empty(),
		.fifo_full(instrFifo_full),

		.CLK(CLK),
		.RSTn(RSTn)
);

endmodule