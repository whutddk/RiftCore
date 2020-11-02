`include "iverilog.vh"
`include "define.vh"

module Crack_FrontEnd_TB();

	reg  CLK;
	reg  RSTn;


	`define ITCM s_frontEnd.i_pcGenerate.i_itcm


//////simulator

initial begin
	CLK = 0;
	RSTn = 0;

	#20

	RSTn <= 1;

	#400
			$display("Time Out !!!");
	 $finish;
end

initial begin
	forever
	begin 
		 #5 CLK <= ~CLK;
	end
end




wire instrFifo_push;
wire instrFifo_full;
wire [`DECODE_INFO_DW-1:0] decode_microInstr;


frontEnd s_frontEnd(

	.instrFifo_full(instrFifo_full),
	.instrFifo_push(instrFifo_push),
	.decode_microInstr(decode_microInstr),

	.CLK(CLK),
	.RSTn(RSTn)
	
);



gen_fifo # (.DW(`DECODE_INFO_DW),.AW(4)) 
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




`define ITCM s_frontEnd.i_pcGenerate.i_itcm
	localparam  ITCM_DP = 2**14;
	integer i;

		reg [7:0] itcm_mem [0:(ITCM_DP-1)*4];
		initial begin
			$readmemh("./tb/rv64ui-p-add.test", itcm_mem);

			for ( i = 0; i < ITCM_DP; i = i + 1 ) begin
					`ITCM.ram[i][7:0] = itcm_mem[i*4+0];
					`ITCM.ram[i][15:8] = itcm_mem[i*4+1];
					`ITCM.ram[i][23:16] = itcm_mem[i*4+2];
					`ITCM.ram[i][31:24] = itcm_mem[i*4+3];
			end

				$display("ITCM 0x00: %h", `ITCM.ram[8'h00]);
				$display("ITCM 0x01: %h", `ITCM.ram[8'h01]);
				$display("ITCM 0x02: %h", `ITCM.ram[8'h02]);
				$display("ITCM 0x03: %h", `ITCM.ram[8'h03]);
				$display("ITCM 0x04: %h", `ITCM.ram[8'h04]);
				$display("ITCM 0x05: %h", `ITCM.ram[8'h05]);
				$display("ITCM 0x06: %h", `ITCM.ram[8'h06]);
				$display("ITCM 0x07: %h", `ITCM.ram[8'h07]);
				$display("ITCM 0x00: %h", `ITCM.ram[8'h08]);
				$display("ITCM 0x09: %h", `ITCM.ram[8'h09]);
				$display("ITCM 0x0A: %h", `ITCM.ram[8'h0A]);
				$display("ITCM 0x0B: %h", `ITCM.ram[8'h0B]);
				$display("ITCM 0x0C: %h", `ITCM.ram[8'h0C]);
				$display("ITCM 0x0D: %h", `ITCM.ram[8'h0D]);
				$display("ITCM 0x0E: %h", `ITCM.ram[8'h0E]);
				$display("ITCM 0x0F: %h", `ITCM.ram[8'h0F]);
		end 


initial
begin
	$dumpfile("./build/wave.vcd"); //生成的vcd文件名称
	$dumpvars(0, Crack_FrontEnd_TB);//tb模块名称
end








endmodule


