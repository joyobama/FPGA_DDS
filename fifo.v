module fifo(clk,read_clk,write_clk,din,read_done,write_done,dout);
	input clk,read_clk,write_clk;
	input[7:0] din;
	output read_done,write_done;
	output[7:0] dout;
	reg read_done = 1;
	reg write_done = 1;
	
	/** 内部寄存器 **/
	(*KEEP="TRUE"*)reg[6:0] write_addr = 7'd0 		/* synthesis preserve */;
	(*KEEP="TRUE"*)reg[6:0] read_addr = 7'd0  		/* synthesis preserve */;
	(*KEEP="TRUE"*)reg[7:0] read_data,write_data 	/* synthesis preserve */;
	(*KEEP="TRUE"*)reg[7:0] ram[0:127] 				/* synthesis preserve */;
	(*KEEP="TRUE"*)wire     fifo_empty,fifo_full 	/* synthesis keep */;
	(*KEEP="TRUE"*)reg      read_flag = 0 			/* synthesis preserve */;
	(*KEEP="TRUE"*)reg      write_flag = 0 			/* synthesis preserve */;
	(*KEEP="TRUE"*)reg 		write_state = 0			/* synthesis preserve */;
	(*KEEP="TRUE"*)reg      read_state = 0			/* synthesis preserve */;
	(*KEEP="TRUE"*)reg      rst_write_flag = 0		/* synthesis preserve */;
	(*KEEP="TRUE"*)reg      rst_read_flag = 0		/* synthesis preserve */;
	
	wire [6:0] tmp;   // tmp = write_addr+1
	assign tmp = write_addr + 7'd1;
	assign fifo_empty = read_addr==write_addr;
	assign fifo_full = tmp==read_addr;
	assign dout = read_data;
	
	// read
	always@(posedge read_clk or posedge rst_read_flag)
		if(rst_read_flag)
			read_flag <= 0;
		else
			read_flag <= 1;

	always@(negedge clk)
		if(~read_state) begin
			read_state <= read_flag;
			read_done <= ~read_flag;
			rst_read_flag <= 0;
		end
		else 
			if(~fifo_empty) begin
				read_data <= ram[read_addr];
				read_addr <= read_addr+1; // notice !!
				read_state <= 0;
				rst_read_flag <= 1;
			end
			
	// write			
	always@(posedge write_clk or posedge rst_write_flag)
		if(rst_write_flag)
			write_flag <= 0;
		else begin
			write_flag <= 1;
			write_data <= din;
		end
	always@(negedge clk)
		if(~write_state) begin
			write_state <= write_flag;
			write_done <= ~write_flag;
			rst_write_flag <= 0;
		end
		else
			if(~fifo_full) begin
				ram[write_addr] <= write_data;
				write_addr <= write_addr+1; // notice !!
				write_state <= 0;
				rst_write_flag <= 1;
			end
endmodule
			
			
	
	
	