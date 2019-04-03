module decay_shift_amount(
	input clock,
	input reset,
	input preset,
	input [3:0] decay_value, sustain_value,
	output [3:0] shift_amount,
	output done
);

	wire [31:0] count_up_to;
	decay_rom dr0 (clock, decay_value, sustain_value, count_up_to);
	
	wire enable;
	rate_divider rd0(clock, reset, count_up_to, enable);

	//15-sustain will be the amount we will shift up to
	wire [3:0] shift_up_to;
	
	assign shift_up_to = (4'd15 - sustain_value);
	
	shift_amount_increaser sai0(clock, reset, preset, enable, 4'd0, shift_up_to, shift_amount, done);
	
endmodule






	
