`default_nettype none
module synthesizer (CLOCK_50, CLOCK2_50, KEY, FPGA_I2C_SCLK, FPGA_I2C_SDAT, AUD_XCK, 
		        AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK, AUD_ADCDAT, AUD_DACDAT, PS2_DAT, PS2_CLK, SW, LEDR);

	input CLOCK_50, CLOCK2_50;
	input [3:0] KEY;
	input [9:0] SW;
	
	// I2C Audio/Video config interface
	output FPGA_I2C_SCLK;
	inout FPGA_I2C_SDAT;
	
	//PS2 inputs
	inout PS2_DAT;
	inout PS2_CLK;
	
	// Audio CODEC
	output AUD_XCK;
	input AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK;
	input AUD_ADCDAT;
	output AUD_DACDAT;
	output [9:0]LEDR;
	
	// Local wires.
	wire read_ready, write_ready, read, write;
	wire [23:0] readdata_left, readdata_right;
	wire [23:0] writedata_left, writedata_right;
	
	wire resetn = ~KEY[0];
	wire keyboard_pushed = |kb;
	wire load = ~KEY[1];
		
	wire release_done;
	wire out;

	rate_divider_frequency rdf0(CLOCK_50, resetn, outkb, out);
	
	assign LEDR[3:0] = shift_amount_out; 
	
	wire counter_clock;
	wire load_a, load_d, load_s, load_r, load_p, load_amp, reset_p, reset_attack, preset_release;
	wire [3:0]	shift_amount_out;
	wire [11:0] kb;
	wire [31:0] outkb;
	
	keyboard_tracker #(.PULSE_OR_HOLD(0)) kt0(
	     .clock(CLOCK_50),
 		  .reset(!resetn),
 		  .PS2_CLK(PS2_CLK),
 		  .PS2_DAT(PS2_DAT),
 		  .a(kb[11]), 
		  .w(kb[10]), 
		  .s(kb[9]), 
		  .e(kb[8]), 
		  .d(kb[7]), 
		  .f(kb[6]), 
		  .t(kb[5]), 
		  .g(kb[4]),
		  .y(kb[3]), 
		  .h(kb[2]), 
		  .u(kb[1]), 
		  .j(kb[0]));
		  
	Keyboard_LUT kbt(CLOCK_50, resetn, kb, outkb);
	
	control c0 (
		.load (load),
		.keyboard_pushed(keyboard_pushed),
		.write_ready (write_ready),
		.enable (out), 
		.release_done(release_done),
		.clock (CLOCK_50),
		.resetn (resetn),
		.load_a (load_a),
		.load_d (load_d),
		.load_s (load_s),
		.load_r (load_r),
		.load_p (load_p),
		.load_amp (load_amp),
		.reset_p (reset_p),
		.counter_clk(counter_clock),
		.write (write),
		.reset_attack(reset_attack),
		.preset_release(preset_release),
		.current_state_out()
	);
	datapath d0(
		.clk(CLOCK_50),
		.counter_clock(counter_clock),
		.resetn(resetn),
		.offset(SW[7:4]),
		.adsr_data_in(SW[3:0]),
		.wave_select(SW[9:8]),
		.keyboard_pushed(keyboard_pushed),
		.load_a (load_a),
		.load_d (load_d),
		.load_s (load_s),
		.load_r (load_r),
		.load_p (load_p),
		.load_amp (load_amp),
		.reset_p (reset_p),
		.reset_attack(reset_attack),
		.preset_release(preset_release),
		.amp_out(writedata_left),
		.release_done(release_done),
		.shift_amount_out(shift_amount_out),
		.done_out(LEDR[6:4])
	);
	
	assign writedata_right = writedata_left;
	

/////////////////////////////////////////////////////////////////////////////////
// Audio CODEC interface. 
//
// The interface consists of the following wires:
// read_ready, write_ready - CODEC ready for read/write operation 
// readdata_left, readdata_right - left and right channel data from the CODEC
// read - send data from the CODEC (both channels)
// writedata_left, writedata_right - left and right channel data to the CODEC
// write - send data to the CODEC (both channels)
// AUD_* - should connect to top-level entity I/O of the same name.
//         These signals go directly to the Audio CODEC
// I2C_* - should connect to top-level entity I/O of the same name.
//         These signals go directly to the Audio/Video Config module
/////////////////////////////////////////////////////////////////////////////////
	clock_generator my_clock_gen(
		// inputs
		CLOCK2_50,
		resetn,

		// outputs
		AUD_XCK
	);

	audio_and_video_config cfg(
		// Inputs
		CLOCK_50,
		resetn,

		// Bidirectionals
		FPGA_I2C_SDAT,
		FPGA_I2C_SCLK
	);

	audio_codec codec(
		// Inputs
		CLOCK_50,
		resetn,

		read,	write,
		writedata_left, writedata_right,

		AUD_ADCDAT,

		// Bidirectionals
		AUD_BCLK,
		AUD_ADCLRCK,
		AUD_DACLRCK,

		// Outputs
		read_ready, write_ready,
		readdata_left, readdata_right,
		AUD_DACDAT
	);
endmodule


module control (
	// ~KEY[1]
	input load,
	// ~KEY[3]
	input keyboard_pushed,
	
	input write_ready,
	input enable,
	
	input release_done,
	
	input clock,
	input resetn,
	output reg load_a ,load_d ,load_s ,load_r ,load_p ,load_amp,
    	output reg reset_p, 
    	output reg counter_clk,
	output reg write,
	output reg reset_attack, preset_release,
	output [3:0]current_state_out
	);
	
	reg [3:0] current_state, next_state; 
	
	assign current_state_out = current_state;
    
    localparam  
					 LOAD_ATTACK			= 4'd0,
					 LOAD_ATTACK_WAIT    = 4'd1,
					 LOAD_DECAY			   = 4'd2,
					 LOAD_DECAY_WAIT     = 4'd3,
					 LOAD_SUSTAIN			= 4'd4,
					 LOAD_SUSTAIN_WAIT   = 4'd5,
					 LOAD_RELEASE        = 4'd6,
					 LOAD_RELEASE_WAIT   = 4'd7,
					 KEYBOARD_LISTEN     = 4'd8,
					 LOAD_AMP_REG        = 4'd9,
					 LISTEN_WRITE_READY  = 4'd11,
					 WRITE_DATA				= 4'd12,
					 UPDATE_PHASE        = 4'd13;
					
    
    // Next state logic aka our state table
    always@(*)
    begin: state_table 
            case (current_state)
                LOAD_ATTACK: next_state = load ? LOAD_ATTACK_WAIT : LOAD_ATTACK;
					
					
                LOAD_ATTACK_WAIT: next_state = load ? LOAD_ATTACK_WAIT : LOAD_DECAY; 
					 
					 
				LOAD_DECAY: next_state = load ? LOAD_DECAY_WAIT : LOAD_DECAY; 
					 
					 
                LOAD_DECAY_WAIT: next_state = load ? LOAD_DECAY_WAIT : LOAD_SUSTAIN; 
					 
					 
				LOAD_SUSTAIN: next_state = load ? LOAD_SUSTAIN_WAIT : LOAD_SUSTAIN; 
					 
					 
                LOAD_SUSTAIN_WAIT: next_state = load ? LOAD_SUSTAIN_WAIT : LOAD_RELEASE; 
					 
					 
				LOAD_RELEASE: next_state = load ? LOAD_RELEASE_WAIT : LOAD_RELEASE; 
					 
					 
                LOAD_RELEASE_WAIT: next_state = load ? LOAD_RELEASE_WAIT : KEYBOARD_LISTEN; 
					 
					 
				KEYBOARD_LISTEN: next_state = (keyboard_pushed || !release_done) ? LOAD_AMP_REG : KEYBOARD_LISTEN;
					 
					 
				LOAD_AMP_REG: next_state = enable ? LISTEN_WRITE_READY : LOAD_AMP_REG;
				 
				 
				LISTEN_WRITE_READY: next_state = write_ready ? WRITE_DATA : LISTEN_WRITE_READY;
				 
				 
				WRITE_DATA: next_state = UPDATE_PHASE;
				 
				 
				UPDATE_PHASE: next_state = KEYBOARD_LISTEN; 

					 
            default:     next_state = LOAD_ATTACK;
        endcase
    end 
    
    // Output logic for datapath control signals
    always @(*)
    begin: enable_signals
        // By default make all signals 0
        load_a = 0;
		  load_d = 0;
		  load_s = 0;
		  load_r = 0;
		  load_p = 0;
		  load_amp = 0;
        reset_p = 0;
        counter_clk = 0;
		  write =0;
		  reset_attack = 0;
		  preset_release = 0;
        
        case (current_state)
            LOAD_ATTACK: begin
					reset_p = 1;
					load_a = 1;
            end
				LOAD_ATTACK_WAIT: begin
					load_a = 0;
				end
            LOAD_DECAY: begin
					load_d = 1;
            end
				LOAD_DECAY_WAIT: begin
				end
            LOAD_SUSTAIN: begin
					load_s = 1;
            end
				LOAD_SUSTAIN_WAIT: begin
				end
				LOAD_RELEASE: begin
					load_r = 1;
            end
				LOAD_RELEASE_WAIT: begin
				reset_attack = 1;
				preset_release = 1;
				end
				KEYBOARD_LISTEN: begin
					load_p = 1;
					if (~keyboard_pushed) begin
						reset_p = 1;
						reset_attack = 1;
					end
            end
				LOAD_AMP_REG: begin
					load_amp = 1;
				end
				LISTEN_WRITE_READY: begin
				end
				WRITE_DATA: begin
					write = 1;
				end
				UPDATE_PHASE: begin
					counter_clk = 1;
				end
        endcase
    end // enable_signals
    
    // current_state registers
    always@(posedge clock)
    begin: state_FFs
        if(resetn)
            current_state <= LOAD_ATTACK;
        else
            current_state <= next_state;
    end // state_FFS
	 
endmodule 

module datapath(
    input clk,
	 input counter_clock,
    input resetn,
	 input [3:0]offset,
    input [3:0] adsr_data_in,
	 input [1:0] wave_select, 
	 input keyboard_pushed,
    input load_a, load_d, load_s, load_r, load_p, load_amp,
	 input reset_p,
	 input reset_attack,
	 input preset_release,
	 output [23:0] amp_out,
	 output release_done,
	 output [3:0] shift_amount_out,
	 output [2:0] done_out
    );
	 
	 assign amp_out = amp;
	 assign shift_amount_out = shift_amount;
    
    // input registers
    reg [3:0] a, d, s, r;
	 reg [23:0] amp;
	 reg [7:0] phase;
	 wire [23:0] shifted_adsr_out;

	wire [7:0] phase_counter_out; 
    
    // Registers with respective input logic
    always @ (posedge clk) begin
        if (resetn) begin
            a <= 4'd0; 
            d <= 4'd0; 
            s <= 4'd0; 
            r <= 4'd0; 
				amp <= 24'd0;
				phase <= 8'd0;
        end
        else begin
            if (load_a)begin
                a <= adsr_data_in; 
		end
            if (load_d)begin
                d <= adsr_data_in; 
		end
            if (load_s)begin
                s <= adsr_data_in;
		end
            if (load_r)begin
                r <= adsr_data_in;
		end
	    if (load_p)begin
                phase <= phase_counter_out;
		end
	    if (load_amp)begin
					 amp <= shifted_adsr_out;
		end
        end
    end
	 
	 phase_counter p0(counter_clock, reset_p, offset, phase_counter_out);
	 
	 wire [15:0] wave_out_to_adsr;
	 wave_rom w0(clk, wave_select, phase, wave_out_to_adsr);
	 
	 wire [15:0] adsr_out; 
	 
	 wire [3:0] shift_amount_a, shift_amount_d, shift_amount_r;
	 
	 reg reset_decay, reset_release;
	 reg [3:0] shift_amount;
	 wire attack_done, decay_done;
	 
	 always @ (*)begin
	 if (!attack_done && keyboard_pushed)begin
	 	reset_release = 1;
	 	reset_decay = 1;
	 	shift_amount = shift_amount_a;	 
	 	end
	 else if (!decay_done && keyboard_pushed) begin
	 	reset_release = 1;
	 	reset_decay = 0;
	 	shift_amount = shift_amount_d;
	 	end 
	 else if (keyboard_pushed)begin
	 	reset_release = 1;
	 	reset_decay = 0;
	 	shift_amount = (4'd15 - s);
	 end
	 else if (!release_done) begin
	 	reset_release = 0;
	 	reset_decay = 0;
	 	shift_amount = shift_amount_r;
	 end
	 else begin 
	 shift_amount = 15;
	 reset_release = 0;
	 reset_decay = 0;
	 end
	 end
	 
	 assign done_out = {attack_done, decay_done, release_done};
	 
	 attack_shift_amount aso1(clk, reset_attack, a, shift_amount_a, attack_done);
	 decay_shift_amount dso1(clk, reset_decay, 0, d, s, shift_amount_d, decay_done);	
	 release_shift_amount rso1(clk, reset_release, preset_release, r, s, shift_amount_r, release_done);	
	 
	 adsr_modification am1(wave_out_to_adsr, shift_amount, adsr_out);
	 
	 assign shifted_adsr_out = {8'b0,adsr_out} << 8;
    
endmodule


