/* charset = ascii */
module  half_int_div(clock,rst,clk_out);
	input rst;
	input	clock;					//输入时钟
	output	clk_out;				//输出时钟
	parameter F_DIV = 326;			//分频系数<<<<-----调整波特率修改这里
	parameter HALF  = 1;         //分频系数(半整数)
	parameter F_DIV_WIDTH = 16; 	//分频计数器宽度

	//内部寄存器
	reg	clk_out = 0;					
	reg[F_DIV_WIDTH - 1:0] count_p = 0;
	reg flag;				
	wire clk_in;					//处理后的内部时钟
	wire full_div_p;				//上升沿计数满标志
	wire half_div_p;				//上升沿计数半满标志

	//判断计数标志位置位与否
	assign full_div_p = (count_p < F_DIV - 1);
	assign half_div_p = (count_p < (F_DIV>>1) - 1);
	assign clk_in = flag^clock;
	always @(negedge clk_out or negedge rst)
		if(~rst) 
			flag <= 0;
		else if(HALF) 
			flag <= ~flag;
			
	always @(posedge clk_in)
		if(~rst || ~full_div_p) begin
			count_p <= 0;
			clk_out <= 0;
		end
		else begin
			count_p <= count_p + 1'b1;
			if(half_div_p)
				clk_out <= 1'b0;
			else
				clk_out <= 1'b1;
		end
endmodule
