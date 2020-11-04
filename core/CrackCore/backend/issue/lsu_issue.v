/*
* @File name: lsu_issue
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-10-27 10:51:21
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-11-04 11:16:23
*/



module lsu_issue (


	//read 可以乱序
	output lu_buffer_pop,
	output [$clog2(`ADDER_ISSUE_DEPTH)-1:0] lu_buffer_pop_index,
	input [`LU_ISSUE_DEPTH-1:0] lu_buffer_malloc,
	input [`LU_ISSUE_INFO_DW*`LU_ISSUE_DEPTH-1 : 0] lu_issue_info

	input lu_execute_ready,
	output lu_execute_vaild,
	output [ :0] lu_execute_info,


	//write 暂时只能顺序
	output su_fifo_pop,
	input su_fifo_empty,
	input [`SU_ISSUE_INFO_DW-1:0] su_issue_info,
	
	input su_execute_ready,
	output su_execute_vaild,
	output [ :0] su_execute_info,

	//from regFile
	input [(64*RNDEPTH*32)-1:0] regFileX_read,
	input [32*RNDEPTH-1 : 0] wbLog_qout,

	//from commit
	input suILP_ready
);







// LLLLLLLLLLL            UUUUUUUU     UUUUUUUU
// L:::::::::L            U::::::U     U::::::U
// L:::::::::L            U::::::U     U::::::U
// LL:::::::LL            UU:::::U     U:::::UU
//   L:::::L               U:::::U     U:::::U 
//   L:::::L               U:::::D     D:::::U 
//   L:::::L               U:::::D     D:::::U 
//   L:::::L               U:::::D     D:::::U 
//   L:::::L               U:::::D     D:::::U 
//   L:::::L               U:::::D     D:::::U 
//   L:::::L               U:::::D     D:::::U 
//   L:::::L         LLLLLLU::::::U   U::::::U 
// LL:::::::LLLLLLLLL:::::LU:::::::UUU:::::::U 
// L::::::::::::::::::::::L UU:::::::::::::UU  
// L::::::::::::::::::::::L   UU:::::::::UU    
// LLLLLLLLLLLLLLLLLLLLLLLL     UUUUUUUUU      





	wire [LU_ISSUE_DEPTH-1:0] rv64i_lb;
	wire [LU_ISSUE_DEPTH-1:0] rv64i_lh;
	wire [LU_ISSUE_DEPTH-1:0] rv64i_lw;
	wire [LU_ISSUE_DEPTH-1:0] rv64i_ld;

	wire [LU_ISSUE_DEPTH-1:0] rv64i_lbu;
	wire [LU_ISSUE_DEPTH-1:0] rv64i_lhu;
	wire [LU_ISSUE_DEPTH-1:0] rv64i_lwu;


	wire [64*LU_ISSUE_DEPTH - 1:0] lu_imm;

	wire [(5+RNBIT)*LU_ISSUE_DEPTH - 1:0] lu_rd0;
	wire [(5+RNBIT)*LU_ISSUE_DEPTH - 1:0] lu_rs1;

	wire [LU_ISSUE_DEPTH - 1:0] rs1_ready;
	wire [LU_ISSUE_DEPTH - 1:0] lu_isClearRAW;

	wire [LU_ISSUE_DEPTH - 1:0] lu_fun_lb;
	wire [LU_ISSUE_DEPTH - 1:0] lu_fun_lh;
	wire [LU_ISSUE_DEPTH - 1:0] lu_fun_lw;
	wire [LU_ISSUE_DEPTH - 1:0] lu_fun_ld;

	wire [64*LU_ISSUE_DEPTH - 1:0] op1;

	wire [LU_ISSUE_DEPTH - 1:0] lu_isUsi;

generate
	for ( genvar i = 0; i < LU_ISSUE_DEPTH; i = i + 1 ) begin

		assign { 
				rv64i_lb[i], rv64i_lh[i], rv64i_lw[i], rv64i_ld[i], rv64i_lbu[i], rv64i_lhu[i], rv64i_lwu[i], 
				lu_imm[64*i +: 64],
				lu_rd0[(5+RNBIT)*i +: (5+RNBIT)],
				lu_rs1[(5+RNBIT)*i +: (5+RNBIT)]
				} = lu_issue_info[`LU_ISSUE_INFO_DW*i +: `LU_ISSUE_INFO_DW];

		assign rs1_ready[i] = wbBuf_qout[lu_rs1[(5+RNBIT)*i +: (5+RNBIT)]];

		assign lu_isClearRAW[i] = lu_buffer_malloc[i] & rs1_ready[i];


		assign lu_fun_lb[i] = rv64i_lb[i] | rv64i_lbu[i];
		assign lu_fun_lh[i] = rv64i_lh[i] | rv64i_lhu[i];
		assign lu_fun_lw[i] = rv64i_lw[i] | rv64i_lwu[i];
		assign lu_fun_ld[i] = rv64i_ld[i];



		assign op1[64*i +:64] = regFileX_read[lu_rs1[(5+RNBIT)*i +: (5+RNBIT)]] + lu_imm[64*i +: 64];

		assign lu_isUsi[i] = rv64i_lbu[i] | rv64i_lhu[i] | rv64i_lwu[i];

	end
endgenerate




wire lu_all_RAW;

	//应该为组合逻辑实现
	lzp #(
		.CW($clog2(LU_ISSUE_DEPTH))
	) lu_RAWClear(
		.in_i(~lu_isClearRAW),
		.cnt_o(lu_buffer_pop_index),
		.empty_o(lu_all_RAW)
	);


	assign lu_execute_info = { 
								lu_fun_lb[lu_buffer_pop_index],
								lu_fun_lh[lu_buffer_pop_index],
								lu_fun_lw[lu_buffer_pop_index],
								lu_fun_ld[lu_buffer_pop_index],

								lu_rd0[(5+RNBIT)*lu_buffer_pop_index +: (5+RNBIT)],
								op1[ 64*lu_buffer_pop_index +:64 ],

								lu_isUsi[ lu_buffer_pop_index ]

								};


	assign lu_execute_vaild =  ~lu_all_RAW;


	assign lu_buffer_pop = ( lu_execute_ready & lu_execute_vaild );










//    SSSSSSSSSSSSSSS UUUUUUUU     UUUUUUUU
//  SS:::::::::::::::SU::::::U     U::::::U
// S:::::SSSSSS::::::SU::::::U     U::::::U
// S:::::S     SSSSSSSUU:::::U     U:::::UU
// S:::::S             U:::::U     U:::::U 
// S:::::S             U:::::D     D:::::U 
//  S::::SSSS          U:::::D     D:::::U 
//   SS::::::SSSSS     U:::::D     D:::::U 
//     SSS::::::::SS   U:::::D     D:::::U 
//        SSSSSS::::S  U:::::D     D:::::U 
//             S:::::S U:::::D     D:::::U 
//             S:::::S U::::::U   U::::::U 
// SSSSSSS     S:::::S U:::::::UUU:::::::U 
// S::::::SSSSSS:::::S  UU:::::::::::::UU  
// S:::::::::::::::SS     UU:::::::::UU    
//  SSSSSSSSSSSSSSS         UUUUUUUUU      








initial $info("写存储器必须保证前序指令已经commit，本指令不会被撤销，需要从commit处顺序fifo跟踪");

	wire rv64i_sb;
	wire rv64i_sh;
	wire rv64i_sw;
	wire rv64i_sd;

	wire rs1_ready;
	wire rs2_ready;

	wire [63:0] su_imm;

	wire [(5+RNBIT) - 1:0] su_rd0;
	wire [(5+RNBIT) - 1:0] su_rs1;

	wire su_isClearRAW;

	wire [63:0] op1;
	wire [63:0] op2;

	assign {
			rv64i_sb, rv64i_sh, rv64i_sw, rv64i_sd,
			su_imm,
			su_rs1,
			su_rs2

			} = su_issue_info;


	assign rs1_ready = wbBuf_qout[su_rs1];
	assign rs2_ready = wbBuf_qout[su_rs2];

	assign su_isClearRAW = ( ~su_fifo_empty ) & 
											 rs1_ready & rs2_ready ;


	assign op1 = regFileX_read[su_rs1] + su_imm;
	assign op2 = regFileX_read[su_rs2];





	assign su_execute_info = { 
								rv64i_sb, rv64i_sh, rv64i_sw, rv64i_sd,

								op1,
								op2
								};

	assign su_execute_vaild = su_isClearRAW & suILP_ready;
	assign su_issue_pop = ( su_execute_ready & su_execute_vaild );





endmodule
