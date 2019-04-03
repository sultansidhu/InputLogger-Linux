module adsr_modification(amplitude, shift_amount, modified_out);
	input [15:0] amplitude;
	input [3:0] shift_amount;
	output [15:0] modified_out;
	
	assign modified_out = amplitude >>> shift_amount;

endmodule


