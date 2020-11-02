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

