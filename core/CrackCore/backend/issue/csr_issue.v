/*
* @File name: csr_issue
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-10-27 10:51:47
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-11-05 17:07:23
*/

`include "define.vh"

module csr_issue #
	(
		parameter DW = `CSR_ISSUE_INFO_DW,
		parameter EXE_DW = `CSR_EXEPARAM_DW
	)
	(
	
	//from fifo
	output csr_fifo_pop,
	input csr_fifo_empty,
	input [DW-1:0] csr_issue_info,

	output csr_exeparam_vaild_qout,
	output [EXE_DW-1 :0] csr_exeparam_qout,

	//from regFile
	input [(64*`RP*32)-1:0] regFileX_read,
	input [32*`RP-1 : 0] wbLog_qout,

	//from commit
	input csrILP_ready,

	input CLK,
	input RSTn
);



initial $info("操作csr必须保证前序指令已经commit，本指令不会被撤销，需要从commit处顺序fifo跟踪");

	//csr must be ready
	wire csr_exeparam_ready = 1'b1;


	wire rv64csr_rw;
	wire rv64csr_rs;
	wire rv64csr_rc;
	wire rv64csr_rwi;
	wire rv64csr_rsi;
	wire rv64csr_rci;

	wire [(5+`RB)-1:0] csr_rd0;
	wire [(5+`RB)-1:0] csr_rs1;
	wire [11:0] csr_imm;


	assign { 
			rv64csr_rw, rv64csr_rs, rv64csr_rc, rv64csr_rwi, rv64csr_rsi, rv64csr_rci,
			csr_imm, csr_rd0, csr_rs1


			} = csr_issue_info;







	wire csr_rw = rv64csr_rw | rv64csr_rwi;
	wire csr_rs = rv64csr_rs | rv64csr_rsi;
	wire csr_rc = rv64csr_rc | rv64csr_rci;

	wire rs1_ready = wbLog_qout[csr_rs1];

	wire csr_isClearRAW = ( ~csr_fifo_empty ) & ( 
													((rv64csr_rw | rv64csr_rs | rv64csr_rc ) & rs1_ready)
													|
													(rv64csr_rwi | rv64csr_rsi | rv64csr_rci )
												);

	wire [63:0] op = ({64{rv64csr_rw | rv64csr_rs | rv64csr_rc}} & regFileX_read[csr_rs1])
					|
					({64{rv64csr_rwi | rv64csr_rsi | rv64csr_rci}} & csr_rs1 );

	wire [11:0] addr = csr_imm;


	wire [EXE_DW-1:0] csr_exeparam_dnxt = { 
			csr_rw,
			csr_rs,
			csr_rc,

			csr_rd0,
			op,
			addr

			};

	wire csr_exeparam_vaild_qout;
	wire csr_exeparam_vaild_dnxt = csr_isClearRAW & csrILP_ready;

	assign csr_fifo_pop = csr_exeparam_vaild_dnxt & csr_exeparam_ready;


	gen_dffr # (.DW(EXE_DW)) csr_exeparam ( .dnxt(csr_exeparam_dnxt), .qout(csr_exeparam_qout), .CLK(CLK), .RSTn(RSTn));
	gen_dffr # (.DW(1)) csr_exeparam_vaild ( .dnxt(csr_exeparam_vaild_dnxt), .qout(csr_exeparam_vaild_qout), .CLK(CLK), .RSTn(RSTn));




endmodule











