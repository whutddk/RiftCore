/*
* @File name: crackCore
* @Author: Ruige Lee
* @Email: wut.ruigeli@gmail.com
* @Date:   2020-09-19 14:09:26
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2020-10-22 12:00:54
*/



module crackCore (
	



	input CLK,
	input RSTn
	
);


pc_generate i_pcgenerate();




decode i_decode();


rename i_rename();



dispatch i_dispatch();


issue i_issue();


excute i_excute();


writeBack i_writeBack();


















endmodule














