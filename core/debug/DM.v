/*
* @File name: DM
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-11-24 11:34:20
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-11-25 17:38:26
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


module DM (



	input [7:0] S_AXI_AWADDR,
	input [2:0] S_AXI_AWPROT,
	input S_AXI_AWVALID,
	output S_AXI_AWREADY,

	input [31:0] S_AXI_WDATA,  
	input [3:0] S_AXI_WSTRB,
	input S_AXI_WVALID,
	output S_AXI_WREADY,

	output [1:0] S_AXI_BRESP,
	output S_AXI_BVALID,
	input S_AXI_BREADY,

	input [7:0] S_AXI_ARADDR,
	input [2:0] S_AXI_ARPROT,
	input S_AXI_ARVALID,
	output S_AXI_ARREADY,

	output [31:0] S_AXI_RDATA,
	output [1:0] S_AXI_RRESP,
	output S_AXI_RVALID,
	input S_AXI_RREADY



	//core region

	output ndmreset,
	output ndmresetn,
	output dmactive,

	output hartReset,



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
	reg	 aw_en;

	assign S_AXI_AWREADY = axi_awready;
	assign S_AXI_WREADY	= axi_wready;
	assign S_AXI_BRESP = axi_bresp;
	assign S_AXI_BVALID	= axi_bvalid;
	assign S_AXI_ARREADY = axi_arready;
	assign S_AXI_RDATA = axi_rdata;
	assign S_AXI_RRESP = axi_rresp;
	assign S_AXI_RVALID	= axi_rvalid;

	always @(posedge CLK or negedge RSTn) begin
		if ( ~RSTn | ~dmactive) begin
			axi_awready <= 1'b0;
			aw_en <= 1'b1;
		end 
		else begin    
			if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID && aw_en) begin
				axi_awready <= 1'b1;
				aw_en <= 1'b0;
			end
			else if (S_AXI_BREADY && axi_bvalid) begin
				aw_en <= 1'b1;
				axi_awready <= 1'b0;
			end
			else begin
				axi_awready <= 1'b0;
			end
		end
	end


	always @(posedge CLK or negedge RSTn) begin
		if ( ~RSTn | ~dmactive) begin
		  axi_awaddr <= 0;
		end 
		else begin
			if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID && aw_en) begin
				axi_awaddr <= S_AXI_AWADDR;
			end
		end 
	end       

	always @(posedge CLK or negedge RSTn) begin
		if ( ~RSTn | ~dmactive) begin
			axi_wready <= 1'b0;
		end 
		else begin    
			if (~axi_wready && S_AXI_WVALID && S_AXI_AWVALID && aw_en ) begin
				axi_wready <= 1'b1;
			end
			else begin
				axi_wready <= 1'b0;
			end
		end 
	end       

	assign slv_reg_wren = axi_wready && S_AXI_WVALID && axi_awready && S_AXI_AWVALID;










	always @(posedge CLK or negedge RSTn) begin
		if ( ~RSTn | ~dmactive) begin
			axi_bvalid <= 0;
			axi_bresp <= 2'b0;
		end 
		else begin
			if (axi_awready && S_AXI_AWVALID && ~axi_bvalid && axi_wready && S_AXI_WVALID) begin
				axi_bvalid <= 1'b1;
				axi_bresp  <= 2'b0;
			end
			else begin
				if (S_AXI_BREADY && axi_bvalid) begin
					axi_bvalid <= 1'b0; 
				end  
			end
		end
	end   

	always @(posedge CLK or negedge RSTn) begin
		if ( ~RSTn | ~dmactive) begin
			axi_arready <= 1'b0;
			axi_araddr  <= 32'b0;
		end 
		else begin    
			if (~axi_arready && S_AXI_ARVALID) begin
				axi_arready <= 1'b1;
				axi_araddr  <= S_AXI_ARADDR;
			end
			else begin
				axi_arready <= 1'b0;
			end
		end 
	end       

	always @(posedge CLK or negedge RSTn) begin
		if ( ~RSTn | ~dmactive) begin
			axi_rvalid <= 0;
			axi_rresp  <= 0;
		end 
		else begin    
			if (axi_arready && S_AXI_ARVALID && ~axi_rvalid) begin
				axi_rvalid <= 1'b1;
				axi_rresp  <= 2'b0;
			end   
			else if (axi_rvalid && S_AXI_RREADY) begin
				axi_rvalid <= 1'b0;
			end                
		end
	end    

	assign slv_reg_rden = axi_arready & S_AXI_ARVALID & ~axi_rvalid;



	always @(posedge  or negedge RSTn) begin
		if ( ~RSTn | ~dmactive) begin
			axi_rdata  <= 0;
		end
		else begin
			if (slv_reg_rden) begin
				axi_rdata <= reg_data_out;     // register read data
			end   
		end
	end    








	wire [9:0] hartsello_dnxt;
	wire [9:0] hartsello_qout;

	wire [9:0] hartselhi_dnxt;
	wire [9:0] hartselhi_qout;

	wire allunavail_dnxt;
	wire allunavail_qout;

	wire anyunavail_dnxt;
	wire anyunavail_qout;

	wire allhavereset_dnxt;
	wire allhavereset_qout;

	wire anyhavereset_dnxt;
	wire anyhavereset_qout;

	wire ackhavereset_dnxt;
	wire ackhavereset_qout;
	
	wire haltreq;




	assign ndmreset = dmcontrol_qout[1];
	assign ndmresetn = ~ndmreset;
	assign dmactive = dmcontrol_qout[0];

	assign hartReset = ({hartselhi_qout, hartsello_qout} == 20'h0) & dmcontrol_qout[29];


//0x04
wire [31:0] data0_dnxt;
wire [31:0] data0_qout;
gen_dffr # (.DW(32)) data0 ( .dnxt(data0_dnxt), .qout(data0_qout), .CLK(CLK), .RSTn(RSTn));

//0x05
wire [31:0] data1_dnxt;
wire [31:0] data1_qout;
gen_dffr # (.DW(32)) data1 ( .dnxt(data1_dnxt), .qout(data1_qout), .CLK(CLK), .RSTn(RSTn));

//0x06
wire [31:0] data2_dnxt;
wire [31:0] data2_qout;
gen_dffr # (.DW(32)) data2 ( .dnxt(data2_dnxt), .qout(data2_qout), .CLK(CLK), .RSTn(RSTn));

//0x07
wire [31:0] data3_dnxt;
wire [31:0] data3_qout;
gen_dffr # (.DW(32)) data3 ( .dnxt(data3_dnxt), .qout(data3_qout), .CLK(CLK), .RSTn(RSTn));

//0x08
wire [31:0] data4_dnxt;
wire [31:0] data4_qout;
gen_dffr # (.DW(32)) data4 ( .dnxt(data4_dnxt), .qout(data4_qout), .CLK(CLK), .RSTn(RSTn));

//0x09
wire [31:0] data5_dnxt;
wire [31:0] data5_qout;
gen_dffr # (.DW(32)) data5 ( .dnxt(data5_dnxt), .qout(data5_qout), .CLK(CLK), .RSTn(RSTn));

//0x0a
wire [31:0] data6_dnxt;
wire [31:0] data6_qout;
gen_dffr # (.DW(32)) data6 ( .dnxt(data6_dnxt), .qout(data6_qout), .CLK(CLK), .RSTn(RSTn));

//0x0b
wire [31:0] data7_dnxt;
wire [31:0] data7_qout;
gen_dffr # (.DW(32)) data7 ( .dnxt(data7_dnxt), .qout(data7_qout), .CLK(CLK), .RSTn(RSTn));

//0x0c
wire [31:0] data8_dnxt;
wire [31:0] data8_qout;
gen_dffr # (.DW(32)) data8 ( .dnxt(data8_dnxt), .qout(data8_qout), .CLK(CLK), .RSTn(RSTn));

//0x0d
wire [31:0] data9_dnxt;
wire [31:0] data9_qout;
gen_dffr # (.DW(32)) data9 ( .dnxt(data9_dnxt), .qout(data9_qout), .CLK(CLK), .RSTn(RSTn));

//0x0e
wire [31:0] data10_dnxt;
wire [31:0] data10_qout;
gen_dffr # (.DW(32)) data10 ( .dnxt(data10_dnxt), .qout(data10_qout), .CLK(CLK), .RSTn(RSTn));

//0x0f
wire [31:0] data11_dnxt;
wire [31:0] data11_qout;
gen_dffr # (.DW(32)) data11 ( .dnxt(data11_dnxt), .qout(data11_qout), .CLK(CLK), .RSTn(RSTn));

//0x10
wire [31:0] dmcontrol_dnxt;
wire [31:0] dmcontrol_qout;
gen_dffr # (.DW(32)) dmcontrol ( .dnxt(dmcontrol_dnxt), .qout(dmcontrol_qout), .CLK(CLK), .RSTn(RSTn));

//0x11
wire [31:0] dmstatus_dnxt;
wire [31:0] dmstatus_qout;
gen_dffr # (.DW(32)) dmstatus ( .dnxt(dmstatus_dnxt), .qout(dmstatus_qout), .CLK(CLK), .RSTn(RSTn));

//0x12
wire [31:0] hartinfo_dnxt;
wire [31:0] hartinfo_qout;
gen_dffr # (.DW(32)) hartinfo ( .dnxt(hartinfo_dnxt), .qout(hartinfo_qout), .CLK(CLK), .RSTn(RSTn));

//0x13
wire [31:0] haltsum1_dnxt;
wire [31:0] haltsum1_qout;
gen_dffr # (.DW(32)) haltsum1 ( .dnxt(haltsum1_dnxt), .qout(haltsum1_qout), .CLK(CLK), .RSTn(RSTn));

//0x14
wire [31:0] hawindowsel_dnxt;
wire [31:0] hawindowsel_qout;
gen_dffr # (.DW(32)) hawindowsel ( .dnxt(hawindowsel_dnxt), .qout(hawindowsel_qout), .CLK(CLK), .RSTn(RSTn));

//0x15
wire [31:0] hawindow_dnxt;
wire [31:0] hawindow_qout;
gen_dffr # (.DW(32)) hawindowsel ( .dnxt(hawindow_dnxt), .qout(hawindow_qout), .CLK(CLK), .RSTn(RSTn));

//0x16
wire [31:0] abstractcs_dnxt;
wire [31:0] abstractcs_qout;
gen_dffr # (.DW(32)) abstractcs ( .dnxt(abstractcs_dnxt), .qout(abstractcs_qout), .CLK(CLK), .RSTn(RSTn));

//0x17
wire [31:0] command_dnxt;
wire [31:0] command_qout;
gen_dffr # (.DW(32)) command ( .dnxt(command_dnxt), .qout(command_qout), .CLK(CLK), .RSTn(RSTn));

//0x18
wire [31:0] abstractauto_dnxt;
wire [31:0] abstractauto_qout;
gen_dffr # (.DW(32)) abstractauto ( .dnxt(abstractauto_dnxt), .qout(abstractauto_qout), .CLK(CLK), .RSTn(RSTn));

//0x19
wire [31:0] confstrptr0_dnxt;
wire [31:0] confstrptr0_qout;
gen_dffr # (.DW(32)) confstrptr0 ( .dnxt(confstrptr0_dnxt), .qout(confstrptr0_qout), .CLK(CLK), .RSTn(RSTn));

//0x1a
wire [31:0] confstrptr1_dnxt;
wire [31:0] confstrptr1_qout;
gen_dffr # (.DW(32)) confstrptr1 ( .dnxt(confstrptr1_dnxt), .qout(confstrptr1_qout), .CLK(CLK), .RSTn(RSTn));

//0x1b
wire [31:0] confstrptr2_dnxt;
wire [31:0] confstrptr2_qout;
gen_dffr # (.DW(32)) confstrptr2 ( .dnxt(confstrptr2_dnxt), .qout(confstrptr2_qout), .CLK(CLK), .RSTn(RSTn));

//0x1c
wire [31:0] confstrptr3_dnxt;
wire [31:0] confstrptr3_qout;
gen_dffr # (.DW(32)) confstrptr3 ( .dnxt(confstrptr3_dnxt), .qout(confstrptr3_qout), .CLK(CLK), .RSTn(RSTn));

//0x1d
wire [31:0] nextdm = 32'h0;

//0x20
wire [31:0] progbuf0_dnxt;
wire [31:0] progbuf0_qout;
gen_dffr # (.DW(32)) progbuf0 ( .dnxt(progbuf0_dnxt), .qout(progbuf0_qout), .CLK(CLK), .RSTn(RSTn));

//0x21
wire [31:0] progbuf1_dnxt;
wire [31:0] progbuf1_qout;
gen_dffr # (.DW(32)) progbuf1 ( .dnxt(progbuf1_dnxt), .qout(progbuf1_qout), .CLK(CLK), .RSTn(RSTn));

//0x22
wire [31:0] progbuf2_dnxt;
wire [31:0] progbuf2_qout;
gen_dffr # (.DW(32)) progbuf2 ( .dnxt(progbuf2_dnxt), .qout(progbuf2_qout), .CLK(CLK), .RSTn(RSTn));

//0x23
wire [31:0] progbuf3_dnxt;
wire [31:0] progbuf3_qout;
gen_dffr # (.DW(32)) progbuf3 ( .dnxt(progbuf3_dnxt), .qout(progbuf3_qout), .CLK(CLK), .RSTn(RSTn));

//0x24
wire [31:0] progbuf4_dnxt;
wire [31:0] progbuf4_qout;
gen_dffr # (.DW(32)) progbuf4 ( .dnxt(progbuf4_dnxt), .qout(progbuf4_qout), .CLK(CLK), .RSTn(RSTn));

//0x25
wire [31:0] progbuf5_dnxt;
wire [31:0] progbuf5_qout;
gen_dffr # (.DW(32)) progbuf5 ( .dnxt(progbuf5_dnxt), .qout(progbuf5_qout), .CLK(CLK), .RSTn(RSTn));

//0x26
wire [31:0] progbuf6_dnxt;
wire [31:0] progbuf6_qout;
gen_dffr # (.DW(32)) progbuf6 ( .dnxt(progbuf6_dnxt), .qout(progbuf6_qout), .CLK(CLK), .RSTn(RSTn));

//0x27
wire [31:0] progbuf7_dnxt;
wire [31:0] progbuf7_qout;
gen_dffr # (.DW(32)) progbuf7 ( .dnxt(progbuf7_dnxt), .qout(progbuf7_qout), .CLK(CLK), .RSTn(RSTn));

//0x28
wire [31:0] progbuf8_dnxt;
wire [31:0] progbuf8_qout;
gen_dffr # (.DW(32)) progbuf8 ( .dnxt(progbuf8_dnxt), .qout(progbuf8_qout), .CLK(CLK), .RSTn(RSTn));

//0x29
wire [31:0] progbuf9_dnxt;
wire [31:0] progbuf9_qout;
gen_dffr # (.DW(32)) progbuf9 ( .dnxt(progbuf9_dnxt), .qout(progbuf9_qout), .CLK(CLK), .RSTn(RSTn));

//0x2a
wire [31:0] progbuf10_dnxt;
wire [31:0] progbuf10_qout;
gen_dffr # (.DW(32)) progbuf10 ( .dnxt(progbuf10_dnxt), .qout(progbuf10_qout), .CLK(CLK), .RSTn(RSTn));

//0x2b
wire [31:0] progbuf11_dnxt;
wire [31:0] progbuf11_qout;
gen_dffr # (.DW(32)) progbuf11 ( .dnxt(progbuf11_dnxt), .qout(progbuf11_qout), .CLK(CLK), .RSTn(RSTn));

//0x2c
wire [31:0] progbuf12_dnxt;
wire [31:0] progbuf12_qout;
gen_dffr # (.DW(32)) progbuf12 ( .dnxt(progbuf12_dnxt), .qout(progbuf12_qout), .CLK(CLK), .RSTn(RSTn));

//0x2d
wire [31:0] progbuf13_dnxt;
wire [31:0] progbuf13_qout;
gen_dffr # (.DW(32)) progbuf13 ( .dnxt(progbuf13_dnxt), .qout(progbuf13_qout), .CLK(CLK), .RSTn(RSTn));

//0x2e
wire [31:0] progbuf14_dnxt;
wire [31:0] progbuf14_qout;
gen_dffr # (.DW(32)) progbuf14 ( .dnxt(progbuf14_dnxt), .qout(progbuf14_qout), .CLK(CLK), .RSTn(RSTn));

//0x2f
wire [31:0] progbuf15_dnxt;
wire [31:0] progbuf15_qout;
gen_dffr # (.DW(32)) progbuf15 ( .dnxt(progbuf15_dnxt), .qout(progbuf15_qout), .CLK(CLK), .RSTn(RSTn));

//0x30
wire [31:0] authdata_dnxt;
wire [31:0] authdata_qout;
gen_dffr # (.DW(32)) authdata ( .dnxt(authdata_dnxt), .qout(authdata_qout), .CLK(CLK), .RSTn(RSTn));

//0x34
wire [31:0] haltsum2_dnxt;
wire [31:0] haltsum2_qout;
gen_dffr # (.DW(32)) haltsum2 ( .dnxt(haltsum2_dnxt), .qout(haltsum2_qout), .CLK(CLK), .RSTn(RSTn));

//0x35
wire [31:0] haltsum3_dnxt;
wire [31:0] haltsum3_qout;
gen_dffr # (.DW(32)) haltsum3 ( .dnxt(haltsum3_dnxt), .qout(haltsum3_qout), .CLK(CLK), .RSTn(RSTn));

//0x37
wire [31:0] sbaddress3_dnxt;
wire [31:0] sbaddress3_qout;
gen_dffr # (.DW(32)) sbaddress3 ( .dnxt(sbaddress3_dnxt), .qout(sbaddress3_qout), .CLK(CLK), .RSTn(RSTn));

//0x38
wire [31:0] sbcs_dnxt;
wire [31:0] sbcs_qout;
gen_dffr # (.DW(32)) sbcs ( .dnxt(sbcs_dnxt), .qout(sbcs_qout), .CLK(CLK), .RSTn(RSTn));

//0x39
wire [31:0] sbaddress0_dnxt;
wire [31:0] sbaddress0_qout;
gen_dffr # (.DW(32)) sbaddress0 ( .dnxt(sbaddress0_dnxt), .qout(sbaddress0_qout), .CLK(CLK), .RSTn(RSTn));

//0x3a
wire [31:0] sbaddress1_dnxt;
wire [31:0] sbaddress1_qout;
gen_dffr # (.DW(32)) sbaddress1 ( .dnxt(sbaddress1_dnxt), .qout(sbaddress1_qout), .CLK(CLK), .RSTn(RSTn));

//0x3b
wire [31:0] sbaddress2_dnxt;
wire [31:0] sbaddress2_qout;
gen_dffr # (.DW(32)) sbaddress2 ( .dnxt(sbaddress2_dnxt), .qout(sbaddress2_qout), .CLK(CLK), .RSTn(RSTn));

//0x3c
wire [31:0] sbdata0_dnxt;
wire [31:0] sbdata0_qout;
gen_dffr # (.DW(32)) sbdata0 ( .dnxt(sbdata0_dnxt), .qout(sbdata0_qout), .CLK(CLK), .RSTn(RSTn));

//0x3d
wire [31:0] sbdata1_dnxt;
wire [31:0] sbdata1_qout;
gen_dffr # (.DW(32)) sbdata1 ( .dnxt(sbdata1_dnxt), .qout(sbdata1_qout), .CLK(CLK), .RSTn(RSTn));

//0x3e
wire [31:0] sbdata2_dnxt;
wire [31:0] sbdata2_qout;
gen_dffr # (.DW(32)) sbdata2 ( .dnxt(sbdata2_dnxt), .qout(sbdata2_qout), .CLK(CLK), .RSTn(RSTn));

//0x3f
wire [31:0] sbdata3_dnxt;
wire [31:0] sbdata3_qout;
gen_dffr # (.DW(32)) sbdata3 ( .dnxt(sbdata3_dnxt), .qout(sbdata3_qout), .CLK(CLK), .RSTn(RSTn));

//0x40
wire [31:0] haltsum0_dnxt;
wire [31:0] haltsum0_qout;
gen_dffr # (.DW(32)) haltsum0 ( .dnxt(haltsum0_dnxt), .qout(haltsum0_qout), .CLK(CLK), .RSTn(RSTn));







assign reg_data_out =
	  ({32{axi_araddr == 8'h4}} & data0_qout)
	| ({32{axi_araddr == 8'h5}} & data1_qout)
	| ({32{axi_araddr == 8'h6}} & data2_qout)
	| ({32{axi_araddr == 8'h7}} & data3_qout)
	| ({32{axi_araddr == 8'h8}} & data4_qout)
	| ({32{axi_araddr == 8'h9}} & data5_qout)
	| ({32{axi_araddr == 8'ha}} & data6_qout)
	| ({32{axi_araddr == 8'hb}} & data7_qout)
	| ({32{axi_araddr == 8'hc}} & data8_qout)
	| ({32{axi_araddr == 8'hd}} & data9_qout)
	| ({32{axi_araddr == 8'he}} & data10_qout)
	| ({32{axi_araddr == 8'hf}} & data11_qout)

	| ({32{axi_araddr == 8'h10}} & dmcontrol_qout)
	| ({32{axi_araddr == 8'h11}} & dmstatus_qout)
	| ({32{axi_araddr == 8'h12}} & hartinfo_qout)
	| ({32{axi_araddr == 8'h13}} & haltsum1_qout)
	| ({32{axi_araddr == 8'h14}} & hawindowsel_qout)
	| ({32{axi_araddr == 8'h15}} & hawindow_qout)
	| ({32{axi_araddr == 8'h16}} & abstractcs_qout)
	// | ({32{axi_araddr == 8'h17}} & command_qout)
	| ({32{axi_araddr == 8'h18}} & abstractauto_qout)

	| ({32{axi_araddr == 8'h19}} & confstrptr0_qout)
	| ({32{axi_araddr == 8'h1a}} & confstrptr1_qout)
	| ({32{axi_araddr == 8'h1b}} & confstrptr2_qout)
	| ({32{axi_araddr == 8'h1c}} & confstrptr3_qout)

	| ({32{axi_araddr == 8'h1d}} & nextdm)

	| ({32{axi_araddr == 8'h20}} & progbuf0_qout)
	| ({32{axi_araddr == 8'h21}} & progbuf1_qout)
	| ({32{axi_araddr == 8'h22}} & progbuf2_qout)
	| ({32{axi_araddr == 8'h23}} & progbuf3_qout)
	| ({32{axi_araddr == 8'h24}} & progbuf4_qout)
	| ({32{axi_araddr == 8'h25}} & progbuf5_qout)
	| ({32{axi_araddr == 8'h26}} & progbuf6_qout)
	| ({32{axi_araddr == 8'h27}} & progbuf7_qout)
	| ({32{axi_araddr == 8'h28}} & progbuf8_qout)
	| ({32{axi_araddr == 8'h29}} & progbuf9_qout)
	| ({32{axi_araddr == 8'h2a}} & progbuf10_qout)
	| ({32{axi_araddr == 8'h2b}} & progbuf11_qout)
	| ({32{axi_araddr == 8'h2c}} & progbuf12_qout)
	| ({32{axi_araddr == 8'h2d}} & progbuf13_qout)
	| ({32{axi_araddr == 8'h2e}} & progbuf14_qout)
	| ({32{axi_araddr == 8'h2f}} & progbuf15_qout)

	| ({32{axi_araddr == 8'h30}} & authdata_qout)
	| ({32{axi_araddr == 8'h34}} & haltsum2_qout)
	| ({32{axi_araddr == 8'h35}} & haltsum3_qout)
	| ({32{axi_araddr == 8'h37}} & sbaddress3_qout)
	| ({32{axi_araddr == 8'h38}} & sbcs_qout)

	| ({32{axi_araddr == 8'h39}} & sbaddress0_qout)
	| ({32{axi_araddr == 8'h3a}} & sbaddress1_qout)
	| ({32{axi_araddr == 8'h3b}} & sbaddress2_qout)

	| ({32{axi_araddr == 8'h3c}} & sbdata0_qout)
	| ({32{axi_araddr == 8'h3d}} & sbdata1_qout)
	| ({32{axi_araddr == 8'h3e}} & sbdata2_qout)
	| ({32{axi_araddr == 8'h3f}} & sbdata3_qout)

	| ({32{axi_araddr == 8'h40}} & haltsum0_qout)
	| 32'b0

	;






	// always @(posedge or negedge RSTn) begin
	// 	if (~RSTn) begin
	// 	  slv_reg0 <= 0;
	// 	  slv_reg1 <= 0;
	// 	  slv_reg2 <= 0;
	// 	  slv_reg3 <= 0;
	// 	end 
	// 	else begin
	// 		if (slv_reg_wren) begin
	// 			case ( axi_awaddr )
	// 				2'h0: begin
	// 					slv_reg0 <= S_AXI_WDATA;
	// 				end  
	// 				2'h1: begin
	// 					slv_reg1 <= S_AXI_WDATA;
	// 				end  
	// 			  	2'h2: begin
	// 					slv_reg2 <= S_AXI_WDATA;
	// 				end  
	// 				2'h3: begin
	// 					slv_reg3 <= S_AXI_WDATA;
	// 				end

	// 				8'h1d: begin
	// 				end

	// 			  	default : begin
	// 					slv_reg0 <= slv_reg0;
	// 					slv_reg1 <= slv_reg1;
	// 					slv_reg2 <= slv_reg2;
	// 					slv_reg3 <= slv_reg3;
	// 				end
	// 			endcase
	// 		end
	//   	end
	// end  



//0x04
assign data0_dnxt = 
	dmactive ? 32'b0 :
				(slv_reg_wren & axi_awaddr == 8'h4) ? S_AXI_WDATA :;

//0x05
assign data1_dnxt;

//0x06
assign data2_dnxt;

//0x07
assign data3_dnxt;

//0x08
assign data4_dnxt;

//0x09
assign data5_dnxt;

//0x0a
assign data6_dnxt;

//0x0b
assign data7_dnxt;

//0x0c
assign data8_dnxt;

//0x0d
assign data9_dnxt;

//0x0e
assign data10_dnxt;

//0x0f
assign data11_dnxt;

//0x10
assign dmcontrol_dnxt;

//0x11
assign dmstatus_dnxt;

//0x12
assign hartinfo_dnxt;

//0x13
assign haltsum1_dnxt;

//0x14
assign hawindowsel_dnxt;

//0x15
assign hawindow_dnxt;

//0x16
assign abstractcs_dnxt;

//0x17
assign command_dnxt;

//0x18
assign abstractauto_dnxt;

//0x19
assign confstrptr0_dnxt;

//0x1a
assign confstrptr1_dnxt;

//0x1b
assign confstrptr2_dnxt;

//0x1c
assign confstrptr3_dnxt;

//0x1d
assign nextdm = 32'h0;

//0x20
assign progbuf0_dnxt;

//0x21
assign progbuf1_dnxt;

//0x22
assign progbuf2_dnxt;

//0x23
assign progbuf3_dnxt;

//0x24
assign progbuf4_dnxt;

//0x25
assign progbuf5_dnxt;

//0x26
assign progbuf6_dnxt;

//0x27
assign progbuf7_dnxt;

//0x28
assign progbuf8_dnxt;

//0x29
assign progbuf9_dnxt;

//0x2a
assign progbuf10_dnxt;

//0x2b
assign progbuf11_dnxt;

//0x2c
assign progbuf12_dnxt;

//0x2d
assign progbuf13_dnxt;

//0x2e
assign progbuf14_dnxt;

//0x2f
assign progbuf15_dnxt;

//0x30
assign authdata_dnxt;

//0x34
assign haltsum2_dnxt;

//0x35
assign haltsum3_dnxt;

//0x37
assign sbaddress3_dnxt;

//0x38
assign sbcs_dnxt;

//0x39
assign sbaddress0_dnxt;

//0x3a
assign sbaddress1_dnxt;

//0x3b
assign sbaddress2_dnxt;

//0x3c
assign sbdata0_dnxt;

//0x3d
assign sbdata1_dnxt;

//0x3e
assign sbdata2_dnxt;

//0x3f
assign sbdata3_dnxt;

//0x40
assign haltsum0_dnxt;







endmodule

