module ADSR (clock, reset, keyboard_pushed, attack_value, decay_value, sustain_value, release_value, wave_out_to_adsr, adsr_out);
	input clock;
	input reset;
	input keyboard_pushed;
	input [3:0] attack_value, decay_value, sustain_value, release_value;
	input [15:0] wave_out_to_adsr;
	output [15:0] adsr_out;
	

	wire reset_attack, reset_decay, reset_release;
	wire attack_done, decay_done, release_done;
	wire [1:0] adr;
	wire is_sustain;
	
	adsr_control adsr_c0 (
		.clk(clock),
		.attack_done(attack_done), 
		.decay_done(decay_done), 
		.release_done(release_done),
		.resetn(reset),
		.keyboard_pushed(keyboard_pushed),
		.is_sustain(is_sustain),
		.adr(adr),
		.attack_reset(reset_attack), 
		.decay_reset(reset_decay), 
		.release_reset (reset_release)
	);

	adsr_datapath adsr_d0(
		.clock(clock),
		.reset_attack(reset_attack),
		.reset_decay(reset_decay),
		.reset_release(reset_release),
		.adr(adr),
		.is_sustain(is_sustain),
		.attack_value(attack_value),
		.decay_value(decay_value),
		.sustain_value(sustain_value),
		.release_value(release_value),
		.wave_out_to_adsr(wave_out_to_adsr),
		.adsr_out(adsr_out),
		.attack_done(attack_done),
		.decay_done(decay_done),
		.release_done(release_done)
	);

endmodule 

module adsr_control(
    input clk,
    input attack_done, decay_done, release_done,
    input resetn,
    input keyboard_pushed, 
    output reg is_sustain, 
    output reg [1:0] adr,
    output reg attack_reset, decay_reset, release_reset
    );

    reg [3:0] current_state, next_state; 
    
    localparam  KEYBOARD_LISTEN    = 4'd0,
                ATTACK             = 4'd1,
                ATTACK_TRANSITION  = 4'd2,
                DECAY              = 4'd3,
                DECAY_TRANSITION   = 4'd4,
                SUSTAIN            = 4'd5,
                SUSTAIN_TRANSITION = 4'd6,
                RELEASE            = 4'd7,
                RELEASE_TRANSITION = 4'd8;
    
    // Next state logic aka our state table
    always@(*)
    begin: state_table 
            case (current_state)
                KEYBOARD_LISTEN: next_state = keyboard_pushed? ATTACK: KEYBOARD_LISTEN;
					 
                ATTACK: next_state = attack_done ? ATTACK_TRANSITION : ATTACK; // Loop in current state until value is input
					 
                ATTACK_TRANSITION: next_state = attack_done ? ATTACK_TRANSITION: DECAY;
					 
                DECAY: next_state = decay_done ? DECAY_TRANSITION : DECAY; // Loop in current state until go signal goes low
					 
                DECAY_TRANSITION: next_state = decay_done? DECAY_TRANSITION: SUSTAIN;
					 
                SUSTAIN: next_state = keyboard_pushed? SUSTAIN : SUSTAIN_TRANSITION; // Loop in current state until value is input
					 
                SUSTAIN_TRANSITION: next_state = RELEASE;
					 
                RELEASE: next_state = release_done ? RELEASE_TRANSITION : RELEASE; // Loop in current state until go signal goes loW
					 
                RELEASE_TRANSITION: next_state = release_done? RELEASE_TRANSITION: KEYBOARD_LISTEN;
            default:     next_state = KEYBOARD_LISTEN;
        endcase
    end // state_table
   

    // Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signals
        // By default make all our signals 0
        is_sustain = 0; 
        adr = 2'd0;
        attack_reset = 0;
        decay_reset = 0;
        release_reset = 0;
        case (current_state)
            KEYBOARD_LISTEN: begin
                release_reset = 0;
                attack_reset = 1;
                decay_reset = 0;
                is_sustain = 0;
                adr = 2'd0;
            end

            ATTACK: begin
                release_reset = 0;
                attack_reset = 0;
                decay_reset = 0;
                is_sustain = 0;
                adr = 2'd1;
            end

            ATTACK_TRANSITION: begin
                is_sustain = 0; 
                adr = 2'b0;
                decay_reset = 1;
                attack_reset = 0;
                release_reset = 0;
            end

            DECAY: begin
                release_reset = 0;
                attack_reset = 0;
                decay_reset = 0;
                is_sustain = 0;
                adr = 2'd2;
            end

            DECAY_TRANSITION: begin
                release_reset = 0;
                attack_reset = 0;
                decay_reset = 0;
                is_sustain = 0;
                adr = 2'd0;
            end

            SUSTAIN: begin
                release_reset = 0;
                attack_reset = 0;
                decay_reset = 0;
                is_sustain = 1;
                adr = 2'b0;
            end

            SUSTAIN_TRANSITION: begin
                release_reset = 1;
                attack_reset = 0;
                decay_reset = 0;
                is_sustain = 0;
                adr = 2'b0;
            end

            RELEASE: begin
                release_reset = 0;
                attack_reset = 0;
                decay_reset = 0;
                is_sustain = 0;
                adr = 2'd3;
            end
				
				RELEASE_TRANSITION: begin
				end
        // default:    // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
        endcase
    end // enable_signals
   
    // current_state registers
    always@(posedge clk)
    begin: state_FFs
        if(resetn)
            current_state <= KEYBOARD_LISTEN;
        else
            current_state <= next_state;
    end // state_FFS
endmodule


module adsr_datapath(
	input clock,
	input reset_attack, reset_decay, reset_release,
	input [1:0] adr,
	input is_sustain,
	input [3:0] attack_value, decay_value, sustain_value, release_value,
	input [15:0] wave_out_to_adsr,
	output [15:0] adsr_out,
	output attack_done, decay_done, release_done
);
	
	wire [15:0] modified_ATTACK_out, modified_DECAY_out, modified_SUSTAIN_out, modified_RELEASE_out;
	//wire attack_done, decay_done, release_done;
	wire [3:0] attack_shift_amount, decay_shift_amount, release_shift_amount;

	attack_shift_amount aso0(clock, reset_attack, attack_value, attack_shift_amount, attack_done);	
	decay_shift_amount dso0(clock, reset_decay, decay_value, sustain_value, decay_shift_amount, decay_done);
	release_shift_amount rso0(clock, reset_release, release_value, sustain_value, release_shift_amount, release_done);

	reg [3:0] shift_amount;

	//MUX the shift amounts
	always @(*)
	begin

	if (is_sustain) begin
		shift_amount = (4'd15 - sustain_value);
	end 
	else begin
		case (adr)
			1: shift_amount = attack_shift_amount;
			2: shift_amount = decay_shift_amount;
			3: shift_amount = release_shift_amount;
			default shift_amount = 4'd0;
		endcase
		end
	end
	
	adsr_modification am0(wave_out_to_adsr, shift_amount, adsr_out);

endmodule


module adsr_modification(amplitude, shift_amount, modified_out);
	input [15:0] amplitude;
	input [3:0] shift_amount;
	output [15:0] modified_out;
	
	assign modified_out = amplitude >>> shift_amount;

endmodule


