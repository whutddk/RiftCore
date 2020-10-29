/*
* @File name: lsu_issue
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-10-27 10:51:21
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-10-29 17:31:22
*/



module lsu_issue (


	//read 可以乱序
	input lu_issue_vaild,
	output lu_issue_ready,
	input [:] lu_issue_info_push,


	input lu_execute_ready,
	output lu_execute_vaild,
	output [ :0] lu_execute_info,


	//write 暂时只能顺序
	input su_issue_vaild,
	output su_issue_ready,
	input [:] su_issue_info_push,
	
	input su_execute_ready,
	output su_execute_vaild,
	output [ :0] su_execute_info,

	//fence
	input fence_issue_vaild,
	output fence_issue_ready,
	input [:] fence_issue_info_push,
	
	input fence_execute_ready,
	output fence_execute_vaild,
	output [ :0] fence_execute_info,




	//from regFile
	input [(64*RNDEPTH*32)-1:0] regFileX_read,
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



















	wire lu_issue_push;
	wire lu_issue_pop;
	wire [$clog2(LU_ISSUE_DEPTH)-1:0] lu_issue_pop_index;
	wire lu_buffer_full;
	wire [LU_ISSUE_DEPTH-1:0] lu_buffer_vaild_qout;
	wire [ : 0] lu_issue_info_qout;

	issue_buffer #
	(
		.DW(),
		.DP(LU_ISSUE_DEPTH),
	)
	lu_issue_buffer
	(

		.issue_info_push(lu_issue_info_push),
		.issue_push(lu_issue_push),
		.buffer_full(lu_buffer_full),

		.issue_pop(lu_issue_pop),
		.issue_pop_index(lu_issue_pop_index),
		.issue_info_qout(lu_issue_info_qout),
		.buffer_vaild_qout(lu_buffer_vaild_qout),

		.CLK(CLK),
		.RSTn(RSTn)
		
	);


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

	wire [64*LU_ISSUE_DEPTH - 1:0] lu_op1;

	wire [LU_ISSUE_DEPTH - 1:0] lu_isUsi;

generate
	for ( genvar i = 0; i < LU_ISSUE_DEPTH; i = i + 1 ) begin

		assign { 
				rv64i_lb[i], rv64i_lh[i], rv64i_lw[i], rv64i_ld[i], rv64i_lbu[i], rv64i_lhu[i], rv64i_lwu[i], 
				lu_imm[64*i +: 64],
				lu_rd0[(5+RNBIT)*i +: (5+RNBIT)],
				lu_rs1[(5+RNBIT)*i +: (5+RNBIT)]
				} = lu_issue_info_pop;

		assign lu_rs1_ready[i] = wbBuf_qout[adder_rs1[(5+RNBIT)*i +: (5+RNBIT)]];

		assign lu_isClearRAW[i] = lu_buffer_vaild_qout[i] & lu_rs1_ready;


		assign lu_fun_lb[i] = rv64i_lb[i] | rv64i_lbu[i];
		assign lu_fun_lh[i] = rv64i_lh[i] | rv64i_lhu[i];
		assign lu_fun_lw[i] = rv64i_lw[i] | rv64i_lwu[i];
		assign lu_fun_ld[i] = rv64i_ld[i];



		assign lu_op1[64*i +:64] = regFileX_read[lu_rs1[(5+RNBIT)*i +: (5+RNBIT)]] + lu_imm[64*i +: 64];

		assign lu_isUsi[i] = rv64i_lbu[i] | rv64i_lhu[i] | rv64i_lwu[i];

	end
endgenerate




wire lu_all_RAW;

	//应该为组合逻辑实现
	lzc #(
		.WIDTH(LU_ISSUE_DEPTH),
		.CNT_WIDTH($clog2(LU_ISSUE_DEPTH))
	) lu_RAWClear(
		.in_i(lu_isClearRAW),
		.cnt_o(lu_issue_pop_index),
		.empty_o(lu_all_RAW)
	);


	assign lu_execute_info = { 
								lu_fun_lb[lu_issue_pop_index],
								lu_fun_lh[lu_issue_pop_index],
								lu_fun_lw[lu_issue_pop_index],
								lu_fun_ld[lu_issue_pop_index],

								lu_rd0[(5+RNBIT)*lu_issue_pop_index +: (5+RNBIT)],
								lu_op1[ 64*lu_issue_pop_index +:64 ],

								lu_isUsi[ lu_issue_pop_index ]

								};


	assign lu_execute_vaild =  ~lu_all_RAW;



	assign lu_issue_push = ( lu_dispat_ready );
	assign lu_issue_pop = ( lu_execute_ready & lu_execute_vaild );

	// 现有vaild，表示信号准备好了，再有ready取信号。
	// ready需要取信号，必须有空间，即nofull或者full，但是同时pop了
	assign lu_dispat_ready = lu_dispat_vaild &
								( ~lu_buffer_full | lu_buffer_full & lu_issue_pop);			
								&
								~( fence_LAS & ~su_fifo_empty )
								&
								~( fence_LAL & (| lu_buffer_vaild_qout) )
								& 
								~(  fence_ALL & ~su_fifo_empty & (| lu_buffer_vaild_qout) );









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




















	wire su_issue_push;
	wire su_issue_pop;

	wire su_fifo_full;
	wire su_fifo_empty;
	wire [ : 0] su_issue_info_pop;




$warning("写外部存储的数据冒险暂时没有解决");
issue_fifo #(
	.DW(),
	.DP(SU_ISSUE_DEPTH),
)
su_issue_fifo
(
	.issue_info_push(su_issue_info_push),
	.issue_info_pop(su_issue_info_pop),

	.issue_push(su_issue_push),
	.issue_pop(su_issue_pop),
	.fifo_full(su_fifo_full),
	.fifo_empty(su_fifo_empty),

	.CLK(CLK),
	.RSTn(RSTn)
	
);


	wire rv64i_sb;
	wire rv64i_sh;
	wire rv64i_sw;
	wire rv64i_sd;

	wire su_rs1_ready;
	wire su_rs2_ready;

	wire [63:0] su_imm;

	wire [(5+RNBIT) - 1:0] su_rd0;
	wire [(5+RNBIT) - 1:0] su_rs1;

	wire [LU_ISSUE_DEPTH - 1:0] su_rs1_ready;
	wire [LU_ISSUE_DEPTH - 1:0] su_rs2_ready;


	wire su_isClearRAW;

	wire  [63:0] su_op1;
	wire  [63:0] su_op2;

	assign {
			rv64i_sb, rv64i_sh, rv64i_sw, rv64i_sd,
			su_imm,
			su_rs1,
			su_rs2

			} = su_issue_info_pop;


	assign su_rs1_ready = wbBuf_qout[rs1];
	assign su_rs2_ready = wbBuf_qout[rs2];

	assign su_isClearRAW = ( ~su_fifo_empty ) & 
											 su_rs1_ready & su_rs2_ready ;


	assign su_op1 = regFileX_read[rs1] + su_imm;
	assign su_op2 = regFileX_read[rs2];





	assign su_execute_info = { 
								rv64i_sb, rv64i_sh, rv64i_sw, rv64i_sd,

								su_op1,
								su_op2
								};

	assign su_execute_vaild = ~su_isClearRAW;


	assign su_issue_push = ( su_dispat_ready );
	assign su_issue_pop = ( su_execute_ready & su_execute_vaild );


	assign su_dispat_ready = su_dispat_vaild &
								( ~su_buffer_full | su_buffer_full & su_issue_pop)
								&
								~(fence_SAS & ~su_fifo_empty)
								&
								~(fence_SAL & (|lu_buffer_vaild_qout))
								&
								~(fence_ALL & ~su_fifo_empty & (|lu_buffer_vaild_qout) ) 
								;





// FFFFFFFFFFFFFFFFFFFFFFEEEEEEEEEEEEEEEEEEEEEENNNNNNNN        NNNNNNNN        CCCCCCCCCCCCCEEEEEEEEEEEEEEEEEEEEEE
// F::::::::::::::::::::FE::::::::::::::::::::EN:::::::N       N::::::N     CCC::::::::::::CE::::::::::::::::::::E
// F::::::::::::::::::::FE::::::::::::::::::::EN::::::::N      N::::::N   CC:::::::::::::::CE::::::::::::::::::::E
// FF::::::FFFFFFFFF::::FEE::::::EEEEEEEEE::::EN:::::::::N     N::::::N  C:::::CCCCCCCC::::CEE::::::EEEEEEEEE::::E
//   F:::::F       FFFFFF  E:::::E       EEEEEEN::::::::::N    N::::::N C:::::C       CCCCCC  E:::::E       EEEEEE
//   F:::::F               E:::::E             N:::::::::::N   N::::::NC:::::C                E:::::E             
//   F::::::FFFFFFFFFF     E::::::EEEEEEEEEE   N:::::::N::::N  N::::::NC:::::C                E::::::EEEEEEEEEE   
//   F:::::::::::::::F     E:::::::::::::::E   N::::::N N::::N N::::::NC:::::C                E:::::::::::::::E   
//   F:::::::::::::::F     E:::::::::::::::E   N::::::N  N::::N:::::::NC:::::C                E:::::::::::::::E   
//   F::::::FFFFFFFFFF     E::::::EEEEEEEEEE   N::::::N   N:::::::::::NC:::::C                E::::::EEEEEEEEEE   
//   F:::::F               E:::::E             N::::::N    N::::::::::NC:::::C                E:::::E             
//   F:::::F               E:::::E       EEEEEEN::::::N     N:::::::::N C:::::C       CCCCCC  E:::::E       EEEEEE
// FF:::::::FF           EE::::::EEEEEEEE:::::EN::::::N      N::::::::N  C:::::CCCCCCCC::::CEE::::::EEEEEEEE:::::E
// F::::::::FF           E::::::::::::::::::::EN::::::N       N:::::::N   CC:::::::::::::::CE::::::::::::::::::::E
// F::::::::FF           E::::::::::::::::::::EN::::::N        N::::::N     CCC::::::::::::CE::::::::::::::::::::E
// FFFFFFFFFFF           EEEEEEEEEEEEEEEEEEEEEENNNNNNNN         NNNNNNN        CCCCCCCCCCCCCEEEEEEEEEEEEEEEEEEEEEE


	wire fence_issue_push;
	wire fence_issue_pop;

	wire fence_fifo_full;
	wire fence_fifo_empty;
	wire [ : 0] fence_issue_info_pop;

issue_fifo #(
	.DW(),
	.DP(1),
)
fence_issue_fifo
(
	.issue_info_push(fence_issue_info_push),
	.issue_info_pop(fence_issue_info_pop),

	.issue_push(fence_issue_push),
	.issue_pop(fence_issue_pop),
	.fifo_full(fence_fifo_full),
	.fifo_empty(fence_fifo_empty),

	.CLK(CLK),
	.RSTn(RSTn)
	
);

	wire rv64zi_fence_i;
	wire rv64i_fence;
	wire [63:0] fence_imm;


	assign {
				rv64zi_fence_i, rv64i_fence,
				fence_imm
			} = fence_issue_info_pop;


	$warning("暂不支持TSO");
	$warning("暂不区分io和memory");


	wire [3:0] predecessor = fence_imm[7:4];
	wire [3:0] successor = fence_imm[3:0];

	wire fence_SAS = | (successor & 4'b0101) & (predecessor & 4'b0101);
	wire fence_SAL = | (successor & 4'b0101) & (predecessor & 4'b1010);
	wire fence_LAS = | (successor & 4'b1010) & (predecessor & 4'b0101);
	wire fence_LAL = | (successor & 4'b1010) & (predecessor & 4'b1010);
	wire fence_ALL = rv64zi_fence_i


	assign fence_execute_vaild = (~fence_fifo_empty) & 
									( (fence_SAS & su_fifo_empty)
										|
										(fence_SAL & (&(~lu_buffer_vaild_qout)))
										|
										( fence_LAS & su_fifo_empty )
										|
										( fence_LAL & (&(~lu_buffer_vaild_qout) ))
										| 
										(  fence_ALL & su_fifo_empty & (&(~lu_buffer_vaild_qout) ) )
									);



	assign fence_issue_push = ( fence_dispat_ready );
	assign fence_issue_pop = ( fence_execute_ready & fence_execute_vaild );


	assign fence_dispat_ready = fence_dispat_vaild &
								( ~fence_buffer_full | fence_buffer_full & fence_issue_pop);
												







endmodule
