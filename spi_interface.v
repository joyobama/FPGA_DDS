/* charset = ascii */
`timescale 1ns / 1ps
module spi_interface(clk,in,out,start,SCLK,MISO,MOSI,CS);
	input clk,start,MISO; 
	input[7:0] in;
	output MOSI,SCLK,CS;
	output[7:0] out;
	
	parameter CLK_DIV = 2;
	
	reg [7:0] T,R,state;
	reg [CLK_DIV-1:0] CLK_DIV_REG;
	reg CS;
	wire inter_clk;
	
	assign inter_clk = clk & (~CS);
	assign out = R;
	assign SCLK = CLK_DIV_REG[CLK_DIV-1];
	assign MOSI = T[7];
	//divide input clock
	always@(posedge inter_clk or posedge start)
		if(start)
			CLK_DIV_REG <= 0;
		else
			CLK_DIV_REG <= CLK_DIV_REG+1;
	always@(negedge SCLK or posedge start)
		if(start) begin
			state <= 8'd1;
			CS <= 0;
		end
		else begin
			case(state)
				8'b0000_0001:CS <= 0;
				8'b0000_0010:CS <= 0;
				8'b0000_0100:CS <= 0;
				8'b0000_1000:CS <= 0;
				8'b0001_0000:CS <= 0;
				8'b0010_0000:CS <= 0;
				8'b0100_0000:CS <= 0;
				8'b1000_0000:CS <= 1;
				default:CS <= 1;
			endcase
			state <= {state[6:0],1'b0};
		end
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
