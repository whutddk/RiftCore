/*
* @File name: frontEnd
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-10-31 15:42:48
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-11-02 14:27:53
*/

`include "define.v"

module frontEnd (

	// input instrFifo_full,
	// output instrFifo_push,
	// output [`DECODE_INFO_DW-1:0] decode_microInstr,

	// input CLK,
	// input RSTn
	
);

	reg instrFifo_full = 0;
	wire instrFifo_push;
	wire [`DECODE_INFO_DW-1:0] decode_microInstr;

	reg CLK;
	reg RSTn;







wire [63:0] fetch_pc_dnxt,fetch_pc_qout;
wire isReset_qout;


gen_dffr # (.DW(64)) fetch_pc ( .dnxt(fetch_pc_dnxt), .qout(fetch_pc_qout), .CLK(CLK), .RSTn(RSTn));
gen_dffr # (.DW(1)) isReset ( .dnxt(1'b1), .qout(isReset_qout), .CLK(CLK), .RSTn(RSTn));

wire [31:0] instr_readout;
wire [31:0] instr;
wire isInstrReadOut;

wire fetch_decode_vaild;

//C0
pcGenerate i_pcGenerate
(
	//feedback
	.fetch_pc_dnxt(fetch_pc_dnxt),
	.fetch_pc_reg(fetch_pc_qout),
	.isReset(~isReset_qout),

	//from jalr exe
	.jalr_vaild(1'b0),
	.jalr_pc(64'b0),
	
	//from bru
	.bru_res_vaild(1'b0),
	.bru_takenBranch(1'b0),


	// from expection 	


	//to fetch
	.instr_readout(instr_readout),

	//to commit to flush
	.isMisPredict(),

	.pcGen_ready(),
	.isInstrReadOut(isInstrReadOut),
	.instrFifo_full(instrFifo_full),

	.CLK(CLK),
	.RSTn(RSTn)
);




//T0  
//T0包含在了C0里

wire [63:0] decode_pc;
//C1
instr_fetch i_instr_fetch(

	.instr_readout(instr_readout),
	.instr(instr),
	.pc_in(fetch_pc_qout),
	.pc_out(decode_pc),

	//handshake
	.isInstrReadOut(isInstrReadOut),
	.fetch_decode_vaild(fetch_decode_vaild),
	.instrFifo_full(instrFifo_full),

	.flush(1'b0),
	.CLK(CLK),
	.RSTn(RSTn)
	
);




//T1
//T1包含在C1中


//C2
decoder i_decoder
(
	.instr(instr),
	.fetch_decode_vaild(fetch_decode_vaild),
	.pc(decode_pc),

	.instrFifo_full(instrFifo_full),
	.decode_microInstr(decode_microInstr),
	.instrFifo_push(instrFifo_push)

);






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

initial
begin            
    $dumpfile("wave.vcd");        //生成的vcd文件名称
    $dumpvars(0, frontEnd);    //tb模块名称
end


	`define ITCM i_pcGenerate.i_itcm
	localparam  ITCM_DP = 2**14;
	integer i;

		reg [7:0] itcm_mem [0:(ITCM_DP-1)*8];
		initial begin
			$readmemh("./tb/rv64ui-p-add.test", itcm_mem);

			for ( i = 0; i < ITCM_DP; i = i + 1 ) begin
					`ITCM.ram[i] = itcm_mem[i*32+0];
			end

				$display("ITCM 0x00: %h", `ITCM.ram[8'h00]);
				$display("ITCM 0x01: %h", `ITCM.ram[8'h01]);
				$display("ITCM 0x02: %h", `ITCM.ram[8'h02]);
				$display("ITCM 0x03: %h", `ITCM.ram[8'h03]);
				$display("ITCM 0x04: %h", `ITCM.ram[8'h04]);
				$display("ITCM 0x05: %h", `ITCM.ram[8'h05]);
				$display("ITCM 0x06: %h", `ITCM.ram[8'h06]);
				$display("ITCM 0x07: %h", `ITCM.ram[8'h07]);
		end 


endmodule






