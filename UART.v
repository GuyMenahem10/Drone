module UART_Rx (
	input Clk,
	input rst,
	input RxEn,
	input Rx,
	input Tick,
	input [3:0]NBits,
	output RxDoneout,
	output [7:0]RxDataout
);
//Variabels used for state machine...
parameter  IDLE = 1'b0, READ = 1'b1; 	//We haev 2 states for the State Machine state 0 and 1 (READ adn IDLE)
reg  State, Next;			//Create some registers for the states
reg  read_enable = 1'b0;		//Variable that will enable or NOT the data in read
reg  start_bit = 1'b1;			//Variable used to notify when the start bit was detected (first falling edge of RX)
reg  RxDone = 1'b0;			//Variable used to notify when the data read process is done
reg [4:0]Bit = 5'b00000;		//Variable used for the bit by bit read loop (in this case 8 bits so 8 loops)
reg [3:0] counter = 4'b0000;		//Counter variable used to count the tick pulses up to 16
reg [7:0] Read_data= 8'b00000000;	//Register where we store the Rx input bits before assigning it to the RxData output
reg [7:0] RxData;			//We register the output as well so we store the value
//--------------------------------------------------------------------------------------------------------
always @ (posedge Clk)			//It is good to always have a reset always
begin
if (rst)	State <= IDLE;				//If reset pin is low, we get to the initial state which is IDLE
else 		State <= Next;				//If not we go to the next state
end
//--------------------------------------------------------------------------------------------------------
always @ (Rx or RxEn or RxDone)
begin
    case(State)	
	IDLE:	if(!Rx & RxEn)		Next = READ;	 //If Rx is low (Start bit detected) we start the read process
		else			Next = IDLE;
	READ:	if(RxDone)		Next = IDLE; 	 //If RxDone is high, than we get back to IDLE and wait for Rx input to go low (start bit detect)
		else			Next = READ;
	default 			Next = IDLE;
    endcase
end
//--------------------------------------------------------------------------------------------------------
always @ (State or RxDone)
begin
    case (State)
	READ: begin
		read_enable <= 1'b1;			//If we are in the Read state, we enable the read process so in the "Tick always" we start getting the bits
	      end
	
	IDLE: begin
		read_enable <= 1'b0;			//If we get back to IDLE, we desable the read process so the "Tick always" could continue without geting Rx bits
	      end
    endcase
end
//--------------------------------------------------------------------------------------------------------
always @ (posedge Tick)

	begin
	if (read_enable)
	begin
	RxDone <= 1'b0;							//Set the RxDone register to low since the process is still going
	counter <= counter+1;						//Increase the counter by 1 with each Tick detected
	

	if ((counter == 4'b1000) & (start_bit))				//Counter is 8? Then we set the start bit to 1. 
	begin
	start_bit <= 1'b0;
	counter <= 4'b0000;
	end

	if ((counter == 4'b1111) & (!start_bit) & (Bit < NBits))	//We make a loop (8 loops in this case) and we read all 8 bits
	begin
	Bit <= Bit+1;
	Read_data <= {Rx,Read_data[7:1]};
	counter <= 4'b0000;
	end
	
	if ((counter == 4'b1111) & (Bit == NBits)  & (Rx))		//Then we count to 16 once again and detect the stop bit (Rx input must be high)
	begin
	Bit <= 4'b0000;
	RxDone <= 1'b1;
	counter <= 4'b0000;
	start_bit <= 1'b1;						//We reset all values for next data input and set RxDone to high
	end
	end
	
	

end
//--------------------------------------------------------------------------------------------------------
always @ (posedge Clk)
begin

if (NBits == 4'b1000)
begin
RxData[7:0] <= Read_data[7:0];	
end

if (NBits == 4'b0111)
begin
RxData[7:0] <= {1'b0,Read_data[7:1]};	
end

if (NBits == 4'b0110)
begin
RxData[7:0] <= {1'b0,1'b0,Read_data[7:2]};	
end
end

//--------------------------------------------------------------------------------------------------------
assign RxDataout = RxData;
assign RxDoneout = RxDone;
endmodule