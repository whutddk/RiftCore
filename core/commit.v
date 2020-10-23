/*
* @File name: commit
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-09-11 15:41:55
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-10-23 15:15:41
*/

module commit (

);








//代表架构寄存器，指向128个寄存器中的地址，完成commit
//指向当前前端可以用的寄存器位置（只会读寄存器），读完不管,32个寄存器，每个可能深度为4
//架构寄存器在commit阶段更新，同时释放rename位置
wire  [ RNBIT*32 - 1 :0 ] archi_X;
//格式一致，排除X0
assign archi_X[RNBIT-1:0] = 'd0;







endmodule


