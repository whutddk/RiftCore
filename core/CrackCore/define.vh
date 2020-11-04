/*
* @File name: define
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-10-22 11:47:58
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-11-02 16:43:31
*/


`define RNDEPTH   4 //重命名深度
`define RNBIT $clog2(RNDEPTH) 


`define MAXINDIS 20 //最大顺序派遣数 MAX_INFIY_DISPATCH



`define ALU_ISSUE_DEPTH 8 //alu 的发射buffer的深度
`define BLU_ISSUE_DEPTH 4 



`define DECODE_INFO_DW (52+1+6+1+64+64+6+5+5+5) 

`define REORDER_INFO_DW (64+(5+RNDEPTH)+3)

`define ADDER_ISSUE_INFO_DW (8+64+64+(5+RNDEPTH)+(5+RNDEPTH)+(5+RNDEPTH))
`define LOGCMP_ISSUE_INFO_DW (10+64+64+(5+RNDEPTH)+(5+RNDEPTH)+(5+RNDEPTH))
`define SHIFT_ISSUE_INFO_DW (12+64+64+6+(5+RNDEPTH)+(5+RNDEPTH)+(5+RNDEPTH))
`define JAL_ISSUE_INFO_DW (2+64+64+(5+RNDEPTH)+(5+RNDEPTH)+1)
`define BRU_ISSUE_INFO_DW (6+(5+RNDEPTH)+(5+RNDEPTH))
`define LU_ISSUE_INFO_DW (7+64+(5+RNDEPTH)+(5+RNDEPTH))
`define SU_ISSUE_INFO_DW (4+64+(5+RNDEPTH)+(5+RNDEPTH))
`define FENCE_ISSUE_INFO_DW (2+64)
`define CSR_ISSUE_INFO_DW (6+12+(5+RNDEPTH)+(5+RNDEPTH))


`define ADDER_EXEPARAM_DW (2+(5+RNBIT)+64+64+1)
`define LOGCMP_EXEPARAM_DW (4+(5+RNBIT)+64+64+1)
`define SHIFT_EXEPARAM_DW (3+(5+RNBIT)+64+64+1)
`define JAL_EXEPARAM_DW (2+(5+RNBIT)+64+64+1)
`define BRU_EXEPARAM_DW (6+64+64)
`define CSR_EXEPARAM_DW (3+(5+RNBIT)+64+12)

`define LU_EXEPARAM_DW (4+(5+RNBIT)+64+1)
`define SU_EXEPARAM_DW (4+64+64)


