module phase_counter(clock, reset, offset, phase_counter_out);
	input clock;
	input reset;
	input [3:0]offset;
	output reg [7:0] phase_counter_out;
	
	always @ (posedge clock) begin
		if (reset) begin
			phase_counter_out <= 0;
			end
		else begin
			phase_counter_out <= phase_counter_out + offset;
		end
		end

endmodule

