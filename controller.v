/* charset = utf-8 */
module controller(clk,rst,
				DROVER,DRCTL,DRHOLD,OSK,MREST,EPD,PS0,PS1,PS2,DREOR,	/* controller直接控制的外部信号 */
				wr_start,wr_addr,wr_din,wr_done,wr_dout,				/* wr_cmd模块的接口 */
				mem_dout,mem_din,mem_rclk,mem_wclk,mem_done);			/* 存储器(可以是fifo,ram,rom)的接口 */
	input clk,rst,DROVER,wr_done,mem_done;
	input[7:0] mem_dout;
	input[31:0] wr_dout;
	output DRCTL,DRHOLD,OSK,MREST,EPD,PS0,PS1,PS2,DREOR,wr_start,mem_rclk,mem_wclk;
	output[7:0] wr_addr,mem_din;
	output[31:0] wr_din;
	reg DRHOLD,DRCTL,OSK,MREST,EPD,PS0,PS1,PS2;
	reg mem_rclk = 0;  /** wr_start,mem_rclk,mem_wclk 空闲和初始情况下全部为0 **/
	reg mem_wclk = 0;
	reg wr_start = 0;
	reg DREOR = 0;
	/**内部寄存器**/
	reg[2:0] exec_cnt; // execute 状态下消耗的clk计数器
	reg[7:0] order;
	reg[31:0] data;
	assign wr_addr = order;
	assign wr_din = data;
	assign mem_din = data[31:24];
	reg[2:0] state = 0;
	reg[2:0] mem_cnt;  /** 每次读/写的字节数 **/

	parameter fetch = 3'b000;
	parameter execute = 3'b001;
	parameter wr_dds_regs = 3'b010;
	parameter read_mem = 3'b011;
	parameter write_mem = 3'b100;

	/** DRCTL **/
	reg state_drctl = 0;
	reg auto_flip_en = 0;
	reg set_drctl = 0;
	reg auto_flip_ini,auto_value;
	parameter DELAY_INI = 20;    //drctl自动翻转时保持的clk周期数 <<<<<-----修改这里
	reg[8:0] delay_cnt;
	always@(posedge clk)
	DRCTL <= auto_flip_en?auto_value:set_drctl;
	always@(posedge clk or negedge rst)
	if(~rst) begin
		DREOR <= 0;
		state_drctl <= 0;
	end
	else if(~state_drctl) 
		if(DROVER) begin
			state_drctl <= 1;
			delay_cnt <= DELAY_INI;
			auto_value <= ~auto_flip_ini;
		end
		else
			auto_value <= auto_flip_ini;
	else begin
		delay_cnt <= delay_cnt+8'd255;
		if(delay_cnt==8'd0) begin
			DREOR <= DROVER;
			state_drctl <= 0;
			auto_value <= auto_flip_ini;
		end
	end
	/** --END-- **/

	/** 主状态机 **/
	always@(posedge clk or negedge rst)
	if(~rst) begin
		state <= 0;
		mem_rclk <= 0;
		mem_wclk <= 0;
	end
	else case(state) 
		fetch : 
			if(mem_rclk && mem_done) begin
				order <= mem_dout;
				exec_cnt <= 0;
				wr_start <= 0;
				mem_rclk <= 0;
				mem_wclk <= 0;
				state <= execute;
			end
			else
				mem_rclk <= 1;
		execute: begin
			exec_cnt <= {exec_cnt[1:0],1'b1};
			if(order[6]) // 自定义FPGA操作
			
				if(order[4]) begin				/* order = x1x1_????  设置OSK,PS2,PS1,PS0 */
					{OSK,PS2,PS1,PS0} <= order[3:0];
					state <= fetch;
				end
				else if(order[3]) begin			/* order = x1x0_1???  设置DRCTL */
					{auto_flip_en,auto_flip_ini,set_drctl} <= order[2:0];
					state <= fetch;
				end
				else if(order[2]) begin			/* order = x1x0_01??  设置EPD,DRHOLD电平 */
					{EPD,DRHOLD} <= order[1:0];
					state <= fetch;
				end
				else if(order[1]) begin   		/* order = x1x0_001?  设置DDS复位电平 */
					MREST <= order[0];
					state <= fetch;
				end
				else if(order[0])				/* order = x1x0_0001  FPGA延时0-65536个clk */
					if(exec_cnt == 3'd0) begin
						data <= 32'd0;
						state <= read_mem;
						mem_cnt <= 3'd2;
					end
					else begin
					  data <= data + 32'hffff_ffff;     
					  if(data == 32'd0) state <= fetch;
					end
				else 						/* order = x1xx_0000  未定义操作,自动取下一个操作 */
					state <= fetch;
			else
				if(order[7])  
				/***  读DDS寄存器 ***/
					if(exec_cnt == 3'd0)
						wr_start <= 1;
					else if(exec_cnt == 3'd1) begin
						wr_start <= 0;
						state <= wr_dds_regs;
					end
					else if(exec_cnt == 3'd3) begin
						data <= wr_dout;
						state <= write_mem;
						mem_cnt <= 3'd4;
					end
					else
						state <= fetch;
				/***  写DDS寄存器 ***/
				else 
					if(exec_cnt == 3'd0) begin
						mem_cnt <= 3'd4;
						state <= read_mem;
					end
					else if(exec_cnt == 3'd1)
					  wr_start <= 1;
					else if(exec_cnt == 3'd2) begin
					  wr_start <= 0;
					  state <= wr_dds_regs;
					end
					else
						state <= fetch;
		end
		wr_dds_regs :
			if(wr_done)
				state <= execute;
		read_mem : 
			if(mem_cnt==3'd0) begin
				state <= execute;
				mem_rclk <= 0;
			end
			else if(mem_rclk && mem_done) begin
				mem_rclk <= 0;
				data <= {data[23:0],mem_dout};
				mem_cnt <= mem_cnt+3'd7;
			end
			else
				mem_rclk <= 1;
		write_mem :
			if(mem_cnt==3'd0) begin
				state <= execute;
				mem_wclk <= 0;
			end
			else if(mem_wclk && mem_done) begin
				mem_wclk <= 0;
				data <= {data[23:0],8'd0};
				mem_cnt <= mem_cnt+3'd7;
			end
			else
				mem_wclk <= 1;
	endcase
endmodule