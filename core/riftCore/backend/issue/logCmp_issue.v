/*
* @File name: logCmp_issue
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-09-11 15:39:38
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-11-10 14:47:48
*/

`timescale 1 ns / 1 ps
`include "define.vh"

module logCmp_issue #
	(
		parameter DW = `LOGCMP_ISSUE_INFO_DW,
		parameter DP = `LOGCMP_ISSUE_INFO_DP,
		parameter EXE_DW = `LOGCMP_EXEPARAM_DW
	)
	(
	
	//from buffer
	output logCmp_buffer_pop,
	output [$clog2(DP)-1:0] logCmp_buffer_pop_index,
	input [DP-1:0] logCmp_buffer_malloc,
	input [DW*DP-1 : 0] logCmp_issue_info,

	//from execute

	// input logCmp_execute_ready,
	output logCmp_exeparam_vaild_qout,
	output [EXE_DW-1:0] logCmp_exeparam_qout,

	//from regFile
	input [(64*`RP*32)-1:0] regFileX_read,
	input [32*`RP-1 : 0] wbLog_qout,

	input flush,
	input CLK,
	input RSTn
);


	//logCmp must be ready
	wire logCmp_exeparam_ready = 1'b1;



	wire [DP-1:0] rv64i_slti;
	wire [DP-1:0] rv64i_sltiu;
	wire [DP-1:0] rv64i_slt;
	wire [DP-1:0] rv64i_sltu;
	wire [DP-1:0] rv64i_xori;
	wire [DP-1:0] rv64i_ori;
	wire [DP-1:0] rv64i_andi;
	wire [DP-1:0] rv64i_xor;
	wire [DP-1:0] rv64i_or;
	wire [DP-1:0] rv64i_and;

	wire [64*DP-1:0] logCmp_pc;
	wire [64*DP-1:0] logCmp_imm;

	wire [(5+`RB)*DP-1:0] logCmp_rd0;
	wire [(5+`RB)*DP-1:0] logCmp_rs1;
	wire [(5+`RB)*DP-1:0] logCmp_rs2;

	wire [DP-1:0] rs1_ready;
	wire [DP-1:0] rs2_ready;

	wire [DP-1:0] logCmp_isClearRAW;

	wire [DP-1:0] logCmp_fun_slt;
	wire [DP-1:0] logCmp_fun_xor;
	wire [DP-1:0] logCmp_fun_or;
	wire [DP-1:0] logCmp_fun_and;

	wire [64*DP-1:0] src1;
	wire [64*DP-1:0] src2;

	wire  [64*DP-1:0] op1;
	wire  [64*DP-1:0] op2;

	wire [DP-1:0] isUsi;

generate
	for ( genvar i = 0; i < DP; i = i + 1 ) begin

		assign { 
				rv64i_slti[i], rv64i_sltiu[i], rv64i_slt[i], rv64i_sltu[i],
				rv64i_xori[i], rv64i_ori[i], rv64i_andi[i], rv64i_xor[i], rv64i_or[i], rv64i_and[i],
				logCmp_pc[64*i +: 64], logCmp_imm[64*i +: 64],
				logCmp_rd0[(5+`RB)*i +: (5+`RB)], 
				logCmp_rs1[(5+`RB)*i +: (5+`RB)], 
				logCmp_rs2[(5+`RB)*i +: (5+`RB)]
				} = logCmp_issue_info[DW*i +: DW];

		assign rs1_ready[i] = wbLog_qout[logCmp_rs1[(5+`RB)*i +: (5+`RB)]] | (logCmp_rs1[(5+`RB)*i+`RB +: 5] == 5'd0);
		assign rs2_ready[i] = wbLog_qout[logCmp_rs2[(5+`RB)*i +: (5+`RB)]] | (logCmp_rs2[(5+`RB)*i+`RB +: 5] == 5'd0);
		

		assign logCmp_isClearRAW[i] = 	( logCmp_buffer_malloc[i] ) & 
										(
											( rv64i_slti[i] & rs1_ready[i] )
											| ( rv64i_sltiu[i] & rs1_ready[i] )
											| ( rv64i_slt[i] & rs1_ready[i] & rs2_ready[i] )
											| ( rv64i_sltu[i] & rs1_ready[i] & rs2_ready[i] )

											| ( rv64i_xori[i] & rs1_ready[i] & rs2_ready[i] )
											| ( rv64i_xor[i] & rs1_ready[i] & rs2_ready[i] )

											| ( rv64i_ori[i] & rs1_ready[i]  )
											| ( rv64i_or[i] & rs1_ready[i] & rs2_ready[i] )

											| ( rv64i_andi[i] & rs1_ready[i] )
											| ( rv64i_and[i] & rs1_ready[i] & rs2_ready[i] )
										);


		
		assign logCmp_fun_slt[i] = rv64i_slti[i] | rv64i_sltiu[i] | rv64i_slt[i] | rv64i_sltu[i];
		assign logCmp_fun_xor[i] = rv64i_xori[i] | rv64i_xor[i];
		assign logCmp_fun_or[i] = rv64i_ori[i] | rv64i_or[i];
		assign logCmp_fun_and[i] = rv64i_andi[i] | rv64i_and[i];

		assign src1[64*i +: 64] = regFileX_read[logCmp_rs1[(5+`RB)*i +: (5+`RB)]*64 +: 64];
		assign src2[64*i +: 64] = regFileX_read[logCmp_rs2[(5+`RB)*i +: (5+`RB)]*64 +: 64];

		assign op1[64*i +:64] = ( {64{rv64i_slti[i]}} & src1[64*i +: 64] )
								| ( {64{rv64i_sltiu[i]}} & src1[64*i +: 64] )
								| ( {64{rv64i_slt[i]}} & src1[64*i +: 64] )
								| ( {64{rv64i_sltu[i]}} & src1[64*i +: 64] )

								| ( {64{rv64i_xori[i]}} & src1[64*i +: 64] )
								| ( {64{rv64i_xor[i]}} & src1[64*i +: 64] )

								| ( {64{rv64i_ori[i]}} & src1[64*i +: 64] )
								| ( {64{rv64i_or[i]}} & src1[64*i +: 64] )

								| ( {64{rv64i_andi[i]}} & src1[64*i +: 64] )
								| ( {64{rv64i_and[i]}} & src1[64*i +: 64] );

		assign op2[64*i +:64] = ( {64{rv64i_slti[i]}} & logCmp_imm[64*i +: 64] )
								| ( {64{rv64i_sltiu[i]}} & logCmp_imm[64*i +: 64] )
								| ( {64{rv64i_slt[i]}} & src2[64*i +: 64] )
								| ( {64{rv64i_sltu[i]}} & src2[64*i +: 64] )

								| ( {64{rv64i_xori[i]}} & logCmp_imm[64*i +: 64] )
								| ( {64{rv64i_xor[i]}} & src2[64*i +: 64] )

								| ( {64{rv64i_ori[i]}} & logCmp_imm[64*i +: 64] )
								| ( {64{rv64i_or[i]}} & src2[64*i +: 64] )

								| ( {64{rv64i_andi[i]}} & logCmp_imm[64*i +: 64] )
								| ( {64{rv64i_and[i]}} & src2[64*i +: 64] );


		assign isUsi[i] = rv64i_sltiu[i]
							| rv64i_sltu[i];


	end
endgenerate


	wire logCmp_all_RAW;

	lzp #(
		.CW($clog2(DP))
	) logCmp_RAWClear(
		.in_i(~logCmp_isClearRAW),
		.pos_o(logCmp_buffer_pop_index),
		.all1(logCmp_all_RAW),
		.all0()
	);

	wire logCmp_exeparam_vaild_dnxt;
	wire [EXE_DW-1:0] logCmp_exeparam_dnxt = flush ? {EXE_DW{1'b0}} :
									(logCmp_exeparam_vaild_dnxt ? { 
									logCmp_fun_slt[ logCmp_buffer_pop_index ],
									logCmp_fun_xor[ logCmp_buffer_pop_index ],
									logCmp_fun_or[ logCmp_buffer_pop_index ],
									logCmp_fun_and[ logCmp_buffer_pop_index ],

									logCmp_rd0[(5+`RB)*logCmp_buffer_pop_index +: (5+`RB)],
									op1[ 64*logCmp_buffer_pop_index +:64 ],
									op2[ 64*logCmp_buffer_pop_index +:64 ],

									isUsi[ logCmp_buffer_pop_index ]
									}
									: logCmp_exeparam_qout);

	assign logCmp_exeparam_vaild_dnxt = flush ? 1'b0 : (logCmp_exeparam_ready & ~logCmp_all_RAW);

	assign logCmp_buffer_pop = logCmp_exeparam_vaild_dnxt;

												

gen_dffr # (.DW(EXE_DW)) logCmp_exeparam ( .dnxt(logCmp_exeparam_dnxt), .qout(logCmp_exeparam_qout), .CLK(CLK), .RSTn(RSTn));
gen_dffr # (.DW(1)) logCmp_exeparam_vaild ( .dnxt(logCmp_exeparam_vaild_dnxt), .qout(logCmp_exeparam_vaild_qout), .CLK(CLK), .RSTn(RSTn));



































endmodule
