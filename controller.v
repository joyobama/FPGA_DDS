/**
*   x100_0001  master_rest
*   x100_001x  delay
*   x100_01x?  enable auto DRCTL flip when posedge DROVER
*   x100_1???  set OSK,DRHOLD,DRCTL
*/
module controller(clk,rst,MREST,DRCTL,DRHOLD,DROVER,OSK,SYNCIO,SDIO,SDO,SCLK,CS,IO_UPDATE,SYNC_CLK);
  input clk,rst,DROVER,SYNC_CLK,SDO;
  output DRCTL,DRHOLD,OSK,MREST,SYNCIO,SDIO,SCLK,CS,IO_UPDATE;
  parameter N = 2;
  reg MREST,DRHOLD,OSK;
  /******/
  reg[N-1:0] DRCTL_DELAY_REG;   //N = 1 ~ 5  ?DRCTL??N?clk???
  reg busy,wr_start,auto_flip_en,con_drctl;
  reg[7:0] PC,order;
  reg[31:0] data; 
  reg[7:0] counter;
  wire wr_done,rom_clk;
  wire[7:0] rom_out;
  wire[31:0] wr_out;
  /*********/
  assign rom_clk = ~clk;
  ROM m1(rom_clk,PC,rom_out);
  wr_cmd m2(wr_start,rst,clk,order,data,wr_out,wr_done,SYNCIO,SDIO,SDO,SCLK,CS,IO_UPDATE,SYNC_CLK);
  /*********/
  /** DRCTL ***/
  assign DRCTL = (auto_flip_en & DRCTL_DELAY_REG[0]) | (~auto_flip_en & con_drctl);
  always@(posedge clk or posedge DROVER)
    if(DROVER)
      DRCTL_DELAY_REG <= {DRCTL_DELAY_REG,~DRCTL_DELAY_REG[N-1]};
    else
      DRCTL_DELAY_REG <= 0;
  /**********/
  always@(posedge clk or posedge rst)
    if(rst) begin
      busy <= 0;
      PC <= 8'd0;
      MREST <= 0;
      auto_flip_en <= 0;
      DRHOLD <= 0;
    end
    else if(~busy) begin
      order <= rom_out;
      wr_start <= 0;
      order <= 
      busy <= 1;
      counter <= 0;
      PC <= PC+1;
    end
    else begin
		counter <= {counter[6:0],1'b1};
		if(order[6]) // 鑷畾涔夋搷浣			
			if(order[3]) begin
				{OSK,DRHOLD,con_drctl} <= order[2:0];
				busy <= 0;
			end
			else if(order[2]) begin
				auto_flip_en <= order[0];
				busy <= 0;
			end
			else if(order[1])
				if(counter == 8'd0)
					data <= 32'd0;
				else if(counter[7:2] == 7'd0) begin
				  data <= {data[23:0],rom_out};
				  PC <= PC+1;
				end
				else begin
				  data <= data + 32'hffff_ffff;     //data = data -1;
				  if(data == 32'd0) busy <= 0;
				end
			else if(order[0])
				if(counter == 8'd0)
					MREST <= 1;
				else begin
					MREST <= 0;
					busy <= 0;
				end
			else begin
				PC <= PC + 8'hff;  //PC = PC -1;
				busy <= 0;
			end
		else
			if(order[7])  
			/***  璇籇DS瀵勫瓨鍣 ***/
				if(counter == 8'd0)
					wr_start <= 1;
				else begin
					wr_start <= 0;
					if(wr_done) begin
						data <= wr_out;
						busy <= 0;
					end
				end
			/***  鍐橠DS瀵勫瓨鍣 ***/
			else if(counter[7:3] == 5'd0) begin
				data <= {data[23:0],rom_out};
				PC <= PC+1;
			end
			else if(counter[7:4] == 4'd0)
			  wr_start <= 1;
			else begin
			  wr_start <= 0;
			  if(wr_done) busy <= 0;
			end
	end
endmodule
    
  
  
