/* charset = ascii */
module wr_cmd(start,clk,addr,din,dout,done,SYNCIO,SDIO,SDO,SCLK,CS);
	input clk,start,SDO;
	input[7:0] addr;
	input[31:0] din;
	output[31:0] dout;
	output done,SYNCIO,SDIO,SCLK,CS;
	reg[31:0] dout;
	reg done = 1;
	reg SYNCIO = 0;
	assign CS = done;
	/*** internal registe and wire **/
	reg spi_start = 0;
	wire spi_done;
	reg [3:0] wr_cnt;
	reg [1:0] state = 2'd0;
	reg [7:0] cmd_addr;
	reg [31:0]cmd_data;
	wire[7:0] spi_out;	
	
	spi_interface spi_module(clk,cmd_addr,spi_out,spi_start,spi_done,SCLK,SDO,SDIO); 
	/*******************************************/
	always@(posedge clk or posedge start)
		if(start) begin	// ready to start
			spi_start <= 0;
			state <= 2'd1;
			done <= 0;
			SYNCIO <= 1;
			cmd_addr <= addr;
			cmd_data <= din;
		end
		else
			case(state)
				2'd0: begin    	// IDLE 
					done <= 1;
					SYNCIO <= 0;
				end
				2'd1: begin	 	//  ready for start
					SYNCIO <= 0;
					state <= 2'd2;
					wr_cnt <= 4'd0;
				end
				2'd2 : begin	// write datas
					spi_start <= 1;
					state <= 2'd3;
				end
				2'd3 : begin   	// write datas
					spi_start <= 0;
					if(spi_done) begin
						wr_cnt <= {wr_cnt[2:0],1'b1};
						cmd_addr <= cmd_data[31:24];
						cmd_data <= {cmd_data[23:0],8'd0};
						dout <= {dout[23:0],spi_out};
						if(wr_cnt==4'b1111) 
							state <= 2'd0;
						else
							state <= 2'd2;
					end
				end
			endcase
endmodule