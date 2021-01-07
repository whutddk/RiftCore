/*
* @File name: branch_predict
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2021-01-05 16:42:46
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2021-01-07 17:39:45
*/


/*
  Copyright (c) 2020 - 2021 Ruige Lee <wut.ruigeli@gmail.com>

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

module branch_predict (
	input isReset,

	input isJal,
	input isJalr,
	input isBranch,
	input isCall,
	input isReturn,
	input [63:0] imm,
	input isRVC,

	output isMisPredict,
	input isExpection,
	input [63:0] expection_pc,

	input jalr_valid,
	input [63:0] jalr_pc,
	input bru_res_valid,
	input bru_takenBranch,

	input fetch_pc_valid,
	input [63:0] fetch_pc,
	output [63:0] fetch_addr_qout,
	output fetch_addr_valid,
	input pcGen_fetch_ready,

	input CLK,
	input RSTn

);




	wire [63:0] next_pc;
	wire [63:0] take_pc;
	wire [63:0] resolve_pc; 

	wire [63+1:0] bht_data_pop;
	wire [63+1:0] bht_data_push;

	wire isTakenBranch;
	wire bht_full;
	wire bht_pop;
	wire bht_push;

	wire jalr_stall;
	wire bht_stall;

	wire [63:0] ras_addr_pop;
	wire [63:0] ras_addr_push;
	wire ras_push;
	wire ras_pop;
	wire ras_empty;

	wire fetch_addr_valid_dnxt;
	wire [63:0] fetch_addr_dnxt;


	assign bht_data_push = 
				{
					isTakenBranch, 
					(({64{~isTakenBranch}} & take_pc) | ({64{isTakenBranch}} & next_pc))
				};


	assign bht_pop = bru_res_valid;
	assign bht_push = isBranch & ~bht_full & fetch_addr_valid_dnxt;

	assign isMisPredict = bru_res_valid & ( bru_takenBranch ^ bht_data_pop[64]);
	assign resolve_pc = bht_data_pop[63:0];

	assign jalr_stall = isJalr & ( ras_empty | ~isReturn );
	assign bht_stall = (bht_full & isBranch);
	assign fetch_addr_valid_dnxt = 
				isMisPredict | isExpection | isReset | 
				(
					pcGen_fetch_ready & ( 
											(
												fetch_pc_valid & (~bht_stall & ~jalr_stall)
											)
											|
											(
												(bht_stall & bru_res_valid) | (jalr_stall & jalr_valid)
											)
										 )
				)




	(~bht_stall & ~jalr_stall & (fetch_pc_valid | jalr_valid) & ) ;




	assign fetch_addr_dnxt = 
		isReset ? 64'h8000_0000 :
				( 
					isExpection ? expection_pc : 
						(
							isMisPredict ? resolve_pc :
								(
									(
											pcGen_fetch_ready & ( 
											(
												fetch_pc_valid & (~bht_stall & ~jalr_stall)
											)
											|
											(
												(bht_stall & bru_res_valid) | (jalr_stall & jalr_valid)
											)
																)
									) ? 
										(
											isTakenBranch ? take_pc : next_pc
										)
										:
										(
											fetch_pc
										)
								)
						)
				);




	gen_dffr # (.DW(64), .rstValue(64'h8000_0000)) fetch_addr_dffr (.dnxt(fetch_addr_dnxt), .qout(fetch_addr_qout), .CLK(CLK), .RSTn(RSTn));
	gen_dffr # (.DW(1)) fetch_addr_valid_dffr (.dnxt(fetch_addr_valid_dnxt), .qout(fetch_addr_valid), .CLK(CLK), .RSTn(RSTn));



	//static predict
	assign isTakenBranch = ( (isBranch) & ( imm[63] == 1'b0) )
							| (isJal | isJalr); 






	assign ras_push = isCall & ( isJal | isJalr ) & fetch_addr_valid_dnxt;
	assign ras_pop = isReturn & ( isJalr ) & ( !ras_empty ) & fetch_addr_valid_dnxt;

	assign next_pc = fetch_pc + ( isRVC ? 64'd2 : 64'd4 );
	assign take_pc = ( {64{isJal | isBranch}} & (fetch_pc + imm) )
						| ( {64{isJalr & ras_pop}} & ras_addr_pop ) 
						| ( {64{isJalr & !ras_pop & jalr_valid}} & jalr_pc  );
	assign ras_addr_push = next_pc;





	gen_fifo # ( .DW(64+1), .AW(4) ) bht(
		.fifo_pop(bht_pop), .fifo_push(bht_push),
		.data_push(bht_data_push), .data_pop(bht_data_pop),
		.fifo_empty(), .fifo_full(bht_full), 
		
		.flush(isMisPredict|isExpection),
		.CLK(CLK),
		.RSTn(RSTn)
	);




	gen_ringStack # (.DW(64), .AW(4)) ras(
		.stack_pop(ras_pop), .stack_push(ras_push),
		.stack_empty(ras_empty),
		.data_pop(ras_addr_pop), .data_push(ras_addr_push),

		.flush(isMisPredict|isExpection),
		.CLK(CLK),
		.RSTn(RSTn)
	);










endmodule




