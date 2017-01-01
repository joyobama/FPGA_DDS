/* charset = ascii */
`include "config.v"
module spi_interface(clk,din,dout,start,done,SCLK,MISO,MOSI);
	input clk,start,MISO; 
	input[7:0] din;
	output MOSI,SCLK,done;
	output[7:0] dout;
	reg done = 1;
	/** inter regs and wire **/
	parameter CLK_DIV = `SPI_CLK_DIV;
	reg [7:0] T,R;
	reg [7:0] sclk_cnt = 8'd0;
	reg [CLK_DIV-1:0] CLK_DIV_REG = 0;
	wire inter_clk;
	
	assign dout = R;
	assign MOSI = T[7];
	
	//divide input clock
	assign SCLK = CLK_DIV_REG[CLK_DIV-1];
	always@(posedge inter_clk or posedge start)
		if(start) 
			CLK_DIV_REG <= 0;
		else
			CLK_DIV_REG <= CLK_DIV_REG+1;
	//inter clk control signal
	assign inter_clk = ~done & clk & ~sclk_cnt[7];
	always@(negedge SCLK or posedge start)
		if(start) 
			sclk_cnt <= 0;
		else
			sclk_cnt <= {sclk_cnt[6:0],1'b1};
			
	// done
	always@(posedge clk or posedge start)
		if(start) 
			done <= 0;
		else if(~done && sclk_cnt==8'b1111_1111)
			done <= 1;
	// write
	always@(negedge SCLK or posedge start)
		if(start)
			T <= din;
		else
			T <= {T[6:0],1'b0};
	// read
	always@(posedge SCLK) 
		R <= {R[6:0],MISO};	
endmodule