/*
* @File name: logCmp_issue
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-09-11 15:39:38
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-11-04 14:10:24
*/


module logCmp_issue (
	
	//from buffer
	output logCmp_buffer_pop,
	output [$clog2(`LOGCMP_ISSUE_DEPTH)-1:0] logCmp_buffer_pop_index,
	input [`LOGCMP_ISSUE_DEPTH-1:0] logCmp_buffer_malloc,
	input [`LOGCMP_ISSUE_INFO_DW*`LOGCMP_ISSUE_DEPTH-1 : 0] logCmp_issue_info,

	//from execute

	// input logCmp_execute_ready,
	output logCmp_exeparam_vaild_qout,
	output [`LOGCMP_EXEPARAM_DW-1:0] logCmp_exeparam_qout,

	//from regFile
	input [(64*RNDEPTH*32)-1:0] regFileX_read,
	input [32*RNDEPTH-1 : 0] wbLog_qout
);


	//logCmp must be ready
	wire logCmp_exeparam_ready = 1'b1;



	wire [LOGCMP_ISSUE_DEPTH - 1:0] rv64i_slti;
	wire [LOGCMP_ISSUE_DEPTH - 1:0] rv64i_sltiu;
	wire [LOGCMP_ISSUE_DEPTH - 1:0] rv64i_slt;
	wire [LOGCMP_ISSUE_DEPTH - 1:0] rv64i_sltu;
	wire [LOGCMP_ISSUE_DEPTH - 1:0] rv64i_xori;
	wire [LOGCMP_ISSUE_DEPTH - 1:0] rv64i_ori;
	wire [LOGCMP_ISSUE_DEPTH - 1:0] rv64i_andi;
	wire [LOGCMP_ISSUE_DEPTH - 1:0] rv64i_slt;
	wire [LOGCMP_ISSUE_DEPTH - 1:0] rv64i_sltu;
	wire [LOGCMP_ISSUE_DEPTH - 1:0] rv64i_xor;
	wire [LOGCMP_ISSUE_DEPTH - 1:0] rv64i_or;
	wire [LOGCMP_ISSUE_DEPTH - 1:0] rv64i_and;

	wire [64*LOGCMP_ISSUE_DEPTH - 1:0] logCmp_pc;
	wire [64*LOGCMP_ISSUE_DEPTH - 1:0] logCmp_imm;

	wire [(5+RNBIT)*LOGCMP_ISSUE_DEPTH - 1] logCmp_rd0;
	wire [(5+RNBIT)*LOGCMP_ISSUE_DEPTH - 1] logCmp_rs1;
	wire [(5+RNBIT)*LOGCMP_ISSUE_DEPTH - 1] logCmp_rs2;

	wire [LOGCMP_ISSUE_DEPTH - 1] rs1_ready;
	wire [LOGCMP_ISSUE_DEPTH - 1] rs2_ready;

	wire [LOGCMP_ISSUE_DEPTH - 1:0] logCmp_fun_slt;
	wire [LOGCMP_ISSUE_DEPTH - 1:0] logCmp_fun_xor;
	wire [LOGCMP_ISSUE_DEPTH - 1:0] logCmp_fun_or;
	wire [LOGCMP_ISSUE_DEPTH - 1:0] logCmp_fun_and;

	wire [64*LOGCMP_ISSUE_DEPTH-1 : 0] src1;
	wire [64*LOGCMP_ISSUE_DEPTH-1 : 0] src2;

	wire  [64*LOGCMP_ISSUE_DEPTH-1:0] op1,
	wire  [64*LOGCMP_ISSUE_DEPTH-1:0] op2,

	wire [LOGCMP_ISSUE_DEPTH - 1:0] isUsi

generate
	for ( genvar i = 0; i < `LOGCMP_ISSUE_DEPTH; i = i + 1 ) begin

		assign { 
				rv64i_slti[i], rv64i_sltiu[i], rv64i_slt[i], rv64i_sltu[i],
				rv64i_xori[i], rv64i_ori[i], rv64i_andi[i], rv64i_xor[i], rv64i_or[i], rv64i_and[i],
				logCmp_pc[64*i +: 64], logCmp_imm[64*i +: 64],
				logCmp_rd0[(5+RNBIT)*i +: (5+RNBIT)], 
				logCmp_rs1[(5+RNBIT)*i +: (5+RNBIT)], 
				logCmp_rs2[(5+RNBIT)*i +: (5+RNBIT)]
				} = logCmp_issue_info[`LOGCMP_ISSUE_INFO_DW*i +: `LOGCMP_ISSUE_INFO_DW];

		assign rs1_ready[i] = wbBuf_qout[logCmp_rs1[(5+RNBIT)*i +: (5+RNBIT)]];
		assign rs2_ready[i] = wbBuf_qout[logCmp_rs2[(5+RNBIT)*i +: (5+RNBIT)]];
		

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

		assign src1[64*i +: 64] = regFileX_read[logCmp_rs1[(5+RNBIT)*i +: (5+RNBIT)]]
		assign src2[64*i +: 64] = regFileX_read[logCmp_rs2[(5+RNBIT)*i +: (5+RNBIT)]]

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

	//应该为组合逻辑实现
	lzp #(
		.CW$clog2(LOGCMP_ISSUE_DEPTH))
	) logCmp_RAWClear(
		.in_i(~logCmp_isClearRAW),
		.cnt_o(logCmp_buffer_pop_index),
		.empty_o(logCmp_all_RAW),
		.full_o(),
	);


	assign logCmp_exeparam_dnxt = { 
									logCmp_fun_slt[ logCmp_buffer_pop_index ],
									logCmp_fun_xor[ logCmp_buffer_pop_index ],
									logCmp_fun_or[ logCmp_buffer_index ],
									logCmp_fun_and[ logCmp_buffer_index ],

									logCmp_rd0[(5+RNBIT)*logCmp_buffer_pop_index +: (5+RNBIT)],
									op1[ 64*logCmp_buffer_pop_index +:64 ],
									op2[ 64*logCmp_buffer_pop_index +:64 ],

									isUsi[ logCmp_buffer_pop_index ],
									};

	wire logCmp_exeparam_vaild_qout;
	assign logCmp_exeparam_vaild_dnxt =  ~logCmp_all_RAW;

	assign logCmp_buffer_pop = ( logCmp_exeparam_ready & logCmp_exeparam_vaild_dnxt );

												

gen_dffr # (.DW(`LOGCMP_EXEPARAM_DW)) logCmp_exeparam ( .dnxt(logCmp_exeparam_dnxt), .qout(logCmp_exeparam_qout), .CLK(CLK), .RSTn(RSTn));
gen_dffr # (.DW(1)) logCmp_exeparam_vaild ( .dnxt(logCmp_exeparam_vaild_dnxt), .qout(logCmp_exeparam_vaild_qout), .CLK(CLK), .RSTn(RSTn));



































endmodule
