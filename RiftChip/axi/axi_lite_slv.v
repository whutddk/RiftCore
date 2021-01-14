/*
* @File name: axi_lite_slv
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2021-01-14 17:44:08
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2021-01-14 18:10:39
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



module axi4_lite_slave
(
	input [63:0] S_AXI_AWADDR,
	input [2:0] S_AXI_AWPROT,
	input S_AXI_AWVALID,
	output S_AXI_AWREADY,

	input [63:0] S_AXI_WDATA,   
	input [7 0] S_AXI_WSTRB,
	input S_AXI_WVALID,
	output S_AXI_WREADY,

	output [1:0] S_AXI_BRESP,
	output S_AXI_BVALID,
	input S_AXI_BREADY,

	input [63:0] S_AXI_ARADDR,
	input [2:0] S_AXI_ARPROT,
	input S_AXI_ARVALID,
	output S_AXI_ARREADY,

	output [63:0] S_AXI_RDATA,
	output [1:0] S_AXI_RRESP,
	output S_AXI_RVALID,
	input S_AXI_RREADY,

	input CLK,
	input RSTn
);

	// AXI4LITE signals
	reg [C_S_AXI_ADDR_WIDTH-1 : 0] 	axi_awaddr;
	reg  	axi_awready;
	reg  	axi_wready;
	reg [1 : 0] 	axi_bresp;
	reg  	axi_bvalid;
	reg [C_S_AXI_ADDR_WIDTH-1 : 0] 	axi_araddr;
	reg  	axi_arready;
	reg [C_S_AXI_DATA_WIDTH-1 : 0] 	axi_rdata;
	reg [1 : 0] 	axi_rresp;
	reg  	axi_rvalid;

	// Example-specific design signals
	// local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
	// ADDR_LSB is used for addressing 32/64 bit registers/memories
	// ADDR_LSB = 2 for 32 bits (n downto 2)
	// ADDR_LSB = 3 for 64 bits (n downto 3)
	localparam integer ADDR_LSB = (C_S_AXI_DATA_WIDTH/32) + 1;
	localparam integer OPT_MEM_ADDR_BITS = 1;
	//----------------------------------------------
	//-- Signals for user logic register space example
	//------------------------------------------------
	//-- Number of Slave Registers 4
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg0;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg1;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg2;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg3;
	wire	 slv_reg_rden;
	wire	 slv_reg_wren;
	reg [C_S_AXI_DATA_WIDTH-1:0]	 reg_data_out;
	integer	 byte_index;
	reg	 aw_en;

	// I/O Connections assignments

	assign S_AXI_AWREADY	= axi_awready;
	assign S_AXI_WREADY	= axi_wready;
	assign S_AXI_BRESP	= 2'b0;
	assign S_AXI_BVALID	= axi_bvalid;
	assign S_AXI_ARREADY	= axi_arready;
	assign S_AXI_RDATA	= axi_rdata;
	assign S_AXI_RRESP	= 2'b0;
	assign S_AXI_RVALID	= axi_rvalid;
	// Implement axi_awready generation
	// axi_awready is asserted for one S_AXI_ACLK clock cycle when both
	// S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_awready is
	// de-asserted when reset is low.

	wire axi_awready_set, axi_awready_rst, axi_awready_qout;
	wire aw_en_set, aw_en_rst, aw_en_qout;
	wire [63:0] axi_awaddr_dnxt;
	wire [63:0] axi_awaddr_qout;
	wire axi_awaddr_en;
	wire axi_wready_set, axi_wready_rst, axi_wready_qout;


	assign axi_awready_set = ~axi_awready && S_AXI_AWVALID && S_AXI_WVALID && aw_en;
	assign axi_awready_rst = ~axi_awready_set & (S_AXI_BREADY && axi_bvalid);
	assign aw_en_set = axi_awready_rst;
	assign aw_en_rst = axi_awready_set;

	assign axi_awaddr_dnxt = S_AXI_AWADDR;
	assign axi_awaddr_en = ~axi_awready && S_AXI_AWVALID && S_AXI_WVALID && aw_en;

	assign axi_wready_set = ~axi_wready && S_AXI_WVALID && S_AXI_AWVALID && aw_en;
	assign axi_wready_rst = ~axi_wready_set;

	gen_rsffr #(.DW(1)) axi_awready_rsffr (.set_in(axi_awready_set), .rst_in(axi_awready_rst), .qout(axi_awready_qout), .CLK(CLK), .RSTn(RSTn));
	gen_rsffr #(.DW(1), .rstValue(1'b1)) aw_en_rsffr (.set_in(aw_en_set), .rst_in(aw_en_rst), .qout(aw_en_qout), .CLK(CLK), .RSTn(RSTn));

	gen_dffren #(.DW(64)) axi_awaddr_dffren (.dnxt(axi_awaddr_dnxt), .qout(axi_awaddr_qout), .en(axi_awaddr_en), .CLK(CLK), .RSTn(RSTn));
	gen_rsffr #(.DW(1)) axi_wready_rsffr (.set_in(axi_wready_set), .rst_in(axi_wready_rst), .qout(axi_wready_qout), .CLK(CLK), .RSTn(RSTn));


	assign slv_reg_wren = axi_wready && S_AXI_WVALID && axi_awready && S_AXI_AWVALID;







	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
		begin
		  slv_reg0 <= 0;
		  slv_reg1 <= 0;
		  slv_reg2 <= 0;
		  slv_reg3 <= 0;
		end 
	  else begin
		if (slv_reg_wren)
		  begin
			case ( axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] )
			  2'h0:
				for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
				  if ( S_AXI_WSTRB[byte_index] == 1 ) begin
					// Respective byte enables are asserted as per write strobes 
					// Slave register 0
					slv_reg0[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
				  end  
			  2'h1:
				for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
				  if ( S_AXI_WSTRB[byte_index] == 1 ) begin
					// Respective byte enables are asserted as per write strobes 
					// Slave register 1
					slv_reg1[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
				  end  
			  2'h2:
				for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
				  if ( S_AXI_WSTRB[byte_index] == 1 ) begin
					// Respective byte enables are asserted as per write strobes 
					// Slave register 2
					slv_reg2[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
				  end  
			  2'h3:
				for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
				  if ( S_AXI_WSTRB[byte_index] == 1 ) begin
					// Respective byte enables are asserted as per write strobes 
					// Slave register 3
					slv_reg3[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
				  end  
			  default : begin
						  slv_reg0 <= slv_reg0;
						  slv_reg1 <= slv_reg1;
						  slv_reg2 <= slv_reg2;
						  slv_reg3 <= slv_reg3;
						end
			endcase
		  end
	  end
	end    



	wire axi_bvalid_set, axi_bvalid_rst, axi_bvalid_qout;
	wire axi_arready_set, axi_arready_rst, axi_arready_qout;
	wire [63:0] axi_araddr_dnxt;
	wire [63:0] axi_araddr_qout;
	wire axi_araddr_en;
	wire axi_rvalid_set, axi_rvalid_rst, axi_rvalid_qout;

	assign axi_bvalid_set = axi_awready && S_AXI_AWVALID && ~axi_bvalid && axi_wready && S_AXI_WVALID;
	assign axi_bvalid_rst = ~axi_bvalid_set & (S_AXI_BREADY && axi_bvalid);
	assign axi_arready_set = (~axi_arready && S_AXI_ARVALID);
	assign axi_bvalid_rst = ~axi_arready_set;
	assign axi_araddr_dnxt = S_AXI_ARADDR;
	assign axi_araddr_en = (~axi_arready && S_AXI_ARVALID);
	assign axi_rvalid_set = (axi_arready && S_AXI_ARVALID && ~axi_rvalid);
	assign axi_rvalid_rst = ~axi_rvalid_set & (axi_rvalid && S_AXI_RREADY);

	gen_rsffr #(.DW(1)) axi_bvalid_rsffr (.set_in(axi_bvalid_set), .rst_in(axi_bvalid_rst), .qout(axi_bvalid_qout), .CLK(CLK), .RSTn(RSTn));
	gen_rsffr #(.DW(1)) axi_arready_rsffr (.set_in(axi_arready_set), .rst_in(axi_arready_rst), .qout(axi_arready_qout), .CLK(CLK), .RSTn(RSTn));
	gen_dffren #(.DW(64)) axi_araddr_dffren (.dnxt(axi_araddr_dnxt), .qout(axi_araddr_qout), .en(axi_araddr_en), .CLK(CLK), .RSTn(RSTn));

	gen_rsffr #(.DW(1)) axi_rvalid_rsffr (.set_in(axi_rvalid_set), .rst_in(axi_rvalid_rst), .qout(axi_rvalid_qout), .CLK(CLK), .RSTn(RSTn));



	assign slv_reg_rden = axi_arready & S_AXI_ARVALID & ~axi_rvalid;




	always @(*)
	begin
		  // Address decoding for reading registers
		  case ( axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] )
			2'h0   : reg_data_out <= slv_reg0;
			2'h1   : reg_data_out <= slv_reg1;
			2'h2   : reg_data_out <= slv_reg2;
			2'h3   : reg_data_out <= slv_reg3;
			default : reg_data_out <= 0;
		  endcase
	end

	// Output register or memory read data
	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
		begin
		  axi_rdata  <= 0;
		end 
	  else
		begin    
		  // When there is a valid read address (S_AXI_ARVALID) with 
		  // acceptance of read address by the slave (axi_arready), 
		  // output the read dada 
		  if (slv_reg_rden)
			begin
			  axi_rdata <= reg_data_out;     // register read data
			end   
		end
	end    

	// Add user logic here

	// User logic ends

	endmodule




