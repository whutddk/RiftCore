/*
* @File name: define
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-10-22 11:47:58
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-11-02 16:43:31
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


`define RP   4 //重命名深度
`define RB $clog2(`RP) 



`define DECODE_INFO_DW (53+1+6+1+64+64+6+5+5+5) 
`define REORDER_INFO_DW (64+(5+`RB)+3)

`define ADDER_ISSUE_INFO_DW (8+64+64+(5+`RB)+(5+`RB)+(5+`RB))
`define ADDER_ISSUE_INFO_DP 4
`define ADDER_EXEPARAM_DW (2+(5+`RB)+64+64+1)

`define LOGCMP_ISSUE_INFO_DW (10+64+64+(5+`RB)+(5+`RB)+(5+`RB))
`define LOGCMP_ISSUE_INFO_DP 4
`define LOGCMP_EXEPARAM_DW (4+(5+`RB)+64+64+1)

`define SHIFT_ISSUE_INFO_DW (12+64+6+(5+`RB)+(5+`RB)+(5+`RB))
`define SHIFT_ISSUE_INFO_DP 4
`define SHIFT_EXEPARAM_DW (3+(5+`RB)+64+64+1)

`define JAL_ISSUE_INFO_DW (2+64+64+(5+`RB)+(5+`RB)+1)
`define JAL_ISSUE_INFO_DP 2
`define JAL_EXEPARAM_DW (2+(5+`RB)+64+64+64+1)

`define BRU_ISSUE_INFO_DW (6+(5+`RB)+(5+`RB)+(5+`RB))
`define BRU_ISSUE_INFO_DP 2
`define BRU_EXEPARAM_DW (6+(5+`RB)+64+64)

`define LU_ISSUE_INFO_DW (7+64+(5+`RB)+(5+`RB))
`define LU_ISSUE_INFO_DP 4
`define LU_EXEPARAM_DW (4+(5+`RB)+64+1)

`define SU_ISSUE_INFO_DW (4+64+(5+`RB)+(5+`RB))
`define SU_ISSUE_INFO_DP 2
`define SU_EXEPARAM_DW (4+64+64)


`define CSR_ISSUE_INFO_DW (6+64+12+(5+`RB)+(5+`RB))
`define CSR_ISSUE_INFO_DP 2
`define CSR_EXEPARAM_DW (3+(5+`RB)+64+12)





