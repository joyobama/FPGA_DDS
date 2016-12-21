`timescale 1ns / 1ps
module uart_tx(bclk, rst, tx_din, start, tx_done, TX);
	input  bclk,rst,start;
	input  [7:0] tx_din;
	output tx_done,TX;
	reg TX = 1;
	reg tx_done = 1;
	/** 内部寄存器 **/
	reg[7:0] data_t;
	reg[3:0] cnt;
	reg[3:0] dcnt;
	reg state = 1'b0;
	
	always @(posedge bclk or negedge rst)
	   if(~rst) begin
			state <= 1'b0;
			tx_done <= 1;
			TX <= 1;
		end
		else 
			case(state)
				1'b0: begin
					dcnt <= 0;
					cnt <= 0;
					data_t <= tx_din;
					if(start == 1) begin
						tx_done <= 0;
						TX <= 0;
						state <= 1'b1;
					end
					else begin
						TX <= 1;
						tx_done <= 1;
					end
				end
				1'b1: begin
					cnt <= cnt+1;
					if(dcnt == 4'b1001 && cnt == 4'b1110)   //结束位提前一个bclk返回
						state <= 1'b0;
					else if(cnt == 4'b1111) begin			//计数满16个bclk
						{data_t,TX} <= {1'b1,data_t};
						dcnt <= dcnt+1;
					end
				end
			endcase
endmodule