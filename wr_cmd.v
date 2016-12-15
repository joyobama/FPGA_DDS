module wr_cmd(start,clk,addr,din,dout,done,SYNCIO,SDIO,SDO,SCLK,CS,IO_UPDATE,SYNC_CLK);
	input clk,start,SYNC_CLK,SDO;
	input[7:0] addr;
	input[31:0] din;
	output[31:0] dout;
	output done,SYNCIO,SDIO,SCLK,CS,IO_UPDATE;
	
	reg[31:0] dout;
	reg done,SYNCIO,IO_UPDATE;
	
	/*** internal registe and wire **/
	reg update_done,update_en,spi_start;
	reg [3:0] wr_cnt;
	reg [2:0] state;
	reg [7:0] cmd_addr;
	reg [31:0]cmd_data;
	wire[7:0] spi_out;	
	wire inter_sync_clk;
	
	spi_interface m1( 
	.clk(clk),
	.in(cmd_addr),
	.SCLK(SCLK),
	.start(spi_start),
	.MOSI(SDIO),
	.CS(CS),
	.MISO(SDO),
	.out(spi_out));
	

	always@(posedge CS or posedge start)
		if(start) begin
			cmd_addr <= addr;
			cmd_data <= din;
		end
		else begin
			cmd_addr <= cmd_data[31:24];
			cmd_data <= {cmd_data[23:0],8'd0};
			dout <= {dout[23:0],spi_out};
		end
	/*******************************************/
	assign inter_sync_clk = SYNC_CLK | update_done;
	always@(posedge inter_sync_clk or posedge start)
		if(start)
			IO_UPDATE <= 0;
		else
			if(update_en)
				IO_UPDATE <= ~IO_UPDATE;
	always@(negedge IO_UPDATE or posedge start)
		if(start)
			update_done <= 0;
		else
			update_done <= 1;
	/*******************************************/
	always@(posedge clk or posedge start)
		if(start) begin	// ready to start
			update_en <= 0;
			spi_start <= 0;
			wr_cnt <= 4'd0;
			state <= 3'b001;
			done <= 0;
			SYNCIO <= 1;
		end
		else
			case(state)
				3'b001: begin
					SYNCIO <= 0;
					state <= {state[1:0],1'b0};
					spi_start <= 1;
				end
				3'b010: // write datas
					if(spi_start)
						spi_start <= 0;
					else
						if(CS) begin
							wr_cnt <= {wr_cnt[2:0],1'b1};
							if(wr_cnt==4'b1111) begin
								state <= {state[1:0],1'b0};
								update_en <= 1;
							end
							else
								spi_start <= 1;
						end
				3'b100:
					if(update_done) begin
						update_en <= 0;
						done <= 1;
						state <= {state[1:0],1'b0};
					end
				default: begin
					spi_start <= 0;
					state <= 3'd0;
					done <= 1;
					SYNCIO <= 0;
					update_en <=0;
				end
			endcase
endmodule