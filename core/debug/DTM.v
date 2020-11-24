/*
* @File name: DTM
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-11-24 11:33:45
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-11-24 15:15:25
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


module DTM (


	//from host
	input JTAG_TCK,
	input JTAG_TDI,
	output JTAG_TDO,
	input JTAG_TMS,
	input JTAG_TRST,

	//from AXI lite





);

	parameter integer C_M_AXI_ADDR_WIDTH	= 32,
	parameter integer C_M_AXI_DATA_WIDTH	= 32

	input M_AXI_ACLK,
	input M_AXI_ARESETN,

	output [C_M_AXI_ADDR_WIDTH-1 : 0] M_AXI_AWADDR,
	output [2 : 0] M_AXI_AWPROT,
	output M_AXI_AWVALID,
	input M_AXI_AWREADY,

	output [C_M_AXI_DATA_WIDTH-1 : 0] M_AXI_WDATA,
	output [C_M_AXI_DATA_WIDTH/8-1 : 0] M_AXI_WSTRB,
	output M_AXI_WVALID,
	input M_AXI_WREADY,

	input [1 : 0] M_AXI_BRESP,
	input M_AXI_BVALID,
	output M_AXI_BREADY,

	output [C_M_AXI_ADDR_WIDTH-1 : 0] M_AXI_ARADDR,
	output [2 : 0] M_AXI_ARPROT,
	output M_AXI_ARVALID,
	input M_AXI_ARREADY,

	input [C_M_AXI_DATA_WIDTH-1 : 0] M_AXI_RDATA,
	input [1 : 0] M_AXI_RRESP,
	input M_AXI_RVALID,
	output M_AXI_RREADY

	// AXI4LITE signals
	//write address valid
	reg  	axi_awvalid;
	reg  	axi_wvalid;
	reg  	axi_arvalid;
	reg  	axi_rready;
	reg  	axi_bready;
	reg [C_M_AXI_ADDR_WIDTH-1 : 0] 	axi_awaddr;
	reg [C_M_AXI_DATA_WIDTH-1 : 0] 	axi_wdata;
	reg [C_M_AXI_ADDR_WIDTH-1 : 0] 	axi_araddr;
	wire  	write_resp_error;
	wire  	read_resp_error;
	reg  	start_single_write;
	reg  	start_single_read;


	reg [C_M_AXI_DATA_WIDTH-1 : 0] 	expected_rdata;




	// I/O Connections assignments

	assign M_AXI_AWADDR	= axi_awaddr;
	//AXI 4 write data
	assign M_AXI_WDATA	= axi_wdata;
	assign M_AXI_AWPROT	= 3'b000;
	assign M_AXI_AWVALID = axi_awvalid;
	assign M_AXI_WVALID	= axi_wvalid;
	assign M_AXI_WSTRB	= 4'b1111;
	assign M_AXI_BREADY	= axi_bready;
	assign M_AXI_ARADDR	= axi_araddr;
	assign M_AXI_ARVALID	= axi_arvalid;
	assign M_AXI_ARPROT	= 3'b001;
	assign M_AXI_RREADY	= axi_rready;




	always @(posedge M_AXI_ACLK) begin
		if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1) begin
			axi_awvalid <= 1'b0;
		end
		else begin
			if (start_single_write) begin
				axi_awvalid <= 1'b1;
			end
			else if (M_AXI_AWREADY && axi_awvalid) begin
				axi_awvalid <= 1'b0;
			end
		end
	end


	always @(posedge M_AXI_ACLK) begin
		if (M_AXI_ARESETN == 0  || init_txn_pulse == 1'b1) begin
			 axi_wvalid <= 1'b0;
		end
		else if (start_single_write) begin
			axi_wvalid <= 1'b1;
		end
		else if (M_AXI_WREADY && axi_wvalid) begin
			axi_wvalid <= 1'b0;
		end
	end

	always @(posedge M_AXI_ACLK) begin
		if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1) begin
			axi_bready <= 1'b0;
		end
		else if (M_AXI_BVALID && ~axi_bready) begin
			axi_bready <= 1'b1;
		end
		else if (axi_bready) begin
			axi_bready <= 1'b0;
		end
		else
		  axi_bready <= axi_bready;
	end

	assign write_resp_error = (axi_bready & M_AXI_BVALID & M_AXI_BRESP[1]);


	always @(posedge M_AXI_ACLK) begin
		if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1) begin
			axi_arvalid <= 1'b0;
		end
		else if (start_single_read) begin
			axi_arvalid <= 1'b1;
		end
		else if (M_AXI_ARREADY && axi_arvalid) begin
			axi_arvalid <= 1'b0;
		end
	end

	always @(posedge M_AXI_ACLK) begin                                                                 
		if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1) begin                                                             
			axi_rready <= 1'b0;                                             
		end                                                                                      
		else if (M_AXI_RVALID && ~axi_rready) begin                                                             
			axi_rready <= 1'b1;                                             
		end                                                                                              
		else if (axi_rready) begin                                                             
			axi_rready <= 1'b0;                                             
		end
	end
                                                   
	assign read_resp_error = (axi_rready & M_AXI_RVALID & M_AXI_RRESP[1]);







	always @(posedge M_AXI_ACLK) begin                                                     
		if (M_AXI_ARESETN == 0  || init_txn_pulse == 1'b1) begin                                                 
				axi_awaddr <= 0;                                    
		end
		else if (M_AXI_AWREADY && axi_awvalid) begin                                                 
			axi_awaddr <= axi_awaddr + 32'h00000004;            
		end                                                   
	end                                                       
																	                                   
	always @(posedge M_AXI_ACLK) begin                                                     
		if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1 ) begin
			axi_wdata <= C_M_START_DATA_VALUE;
		end
		else if (M_AXI_WREADY && axi_wvalid) begin
			axi_wdata <= C_M_START_DATA_VALUE + write_index;
		end
	end
					

	always @(posedge M_AXI_ACLK) begin                                                     
		if (M_AXI_ARESETN == 0  || init_txn_pulse == 1'b1) begin                                                 
			axi_araddr <= 0;                                    
		end                                                                            
		else if (M_AXI_ARREADY && axi_arvalid) begin                                                 
			axi_araddr <= axi_araddr + 32'h00000004;            
		end                                                   
	end                                                       
																
	always @(posedge M_AXI_ACLK) begin                                                     
		if (M_AXI_ARESETN == 0  || init_txn_pulse == 1'b1) begin                                                 
			expected_rdata <= C_M_START_DATA_VALUE;             
		end                                                                             
		else if (M_AXI_RVALID && axi_rready) begin                                                 
			expected_rdata <= C_M_START_DATA_VALUE + read_index;
		end                                                   
	end    









endmodule







