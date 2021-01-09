module TOP(
	input clk,
	input rst,
	input KEY0,
	input Rx,
	inout sda,
	output scl,
	output motorout1,
	output motorout2,	
	output motorout3,
	output motorout4,
	output [7:0]RxDataout,
	output RxDoneout
);

wire motor1,motor2,motor3,motor4;
wire Tick,RxDone,dfreqclk;
wire RxEn = 1'b1;
wire [7:0]RxData;
wire [15:0]ACC_X;
wire [15:0]ACC_Y;
wire [15:0]ACC_Z;
wire [15:0]GYRO_X;
wire [15:0]GYRO_Y;
wire [15:0]GYRO_Z;
wire init_done;

reg rst_motor = 1'b1;
reg [7:0]RxDataB;
reg [31:0]Dfreq;
reg [31:0]PLUS = 0;
reg [31:0]dutycycle = 0;

mpu6050 GYRO(
	.clk(clk), 
    .scl(scl),  
    .sda(sda),  
    .rst_n(~rst),  
	 .ACC_X(ACC_X),
	 .ACC_Y(ACC_Y),
	 .ACC_Z(ACC_Z),
	 .GYRO_X(GYRO_X),
	 .GYRO_Y(GYRO_Y),
	 .GYRO_Z(GYRO_Z),
	 .init_done(init_done)
);

always @(posedge RxDone) begin	
		RxDataB <= RxData[7:0];
end	

always @ (RxDataB,rst,rst_motor)
begin 
	if (RxDataB == 1 && rst == 1'b0)
		rst_motor = 1'b0;
		Dfreq <= 0;
end

always @ (posedge dfreqclk)
begin 
	if (RxDataB == 2 && rst == 1'b0 && Dfreq < 49925)
		Dfreq = Dfreq + 75;
end

always @ (posedge dfreqclk)
begin 
	if (RxDataB == 3 && rst == 1'b0 && Dfreq > 75)
		Dfreq = Dfreq - 75;
end

assign RxDataout = RxDataB;
assign RxDoneout = RxDone;

ClkFREQHz  Rxclk(
	.clk(clk),
	.rst(rst),
	.PLUS(0),
	.Dfreq(0),
	.FREQ(153601), //in Hz
	.dutycycle(50),//between 1 to 100
	.clk_out(Tick)
);

ClkFREQHz  Dfreqclk(
	.clk(clk),
	.rst(rst),
	.PLUS(0),
	.Dfreq(0),
	.FREQ(50), //in Hz
	.dutycycle(50),//between 1 to 100
	.clk_out(dfreqclk)
);

UART_Rx Rxee(
    	.Clk(clk),
		.rst(rst),
    	.RxEn(RxEn),
    	.RxDataout(RxData),
    	.RxDoneout(RxDone),
    	.Rx(Rx),
    	.Tick(Tick),
    	.NBits(4'b1000)
    );

ClkFREQHz  Motor1(
	.clk(clk),
	.rst(rst_motor),
	.PLUS(0),
	.Dfreq(Dfreq),
	.FREQ(50), //in Hz
	.dutycycle(5),//between 1 to 100
	.clk_out(motorout1)
);
ClkFREQHz  Motor2(
	.clk(clk),
	.rst(rst_motor),
	.PLUS(0),
	.Dfreq(Dfreq),
	.FREQ(50), //in Hz
	.dutycycle(5),//between 1 to 100
	.clk_out(motorout2)
);
ClkFREQHz  Motor3(
	.clk(clk),
	.rst(rst_motor),
	.PLUS(0),
	.Dfreq(Dfreq),
	.FREQ(50), //in Hz
	.dutycycle(5),//between 1 to 100
	.clk_out(motorout3)
);
ClkFREQHz  Motor4(
	.clk(clk),
	.rst(rst_motor),
	.PLUS(0),
	.Dfreq(Dfreq),
	.FREQ(50), //in Hz
	.dutycycle(5),//between 1 to 100
	.clk_out(motorout4)
);
endmodule