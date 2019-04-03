module Keyboard_LUT(
  input clock,
  input resetn,
  input [11:0] keyboard_out,
  output reg [31:0] out
  );
  always @(posedge clock) begin
	 if (resetn)begin
		out <= 32'd0;
	 end
	 else begin
    case(keyboard_out)
      12'b100000000000: out <= 32'd2959;
      12'b010000000000: out <= 32'd2830;
      12'b001000000000: out <= 32'd2675;
      12'b000100000000: out <= 32'd2536;
      12'b000010000000: out <= 32'd2381;
      12'b000001000000: out <= 32'd2244;
      12'b000000100000: out <= 32'd2122;
      12'b000000010000: out <= 32'd1992;
      12'b000000001000: out <= 32'd1878;
      12'b000000000100: out <= 32'd1775;
      12'b000000000010: out <= 32'd1669;
      12'b000000000001: out <= 32'd1587;
		default: out <= out;
    endcase
	 end
  end
endmodule
