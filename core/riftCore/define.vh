/*
* @File name: define
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-10-22 11:47:58
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-11-02 16:43:31
*/


`define RP   4 //重命名深度
`define RB $clog2(`RP) 



`define DECODE_INFO_DW (52+1+6+1+64+64+6+5+5+5) 
`define REORDER_INFO_DW (64+(5+`RB)+3)

`define ADDER_ISSUE_INFO_DW (8+64+64+(5+`RB)+(5+`RB)+(5+`RB))
`define ADDER_ISSUE_INFO_DP 4
`define ADDER_EXEPARAM_DW (2+(5+`RB)+64+64+1)

`define LOGCMP_ISSUE_INFO_DW (10+64+64+(5+`RB)+(5+`RB)+(5+`RB))
`define LOGCMP_ISSUE_INFO_DP 4
`define LOGCMP_EXEPARAM_DW (4+(5+`RB)+64+64+1)

`define SHIFT_ISSUE_INFO_DW (12+64+64+6+(5+`RB)+(5+`RB)+(5+`RB))
`define SHIFT_ISSUE_INFO_DP 4
`define SHIFT_EXEPARAM_DW (3+(5+`RB)+64+64+1)

`define JAL_ISSUE_INFO_DW (2+64+(5+`RB)+(5+`RB)+1)
`define JAL_ISSUE_INFO_DP 2
`define JAL_EXEPARAM_DW (2+(5+`RB)+64+64+1)

`define BRU_ISSUE_INFO_DW (6+(5+`RB)+(5+`RB))
`define BRU_ISSUE_INFO_DP 2
`define BRU_EXEPARAM_DW (6+64+64)

`define LU_ISSUE_INFO_DW (7+64+(5+`RB)+(5+`RB))
`define LU_ISSUE_INFO_DP 4
`define LU_EXEPARAM_DW (4+(5+`RB)+64+1)

`define SU_ISSUE_INFO_DW (4+64+(5+`RB)+(5+`RB))
`define SU_ISSUE_INFO_DP 2
`define SU_EXEPARAM_DW (4+64+64)


`define CSR_ISSUE_INFO_DW (6+12+(5+`RB)+(5+`RB))
`define CSR_ISSUE_INFO_DP 2
`define CSR_EXEPARAM_DW (3+(5+`RB)+64+12)





