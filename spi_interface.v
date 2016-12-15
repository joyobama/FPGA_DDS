`timescale 1ns / 1ps
module spi_interface(clk,rst,in,out,start,SCLK,MISO,MOSI,CS);
	input clk,start,rst,MISO;  // posedge rst is not necessary,it can just stay low
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
	always@(posedge inter_clk or posedge start or posedge rst)
		if(start || rst)
			CLK_DIV_REG <= 0;
		else
			CLK_DIV_REG <= CLK_DIV_REG+1;
	/*  master state
	* state = 0 free or write or read finish
	* state = 2^i  the i-th bit is ready to read or write
	* after the last bit is read or write half clock circle the CS becomes high from low 
	*/
	always@(negedge SCLK or posedge start or posedge rst)
		if(rst) begin
			state <= 8'd0;
			CS <= 1;
		end
		else if(start) begin
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
