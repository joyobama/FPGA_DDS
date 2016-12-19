/* charset = ascii */
module controller(clk,rst,DROVER,DRCTL,DRHOLD,OSK,MREST,
				wr_start,wr_addr,wr_data,wr_done,wr_out,
				mem_addr,mem_done,mem_out);
  input clk,rst,DROVER,wr_done,mem_done;
  input[7:0] mem_out;
  input[31:0] wr_out;
  output DRCTL,DRHOLD,OSK,MREST,wr_start;
  output[7:0] wr_addr,mem_addr;
  output[31:0] wr_data;
  reg DRHOLD,OSK,MREST,wr_start; 
  /**内部寄存器**/
  parameter N = 2;
  reg[N-1:0] DRCTL_DELAY_REG;    
  reg busy,auto_flip_en,set_drctl;
  reg[7:0] PC,order,counter;
  reg[31:0] data; 
  assign wr_addr = order;
  assign wr_data = data;
  assign mem_addr = PC;
  /** DRCTL ***/
  assign DRCTL = (auto_flip_en & DRCTL_DELAY_REG[0]) | (~auto_flip_en & set_drctl);
  always@(posedge clk)
    if(DROVER)
      DRCTL_DELAY_REG <= {DRCTL_DELAY_REG,~DRCTL_DELAY_REG[N-1]};
    else
      DRCTL_DELAY_REG <= 0;
  /** 主状态机 **/
  always@(posedge clk or posedge rst)
    if(rst) begin
      busy <= 0;
      PC <= 8'd0;
	  wr_start <= 0;
    end
    else if(~busy && mem_done) begin
		  order <= mem_out;
		  wr_start <= 0;
		  busy <= 1;
		  counter <= 0;
		  PC <= PC+1;
    end
    else if(mem_done) begin
		counter <= {counter[6:0],1'b1};
		if(order[6]) // 自定义FPGA操作			
			if(order[3]) begin		/* order = x1xx_1???  设置OSK,DRHOLD,DRCTL电平 */
				{OSK,DRHOLD,set_drctl} <= order[2:0];
				busy <= 0;
			end
			else if(order[2]) begin	/* order = x1xx_01x?  设置DRCTL自动翻转*/
				auto_flip_en <= order[0];
				busy <= 0;
			end
			else if(order[1])		/* order = x1xx_001x  FPGA延时0-65536个clk */
				if(counter == 8'd0)
					data <= 32'd0;
				else if(counter[7:2] == 7'd0) begin
				  data <= {data[23:0],mem_out};
				  PC <= PC+1;
				end
				else begin
				  data <= data + 32'hffff_ffff;     
				  if(data == 32'd0) busy <= 0;
				end
			else if(order[0])   	/* order = x1xx_0001  复位DDS */
				if(counter == 8'd0)
					MREST <= 1;
				else begin
					MREST <= 0;
					busy <= 0;
				end
			else 					/* order = x1xx_0000  未定义操作 */
				busy <= 1;
		else
			if(order[7])  
			/***  读DDS寄存器 ***/
				if(counter == 8'd0)
					wr_start <= 1;
				else begin
					wr_start <= 0;
					if(wr_done) begin
						data <= wr_out;
						busy <= 0;
					end
				end
			/***  写DDS寄存器 ***/
			else if(counter[7:3] == 5'd0) begin
				data <= {data[23:0],mem_out};
				PC <= PC+1;
			end
			else if(counter == 8'b0000_1111)
			  wr_start <= 1;
			else begin
			  wr_start <= 0;
			  if(wr_done) busy <= 0;
			end
	end
endmodule