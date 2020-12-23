/*
* @File name: div_tb
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-12-23 14:37:23
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-12-23 19:37:32
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



module div_tb (

);
	reg CLK;
	reg RSTn;
	reg mulDiv_exeparam_vaild;
	reg rv64m_div,rv64m_divu, rv64m_rem, rv64m_remu, rv64m_divw, rv64m_divuw, rv64_remw, rv64m_remuw;	

	reg [63:0] src1;
	reg [63:0] src2;






	//div
	wire div_fun = 
		rv64m_div
		| rv64m_divu
		| rv64m_rem
		| rv64m_remu
		| rv64m_divw
		| rv64m_divuw
		| rv64_remw
		| rv64m_remuw;

	wire is32w = rv64m_divw | rv64m_divuw | rv64_remw | rv64m_remuw;
	wire isUsi = rv64m_divu | rv64m_remu | rv64m_divuw | rv64m_remuw;


	wire [127:0] dividend_dnxt, dividend_qout;
	wire [127:0] divisor_dnxt, divisor_qout;
	wire [63:0] div_res_dnxt, div_res_qout;
	wire [6:0] div_cnt_dnxt, div_cnt_qout;

	wire [63:0] dividend_load = isUsi ? 
									src1 : 
									( 
										is32w ?  
											{ 32'b0, (src1[31] ? $signed(-src1[31:0]) : src1[31:0])} : 
											(src1[63] ? $signed(-src1) : src1)
									);

	wire [63:0] divisor_load = isUsi ? 
									src2 : 
									( 
										is32w ?  
										{ {32'b0}, (src2[31] ? $signed(-src2[31:0]) : src2[31:0])} : 
											(src2[63] ? $signed(-src2) : src2)
									);

	wire dividend_sign = isUsi ? 1'b0 : (is32w ? src1[31] : src1[63]);
	wire divisor_sign  = isUsi ? 1'b0 : (is32w ? src2[31] : src2[63]);

	wire signed [127:0] add_op1, add_op2, add_res;
	wire div_cmp;

	wire div_by_zero = (src2 == 64'd0);
	wire div_overflow = ~isUsi & 
							(
								(is32w & (src1[31] & ~src1[30:0]) & (&src2[31:0]))
								|
								(~is32w & (src1[63] & ~src1[62:0]) & (&src2[63:0]))								
							);

	wire [6:0] cnt_init = 6'd63;






	assign dividend_dnxt = (mulDiv_exeparam_vaild & div_fun) ? 
						{64'd0, dividend_load} :
						((div_cnt_dnxt == 7'd64) ? dividend_qout : add_res)
						;
	assign divisor_dnxt = (mulDiv_exeparam_vaild & div_fun) ? 
						{divisor_load, 64'd0} :
						divisor_qout >> 1;

	assign div_cnt_dnxt = (mulDiv_exeparam_vaild & div_fun) ? 
							cnt_init :
							(div_cnt_qout == 7'd64 ? div_cnt_qout : div_cnt_qout - 1);

	assign div_cmp_dnxt = isUsi ? (dividend_dnxt < divisor_dnxt) : dividend_dnxt[63] ^ divisor_dnxt[63];
	assign div_cmp_qout = isUsi ? (dividend_qout < divisor_qout) : dividend_qout[63] ^ divisor_qout[63];

	assign add_op1 = dividend_qout;
	assign add_op2 = divisor_qout;
	assign add_res = $signed(add_op1) + (div_cmp_qout ? $signed(add_op2) : $signed(-add_op2));

	assign div_res_dnxt = (mulDiv_exeparam_vaild & div_fun) ? 
							64'b0 :
							(div_cnt_dnxt == 7'd64 ? div_res_qout : (div_res_qout << 1 | {63'b0, ~div_cmp_dnxt}));



	// wire [63:0] inv_src1;
	// wire [63:0] inv_src2;

	// wire [5:0] src1_zp;
	// wire [5:0] src2_zp;

	// wire isSrc1_all0;
	// wire isSrc2_all0;

	// wire [6:0] src1_dw;
	// wire [6:0] src2_dw;

	// generate
	// 	for ( genvar i = 0; i < 64; i = i + 1 ) begin
	// 		assign inv_src1[i] = ~src1[63-i];
	// 		assign inv_src2[i] = ~src2[63-i];
	// 	end
	// endgenerate


	// lzp #(
	// 	.CW(6)
	// ) src1_lzp(
	// 	.in_i(inv_src1),
	// 	.pos_o(src1_zp), // the last zero pos is the first 1 pos after reverting
	// 	.all1(isSrc1_all0), // has been reverted
	// 	.all0()
	// );


	// lzp #(
	// 	.CW(6)
	// ) src2_lzp(
	// 	.in_i(inv_src2),
	// 	.pos_o(src2_zp),
	// 	.all1(isSrc2_all0), // has been reverted
	// 	.all0()
	// );

	// assign src1_dw = isSrc1_all0 ? 7'd0 : 7'd64 - src1_zp;
	// assign src2_dw = isSrc2_all0 ? 7'd0 : 7'd64 - src2_zp;









	gen_dffr # (.DW(128)) dividend ( .dnxt(dividend_dnxt), .qout(dividend_qout), .CLK(CLK), .RSTn(RSTn));
	gen_dffr # (.DW(128)) divisor ( .dnxt(divisor_dnxt), .qout(divisor_qout), .CLK(CLK), .RSTn(RSTn));
	gen_dffr # (.DW(64)) div_res ( .dnxt(div_res_dnxt), .qout(div_res_qout), .CLK(CLK), .RSTn(RSTn));
	gen_dffr # (.DW(7)) div_cnt ( .dnxt(div_cnt_dnxt), .qout(div_cnt_qout), .CLK(CLK), .RSTn(RSTn));








initial
begin
	$dumpfile("../build/div_tb.vcd"); //生成的vcd文件名称
	$dumpvars(0, div_tb);//tb模块名称
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

	mulDiv_exeparam_vaild = 0;
	rv64m_div = 0;
	rv64m_divu = 0;
	rv64m_rem = 0;
	rv64m_remu = 0;
	rv64m_divw = 0;
	rv64m_divuw = 0;
	rv64_remw = 0;
	rv64m_remuw	= 0;

	src1 = 0;
	src2 = 0;

	#36

	mulDiv_exeparam_vaild = 1;
	rv64m_div = 1;
	rv64m_divu = 0;
	rv64m_rem = 0;
	rv64m_remu = 0;
	rv64m_divw = 0;
	rv64m_divuw = 0;
	rv64_remw = 0;
	rv64m_remuw	= 0;

	src1 = -21000;
	src2 = -3;

# 10

	mulDiv_exeparam_vaild = 0;




end
































endmodule



