/*
* @File name: program_buffer
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-11-24 11:36:22
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2021-01-03 12:04:27
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

module program_buffer (
	
	input [63:0] S_PB_AXI_AWADDR,
	input S_PB_AXI_AWVALID,
	output S_PB_AXI_AWREADY,

	input [63:0] S_PB_AXI_WDATA,  
	input [7:0] S_PB_AXI_WSTRB,
	input S_PB_AXI_WVALID,
	output S_PB_AXI_WREADY,

	output [1:0] S_PB_AXI_BRESP,
	output S_PB_AXI_BVALID,
	input S_PB_AXI_BREADY,

	input [63:0] S_PB_AXI_ARADDR,
	input S_PB_AXI_ARVALID,
	output S_PB_AXI_ARREADY,

	output [63:0] S_PB_AXI_RDATA,
	output [1:0] S_PB_AXI_RRESP,
	output S_PB_AXI_RVALID,
	input S_PB_AXI_RREADY,



	input [31:0] probuf0,
	input [31:0] probuf1,
	input [31:0] probuf2,
	input [31:0] probuf3,
	input [31:0] probuf4,
	input [31:0] probuf5,
	input [31:0] probuf6,
	input [31:0] probuf7,
	input [31:0] probuf8,
	input [31:0] probuf9,
	input [31:0] probuf10,
	input [31:0] probuf11,
	input [31:0] probuf12,
	input [31:0] probuf13,
	input [31:0] probuf14,
	input [31:0] probuf15,

	input CLK,
	input RSTn



);





//                AAA               XXXXXXX       XXXXXXXIIIIIIIIII     444444444                   LLLLLLLLLLL             IIIIIIIIIITTTTTTTTTTTTTTTTTTTTTTTEEEEEEEEEEEEEEEEEEEEEE
//               A:::A              X:::::X       X:::::XI::::::::I    4::::::::4                   L:::::::::L             I::::::::IT:::::::::::::::::::::TE::::::::::::::::::::E
//              A:::::A             X:::::X       X:::::XI::::::::I   4:::::::::4                   L:::::::::L             I::::::::IT:::::::::::::::::::::TE::::::::::::::::::::E
//             A:::::::A            X::::::X     X::::::XII::::::II  4::::44::::4                   LL:::::::LL             II::::::IIT:::::TT:::::::TT:::::TEE::::::EEEEEEEEE::::E
//            A:::::::::A           XXX:::::X   X:::::XXX  I::::I   4::::4 4::::4                     L:::::L                 I::::I  TTTTTT  T:::::T  TTTTTT  E:::::E       EEEEEE
//           A:::::A:::::A             X:::::X X:::::X     I::::I  4::::4  4::::4                     L:::::L                 I::::I          T:::::T          E:::::E             
//          A:::::A A:::::A             X:::::X:::::X      I::::I 4::::4   4::::4                     L:::::L                 I::::I          T:::::T          E::::::EEEEEEEEEE   
//         A:::::A   A:::::A             X:::::::::X       I::::I4::::444444::::444 ---------------   L:::::L                 I::::I          T:::::T          E:::::::::::::::E   
//        A:::::A     A:::::A            X:::::::::X       I::::I4::::::::::::::::4 -:::::::::::::-   L:::::L                 I::::I          T:::::T          E:::::::::::::::E   
//       A:::::AAAAAAAAA:::::A          X:::::X:::::X      I::::I4444444444:::::444 ---------------   L:::::L                 I::::I          T:::::T          E::::::EEEEEEEEEE   
//      A:::::::::::::::::::::A        X:::::X X:::::X     I::::I          4::::4                     L:::::L                 I::::I          T:::::T          E:::::E             
//     A:::::AAAAAAAAAAAAA:::::A    XXX:::::X   X:::::XXX  I::::I          4::::4                     L:::::L         LLLLLL  I::::I          T:::::T          E:::::E       EEEEEE
//    A:::::A             A:::::A   X::::::X     X::::::XII::::::II        4::::4                   LL:::::::LLLLLLLLL:::::LII::::::II      TT:::::::TT      EE::::::EEEEEEEE:::::E
//   A:::::A               A:::::A  X:::::X       X:::::XI::::::::I      44::::::44                 L::::::::::::::::::::::LI::::::::I      T:::::::::T      E::::::::::::::::::::E
//  A:::::A                 A:::::A X:::::X       X:::::XI::::::::I      4::::::::4                 L::::::::::::::::::::::LI::::::::I      T:::::::::T      E::::::::::::::::::::E
// AAAAAAA                   AAAAAAAXXXXXXX       XXXXXXXIIIIIIIIII      4444444444                 LLLLLLLLLLLLLLLLLLLLLLLLIIIIIIIIII      TTTTTTTTTTT      EEEEEEEEEEEEEEEEEEEEEE







	// AXI4LITE signals
	reg [7:0] axi_awaddr;
	reg axi_awready;
	reg axi_wready;
	reg [1 : 0] axi_bresp;
	reg axi_bvalid;
	reg [7:0] axi_araddr;
	reg axi_arready;
	reg [31 0] axi_rdata;
	reg [1:0] axi_rresp;
	reg axi_rvalid;


	wire slv_reg_rden;
	wire slv_reg_wren;
	wire [31:0] reg_data_out;
	reg  aw_en;

	assign S_PB_AXI_AWREADY = axi_awready;
	assign S_PB_AXI_WREADY = axi_wready;
	assign S_PB_AXI_BRESP = axi_bresp;
	assign S_PB_AXI_BVALID = axi_bvalid;
	assign S_PB_AXI_ARREADY = axi_arready;
	assign S_PB_AXI_RDATA = axi_rdata;
	assign S_PB_AXI_RRESP = axi_rresp;
	assign S_PB_AXI_RVALID = axi_rvalid;

	always @(posedge CLK or negedge RSTn) begin
		if ( ~RSTn ) begin
			axi_awready <= 1'b0;
			aw_en <= 1'b1;
		end 
		else begin    
			if (~axi_awready && S_PB_AXI_AWVALID && S_PB_AXI_WVALID && aw_en) begin
				axi_awready <= 1'b1;
				aw_en <= 1'b0;
			end
			else if (S_PB_AXI_BREADY && axi_bvalid) begin
				aw_en <= 1'b1;
				axi_awready <= 1'b0;
			end
			else begin
				axi_awready <= 1'b0;
			end
		end
	end


	always @(posedge CLK or negedge RSTn) begin
		if ( ~RSTn ) begin
			axi_awaddr <= 0;
		end 
		else begin
			if (~axi_awready && S_PB_AXI_AWVALID && S_PB_AXI_WVALID && aw_en) begin
				axi_awaddr <= S_PB_AXI_AWADDR;
			end
		end 
	end       

	always @(posedge CLK or negedge RSTn) begin
		if ( ~RSTn ) begin
			axi_wready <= 1'b0;
		end 
		else begin    
			if (~axi_wready && S_PB_AXI_WVALID && S_PB_AXI_AWVALID && aw_en ) begin
				axi_wready <= 1'b1;
			end
			else begin
				axi_wready <= 1'b0;
			end
		end 
	end       

	assign slv_reg_wren = axi_wready && S_PB_AXI_WVALID && axi_awready && S_PB_AXI_AWVALID;










	always @(posedge CLK or negedge RSTn) begin
		if ( ~RSTn ) begin
			axi_bvalid <= 0;
			axi_bresp <= 2'b0;
		end 
		else begin
			if (axi_awready && S_PB_AXI_AWVALID && ~axi_bvalid && axi_wready && S_PB_AXI_WVALID) begin
				axi_bvalid <= 1'b1;
				axi_bresp  <= 2'b0;
			end
			else begin
				if (S_PB_AXI_BREADY && axi_bvalid) begin
					axi_bvalid <= 1'b0; 
				end  
			end
		end
	end   

	always @(posedge CLK or negedge RSTn) begin
		if ( ~RSTn ) begin
			axi_arready <= 1'b0;
			axi_araddr  <= 32'b0;
		end 
		else begin    
			if (~axi_arready && S_PB_AXI_ARVALID) begin
				axi_arready <= 1'b1;
				axi_araddr  <= S_PB_AXI_ARADDR;
			end
			else begin
				axi_arready <= 1'b0;
			end
		end 
	end       

	always @(posedge CLK or negedge RSTn) begin
		if ( ~RSTn ) begin
			axi_rvalid <= 0;
			axi_rresp  <= 0;
		end 
		else begin    
			if (axi_arready && S_PB_AXI_ARVALID && ~axi_rvalid) begin
				axi_rvalid <= 1'b1;
				axi_rresp  <= 2'b0;
			end   
			else if (axi_rvalid && S_PB_AXI_RREADY) begin
				axi_rvalid <= 1'b0;
			end                
		end
	end    

	assign slv_reg_rden = axi_arready & S_AXI_ARVALID & ~axi_rvalid;



	always @(posedge  or negedge RSTn) begin
		if ( ~RSTn ) begin
			axi_rdata  <= 0;
		end
		else begin
			if (slv_reg_rden) begin
				axi_rdata <= reg_data_out;     // register read data
			end   
		end
	end    



assign reg_data_out =   
	  ({64{axi_araddr[5:3] == 3'h0}} & {probuf1, probuf0})
	| ({64{axi_araddr[5:3] == 3'h1}} & {probuf3, probuf2})
	| ({64{axi_araddr[5:3] == 3'h2}} & {probuf5, probuf4})
	| ({64{axi_araddr[5:3] == 3'h3}} & {probuf7, probuf6})
	| ({64{axi_araddr[5:3] == 3'h4}} & {probuf9, probuf8})
	| ({64{axi_araddr[5:3] == 3'h5}} & {probuf11, probuf10})
	| ({64{axi_araddr[5:3] == 3'h6}} & {probuf13, probuf12})
	| ({64{axi_araddr[5:3] == 3'h7}} & {probuf15, probuf14});





endmodule


