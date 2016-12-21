/* charset = ascii */
`timescale 1ns / 1ps
module half_int_div_tb;
	reg clk,rst;
	wire clk_out;
	initial begin
		clk = 0;
		rst = 0;
		#5 rst = 1;
	end
	always #10 clk = ~clk;
	half_int_div m1(clk,rst,clk_out);
endmodule