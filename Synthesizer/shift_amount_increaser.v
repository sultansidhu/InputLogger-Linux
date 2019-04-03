module shift_amount_increaser(clock, reset, preset, enable, shift_from, shift_up_to, shift_amount, shift_done);
	input clock;
	input reset;
	input preset;
	input enable;
	// shift_from is a lower value than shift_up_to -- we wanna end up with 
	// a higher shift = a lower volume
	input [3:0] shift_from, shift_up_to;
	output reg [3:0]shift_amount;
	output reg shift_done;

	always @ (posedge clock) begin
		if (preset)begin
			shift_done <= 1;
			shift_amount <= 0;
		end
		else if (reset)begin
			shift_done <= 0;
			shift_amount <= shift_from;
			end
		else if(enable)begin
			shift_done <= shift_done;
			shift_amount <= shift_amount + 1;
			end
		else if (shift_amount == shift_up_to) begin
			shift_done <= 1;
			shift_amount <= shift_from;
			end
		end
endmodule