/*
* @File name: jal_issue
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-09-11 15:39:38
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-11-08 14:52:10
*/

`timescale 1 ns / 1 ps
`include "define.vh"

module jal_issue #
	(
		parameter DW = `JAL_ISSUE_INFO_DW,
		parameter DP = `JAL_ISSUE_INFO_DP,
		parameter EXE_DW = `JAL_EXEPARAM_DW
	)
	(
	
	//from buffer
	output jal_buffer_pop,
	output [$clog2(DP)-1:0] jal_buffer_pop_index,
	input [DP-1:0] jal_buffer_malloc,
	input [DW*DP-1 : 0] jal_issue_info,
	//from execute


	output jal_exeparam_vaild_qout,
	output [EXE_DW-1:0] jal_exeparam_qout,

	//from regFile
	input [(64*`RP*32)-1:0] regFileX_read,
	input [32*`RP-1 : 0] wbLog_qout,

	input CLK,
	input RSTn
);

	wire jal_exeparam_ready = 1'b1;


	wire [DP-1:0] rv64i_jal;
	wire [DP-1:0] rv64i_jalr;

	wire [64*DP-1:0] jal_pc;

	wire [(5+`RB)*DP-1:0] jal_rd0;
	wire [(5+`RB)*DP-1:0] jal_rs1;


	wire [DP-1:0] rs1_ready;

	wire [DP-1:0] jal_isClearRAW;

	wire [64*DP-1:0] src1;


	wire  [64*DP-1:0] op1;
	wire  [64*DP-1:0] op2;

	wire [DP-1:0] is_rvc;

generate
	for ( genvar i = 0; i < DP; i = i + 1 ) begin

		assign { 
				rv64i_jal[i],
				rv64i_jalr[i],

				jal_pc[64*i +: 64],

				jal_rd0[(5+`RB)*i +: (5+`RB)], 
				jal_rs1[(5+`RB)*i +: (5+`RB)], 

				is_rvc[i]
				} = jal_issue_info[DW*i +: DW];

		assign rs1_ready[i] = wbLog_qout[jal_rs1[(5+`RB)*i +: (5+`RB)]] | (jal_rs1[(5+`RB)*i+`RB +: 5] == 5'd0);


		assign jal_isClearRAW[i] = 	( jal_buffer_malloc[i] ) & 
										(
										  rv64i_jal[i]
										| ( rv64i_jalr[i] & rs1_ready[i] )
										);


		assign src1[64*i +: 64] = regFileX_read[jal_rs1[(5+`RB)*i +: (5+`RB)]*64 +: 64];

	end
endgenerate


	wire jal_all_RAW;


	lzp #(
		.CW($clog2(DP))
	) jal_RAWClear(
		.in_i(~jal_isClearRAW),
		.pos_o(jal_buffer_pop_index),
		.all1(jal_all_RAW),
		.all0()
	);


	wire [EXE_DW-1:0] jal_exeparam_dnxt = { 
									rv64i_jal[ jal_buffer_pop_index ],
									rv64i_jalr[ jal_buffer_pop_index ],
								
									jal_rd0[(5+`RB)*jal_buffer_pop_index +: (5+`RB)],
									src1[ 64*jal_buffer_pop_index +:64 ],
									jal_pc[ 64*jal_buffer_pop_index +:64 ],

									is_rvc[ jal_buffer_pop_index ]
								};


	wire jal_exeparam_vaild_dnxt =  ~jal_all_RAW;


	assign jal_buffer_pop = ( jal_exeparam_ready & jal_exeparam_vaild_dnxt );





gen_dffr # (.DW(EXE_DW)) jal_exeparam ( .dnxt(jal_exeparam_dnxt), .qout(jal_exeparam_qout), .CLK(CLK), .RSTn(RSTn));
gen_dffr # (.DW(1)) jal_exeparam_vaild ( .dnxt(jal_exeparam_vaild_dnxt), .qout(jal_exeparam_vaild_qout), .CLK(CLK), .RSTn(RSTn));































endmodule
