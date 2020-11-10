/*
* @File name: lsu
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-10-29 17:31:40
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-11-10 14:14:29
*/
`timescale 1 ns / 1 ps
`include "define.vh"

module lsu #
	(
		parameter LU_DW = `LU_EXEPARAM_DW,
		parameter SU_DW = `SU_EXEPARAM_DW,

		parameter AW = 14
	)
	(


	//read 可以乱序
	output lu_exeparam_ready,
	input lu_exeparam_vaild,
	input [LU_DW-1:0] lu_exeparam,


	//write 暂时只能顺序
	output su_exeparam_ready,
	input su_exeparam_vaild,
	input [SU_DW-1:0] su_exeparam,
	
	output lsu_writeback_vaild,
	output [63:0] lsu_res_qout,
	output [(5+`RB-1):0] lsu_rd0_qout,

	input flush,
	input CLK,
	input RSTn
);

initial $warning("定义load优先级高于store");
wire store_fun = su_exeparam_vaild & ~lu_exeparam_vaild;
wire load_fun = lu_exeparam_vaild;




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




	wire lu_fun_lb;
	wire lu_fun_lh;
	wire lu_fun_lw;
	wire lu_fun_ld;

	wire [(5+`RB-1):0] lu_rd0;
	wire [63:0] lu_op1;

	wire lu_isUsi;

	assign { 
			lu_fun_lb,
			lu_fun_lh,
			lu_fun_lw,
			lu_fun_ld,

			lu_rd0,
			lu_op1,

			lu_isUsi

			} = lu_exeparam;



wire [2:0] luAddr_align = lu_op1[2:0];

wire [7:0] loadB_align = data_qout[ luAddr_align +: 8 ];
wire [15:0] loadH_align = data_qout[ luAddr_align +: 16 ];
wire [31:0] loadW_align = data_qout[ luAddr_align +: 32 ];
wire [63:0] loadD_align = data_qout[ luAddr_align +: 64 ];

wire [63:0] lsu_res_dnxt = 
			({64{lu_fun_lb}} & ( lu_isUsi ? {56'b0,loadB_align} : {{56{loadB_align[7]}},loadB_align} ))
			|
			({64{lu_fun_lh}} & ( lu_isUsi ? {48'b0,loadH_align} : {{48{loadH_align[15]}},loadH_align} ))
			|
			({64{lu_fun_lw}} & ( lu_isUsi ? {32'b0,loadW_align} : {{32{loadW_align[31]}},loadW_align} ))
			|
			({64{lu_fun_ld}} & loadD_align);


wire [63:0] lu_addrA_Raw = lu_op1[3] ? lu_op1 + 64'b1000 : lu_op1;
wire [63:0] lu_addrB_Raw = lu_op1[3] ? lu_op1 : lu_op1 | 64'b1000;
wire [127:0] data_qout = lu_op1[3] ? { data_qout_A, data_qout_B} : { data_qout_B, data_qout_A};


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



	wire rv64i_sb;
	wire rv64i_sh;
	wire rv64i_sw;
	wire rv64i_sd;
	wire [63:0] su_op1;
	wire [63:0] su_op2;



	assign { 
			rv64i_sb, rv64i_sh, rv64i_sw, rv64i_sd,

			su_op1,
			su_op2
			} = su_exeparam;



wire [63:0] su_addrA_Raw = su_op1[3] ? su_op1 + 64'b1000 : su_op1;
wire [63:0] su_addrB_Raw = su_op1[3] ? su_op1 : su_op1 | 64'b1000;

wire [2:0] su_addr_align = su_op1[2:0];

wire [63:0] data_dnxt_A;
wire [63:0] data_dnxt_B;

wire wen_A = store_fun;
wire wen_B = store_fun;

wire [7:0] wmask_A;
wire [7:0] wmask_B;

wire [63:0] data_qout_A;
wire [63:0] data_qout_B;


wire [15:0] mask = ({16{rv64i_sb}} & ( 16'b1 << su_addr_align ))
					|
					({16{rv64i_sh}} & ( 16'b11 << su_addr_align ))
					|
					({16{rv64i_sw}} & ( 16'b1111 << su_addr_align ))
					|
					({16{rv64i_sd}} & ( 16'b11111111 << su_addr_align ));


assign { wmask_B, wmask_A } = su_op1[3] ? {mask[7:0],mask[15:8]} :mask;

wire [127:0] data_dxnt = su_op2 << {su_addr_align,3'b0};
assign {data_dnxt_B, data_dnxt_A} = su_op1[3] ? {data_dxnt[63:0],data_dxnt[127:64]} : data_dxnt;


wire [AW-1:0] addr_A = ({AW{load_fun}} & lu_addrA_Raw[3 +:AW])
					|
					({AW{store_fun}} &  su_addrA_Raw[3+:AW])
					;
wire [AW-1:0] addr_B = ({AW{load_fun}} & lu_addrB_Raw[3 +:AW])
					|
					({AW{store_fun}} &  su_addrB_Raw[3 +:AW])
					;



dtcm #(.DW(64), .AW(AW)) 
i_dtcm_A
(
	.addr(addr_A),
	.data_dxnt(data_dnxt_A),
	.wen(wen_A),
	.wmask(wmask_A),
	.data_qout(data_qout_A),

	.CLK(CLK),
	.RSTn(RSTn)

);


dtcm #( .DW(64), .AW(AW))
i_dtcm_B
(
	.addr(addr_B),
	.data_dxnt(data_dnxt_B),
	.wen(wen_B),
	.wmask(wmask_B),
	.data_qout(data_qout_B),

	.CLK(CLK),
	.RSTn(RSTn)

);




	initial $warning("直接握手前提是单拍出结果");
	wire memory_ready = 1'b1;

	initial $info("定义load优先级高于store");
	assign lu_exeparam_ready = memory_ready;
	assign su_exeparam_ready = memory_ready & ~lu_exeparam_vaild;


	wire lsu_writeback_vaild_dnxt = (lu_exeparam_vaild & lu_exeparam_ready)
									| (su_exeparam_vaild & su_exeparam_ready);



	wire [(5+`RB)-1 : 0] lsu_rd0_dnxt = ({(5+`RB){load_fun}} & lu_rd0)
							|
							({(5+`RB){store_fun}} & 'd0);


wire lsu_vaild_dnxt = (lu_exeparam_vaild | su_exeparam_vaild);
wire lsu_vaild_qout;
assign lsu_writeback_vaild = lsu_vaild_qout & memory_ready;


gen_dffr # (.DW((5+`RB))) lsu_rd0 ( .dnxt(lsu_rd0_dnxt), .qout(lsu_rd0_qout), .CLK(CLK), .RSTn(RSTn));
gen_dffr # (.DW(64)) lsu_res ( .dnxt(lsu_res_dnxt), .qout(lsu_res_qout), .CLK(CLK), .RSTn(RSTn));
gen_dffr # (.DW(1)) lsu_vaild ( .dnxt(lu_exeparam_vaild&(~flush)), .qout(lsu_vaild_qout), .CLK(CLK), .RSTn(RSTn));




endmodule














