module attack_shift_amount(
	input clock,
	input reset,
	input [3:0] attack_value,
	output [3:0] shift_amount,
	output done
);

	wire [31:0] count_up_to;
	attack_rom ar0(clock, attack_value, count_up_to);
	
	wire enable;
	rate_divider rd0(clock, reset, count_up_to, enable);
	
	shift_amount_reducer sar0(clock, reset, enable, shift_amount, done);

endmodule
	
module shift_amount_reducer(clock, reset, enable, shift_amount, shift_done);
	input clock;
	input reset;
	input enable;
	output reg [3:0]shift_amount;
	output reg shift_done;

	always @ (posedge clock) begin
		if (reset)begin
			shift_done <= 0;
			shift_amount <= 4'd15;
			end
		else if(enable)begin
			shift_done <= shift_done;
			shift_amount <= shift_amount - 1;
			end
		else if (shift_amount == 4'd0) begin
			shift_done <= 1;
			shift_amount <= 4'd15;
			end
		end

endmodule
