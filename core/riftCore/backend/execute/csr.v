/*
* @File name: csr
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-10-30 14:30:32
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-11-17 09:48:58
*/

/*
  Copyright (c) 2020 - 2020 Ruige Lee <wut.ruigeli@gmail.com>

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/

`timescale 1 ns / 1 ps
`include "define.vh"

module csr #
	(
		parameter DW = `CSR_EXEPARAM_DW
	)
	(

	input csr_exeparam_vaild,
	input [DW-1 :0] csr_exeparam,

	output csr_writeback_vaild,
	output [63:0] csr_res_qout,
	output [(5+`RB-1):0] csr_rd0_qout,

	input CLK,
	input RSTn,
	input flush
	
);


	wire rv64csr_rw;
	wire rv64csr_rs;
	wire rv64csr_rc;

	wire [(5+`RB)-1:0] csr_rd0_dnxt;
	wire [63:0] op;
	wire [11:0] addr;




	assign { 
			rv64csr_rw,
			rv64csr_rs,
			rv64csr_rc,

			csr_rd0_dnxt,
			op,
			addr

			} = csr_exeparam;


wire dontRead = (csr_rd0_dnxt == 'd0) & rv64csr_rw;
wire dontWrite = (op == 'd0) & ( rv64csr_rs | rv64csr_rc );



initial $warning("no exception at this version");

wire illagle_op = 1'b0;





assign mstatus_dnxt = {64{~dontWrite & (addr == 12'h300) & csr_exeparam_vaild}} &
						(
							({64{rv64csr_rw}} & op)
							|
							({64{rv64csr_rs}} | op)
							|
							({64{rv64csr_rc}} & (~op))
						);

assign mie_dnxt = {64{~dontWrite & (addr == 12'h304) & csr_exeparam_vaild}} &
						(
							({64{rv64csr_rw}} & op)
							|
							({64{rv64csr_rs}} | op)
							|
							({64{rv64csr_rc}} & (~op))
						);

assign mtvec_dnxt = {64{~dontWrite & (addr == 12'h305) & csr_exeparam_vaild}} &
						(
							({64{rv64csr_rw}} & op)
							|
							({64{rv64csr_rs}} | op)
							|
							({64{rv64csr_rc}} & (~op))
						);

assign mepc_dnxt = {64{~dontWrite & (addr == 12'h341) & csr_exeparam_vaild}} &
						(
							({64{rv64csr_rw}} & op)
							|
							({64{rv64csr_rs}} | op)
							|
							({64{rv64csr_rc}} & (~op))
						);

assign mcause_dnxt = {64{~dontWrite & (addr == 12'h342) & csr_exeparam_vaild}} &
						(
							({64{rv64csr_rw}} & op)
							|
							({64{rv64csr_rs}} | op)
							|
							({64{rv64csr_rc}} & (~op))
						);

assign mtval_dnxt = {64{~dontWrite & (addr == 12'h343) & csr_exeparam_vaild}} &
						(
							({64{rv64csr_rw}} & op)
							|
							({64{rv64csr_rs}} | op)
							|
							({64{rv64csr_rc}} & (~op))
						);

assign mip_dnxt = {64{~dontWrite & (addr == 12'h344) & csr_exeparam_vaild}} &
						(
							({64{rv64csr_rw}} & op)
							|
							({64{rv64csr_rs}} | op)
							|
							({64{rv64csr_rc}} & (~op))
						);





gen_dffr # (.DW((5+`RB))) csr_rd0 ( .dnxt(csr_rd0_dnxt), .qout(csr_rd0_qout), .CLK(CLK), .RSTn(RSTn&(~flush)));
gen_dffr # (.DW(64)) csr_res ( .dnxt(csr_res_dnxt), .qout(csr_res_qout), .CLK(CLK), .RSTn(RSTn&(~flush)));
gen_dffr # (.DW(1)) vaild ( .dnxt(csr_exeparam_vaild), .qout(csr_writeback_vaild), .CLK(CLK), .RSTn(RSTn&(~flush)));



endmodule














