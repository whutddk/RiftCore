/*
* @File name: pcGenerate
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-10-13 16:56:39
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-11-17 18:04:06
*/

/*
  Copyright (c) 2020 - 2020 Ruige Lee <wut.ruigeli@gmail.com>

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/



`timescale 1 ns / 1 ps

`include "define.vh"

module pcGenerate (

	output [63:0] fetch_pc_qout,

	input isReset,

	//from jalr exe
	input jalr_vaild,
	input [63:0] jalr_pc,
	
	//from bru
	input bru_res_vaild,
	input bru_takenBranch,

	// from expection 	
	input [63:0] privileged_pc,
	input privileged_vaild,

	//to commit to flush
	output isMisPredict,

	//to fetch
	output [31:0] instr_readout,


	//hadnshake

	output isInstrReadOut,
	input instrFifo_full,

	input CLK,
	input RSTn

);

	wire [63:0] fetch_pc_dnxt;
	wire [63:0] fetch_pc_qout;


	// from branch predict
	wire isTakenBranch;
	wire isPredit;


	wire pcGen_fetch_vaild;


	wire isExpection = privileged_vaild;
	wire [63:0] expection_pc = privileged_pc;


	wire isJal;
	wire isJalr;
	wire isBranch;

	wire isCall;
	wire isReturn;
	wire [31:0] load_instr;
	wire [63:0] next_pc;
	wire [63:0] take_pc;
	wire ras_empty;

	wire itcm_ready;


	wire [63+1:0] bht_data_pop;
	wire [63+1:0] bht_data_push = {
									isTakenBranch, 
									(({64{~isTakenBranch}} & take_pc) | ({64{isTakenBranch}} & next_pc))
									};

	wire bht_full;
	wire bht_pop = bru_res_vaild;
	wire bht_push = isPredit & ~bht_full & pcGen_fetch_vaild;

	assign isMisPredict = bru_res_vaild & ( bru_takenBranch ^ bht_data_pop[64]);
	wire [63:0] resolve_pc = bht_data_pop[63:0];


	// wire instrFifo_stall = instrFifo_full;
	wire jalr_stall = isJalr & ~jalr_vaild & ( ras_empty | ~isReturn );
	wire bht_stall = (bht_full & isPredit);

	assign pcGen_fetch_vaild = (~bht_stall & ~jalr_stall & itcm_ready) | isMisPredict | isExpection;


	assign fetch_pc_dnxt = 	( {64{isReset}} & 64'h8000_0000)
							|
							({64{~isReset}} & (( {64{isExpection}} & expection_pc )
															| 
															( ( {64{~isExpection}} ) & 
																(	
																	( {64{isMisPredict}} & resolve_pc)
																	|
																	(
																		{64{~isMisPredict}} &
																		(
																			{64{~bht_stall}} &
																			(
																				{64{isTakenBranch}} & take_pc 
																				|
																				{64{~isTakenBranch}} & next_pc
																			)
																			| 
																			{64{bht_stall | jalr_stall}} &
																			(
																				fetch_pc_qout
																			)
																		)
																	)
																)
															)));







	//branch predict



	assign isJal = (load_instr[6:0] == 7'b1101111);
	assign isJalr = (load_instr[6:0] == 7'b1100111);
	assign isBranch = (load_instr[6:0] == 7'b1100011);

	assign isCall = (isJalr | isJal) & ((load_instr[11:7] == 5'd1) | load_instr[11:7] == 5'd5);
	assign isReturn = isJalr & ((load_instr[19:15] == 5'd1) | load_instr[19:15] == 5'd5)
								& (load_instr[19:15] != load_instr[11:7]);


    initial $warning("there is no rv64c");
	wire is_rvc_instr = 1'b0;
	wire [63:0] imm = ({64{isJal}} & {{44{load_instr[31]}},load_instr[19:12],load_instr[20],load_instr[30:21],1'b0})
	|
	({64{isJalr}} & {{52{load_instr[31]}},load_instr[31:20]})
	|
	({64{isBranch}} & {{52{load_instr[31]}},load_instr[7],load_instr[30:25],load_instr[11:8],1'b0});


	assign isPredit = isBranch;

	//static predict
	assign isTakenBranch = ( (isBranch) & ( imm[63] == 1'b0) )
							| (isJal | isJalr); 


	wire [63:0] ras_addr_pop;
	wire [63:0] ras_addr_push;

	wire ras_push = isCall & ( isJal | isJalr ) & pcGen_fetch_vaild;
	wire ras_pop = isReturn & ( isJalr ) & ( !ras_empty ) & pcGen_fetch_vaild;

	assign next_pc = fetch_pc_qout + ( is_rvc_instr ? 64'd2 : 64'd4 );
	assign take_pc = ( {64{isJal | isBranch}} & (fetch_pc_qout + imm) )
						| ( {64{isJalr &  ras_pop}} & ras_addr_pop ) 
						| ( {64{isJalr & !ras_pop & jalr_vaild}} & jalr_pc  );
	assign ras_addr_push = next_pc;



	wire isITCM = (fetch_pc_dnxt & 64'hFFFF_FFFF_FFFF_0000) == 64'h8000_0000;
	initial $warning("no cache");
	wire isCache = 1'b0;


	initial $warning("no debuger and no odd memory");
	itcm i_itcm
	(
		.itcm_ready(itcm_ready),
		.pcGen_vaild(pcGen_fetch_vaild),
		.instrFifo_full(instrFifo_full),

		.fetch_pc_dnxt(fetch_pc_dnxt),
		.instr_out(load_instr),

		.instr_vaild(isInstrReadOut),
		.fetch_pc_qout(fetch_pc_qout),

		.CLK(CLK),
		.RSTn(RSTn)		
	);



	assign instr_readout = load_instr;


initial $warning("假设分支最多16次,fifo满则挂机");

gen_fifo # (
	.DW(64+1),
	.AW(4)
) bht(

	.fifo_pop(bht_pop), 
	.fifo_push(bht_push),
	.data_push(bht_data_push),

	.fifo_empty(), 
	.fifo_full(bht_full), 
	.data_pop(bht_data_pop),

	.flush(isMisPredict|isExpection),
	.CLK(CLK),
	.RSTn(RSTn)
);



initial $warning("no feedback from commit, if flush, all flush");
gen_ringStack # (.DW(64), .AW(4)) ras(
	.stack_pop(ras_pop), .stack_push(ras_push),
	.stack_empty(ras_empty),
	.data_pop(ras_addr_pop), .data_push(ras_addr_push),

	.flush(isMisPredict|isExpection),
	.CLK(CLK),
	.RSTn(RSTn)
);




endmodule










