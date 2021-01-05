/*
* @File name: bus_access
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-11-24 11:36:00
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2021-01-05 16:43:28
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


module bus_access #
(
	parameter sbasize = 64
)
(

	input [31:0] sbcs,

	input [sbasize-1:0] sbaddress,

	input [63:0] sbdata_write,
	output [63:0] sbdata_read,

	output read_data_ready,
	output wirte_data_ready,
	input start_single_write,
	input start_single_read,







	output [63:0] M_DM_AXI_AWADDR,
	output M_DM_AXI_AWVALID,
	input M_DM_AXI_AWREADY,

	output [63:0] M_DM_AXI_WDATA,
	output [7:0] M_DM_AXI_WSTRB,
	output M_DM_AXI_WVALID,
	input M_DM_AXI_WREADY,

	input [1:0] M_DM_AXI_BRESP,
	input M_DM_AXI_BVALID,
	output M_DM_AXI_BREADY,

	output [63:0] M_DM_AXI_ARADDR,
	output M_DM_AXI_ARVALID,
	input M_DM_AXI_ARREADY,

	input [63:0] M_DM_AXI_RDATA,
	input [1:0] M_DM_AXI_RRESP,
	input M_DM_AXI_RVALID,
	output M_DM_AXI_RREADY





);










































always @(posedge CLK or negedge RSTn) begin
	if(~RSTn) begin
		read_data_ready <= 1'b0;
		write_data_ready <= 1'b0;
	end else begin
		sbdata_read <= sbdata_read;
		if ( M_DM_AXI_RVALID ) begin
			sbdata_read <= M_AXI_RDATA;
			read_data_ready <= 1'b1;
		end
		if ( M_DM_AXI_BRESP == 2'b0 && M_DM_AXI_BVALID ) begin
			write_data_ready <= 1'b1;
		end
		if ( read_resp_error || write_resp_error ) begin

		end

	end
end













assign axi_awaddr = sbaddress;
assign axi_araddr = sbaddress;
assign axi_wdata <= sbdata_write;




	reg axi_awvalid;
	reg axi_wvalid;
	reg axi_arvalid;
	reg axi_rready;
	reg axi_bready;



	// I/O Connections assignments
	assign M_DM_AXI_AWADDR = axi_awaddr;
	assign M_DM_AXI_WDATA  = axi_wdata;
	assign M_DM_AXI_AWPROT = 3'b000;
	assign M_DM_AXI_AWVALID = axi_awvalid;
	assign M_DM_AXI_WVALID = axi_wvalid;
	assign M_DM_AXI_WSTRB  = 4'b1111;
	assign M_DM_AXI_BREADY = axi_bready;
	assign M_DM_AXI_ARADDR = axi_araddr;
	assign M_DM_AXI_ARVALID  = axi_arvalid;
	assign M_DM_AXI_ARPROT = 3'b001;
	assign M_DM_AXI_RREADY = axi_rready;




	always @(posedge CLK or negedge RSTn) begin
		if ( ~RSTn ) begin
			axi_awvalid <= 1'b0;
		end
		else begin
			if (start_single_write) begin
				axi_awvalid <= 1'b1;
			end
			else if (M_DM_AXI_AWREADY && axi_awvalid) begin
				axi_awvalid <= 1'b0;
			end
		end
	end


	always @(posedge CLK or negedge RSTn) begin
		if ( ~RSTn ) begin
			 axi_wvalid <= 1'b0;
		end
		else if (start_single_write) begin
			axi_wvalid <= 1'b1;
		end
		else if (M_DM_AXI_WREADY && axi_wvalid) begin
			axi_wvalid <= 1'b0;
		end
	end

	always @(posedge CLK or negedge RSTn) begin
		if ( ~RSTn ) begin
			axi_bready <= 1'b0;
		end
		else if (M_DM_AXI_BVALID && ~axi_bready) begin
			axi_bready <= 1'b1;
		end
		else if (axi_bready) begin
			axi_bready <= 1'b0;
		end
		else
			axi_bready <= axi_bready;
	end

	assign write_resp_error = (axi_bready & M_DM_AXI_BVALID & M_DM_AXI_BRESP[1]);


	always @(posedge CLK or negedge RSTn) begin
		if ( ~RSTn ) begin
			axi_arvalid <= 1'b0;
		end
		else if (start_single_read) begin
			axi_arvalid <= 1'b1;
		end
		else if (M_DM_AXI_ARREADY && axi_arvalid) begin
			axi_arvalid <= 1'b0;
		end
	end

	always @(posedge CLK or negedge RSTn) begin
		if ( ~RSTn ) begin
			axi_rready <= 1'b0;
		end
		else if (M_DM_AXI_RVALID && ~axi_rready) begin
			axi_rready <= 1'b1;
		end
		else if (axi_rready) begin
			axi_rready <= 1'b0;
		end
	end

	assign read_resp_error = (axi_rready & M_AXI_RVALID & M_DM_AXI_RRESP[1]);






endmodule

