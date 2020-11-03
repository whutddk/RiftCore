/*
* @File name: csr_issue
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-10-27 10:51:47
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-11-03 20:06:24
*/



module csr_issue (
	
	//from buffer
	output csr_buffer_pop,
	output [$clog2(`CSR_ISSUE_DEPTH)-1:0] csr_buffer_pop_index,
	input [`CSR_ISSUE_DEPTH-1:0] csr_buffer_malloc,
	input [`CSR_ISSUE_INFO_DW*`CSR_ISSUE_DEPTH-1 : 0] csr_issue_info

	
	input csr_execute_ready,
	output csr_execute_vaild,
	output [ :0] csr_execute_info,


	//from regFile
	input [(64*RNDEPTH*32)-1:0] regFileX_read,
	input [32*RNDEPTH-1 : 0] wbLog_qout


	
);



$error("操作csr必须保证前序指令已经commit，本指令不会被撤销，需要从commit处顺序fifo跟踪");


wire [(5+RNBIT)-1:0] rd0;
wire [(5+RNBIT)-1:0] rs1;
wire [11:0] imm


	assign { 
			rv64csr_rw, rv64csr_rs, rv64csr_rc, rv64csr_rwi, rv64csr_rsi, rv64csr_rci,
			imm, rd0, rs1


			} = csr_issue_info;







wire csr_rw = rv64csr_rw | rv64csr_rwi;
wire csr_rs = rv64csr_rs | rv64csr_rsi;
wire csr_rc = rv64csr_rc | rv64csr_rci;

wire csr_rs1_ready = wbBuf_qout[rs1];

wire csr_isClearRAW = ( ~csr_fifo_empty ) & ( 
												((rv64csr_rw | rv64csr_rs | rv64csr_rc ) & csr_rs1_ready)
												|
												(rv64csr_rwi | rv64csr_rsi | rv64csr_rci )
											);

wire [63:0] op = ({64{rv64csr_rw | rv64csr_rs | rv64csr_rc}} & regFileX_read[rs1])
				|
				({64{rv64csr_rwi | rv64csr_rsi | rv64csr_rci}} & rs1 );

wire [11:0] addr = imm;


	assign csr_execute_info = { 
			csr_rw,
			csr_rs,
			csr_rc,

			rd0,
			op,
			addr

			};



	assign csr_dispat_ready = csr_dispat_vaild & csr_execute_ready;

	assign csr_execute_vaild = csr_isClearRAW,



endmodule











