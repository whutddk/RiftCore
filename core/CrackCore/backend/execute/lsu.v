/*
* @File name: lsu
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-10-29 17:31:40
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-10-29 20:11:13
*/



module lsu (


	//read 可以乱序
	output lu_execute_ready,
	input lu_execute_vaild,
	input [ :0] lu_execute_info_dnxt,


	//write 暂时只能顺序
	output su_execute_ready,
	input su_execute_vaild,
	input [ :0] su_execute_info,

	//fence
	output fence_execute_ready,
	input fence_execute_vaild,
	
	output lsu_writeback_vaild,
	output [63:0] lsu_res,
	output [(5+RNBIT-1):0] lsu_rd0,


);

$warning("定义store优先级高于load，fence与store，load不会同时出现");
wire store_fun = su_execute_vaild;
wire load_fun = lu_execute_vaild & ~su_execute_vaild;
wire fence_fun = fence_execute_vaild;



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











wire lu_fun_lb_dnxt;
wire lu_fun_lh_dnxt;
wire lu_fun_lw_dnxt;
wire lu_fun_ld_dnxt;
wire [(5+RNBIT)-1:0] lu_rd0_dnxt;
wire [(5+RNBIT)-1:0] lu_op1_dnxt;
wire lu_isUsi_dnxt;

wire lu_fun_lb_qout;
wire lu_fun_lh_qout;
wire lu_fun_lw_qout;
wire lu_fun_ld_qout;
wire [(5+RNBIT)-1:0] lu_rd0_qout;
wire [(5+RNBIT)-1:0] lu_op1_qout;
wire lu_isUsi_qout;
wire [] lu_execute_info_qout;


	assign { 
			lu_fun_lb_dnxt,
			lu_fun_lh_dnxt,
			lu_fun_lw_dnxt,
			lu_fun_ld,

			lu_rd0_dnxt,
			lu_op1_dnxt,

			lu_isUsi_dnxt

			} = lu_execute_info_dnxt;

	assign { 
			lu_fun_lb_qout,
			lu_fun_lh_qout,
			lu_fun_lw_qout,
			lu_fun_ld_qout,

			lu_rd0_qout,
			lu_op1_qout,

			lu_isUsi_qout

			} = lu_execute_info_qout;

gen_dffr lu_execute_info () 



wire [63:0] load_res;



wire [2:0] lu_addr_align = lu_op1_qout[2:0];

wire [7:0] loadb_align = data_qout[ luaddr_align +: 8 ];
wire [15:0] loadh_align = data_qout[ luaddr_align +: 16 ];
wire [31:0] loadw_align = data_qout[ luaddr_align +: 32 ];
wire [63:0] loadd_align = data_qout[ luaddr_align +: 64 ];

assign load_res = 
			({64{lu_fun_lb}} & ( lu_isUsi_qout ? {56'b0,loadb_align} : {56{loadb_align[7]},loadb_align} ))
			|
			({64{lu_fun_lh}} & ( lu_isUsi_qout ? {48'b0,loadb_align} : {48{loadb_align[15]},loadb_align} ))
			|
			({64{lu_fun_lw}} & ( lu_isUsi_qout ? {32'b0,loadb_align} : {32{loadb_align[31]},loadb_align} ))
			|
			({64{lu_fun_ld}} & loadd_align);


			






wire [63:0] lu_addrA_Raw = lu_op1_dnxt[3] ? lu_op1_dnxt + 64'b1000 : lu_op1_dnxt;
wire [63:0] lu_addrB_Raw = lu_op1_dnxt[3] ? lu_op1_dnxt : lu_op1_dnxt | 64'b1000;
wire [127:0] data_qout = lu_op1_dnxt[3] ? { data_qout_A, data_qout_B} : { data_qout_B, data_qout_A};











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
			} = su_execute_info;



wire [63:0] su_addrA_Raw = su_op1[3] ? su_op1 + 64'b1000 : su_op1;
wire [63:0] su_addrB_Raw = su_op1[3] ? su_op1 : su_op1 | 64'b1000;

wire [2:0] su_addr_align = su_op1[2:0];



wire [15:0] mask = ({16{rv64i_sb}} & ( 16'b1 << su_addr_align ))
					|
					({16{rv64i_sh}} & ( 16'b11 << su_addr_align ))
					|
					({16{rv64i_sw}} & ( 16'b1111 << su_addr_align ))
					|
					({16{rv64i_sd}} & ( 16'b11111111 << su_addr_align ));






assign { wmask_B, wmask_A } = su_op1[3] ? {mask[7:0],mask[15:8]} :mask;

wire [127:0] data_dxnt = su_op2 << {su_addr_align,3'b0};
assign {data_dxnt_B, data_dxnt_A} = su_op1[3] ? {data_dxnt[63:0],data_dxnt[127:64]} : data_dxnt;


wire [AW-1:0] addr_A = ({AW{load_fun}} & lu_addrA_Raw[3 +:AW])
					|
					({AW{store_fun}} &  su_addrA_Raw[3+:AW])
					;
wire [AW-1:0] addr_B = ({AW{load_fun}} & lu_addrB_Raw[3 +:AW])
					|
					({AW{store_fun}} &  su_addrB_Raw[3 +:AW])
					;

wire [63:0] data_dxnt_A;
wire [63:0] data_dxnt_B;

wire wen_A = store_fun;
wire wen_B = store_fun;

wire [7:0] wmask_A;
wire [7:0] wmask_B;

wire [63:0] data_qout_A;
wire [63:0] data_qout_B;


dtcm #
(
	.DW(64),
	.AW(AW),
) i_dtcm_A
(

	.addr(addr_A),
	.data_dxnt(data_dxnt_A),
	.wen(wen_A),
	.wmask(wmask_A)
	.data_qout(data_qout_A),

	.CLK(CLK),
	.RSTn(RSTn)

);


dtcm #
(
	.DW(64),
	.AW(AW),
) i_dtcm_B
(

	.addr(addr_B),
	.data_dxnt(data_dxnt_B),
	.wen(wen_B),
	.wmask(wmask_B)
	.data_qout(data_qout_B),

	.CLK(CLK),
	.RSTn(RSTn)

);


	$warning("定义store优先级高于load，fence与store，load不会同时出现");
	assign lu_execute_ready = lsu_writeback_vaild_qout & lu_execute_vaild & ~su_execute_vaild;
	assign su_execute_ready = lsu_writeback_vaild_qout & su_execute_vaild;
	assign fence_execute_ready = lsu_writeback_vaild_qout;

	$warning("直接握手前提是单拍出结果");
	wire lsu_writeback_vaild_dnxt = lu_execute_ready | su_execute_ready | fence_execute_ready;
	wire lsu_writeback_vaild_qout;

	gen_dffr lsu_writeback_vaild ();

	assign lsu_writeback_vaild = lsu_writeback_vaild_qout



	assign lsu_res = load_res;
	assign lsu_rd0 = ({(5+RNBIT){load_fun}} & lu_rd0_qout)
					|
					({(5+RNBIT){store_fun}} & 'd0)
					|
					({(5+RNBIT){fence_fun}} & 'd0);










endmodule














