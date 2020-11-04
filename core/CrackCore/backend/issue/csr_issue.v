/*
* @File name: csr_issue
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-10-27 10:51:47
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-11-04 10:31:57
*/



module csr_issue (
	
	//from fifo
	output csr_fifo_pop,
	input csr_fifo_empty,
	input [`CSR_ISSUE_INFO_DW-1:0] csr_issue_info,

	output csr_execute_vaild,
	output [ :0] csr_execute_info,

	//from regFile
	input [(64*RNDEPTH*32)-1:0] regFileX_read,
	input [32*RNDEPTH-1 : 0] wbLog_qout

	//from commit
	input csrILP_ready,
);



initial $info("操作csr必须保证前序指令已经commit，本指令不会被撤销，需要从commit处顺序fifo跟踪");

	//csr must be ready
	wire csr_execute_ready = 1'b1;


	wire rv64csr_rw;
	wire rv64csr_rs;
	wire rv64csr_rc;
	wire rv64csr_rwi;
	wire rv64csr_rsi;
	wire rv64csr_rci;

	wire [(5+RNBIT)-1:0] csr_rd0;
	wire [(5+RNBIT)-1:0] csr_rs1;
	wire [11:0] csr_imm


	assign { 
			rv64csr_rw, rv64csr_rs, rv64csr_rc, rv64csr_rwi, rv64csr_rsi, rv64csr_rci,
			csr_imm, csr_rd0, csr_rs1


			} = csr_issue_info;







	wire csr_rw = rv64csr_rw | rv64csr_rwi;
	wire csr_rs = rv64csr_rs | rv64csr_rsi;
	wire csr_rc = rv64csr_rc | rv64csr_rci;

	wire rs1_ready = wbBuf_qout[csr_rs1];

	wire csr_isClearRAW = ( ~csr_fifo_empty ) & ( 
													((rv64csr_rw | rv64csr_rs | rv64csr_rc ) & rs1_ready)
													|
													(rv64csr_rwi | rv64csr_rsi | rv64csr_rci )
												);

	wire [63:0] op = ({64{rv64csr_rw | rv64csr_rs | rv64csr_rc}} & regFileX_read[rs1])
					|
					({64{rv64csr_rwi | rv64csr_rsi | rv64csr_rci}} & csr_rs1 );

	wire [11:0] addr = csr_imm;


	assign csr_execute_info = { 
			csr_rw,
			csr_rs,
			csr_rc,

			csr_rd0,
			op,
			addr

			};


	assign csr_execute_vaild = csr_isClearRAW & csrILP_ready,

	assign csr_fifo_pop = csr_execute_vaild & csr_execute_ready;





endmodule











