/*
* @File name: pcGenerate
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-10-13 16:56:39
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-10-31 17:49:05
*/

//产生的pc不是执行pc，每条指令应该对应一个pc



module pcGenerate (

	//feedback
	output [63:0] fetch_pc_dnxt,
	input [63:0] fetch_pc_reg,
	input isReset,

	//from jalr exe
	input jalr_vaild,
	input [63:0] jalr_pc,
	
	//from bru
	input bru_res_vaild,
	input bru_takenBranch,


	// from expection 	

	//to commit to flush
	output isMisPredict,

	//to fetch
	output [31:0] instr_readout,


	//hadnshake
	output pcGen_ready,
	output isInstrReadOut,
	input instrFifo_full,

	input CLK,
	input RSTn

);


// from branch predict
wire [63:0] taken_pc;
wire isTakenBranch;
wire isPredit;


wire pcGen_fetch_vaild;



$warning("暂时忽略中断异常");
wire expection_vaild = 1'b0;
wire isExpection = 1'b0;
wire [63:0] expection_pc = 64'h0;


	wire isJal;
	wire isJalr;
	wire isBranch;

	wire isCall;
	wire isReturn;
wire [31:0] load_instr;
wire [63:0] next_pc;
wire [63:0] take_pc;
wire ras_empty;


//分支历史表写入没有预测的分支项
wire [63+1:0] bht_data_pop;
wire [63+1:0] bht_data_push = {64{~isTakenBranch}} & taken_pc 
							|
							 {64{isTakenBranch}} & next_pc;

wire bht_full;
wire bht_pop = bru_res_vaild;
wire bht_push = isPredit & ~bht_full;

//分支历史表必须保持最后一个结果显示
assign isMisPredict = bru_res_vaild & ( bru_takenBranch ^ bht_data_pop[64]);
wire [63:0] resolve_pc = bht_data_pop[63:0];



assign fetch_pc_dnxt = 	pcGen_fetch_vaild? (
						( {64{isExpection}} & expection_pc )
						| 
						( ( {64{~isExpection}} ) & 
							(	
								( {64{isMisPredict}} & resolve_pc)
								|
								(
									{64{~isMisPredict}} &
									(
										{64{isTakenBranch}} & taken_pc 
										|
										{64{~isTakenBranch}} & next_pc
									)

								)

							)
						) )
						:
						fetch_pc_reg;

$info("在有分支预测且bht已满时会卡流水线，保持输入的指令不变");
$info("在jalr有可能卡流水线，保持输入指令不变");
$info("在指令fifo满时会卡流水线，保持输入指令不变");
assign pcGen_fetch_vaild =  ~ ( (bht_full & isPredit) 
					 		| ( isJalr & ~jalr_vaild & ( ras_empty | ~isReturn ) )
					 		| instrFifo_full
					 		);





//branch predict





//在这里把地址计算出来，同时保留两者结果并根据预测算法决策，并和最终结果对比
//如果是JARL必需要跳，但是寄存器需要到发射之后才可以确定，因此需要在BLU中计算，预测没有意义，直接挂起取指即可


	assign isJal = (load_instr[6:0] == 7'b1101111);
	assign isJalr = (load_instr[6:0] == 7'b1100111);
	assign isBranch = (load_instr[6:0] == 7'b1100011);

	assign isCall = (isJalr | isJal) & ((load_instr[11:7] == 5'd1) | load_instr[11:7] == 5'd5);
	assign isReturn = isJalr & ((load_instr[19:15] == 5'd1) | load_instr[19:15] == 5'd5)
								& (load_instr[19:15] != load_instr[11:7]);


    $warning("在没有压缩指令的情况下");
	wire is_rvc_instr = 1'b0;
	wire [63:0] imm = ({64{isJal}} & {{44{load_instr[31]}},load_instr[19:12],load_instr[20],load_instr[30:21],1'b0})
	|
	({64{isJalr}} & {{52{load_instr[31]}},load_instr[31:20]})
	|
	({64{isBranch}} & {{52{load_instr[31]}},load_instr[7],load_instr[30:25],load_instr[11:8],1'b0});


//分支预测算法,分支指令才预测，直接跳转指令和其他指令不预测
assign isPredit = isBranch;

//分支指令只预测向后跳则采用taken结果，无条件跳转直接采用taken结果，分支前跳和其他指令采用pc自增组
assign isTakenBranch = ( (isBranch) & ( (imm[63] == 1'b0) : 1'b1 : 1'b0) )
						| (isJal | isJalr); 




//RAS 返回地址堆栈
wire [63:0] ras_addr_pop;
wire [63:0] ras_addr_push;




wire ras_push = isCall & ( isJal | isJalr );
wire ras_pop = isReturn & ( isJalr ) & ( !ras_empty );

//计算两种分支结果
assign next_pc = isReset ? (64'h80000000) : fetch_pc_reg + ( is_rvc_instr ? 64'd2 : 64'd4 );
assign take_pc = ( {64{isJal | isBranch}} & (fetch_pc_reg + imm) )
					| ( {64{isJalr &  ras_pop}} & ras_addr_pop ) 
					| ( {64{isJalr & !ras_pop & jalr_vaild}} & jalr_pc  );


assign ras_addr_push = next_pc;



wire isITCM = (fetch_pc_dnxt & 64'hFFFF_FFFF_FFFF_0000) == 64'h8000_0000;
$warning("在没有cache的情况下");
wire isCache = 1'b0;






$info("如果不能立即获得指令，当拍可能打多次");
$warning("在没有调试器访问写入的情况下,在不使用奇偶存储器情况下");
itcm #
	(
		.DW(32),
		.AW(14)
	)i_itcm
	(

	.addr(fetch_pc_dnxt[2 +: 14]),
	.instr_out(load_instr),

	.instr_in('b0),
	.wen('b0),

	.CLK(CLK)
	
);




$warning("在不考虑压缩指令并强制32bit对齐的情况下");
assign instr_readout = load_instr;

$warning("在使用ITCM强制一拍必出指令的情况下");


gen_dffr # (.DW(1)) isReadOut ( .dnxt(pcGen_fetch_vaild), .qout(isInstrReadOut), .CLK(CLK), .RSTn(RSTn));

wire mem_ready = 1'b1; $warning("itcm总是ready");
assign pcGen_ready = pcGen_fetch_vaild & mem_ready;




//分支历史表
//分支历史表必须保持最后一个结果显示，必须可以同时pop，push
$warning("假设分支最多16次,fifo满则挂机");

gen_fifo # (
	.DW(64+1),
	.AW(4)
) bht(

	.fifo_pop(bht_pop), 
	.fifo_push(bht_push),
	.data_push(bht_data_push),

	.fifo_empty(), 
	.fifo_full(bht_full), 
	.data_pop(bht_data_pop),

	.CLK(CLK),
	.RSTn()
);



$info("使用 ring-fifo策略，压栈不会压爆，但是会空");
$warning("暂时没有commit反馈，冲刷只能全部刷掉");
gen_ringStack # (.DW(64), .AW(4)) ras(
	.stack_pop(ras_pop), .stack_push(ras_push),
	.stack_empty(ras_empty),
	.data_pop(ras_addr_pop), .data_push(ras_addr_push),

	.CLK(CLK),
	.RSTn()
);




endmodule










