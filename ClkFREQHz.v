module ClkFREQHz (
	input clk,
	input rst,
	input [31:0]Dfreq,
	input [31:0]FREQ,
	input [31:0]PLUS,
	input [31:0]dutycycle,
	output reg clk_out
);
//localparam [31:0]MAIN_CLK = 50_000_000;
reg [31:0]counter = 31'b0;


always @(posedge clk or posedge rst) begin
	if (rst == 1'b1)begin
		counter <= 0;
		clk_out <= 0;
	end else begin	
		counter <= counter + 1;
		if (counter == 0) begin
			clk_out <= 1;
		end
		
		if (counter ==  50_000_000*dutycycle/100/FREQ + Dfreq + PLUS) begin
			clk_out <= 0;
		end
		
		if (counter == 50_000_000/FREQ ) begin
			counter <= 0;
		end
	end
end 

endmodule