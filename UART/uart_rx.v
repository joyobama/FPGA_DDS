/** charset = ascii **/
module uart_rx(bclk,rst,RX,rx_done,rx_dout);
	input bclk,rst,RX;
	output rx_done;
	output[7:0] rx_dout;
	reg rx_done = 0;
	reg[7:0] rx_dout;
	/** internal registers **/
	reg[3:0] dcnt;
	reg[3:0] cnt;	
	reg[3:0] jcnt;  
	wire rec_bit;   
	reg state = 1'b0;
	assign rec_bit = jcnt > 4'b0111;
	always@(posedge bclk or negedge rst)
		if(~rst) begin
			state <= 1'b0;
			rx_done <= 0;
		end
		else 
			case(state)
				1'b0: begin
					rx_done <= 0;
					dcnt <= 0;
					cnt <= 0;
					jcnt <= 0;
					if(~RX) 
						state <= 1'b1;
				end
				1'b1: begin
					cnt <= cnt+1;
					if(dcnt == 4'b1001)	begin		
						if(cnt == 4'b0010)
							rx_done <= 1;
						else if(cnt == 4'b1001)
							state <= 1'b0;
					end
					else if(cnt == 4'b1111) begin
						dcnt <= dcnt+1;
						if(dcnt == 4'd0 && rec_bit)	
							state <= 1'b0;
						rx_dout <= {rec_bit,rx_dout[7:1]};
						jcnt <= 0;
					end
					else if(RX)
						jcnt <= jcnt+1;
				end
			endcase
endmodule
					
				
				









