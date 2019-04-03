module release_shift_amount(
	input clock,
	input reset,
	input preset_release,
	input [3:0] release_value, sustain_value,
	output [3:0] shift_amount,
	output done
);

	wire [31:0] count_up_to;
	release_rom rr0 (clock, release_value, sustain_value, count_up_to);
	
	wire enable;
	rate_divider_frequency rd1(clock, reset, count_up_to, enable);

	wire [3:0] shift_from;
	
	assign shift_from = (4'd15 - sustain_value);
	
	shift_amount_increaser sai1(clock, reset, preset_release, enable, shift_from, 4'd15, shift_amount, done);
	
endmodule
