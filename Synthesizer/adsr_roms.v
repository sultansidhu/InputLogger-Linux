//////////////////////////////////////////////////
////////////	Attack ROM Table	//////////////
//////////////////////////////////////////////////
module attack_rom (clock, attack, count_up_to);
input clock;
input [3:0] attack;
output reg [31:0] count_up_to;
always@(posedge clock)
begin
	case(attack)
    		4'd0: count_up_to = 32'd5;
			4'd1: count_up_to = 32'd833333;
			4'd2: count_up_to = 32'd1666666;
			4'd3: count_up_to = 32'd2500000;
			4'd4: count_up_to = 32'd3333333;
			4'd5: count_up_to = 32'd4166666;
			4'd6: count_up_to = 32'd5000000;
			4'd7: count_up_to = 32'd5833333;
			4'd8: count_up_to = 32'd6666666;
			4'd9: count_up_to = 32'd7500000;
			4'd10: count_up_to = 32'd8333333;
			4'd11: count_up_to = 32'd9166666;
			4'd12: count_up_to = 32'd10000000;
			4'd13: count_up_to = 32'd10833333;
			4'd14: count_up_to = 32'd11666666;
			4'd15: count_up_to = 32'd12500000;
	endcase
end
endmodule

//////////////////////////////////////////////////
////////////	Decay / Sustain ROM Table	//////////////
//////////////////////////////////////////////////
module decay_rom (clock, decay, sustain, count_up_to);
input clock;
input [3:0] decay, sustain;
output reg [31:0] count_up_to;
wire [3:0] shifting_distance;

assign shifting_distance = (4'd15 - sustain);

wire [31:0] out_0, out_1, out_2, out_3, out_4, out_5, out_6, out_7, 
out_8, out_9, out_10, out_11, out_12, out_13, out_14, out_15; 

distance0_rom  dr0(decay, out_0);
distance1_rom  dr1(decay, out_1);
distance2_rom  dr2(decay, out_2);
distance3_rom  dr3(decay, out_3);
distance4_rom  dr4(decay, out_4);
distance5_rom  dr5(clock, decay, out_5);
distance6_rom  dr6(decay, out_6);
distance7_rom  dr7(decay, out_7);
distance8_rom  dr8(decay, out_8);
distance9_rom  dr9(decay, out_9);
distance10_rom dr10(decay, out_10);
distance11_rom dr11(decay, out_11);
distance12_rom dr12(decay, out_12);
distance13_rom dr13(decay, out_13);
distance14_rom dr14(decay, out_14);
distance15_rom dr15(decay, out_15);


always@(posedge clock)begin
case(shifting_distance)
    		4'd0: count_up_to = out_0;
			4'd1: count_up_to = out_1;
			4'd2: count_up_to = out_2;
			4'd3: count_up_to = out_3;
			4'd4: count_up_to = out_4;
			4'd5: count_up_to = out_5;
			4'd6: count_up_to = out_6;
			4'd7: count_up_to = out_7;
			4'd8: count_up_to = out_8;
			4'd9: count_up_to = out_9;
			4'd10: count_up_to = out_10;
			4'd11: count_up_to = out_11;
			4'd12: count_up_to = out_12;
			4'd13: count_up_to = out_13;
			4'd14: count_up_to = out_14;
			4'd15: count_up_to = out_15;
	endcase
end
endmodule

//////////////////////////////////////////////////
////////////	Release / Sustain ROM Table	//////////////
//////////////////////////////////////////////////
module release_rom (clock, myrelease, sustain, count_up_to);
input clock;
input [3:0] myrelease, sustain;
output reg [31:0] count_up_to;
wire [3:0] shifting_distance;

assign shifting_distance = sustain;

wire [31:0] out_0, out_1, out_2, out_3, out_4, out_5, out_6, out_7, 
out_8, out_9, out_10, out_11, out_12, out_13, out_14, out_15; 

distance0_rom  dr0(myrelease, out_0);
distance1_rom  dr1(myrelease, out_1);
distance2_rom  dr2(myrelease, out_2);
distance3_rom  dr3(myrelease, out_3);
distance4_rom  dr4(myrelease, out_4);
distance5_rom  dr5(myrelease, out_5);
distance6_rom  dr6(myrelease, out_6);
distance7_rom  dr7(myrelease, out_7);
distance8_rom  dr8(myrelease, out_8);
distance9_rom  dr9(myrelease, out_9);
distance10_rom dr10(myrelease, out_10);
distance11_rom dr11(myrelease, out_11);
distance12_rom dr12(myrelease, out_12);
distance13_rom dr13(myrelease, out_13);
distance14_rom dr14(myrelease, out_14);
distance15_rom dr15(myrelease, out_15);


always@(posedge clock)begin
case(shifting_distance)
    		4'd0: count_up_to = out_0;
			4'd1: count_up_to = out_1;
			4'd2: count_up_to = out_2;
			4'd3: count_up_to = out_3;
			4'd4: count_up_to = out_4;
			4'd5: count_up_to = out_5;
			4'd6: count_up_to = out_6;
			4'd7: count_up_to = out_7;
			4'd8: count_up_to = out_8;
			4'd9: count_up_to = out_9;
			4'd10: count_up_to = out_10;
			4'd11: count_up_to = out_11;
			4'd12: count_up_to = out_12;
			4'd13: count_up_to = out_13;
			4'd14: count_up_to = out_14;
			4'd15: count_up_to = out_15;
	endcase
end
endmodule


//////////////////////////////////////////////////
////////////	Distance ROM Tables	//////////////
//////////////////////////////////////////////////

module distance0_rom (decay_or_release, count_up_to);
    input [3:0] decay_or_release;
    output reg [31:0] count_up_to;
    always @ (*)
        case(decay_or_release)
        4'd0: count_up_to = 32'd5;
        4'd1: count_up_to = 32'd5;
        4'd2: count_up_to = 32'd5;
        4'd3: count_up_to = 32'd5;
        4'd4: count_up_to = 32'd5;
        4'd5: count_up_to = 32'd5;
        4'd6: count_up_to = 32'd5;
        4'd7: count_up_to = 32'd5;
        4'd8: count_up_to = 32'd5;
        4'd9: count_up_to = 32'd5;
        4'd10: count_up_to = 32'd5;
        4'd11: count_up_to = 32'd5;
        4'd12: count_up_to = 32'd5;
        4'd13: count_up_to = 32'd5;
        4'd14: count_up_to = 32'd5;
        4'd15: count_up_to = 32'd5;
        endcase
endmodule


module distance1_rom (decay_or_release, count_up_to);
    input [3:0] decay_or_release;
    output reg [31:0] count_up_to;
    always @ (*)
        case(decay_or_release)
        4'd0: count_up_to = 32'd5;
        4'd1: count_up_to = 32'd12500000;
        4'd2: count_up_to = 32'd25000000;
        4'd3: count_up_to = 32'd37500000;
        4'd4: count_up_to = 32'd50000000;
        4'd5: count_up_to = 32'd62500000;
        4'd6: count_up_to = 32'd75000000;
        4'd7: count_up_to = 32'd87500000;
        4'd8: count_up_to = 32'd100000000;
        4'd9: count_up_to = 32'd112500000;
        4'd10: count_up_to = 32'd125000000;
        4'd11: count_up_to = 32'd137500000;
        4'd12: count_up_to = 32'd150000000;
        4'd13: count_up_to = 32'd162500000;
        4'd14: count_up_to = 32'd175000000;
        4'd15: count_up_to = 32'd187500000;
        endcase
endmodule


module distance2_rom (decay_or_release, count_up_to);
    input [3:0] decay_or_release;
    output reg [31:0] count_up_to;
    always @ (*)
        case(decay_or_release)
        4'd0: count_up_to = 32'd5;
        4'd1: count_up_to = 32'd6250000;
        4'd2: count_up_to = 32'd12500000;
        4'd3: count_up_to = 32'd18750000;
        4'd4: count_up_to = 32'd25000000;
        4'd5: count_up_to = 32'd31250000;
        4'd6: count_up_to = 32'd37500000;
        4'd7: count_up_to = 32'd43750000;
        4'd8: count_up_to = 32'd50000000;
        4'd9: count_up_to = 32'd56250000;
        4'd10: count_up_to = 32'd62500000;
        4'd11: count_up_to = 32'd68750000;
        4'd12: count_up_to = 32'd75000000;
        4'd13: count_up_to = 32'd81250000;
        4'd14: count_up_to = 32'd87500000;
        4'd15: count_up_to = 32'd93750000;
        endcase
endmodule


module distance3_rom (decay_or_release, count_up_to);
    input [3:0] decay_or_release;
    output reg [31:0] count_up_to;
    always @ (*)
        case(decay_or_release)
        4'd0: count_up_to = 32'd5;
        4'd1: count_up_to = 32'd4166666;
        4'd2: count_up_to = 32'd8333333;
        4'd3: count_up_to = 32'd12500000;
        4'd4: count_up_to = 32'd16666666;
        4'd5: count_up_to = 32'd20833333;
        4'd6: count_up_to = 32'd25000000;
        4'd7: count_up_to = 32'd29166666;
        4'd8: count_up_to = 32'd33333333;
        4'd9: count_up_to = 32'd37500000;
        4'd10: count_up_to = 32'd41666666;
        4'd11: count_up_to = 32'd45833333;
        4'd12: count_up_to = 32'd50000000;
        4'd13: count_up_to = 32'd54166666;
        4'd14: count_up_to = 32'd58333333;
        4'd15: count_up_to = 32'd62500000;
        endcase
endmodule


module distance4_rom (decay_or_release, count_up_to);
    input [3:0] decay_or_release;
    output reg [31:0] count_up_to;
    always @ (*)
        case(decay_or_release)
        4'd0: count_up_to = 32'd5;
        4'd1: count_up_to = 32'd3125000;
        4'd2: count_up_to = 32'd6250000;
        4'd3: count_up_to = 32'd9375000;
        4'd4: count_up_to = 32'd12500000;
        4'd5: count_up_to = 32'd15625000;
        4'd6: count_up_to = 32'd18750000;
        4'd7: count_up_to = 32'd21875000;
        4'd8: count_up_to = 32'd25000000;
        4'd9: count_up_to = 32'd28125000;
        4'd10: count_up_to = 32'd31250000;
        4'd11: count_up_to = 32'd34375000;
        4'd12: count_up_to = 32'd37500000;
        4'd13: count_up_to = 32'd40625000;
        4'd14: count_up_to = 32'd43750000;
        4'd15: count_up_to = 32'd46875000;
        endcase
endmodule


module distance5_rom (clock, decay_or_release, count_up_to);
	 input clock;
    input [3:0] decay_or_release;
    output reg [31:0] count_up_to;
    always @ (posedge clock)
        case(decay_or_release)
        4'd0: count_up_to <= 32'd5;
        4'd1: count_up_to <= 32'd2500000;
        4'd2: count_up_to <= 32'd5000000;
        4'd3: count_up_to <= 32'd7500000;
        4'd4: count_up_to <= 32'd10000000;
        4'd5: count_up_to <= 32'd12500000;
        4'd6: count_up_to <= 32'd15000000;
        4'd7: count_up_to <= 32'd17500000;
        4'd8: count_up_to <= 32'd20000000;
        4'd9: count_up_to <= 32'd22500000;
        4'd10: count_up_to <= 32'd25000000;
        4'd11: count_up_to <= 32'd27500000;
        4'd12: count_up_to <= 32'd30000000;
        4'd13: count_up_to <= 32'd32500000;
        4'd14: count_up_to <= 32'd35000000;
        4'd15: count_up_to <= 32'd37500000;
        endcase
endmodule


module distance6_rom (decay_or_release, count_up_to);
    input [3:0] decay_or_release;
    output reg [31:0] count_up_to;
    always @ (*)
        case(decay_or_release)
        4'd0: count_up_to = 32'd5;
        4'd1: count_up_to = 32'd2083333;
        4'd2: count_up_to = 32'd4166666;
        4'd3: count_up_to = 32'd6250000;
        4'd4: count_up_to = 32'd8333333;
        4'd5: count_up_to = 32'd10416666;
        4'd6: count_up_to = 32'd12500000;
        4'd7: count_up_to = 32'd14583333;
        4'd8: count_up_to = 32'd16666666;
        4'd9: count_up_to = 32'd18750000;
        4'd10: count_up_to = 32'd20833333;
        4'd11: count_up_to = 32'd22916666;
        4'd12: count_up_to = 32'd25000000;
        4'd13: count_up_to = 32'd27083333;
        4'd14: count_up_to = 32'd29166666;
        4'd15: count_up_to = 32'd31250000;
        endcase
endmodule


module distance7_rom (decay_or_release, count_up_to);
    input [3:0] decay_or_release;
    output reg [31:0] count_up_to;
    always @ (*)
        case(decay_or_release)
        4'd0: count_up_to = 32'd5;
        4'd1: count_up_to = 32'd1785714;
        4'd2: count_up_to = 32'd3571428;
        4'd3: count_up_to = 32'd5357142;
        4'd4: count_up_to = 32'd7142857;
        4'd5: count_up_to = 32'd8928571;
        4'd6: count_up_to = 32'd10714285;
        4'd7: count_up_to = 32'd12500000;
        4'd8: count_up_to = 32'd14285714;
        4'd9: count_up_to = 32'd16071428;
        4'd10: count_up_to = 32'd17857142;
        4'd11: count_up_to = 32'd19642857;
        4'd12: count_up_to = 32'd21428571;
        4'd13: count_up_to = 32'd23214285;
        4'd14: count_up_to = 32'd25000000;
        4'd15: count_up_to = 32'd26785714;
        endcase
endmodule


module distance8_rom (decay_or_release, count_up_to);
    input [3:0] decay_or_release;
    output reg [31:0] count_up_to;
    always @ (*)
        case(decay_or_release)
        4'd0: count_up_to = 32'd5;
        4'd1: count_up_to = 32'd1562500;
        4'd2: count_up_to = 32'd3125000;
        4'd3: count_up_to = 32'd4687500;
        4'd4: count_up_to = 32'd6250000;
        4'd5: count_up_to = 32'd7812500;
        4'd6: count_up_to = 32'd9375000;
        4'd7: count_up_to = 32'd10937500;
        4'd8: count_up_to = 32'd12500000;
        4'd9: count_up_to = 32'd14062500;
        4'd10: count_up_to = 32'd15625000;
        4'd11: count_up_to = 32'd17187500;
        4'd12: count_up_to = 32'd18750000;
        4'd13: count_up_to = 32'd20312500;
        4'd14: count_up_to = 32'd21875000;
        4'd15: count_up_to = 32'd23437500;
        endcase
endmodule


module distance9_rom (decay_or_release, count_up_to);
    input [3:0] decay_or_release;
    output reg [31:0] count_up_to;
    always @ (*)
        case(decay_or_release)
        4'd0: count_up_to = 32'd5;
        4'd1: count_up_to = 32'd1388888;
        4'd2: count_up_to = 32'd2777777;
        4'd3: count_up_to = 32'd4166666;
        4'd4: count_up_to = 32'd5555555;
        4'd5: count_up_to = 32'd6944444;
        4'd6: count_up_to = 32'd8333333;
        4'd7: count_up_to = 32'd9722222;
        4'd8: count_up_to = 32'd11111111;
        4'd9: count_up_to = 32'd12500000;
        4'd10: count_up_to = 32'd13888888;
        4'd11: count_up_to = 32'd15277777;
        4'd12: count_up_to = 32'd16666666;
        4'd13: count_up_to = 32'd18055555;
        4'd14: count_up_to = 32'd19444444;
        4'd15: count_up_to = 32'd20833333;
        endcase
endmodule


module distance10_rom (decay_or_release, count_up_to);
    input [3:0] decay_or_release;
    output reg [31:0] count_up_to;
    always @ (*)
        case(decay_or_release)
        4'd0: count_up_to = 32'd5;
        4'd1: count_up_to = 32'd1250000;
        4'd2: count_up_to = 32'd2500000;
        4'd3: count_up_to = 32'd3750000;
        4'd4: count_up_to = 32'd5000000;
        4'd5: count_up_to = 32'd6250000;
        4'd6: count_up_to = 32'd7500000;
        4'd7: count_up_to = 32'd8750000;
        4'd8: count_up_to = 32'd10000000;
        4'd9: count_up_to = 32'd11250000;
        4'd10: count_up_to = 32'd12500000;
        4'd11: count_up_to = 32'd13750000;
        4'd12: count_up_to = 32'd15000000;
        4'd13: count_up_to = 32'd16250000;
        4'd14: count_up_to = 32'd17500000;
        4'd15: count_up_to = 32'd18750000;
        endcase
endmodule


module distance11_rom (decay_or_release, count_up_to);
    input [3:0] decay_or_release;
    output reg [31:0] count_up_to;
    always @ (*)
        case(decay_or_release)
        4'd0: count_up_to = 32'd5;
        4'd1: count_up_to = 32'd1136363;
        4'd2: count_up_to = 32'd2272727;
        4'd3: count_up_to = 32'd3409090;
        4'd4: count_up_to = 32'd4545454;
        4'd5: count_up_to = 32'd5681818;
        4'd6: count_up_to = 32'd6818181;
        4'd7: count_up_to = 32'd7954545;
        4'd8: count_up_to = 32'd9090909;
        4'd9: count_up_to = 32'd10227272;
        4'd10: count_up_to = 32'd11363636;
        4'd11: count_up_to = 32'd12500000;
        4'd12: count_up_to = 32'd13636363;
        4'd13: count_up_to = 32'd14772727;
        4'd14: count_up_to = 32'd15909090;
        4'd15: count_up_to = 32'd17045454;
        endcase
endmodule


module distance12_rom (decay_or_release, count_up_to);
    input [3:0] decay_or_release;
    output reg [31:0] count_up_to;
    always @ (*)
        case(decay_or_release)
        4'd0: count_up_to = 32'd5;
        4'd1: count_up_to = 32'd1041666;
        4'd2: count_up_to = 32'd2083333;
        4'd3: count_up_to = 32'd3125000;
        4'd4: count_up_to = 32'd4166666;
        4'd5: count_up_to = 32'd5208333;
        4'd6: count_up_to = 32'd6250000;
        4'd7: count_up_to = 32'd7291666;
        4'd8: count_up_to = 32'd8333333;
        4'd9: count_up_to = 32'd9375000;
        4'd10: count_up_to = 32'd10416666;
        4'd11: count_up_to = 32'd11458333;
        4'd12: count_up_to = 32'd12500000;
        4'd13: count_up_to = 32'd13541666;
        4'd14: count_up_to = 32'd14583333;
        4'd15: count_up_to = 32'd15625000;
        endcase
endmodule


module distance13_rom (decay_or_release, count_up_to);
    input [3:0] decay_or_release;
    output reg [31:0] count_up_to;
    always @ (*)
        case(decay_or_release)
        4'd0: count_up_to = 32'd5;
        4'd1: count_up_to = 32'd961538;
        4'd2: count_up_to = 32'd1923076;
        4'd3: count_up_to = 32'd2884615;
        4'd4: count_up_to = 32'd3846153;
        4'd5: count_up_to = 32'd4807692;
        4'd6: count_up_to = 32'd5769230;
        4'd7: count_up_to = 32'd6730769;
        4'd8: count_up_to = 32'd7692307;
        4'd9: count_up_to = 32'd8653846;
        4'd10: count_up_to = 32'd9615384;
        4'd11: count_up_to = 32'd10576923;
        4'd12: count_up_to = 32'd11538461;
        4'd13: count_up_to = 32'd12500000;
        4'd14: count_up_to = 32'd13461538;
        4'd15: count_up_to = 32'd14423076;
        endcase
endmodule


module distance14_rom (decay_or_release, count_up_to);
    input [3:0] decay_or_release;
    output reg [31:0] count_up_to;
    always @ (*)
        case(decay_or_release)
        4'd0: count_up_to = 32'd5;
        4'd1: count_up_to = 32'd892857;
        4'd2: count_up_to = 32'd1785714;
        4'd3: count_up_to = 32'd2678571;
        4'd4: count_up_to = 32'd3571428;
        4'd5: count_up_to = 32'd4464285;
        4'd6: count_up_to = 32'd5357142;
        4'd7: count_up_to = 32'd6250000;
        4'd8: count_up_to = 32'd7142857;
        4'd9: count_up_to = 32'd8035714;
        4'd10: count_up_to = 32'd8928571;
        4'd11: count_up_to = 32'd9821428;
        4'd12: count_up_to = 32'd10714285;
        4'd13: count_up_to = 32'd11607142;
        4'd14: count_up_to = 32'd12500000;
        4'd15: count_up_to = 32'd13392857;
        endcase
endmodule


module distance15_rom (decay_or_release, count_up_to);
    input [3:0] decay_or_release;
    output reg [31:0] count_up_to;
    always @ (*)
        case(decay_or_release)
        4'd0: count_up_to = 32'd5;
        4'd1: count_up_to = 32'd833333;
        4'd2: count_up_to = 32'd1666666;
        4'd3: count_up_to = 32'd2500000;
        4'd4: count_up_to = 32'd3333333;
        4'd5: count_up_to = 32'd4166666;
        4'd6: count_up_to = 32'd5000000;
        4'd7: count_up_to = 32'd5833333;
        4'd8: count_up_to = 32'd6666666;
        4'd9: count_up_to = 32'd7500000;
        4'd10: count_up_to = 32'd8333333;
        4'd11: count_up_to = 32'd9166666;
        4'd12: count_up_to = 32'd10000000;
        4'd13: count_up_to = 32'd10833333;
        4'd14: count_up_to = 32'd11666666;
        4'd15: count_up_to = 32'd12500000;
        endcase
endmodule