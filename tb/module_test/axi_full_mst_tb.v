/*
* @File name: axi_full_mst_tb
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2021-02-24 09:24:56
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2021-02-24 15:28:33
*/


/*
	Copyright (c) 2020 - 2021 Ruige Lee <wut.ruigeli@gmail.com>

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


module axi_full_mst_tb
(

);
	reg CLK;
	reg RSTn;


	wire M_AXI_ARVALID = axi_arvalid_qout;
	wire M_AXI_RREADY = axi_rready_qout;
	reg [2:0] M_AXI_AWSIZE;
	reg [2:0] M_AXI_ARSIZE;
	reg [7:0] M_AXI_AWLEN;
	reg [7:0] M_AXI_ARLEN;
	reg [31:0] M_AXI_AWADDR;
	reg [31:0] M_AXI_ARADDR;
	reg [7:0] M_AXI_WSTRB;

	reg start_single_burst_read, start_single_burst_write;


	wire M_AXI_ARREADY;
	wire [63:0] M_AXI_RDATA;
	wire [1:0] M_AXI_RRESP;
	wire M_AXI_RLAST;
	wire M_AXI_RVALID;
	wire M_AXI_AWREADY;
	reg [63:0] M_AXI_WDATA;
	wire M_AXI_WREADY;
	wire [1:0] M_AXI_BRESP;
	wire M_AXI_BVALID;

	wire M_AXI_AWVALID = axi_awvalid_qout;
	wire M_AXI_WLAST = axi_wlast_qout;
	wire M_AXI_WVALID = axi_wvalid_qout;
	wire M_AXI_BREADY = axi_bready_qout;

	wire axi_awvalid_set, axi_awvalid_rst, axi_awvalid_qout;
	wire axi_wvalid_set, axi_wvalid_rst, axi_wvalid_qout;
	wire axi_wlast_set, axi_wlast_rst, axi_wlast_qout;
	wire [7:0] write_index_dnxt;
	wire [7:0] write_index_qout;
	wire axi_bready_set, axi_bready_rst, axi_bready_qout;
	wire axi_arvalid_set, axi_arvalid_rst, axi_arvalid_qout;
	wire [7:0] read_index_dnxt;
	wire [7:0] read_index_qout;
	wire axi_rready_set, axi_rready_rst, axi_rready_qout;
	wire wnext, rnext;
	wire write_resp_error, read_resp_error;









	assign axi_awvalid_set = ~axi_awvalid_qout & start_single_burst_write;
	assign axi_awvalid_rst =  axi_awvalid_qout & M_AXI_AWREADY ;
	gen_rsffr axi_awvalid_rsffr (.set_in(axi_awvalid_set), .rst_in(axi_awvalid_rst), .qout(axi_awvalid_qout), .CLK(CLK), .RSTn(RSTn));



	assign wnext = M_AXI_WREADY & axi_wvalid_qout;


	assign axi_wvalid_set = (~axi_wvalid_qout & start_single_burst_write);
	assign axi_wvalid_rst = (wnext & axi_wlast_qout) ;
	gen_rsffr axi_wvalid_rsffr (.set_in(axi_wvalid_set), .rst_in(axi_wvalid_rst), .qout(axi_wvalid_qout), .CLK(CLK), .RSTn(RSTn));




	assign axi_wlast_set = ((write_index_qout == M_AXI_AWLEN-1 & M_AXI_AWLEN >= 1) & wnext) || (M_AXI_AWLEN == 0 );
	assign axi_wlast_rst = ~axi_wlast_set & ( wnext | (axi_wlast_qout & M_AXI_AWLEN == 0) );
	gen_rsffr axi_wlast_rsffr (.set_in(axi_wlast_set), .rst_in(axi_wlast_rst), .qout(axi_wlast_qout), .CLK(CLK), .RSTn(RSTn));


	assign write_index_dnxt = start_single_burst_write ? 8'd0 :
								(
									(wnext & (write_index_qout != M_AXI_AWLEN)) ? (write_index_qout + 8'd1) : write_index_qout
								);              
	gen_dffr # (.DW(8)) write_index_dffr (.dnxt(write_index_dnxt), .qout(write_index_qout), .CLK(CLK), .RSTn(RSTn));


	assign axi_bready_set = (M_AXI_BVALID && ~axi_bready_qout);
	assign axi_bready_rst = axi_bready_qout;
	gen_rsffr axi_bready_rsffr (.set_in(axi_bready_set), .rst_in(axi_bready_rst), .qout(axi_bready_qout), .CLK(CLK), .RSTn(RSTn));
	

	assign write_resp_error = axi_bready_qout & M_AXI_BVALID & M_AXI_BRESP[1]; 




	assign axi_arvalid_set = ~axi_arvalid_qout & start_single_burst_read;
	assign axi_arvalid_rst = axi_arvalid_qout & M_AXI_ARREADY ;
	gen_rsffr axi_arvalid_rsffr (.set_in(axi_arvalid_set), .rst_in(axi_arvalid_rst), .qout(axi_arvalid_qout), .CLK(CLK), .RSTn(RSTn));
	

	assign rnext = M_AXI_RVALID && axi_rready_qout;



	assign read_index_dnxt = start_single_burst_read ? 8'd0 :
								(
									(rnext & (read_index_qout != M_AXI_ARLEN)) ? (read_index_qout + 8'd1) : read_index_qout
								);              
	gen_dffr # (.DW(8)) read_index_dffr (.dnxt(read_index_dnxt), .qout(read_index_qout), .CLK(CLK), .RSTn(RSTn));


	assign axi_rready_set = M_AXI_RVALID & (~M_AXI_RLAST | ~axi_rready_qout);
	assign axi_rready_rst = M_AXI_RVALID &   M_AXI_RLAST &  axi_rready_qout;
	gen_rsffr axi_rready_rsffr (.set_in(axi_rready_set), .rst_in(axi_rready_rst), .qout(axi_rready_qout), .CLK(CLK), .RSTn(RSTn));


	assign read_resp_error = axi_rready_qout & M_AXI_RVALID & M_AXI_RRESP[1];





//-------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------





axi_full_slv_sram s_axi_full_slv_sram
(

	.S_AXI_AWADDR(M_AXI_AWADDR),
	.S_AXI_AWLEN(M_AXI_AWLEN),
	.S_AXI_AWSIZE(M_AXI_AWSIZE),
	.S_AXI_AWBURST(2'b00),
	.S_AXI_AWVALID(M_AXI_AWVALID),
	.S_AXI_AWREADY(M_AXI_AWREADY),

	.S_AXI_WDATA(M_AXI_WDATA),
	.S_AXI_WSTRB(M_AXI_WSTRB),
	.S_AXI_WLAST(M_AXI_WLAST),
	.S_AXI_WVALID(M_AXI_WVALID),
	.S_AXI_WREADY(M_AXI_WREADY),

	.S_AXI_BRESP(M_AXI_BRESP),
	.S_AXI_BVALID(M_AXI_BVALID),
	.S_AXI_BREADY(M_AXI_BREADY),

	.S_AXI_ARADDR(M_AXI_ARADDR),
	.S_AXI_ARLEN(M_AXI_ARLEN),
	.S_AXI_ARSIZE(M_AXI_ARSIZE),
	.S_AXI_ARBURST(2'b01),
	.S_AXI_ARVALID(M_AXI_ARVALID),
	.S_AXI_ARREADY(M_AXI_ARREADY),

	.S_AXI_RDATA(M_AXI_RDATA),
	.S_AXI_RRESP(M_AXI_RRESP),
	.S_AXI_RLAST(M_AXI_RLAST),
	.S_AXI_RVALID(M_AXI_RVALID),
	.S_AXI_RREADY(M_AXI_RREADY),

	.CLK(CLK),
	.RSTn(RSTn)
);




// L3cache s_L3cache
// (

// 	//form L2cache
// 	.L2C_AWID(1'b0),
// 	.L2C_AWADDR(M_AXI_AWADDR),
// 	.L2C_AWLEN(8'd0),
// 	.L2C_AWSIZE($clog2(64/8)),
// 	.L2C_AWBURST(2'b00),
// 	.L2C_AWPROT(3'h0),
// 	.L2C_AWVALID(axi_awvalid_qout),
// 	.L2C_AWREADY(M_AXI_ARREADY),

// 	.L2C_WDATA(M_AXI_WDATA),
// 	.L2C_WSTRB(M_AXI_WSTRB),
// 	.L2C_WLAST(axi_wlast_qout),
// 	.L2C_WVALID(axi_wvalid_qout),
// 	.L2C_WREADY(M_AXI_WREADY),

// 	.L2C_BID(),
// 	.L2C_BRESP(M_AXI_BRESP),
// 	.L2C_BVALID(M_AXI_BVALID),
// 	.L2C_BREADY(axi_bready_qout),

// 	.L2C_ARID(1'b0),
// 	.L2C_ARADDR(M_AXI_ARADDR),
// 	.L2C_ARLEN(8'd15),
// 	.L2C_ARSIZE($clog2(64/8)),
// 	.L2C_ARBURST(2'b01),
// 	.L2C_ARPROT(3'h0),
// 	.L2C_ARVALID(axi_arvalid_qout),
// 	.L2C_ARREADY(M_AXI_ARREADY),

// 	.L2C_RID(),
// 	.L2C_RDATA(M_AXI_RDATA),
// 	.L2C_RRESP(M_AXI_RRESP),
// 	.L2C_RLAST(M_AXI_RLAST),
// 	.L2C_RVALID(M_AXI_RVALID),
// 	.L2C_RREADY(axi_rready_qout),


// 	//from DDR
// 	output [0:0] MEM_AWID,
// 	output [63:0] MEM_AWADDR,
// 	output [7:0] MEM_AWLEN,
// 	output [2:0] MEM_AWSIZE,
// 	output [1:0] MEM_AWBURST,
// 	output MEM_AWLOCK,
// 	output [3:0] MEM_AWCACHE,
// 	output [2:0] MEM_AWPROT,
// 	output [3:0] MEM_AWQOS,
// 	output [0:0] MEM_AWUSER,
// 	output MEM_AWVALID,
// 	input MEM_AWREADY,

// 	output [63:0] MEM_WDATA,
// 	output [7:0] MEM_WSTRB,
// 	output MEM_WLAST,
// 	output [0:0] MEM_WUSER,
// 	output MEM_WVALID,
// 	input MEM_WREADY,

// 	input [0:0] MEM_BID,
// 	input [1:0] MEM_BRESP,
// 	input [0:0] MEM_BUSER,
// 	input MEM_BVALID,
// 	output MEM_BREADY,

// 	output [0:0] MEM_ARID,
// 	output [63:0] MEM_ARADDR,
// 	output [7:0] MEM_ARLEN,
// 	output [2:0] MEM_ARSIZE,
// 	output [1:0] MEM_ARBURST,
// 	output MEM_ARLOCK,
// 	output [3:0] MEM_ARCACHE,
// 	output [2:0] MEM_ARPROT,
// 	output [3:0] MEM_ARQOS,
// 	output [0:0] MEM_ARUSER,
// 	output MEM_ARVALID,
// 	input MEM_ARREADY,

// 	input [0:0] MEM_RID,
// 	input [63:0] MEM_RDATA,
// 	input [1:0] MEM_RRESP,
// 	input MEM_RLAST,
// 	input [0:0] MEM_RUSER,
// 	input MEM_RVALID,
// 	output MEM_RREADY,

// 	input l3c_fence,
// 	.CLK(CLK),
// 	.RSTn(RSTn)

// );







initial
begin
	$dumpfile("../build/wave.vcd"); //生成的vcd文件名称
	$dumpvars(0, axi_full_mst_tb);//tb模块名称
end



initial begin

	CLK = 0;
	RSTn = 0;

	#20

	RSTn <= 1;

	#8000
			$display("Time Out !!!");
	 $finish;
end

initial begin
	forever begin 
		#5 CLK <= ~CLK;
	end
end

initial begin
	M_AXI_AWADDR = 32'h0;
	M_AXI_ARADDR = 32'h0;
	M_AXI_WDATA = 64'd0;
	M_AXI_WSTRB = 8'b0;
	start_single_burst_read = 1'b0;
	start_single_burst_write = 1'b0;
	M_AXI_AWLEN = 8'b0;
	M_AXI_ARLEN = 8'd15;
	M_AXI_AWSIZE = $clog2(64/8);
	M_AXI_ARSIZE = $clog2(64/8);

	#52
	start_single_burst_write = 1'b1;
	M_AXI_AWADDR = 32'b11000;
	M_AXI_WDATA = 64'haa;
	M_AXI_WSTRB = 8'hff;

	#10
	start_single_burst_write = 1'b0;

	#100
	start_single_burst_read = 1'b1;

	#10
	start_single_burst_read = 1'b0;
end





endmodule




