/* charset = ascii */
module  half_int_div(clock,rst,clk_out);
	input rst;
	input	clock;					//����ʱ��
	output	clk_out;				//���ʱ��
	parameter F_DIV = 326;			//��Ƶϵ��<<<<-----�����������޸�����
	parameter HALF  = 1;         //��Ƶϵ��(������)
	parameter F_DIV_WIDTH = 16; 	//��Ƶ���������

	//�ڲ��Ĵ���
	reg	clk_out = 0;					
	reg[F_DIV_WIDTH - 1:0] count_p = 0;
	reg flag;				
	wire clk_in;					//�������ڲ�ʱ��
	wire full_div_p;				//�����ؼ�������־
	wire half_div_p;				//�����ؼ���������־

	//�жϼ�����־λ��λ���
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
