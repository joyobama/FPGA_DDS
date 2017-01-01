
/*   串口波特率设置
 *无论哪种情况串口工作的时钟频率应设置为波特率的16倍(最大可靠通信误差2%),串口模块分频器的分频比为 (BAUD_DIV - BAUD_DIV_HALF*0.5) : 1 
 *                    对于50M的晶振,不同波特率的分频比设置如下:
 *                波特率      BAUD_DIV     BAUD_DIV_HALF     误差
 *                 9600         326              1          0.0064%
 *                14400         217              0          0.0064%
 *                19200         163              1          0.16%
 *                56000          56              0          0.35%
 *                57600          54              0          0.47%
 *                115200         27              0          0.47%
 *                128000         25              1          0.35% (默认)
 *                256000         12              0          1.73% 
**/
`define BAUD_DIV 25
`define BAUD_DIV_HALF 1


/*   SPI总线时钟速率
 * SPI时钟总线时钟速率 f_sclk = f_sys/2^SPI_CLK_DIV
 **/
`define SPI_CLK_DIV 3


/*   DRCTL引脚脉冲宽度
 * 在自动翻转状态下(auto_filp_en = 1),
 * 每个DROVER高电平跳变,会触发DRCTL引脚上产生一个宽度为 DRCTL_HOLD_CLK*f_sclk 的脉冲
 * 脉冲方向由 set_drctl决定
 **/
`define DRCTL_PULSE_WIDTH 20