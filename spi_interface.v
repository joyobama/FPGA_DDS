/* charset = ascii */
`timescale 1ns / 1ps
module spi_interface(clk,in,out,start,SCLK,MISO,MOSI,CS);
	input clk,start,MISO; 
	input[7:0] in;
	output MOSI,SCLK,CS;
	output[7:0] out;
	reg CS = 1;
	/** inter regs and wire **/
	parameter CLK_DIV = 2;
	reg [7:0] T,R;
	reg [7:0] sclk_cnt = 8'd0;
	reg [CLK_DIV-1:0] CLK_DIV_REG;
	wire inter_clk,inter_clk_en;
	
	assign out = R;
	assign MOSI = T[7];
	
	//divide input clock
	assign SCLK = CLK_DIV_REG[CLK_DIV-1];
	always@(posedge inter_clk or posedge start)
		if(start) 
			CLK_DIV_REG <= 0;
		else
			CLK_DIV_REG <= CLK_DIV_REG+1;
	//inter clk control signal
	assign inter_clk = ~(sclk_cnt==8'b1111_1111) & clk;
	always@(negedge SCLK or posedge start)
		if(start) 
			sclk_cnt <= 0;
		else
			sclk_cnt <= {sclk_cnt[6:0],1'b1};
			
	// CS
	always@(posedge clk or posedge start)
		if(start) 
			CS <= 0;
		else if(~CS && sclk_cnt==8'b1111_1111)
			CS <= 1;
	// write
	always@(negedge SCLK or posedge start)
		if(start)
			T <= in;
		else
			T <= {T[6:0],1'b0};
	// read
	always@(posedge SCLK) 
		R <= {R[6:0],MISO};	
endmodule