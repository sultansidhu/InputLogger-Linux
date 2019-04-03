module rate_divider_frequency(clock, reset, count_up_to, out);
	input clock;
	input reset;
	input [31:0] count_up_to;
	output reg out; // added reg
	
	reg [31:0] rate_divider;
	
	always @ (posedge clock)
	begin
		if (reset)begin
			rate_divider <= 0;
			out <= 0; // new
			end
		else if(rate_divider >= count_up_to)begin
			rate_divider <= 0;
			out <= 1; // new
			end
		else begin
			rate_divider <= rate_divider + 1;
			out <= 0; // new
		end
	end


endmodule