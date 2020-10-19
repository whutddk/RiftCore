/*
* @File name: pc_generate
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-10-13 16:56:39
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-10-19 17:15:52
*/

//产生的pc不是执行pc，每条指令应该对应一个pc



module pc_generate (


// from branch predict
	input [63:0] taken_pc,
	input [63:0] next_pc,
	input isPreditTakenBranch,
	input isPredit,
	input predit_vaild,
	
//from blu


	input blu_res_vaild,
	input blu_takenBranch,


// from expection 	


	input [63:0] blu_pc,
	input [63:0] blu_res,



	output [63:0] fetch_pc,
	output fetch_vaild,
);


//暂时忽略中断异常
wire expection_vaild = 1'b0;
wire isExpection = 1'b0;
wire [63:0] expection_pc = 64'h0;



//分支历史表写入没有预测的分支项
wire [63+1:0] bht_data_in;
wire [63+1:0] bht_data_out = {64{~isPreditTakenBranch}} & taken_pc 
							|
							 {64{isPreditTakenBranch}} & next_pc;

wire bht_pop = blu_res_vaild;
wire bht_push = isPredit;

//分支历史表必须保持最后一个结果显示
wire isMisPredict = (blu_res_vaild & ( blu_takenBranch ^ bht_data_out[64]);
wire [63:0] resolve_pc = bht_data_out[63：0];



assign fetch_pc = 	( {64{isExpection}} & expection_pc )
					| 
					( ( {64{~isExpection}} ) & 
						(	
							( {64{isMisPredict}} & resolve_pc)
							|
							(
								{64{~isMisPredict}} &
								(
									{64{isPreditTakenBranch}} & taken_pc 
									|
									{64{~isPreditTakenBranch}} & next_pc
								)

							)

						)
					);


assign fetch_vaild = predit_vaild | isMisPredict | expection_vaild;


//分支历史表
//分支历史表必须保持最后一个结果显示，必须可以同时pop，push

$warning("假设分支预测到resolve最多4拍");
bht #(
	.DEPTH(4)
	)
i_bht
(
	.clk(),
	.RSTn(),
	.flush(),

	.pop(bht_pop),
	.push(bht_push),

	.data_in(bht_data_in),
	.data_out(bht_data_out),

	.full(),
	.empty()
);




















fifo i_predit_fifo();








endmodule










