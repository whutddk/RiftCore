/*
* @File name: adder_issue
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-09-11 15:39:38
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-11-04 14:10:36
*/



//保证进入的指令只有真相关数据冒险
//根据单元空闲情况及RAW相关性处理

module adder_issue (
	
	//from buffer
	output adder_buffer_pop,
	output [$clog2(`ADDER_ISSUE_DEPTH)-1:0] adder_buffer_pop_index,
	input [`ADDER_ISSUE_DEPTH-1:0] adder_buffer_malloc,
	input [`ADDER_ISSUE_INFO_DW*`ADDER_ISSUE_DEPTH-1 : 0] adder_issue_info
	//from execute

	// input adder_execute_ready,
	output adder_exeparam_vaild_qout,
	output [`ADDER_EXEPARAM_DW-1:0] adder_exeparam_qout,

	//from regFile
	input [(64*RNDEPTH*32)-1:0] regFileX_read,
	input [32*RNDEPTH-1 : 0] wbLog_qout,

	input CLK,
	input RSTn

);

	//adder must be ready
	wire adder_exeparam_ready = 1'b1;



	wire [ADDER_ISSUE_DEPTH - 1:0] rv64i_lui;
	wire [ADDER_ISSUE_DEPTH - 1:0] rv64i_auipc;
	wire [ADDER_ISSUE_DEPTH - 1:0] rv64i_addi;
	wire [ADDER_ISSUE_DEPTH - 1:0] rv64i_addiw;

	wire [ADDER_ISSUE_DEPTH - 1:0] rv64i_add;
	wire [ADDER_ISSUE_DEPTH - 1:0] rv64i_addw;
	wire [ADDER_ISSUE_DEPTH - 1:0] rv64i_sub;
	wire [ADDER_ISSUE_DEPTH - 1:0] rv64i_subw;


	wire [64*ADDER_ISSUE_DEPTH - 1:0] adder_pc;
	wire [64*ADDER_ISSUE_DEPTH - 1:0] adder_imm;

	wire [(5+RNBIT)*ADDER_ISSUE_DEPTH - 1:0] adder_rd0;
	wire [(5+RNBIT)*ADDER_ISSUE_DEPTH - 1:0] adder_rs1;
	wire [(5+RNBIT)*ADDER_ISSUE_DEPTH - 1:0] adder_rs2;

	wire [ADDER_ISSUE_DEPTH - 1:0] rs1_ready;
	wire [ADDER_ISSUE_DEPTH - 1:0] rs2_ready;

	wire [ADDER_ISSUE_DEPTH - 1:0] adder_fun_add;
	wire [ADDER_ISSUE_DEPTH - 1:0] adder_fun_sub;

	wire [64*ADDER_ISSUE_DEPTH-1 : 0] src1;
	wire [64*ADDER_ISSUE_DEPTH-1 : 0] src2;

	wire  [64*ADDER_ISSUE_DEPTH-1:0] op1;
	wire  [64*ADDER_ISSUE_DEPTH-1:0] op2;

	wire [ADDER_ISSUE_DEPTH-1:0] is32;


generate
	for ( genvar i = 0; i < `ADDER_ISSUE_DEPTH; i = i + 1 ) begin

		assign { rv64i_lui[i], rv64i_auipc[i], 
				rv64i_addi[i], rv64i_addiw[i], rv64i_add[i], rv64i_addw[i], rv64i_sub[i], rv64i_subw[i],
				
				adder_pc[64*i +: 64], adder_imm[64*i +: 64],
				adder_rd0[(5+RNBIT)*i +: (5+RNBIT)], 
				adder_rs1[(5+RNBIT)*i +: (5+RNBIT)], 
				adder_rs2[(5+RNBIT)*i +: (5+RNBIT)]
				} = adder_issue_info[`ADDER_ISSUE_INFO_DW*i +: `ADDER_ISSUE_INFO_DW];

		assign rs1_ready[i] = wbBuf_qout[adder_rs1[(5+RNBIT)*i +: (5+RNBIT)]];
		assign rs2_ready[i] = wbBuf_qout[adder_rs2[(5+RNBIT)*i +: (5+RNBIT)]];
		
		assign adder_isClearRAW[i] = ( adder_buffer_malloc[i] ) & 
										(
										  rv64i_lui[i]
										| rv64i_auipc[i]
										| ( rv64i_addi[i] & rs1_ready[i] )
										| ( rv64i_addiw[i] & rs1_ready[i] )
										| ( rv64i_add[i] & rs1_ready[i] & rs2_ready[i] )
										| ( rv64i_addw[i] & rs1_ready[i] & rs2_ready[i] )

										| ( rv64i_sub[i] & rs1_ready[i] & rs2_ready[i] )
										| ( rv64i_subw[i] & rs1_ready[i] & rs2_ready[i] )
									);


		assign adder_fun_add[i] = rv64i_lui[i] | rv64i_auipc[i] | rv64i_addi[i] | rv64i_addiw[i] | rv64i_add[i] | rv64i_addw[i];
		assign adder_fun_sub[i] = rv64i_sub[i] | rv64i_subw[i];

		assign src1[64*i +: 64] = regFileX_read[adder_rs1[(5+RNBIT)*i +: (5+RNBIT)]]
		assign src2[64*i +: 64] = regFileX_read[adder_rs2[(5+RNBIT)*i +: (5+RNBIT)]]

		assign op1[64*i +:64] = ( {64{rv64i_lui[i]}} & 64'h0)
								| ( {64{rv64i_auipc[i]}} & adder_pc[64*i +: 64] )
								| ( {64{rv64i_addi[i]}} & src1[64*i +: 64] )
								| ( {64{rv64i_addiw[i]}} & src1[64*i +: 64] )
								| ( {64{rv64i_add[i]}} & src1[64*i +: 64] )
								| ( {64{rv64i_addw[i]}} & src1[64*i +: 64] )

								| ( {64{rv64i_sub[i]}} & src1[64*i +: 64] )
								| ( {64{rv64i_subw[i]}} & src1[64*i +: 64] )

								;

		assign op2[64*i +:64] = ( {64{rv64i_lui[i]}} & adder_imm[64*i +: 64])
								| ( {64{rv64i_auipc[i]}} & adder_imm[64*i +: 64])
								| ( {64{rv64i_addi[i]}} & adder_imm[64*i +: 64] )
								| ( {64{rv64i_addiw[i]}} & adder_imm[64*i +: 64] )
								| ( {64{rv64i_add[i]}} & src2[64*i +: 64] )
								| ( {64{rv64i_addw[i]}} & src2[64*i +: 64] )

								| ( {64{rv64i_sub[i]}} & src2[64*i +: 64] )
								| ( {64{rv64i_subw[i]}} & src2[64*i +: 64] )

								;


		assign is32[i] = rv64i_addiw[i]
						| rv64i_addw[i]
						| rv64i_subw[i];


	end
endgenerate


	wire adder_all_RAW;


	lzp #(
		.CW($clog2(`ADDER_ISSUE_DEPTH))
	) adder_RAWClear(
		.in_i(~adder_isClearRAW),
		.pos_o(adder_buffer_pop_index),
		.empty_o(adder_all_RAW),
		.full_o(),
	);

	wire [`ADDER_EXEPARAM_DW-1:0] adder_exeparam_dnxt = adder_exeparam_vaild_dnxt ? { 
								adder_fun_add[ adder_buffer_pop_index ],
								adder_fun_sub[ adder_buffer_pop_index ],

								adder_rd0[(5+RNBIT)*adder_buffer_pop_index +: (5+RNBIT)],
								op1[ 64*adder_buffer_pop_index +:64 ],
								op2[ 64*adder_buffer_pop_index +:64 ],

								is32[ adder_buffer_pop_index ]

								}
								: adder_exeparam_qout;

	wire adder_exeparam_vaild_qout;
	assign adder_exeparam_vaild_dnxt =  ~adder_all_RAW;


	assign adder_buffer_pop = ( adder_execute_ready & adder_exeparam_vaild_dnxt );






//T4

gen_dffr # (.DW(`ADDER_EXEPARAM_DW)) adder_exeparam ( .dnxt(adder_exeparam_dnxt), .qout(adder_exeparam_qout), .CLK(CLK), .RSTn(RSTn));
gen_dffr # (.DW(1)) adder_exeparam_vaild ( .dnxt(adder_exeparam_vaild_dnxt), .qout(adder_exeparam_vaild_qout), .CLK(CLK), .RSTn(RSTn));


























endmodule
