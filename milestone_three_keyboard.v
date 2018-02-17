`timescale 1ns / 1ns

module milestone_three (
	CLOCK_50,
	KEY,
	SW,
	
	AUD_ADCDAT,
	AUD_BCLK,
	AUD_ADCLRCK,
	AUD_DACLRCK,
	AUD_XCK,
	AUD_DACDAT,
	PS2_CLK,
	PS2_DAT,
	
	FPGA_I2C_SDAT,
	FPGA_I2C_SCLK
);

//Inputs and outputs assigned below.

	input CLOCK_50;
	input AUD_ADCDAT;
	
	inout AUD_BCLK;
	inout AUD_ADCLRCK;
	inout AUD_DACLRCK;
	
	output AUD_XCK;
	output AUD_DACDAT;
	
	inout PS2_CLK;
	inout PS2_DAT;
	
	inout FPGA_I2C_SDAT;
	output FPGA_I2C_SCLK;
	
	input [3:0] KEY;
	input [9:0] SW;

//internal wires/registers below.

	wire [31:0] left_channel_audio_out;
	wire [31:0] right_channel_audio_out;
	wire [31:0] sound;
	wire write_audio_out;
	wire audio_out_allowed;
	
	wire send;
	
	wire [9:0] keys_out;
	
	wire [7:0] ps2_key_data;
	wire ps2_key_pressed;
	
//Functioning and assignments below.

	pianoKeyBoard2(
		.clock(CLOCK_50),
		.ps2_key_data(ps2_key_data),
		.ps2_key_pressed(ps2_key_pressed),
		.keys_out(keys_out),
		.reset(~KEY[0])
	);
	
	pianoTenKey(
		.switches(keys_out),
		.clock(CLOCK_50),
		.sound(sound),
		.allowed(audio_out_allowed)
	);
	
		
	
	assign left_channel_audio_out = sound;
	assign right_channel_audio_out = sound;
	assign write_audio_out = audio_out_allowed;
	
	Audio_Controller Audio_Controller(
		.CLOCK_50(CLOCK_50),
		.reset(~KEY[0]),
		.clear_audio_in_memory(),
		.read_audio_in(),
		.clear_audio_out_memory(),
		.left_channel_audio_out(left_channel_audio_out),
		.right_channel_audio_out(eight_channel_audio_out),
		.write_audio_out(write_audio_out),
		
		.AUD_ADCDAT(AUD_ADCDAT),
		
		.AUD_BCLK(AUD_BCLK),
		.AUD_ADCLRCK(AUD_ADCLRCK),
		.AUD_DACLRCK(AUD_DACLRCK),
		
		.left_channel_audio_in(),
		.right_channel_audio_in(),
		.audio_in_available(),
		.audio_out_allowed(audio_out_allowed),
		.AUD_XCK(AUD_XCK),
		.AUD_DACDAT(AUD_DACDAT)
		);
		
	avconf #(.USE_MIC_INPUT(1)) avc (
		.CLOCK_50(CLOCK_50),
		.reset(~KEY[0]),
		.FPGA_I2C_SCLK(FPGA_I2C_SCLK),
		.FPGA_I2C_SDAT(FPGA_I2C_SDAT)
		);
		
	PS2_Controller PS2 (
	// Inputs
	.CLOCK_50(CLOCK_50),
	.reset(~KEY[0]),

	// Bidirectionals
	.PS2_CLK(PS2_CLK),
 	.PS2_DAT(PS2_DAT),

	// Outputs
	.received_data		(ps2_key_data),
	.received_data_en	(ps2_key_pressed)
	);
	
	
endmodule


module pianoKeyBoard(clock, /*PS2_CLK, PS2_DAT*/ keys_out, reset, ps2_key_data, ps2_key_pressed);

	input clock;
	input reset;
	//inout PS2_CLK;
	//inout PS2_DAT;
	
	output reg [9:0] keys_out;
	
	input [7:0] ps2_key_data;
	input ps2_key_pressed;
	wire operation;
	
	reg [7:0] last_data_received;
	reg [7:0] temp, temp2; //stores ONLY make codes.
	reg able, able9, able8, able7, able6, able5, able4, able3, able2, able1, able0;
	reg allowed9, allowed8, allowed7, allowed6, allowed5, allowed4, allowed3, allowed2, allowed1, allowed0;
	
	
	/*PS2_Controller PS2 (
	// Inputs
	.CLOCK_50(clock),
	.reset(reset),

	// Bidirectionals
	.PS2_CLK(PS2_CLK),
 	.PS2_DAT(PS2_DAT),

	// Outputs
	.received_data		(ps2_key_data),
	.received_data_en	(ps2_key_pressed)
	);*/
	
	// FUNCTIONING

	always @(posedge clock)
	begin
		if (reset == 1'b1)
			last_data_received <= 8'h00;
		else if (ps2_key_pressed == 1'b1 && ps2_key_data != 8'hF0 && able == 0) begin
			last_data_received <= ps2_key_data;
			temp <= ps2_key_data;
		end
		else if(ps2_key_pressed == 1'b1 && ps2_key_data == 8'hF0)
			last_data_received <= ps2_key_data;
		else if (ps2_key_pressed == 1'b1 && ps2_key_data != 8'hF0 && able == 1) begin
			last_data_received <= ps2_key_data;
		end
	end
	
	always@(posedge clock)
	begin
		if(last_data_received == 8'hF0) begin
			able <= 1'b1;
		end
		else if(able == 1'b1 && last_data_received == temp) begin
			able <= 1'b1;
		end
		else able <= 1'b0;
	end
	
	// FUNCTIONING
	
	// TEST
	
	// do a case statement, 2 cases, for deleting or making for each key.
	
	/*always@(posedge clock)
		begin
			if(last_data_received == 8'hF0) begin
				deletion <= 1'b1;
			end
			else if(last_data_received != temp2) begin
				deletion <= 1'b0;
			end
		end
	
	always@(posedge clock)
		begin
			if(last_data_received != 8'hF0 && deletion == 1'b1) begin
				temp2 <= last_data_received;
			end
			else temp2 <= 8'h00;
		end
		
	//is above even necessary?
		
	always@(posedge clock)
		begin
			case(deletion)
				1'b1: if(last_data_received == 8'h1A) begin
							able9 <= 1'b1;
							//deletion1 <= 1'b0;
							temp2 <= 8'h1A;
						end else if(last_data_received == 8'h1B) begin
							able8 <= 1'b1;
							//deletion1 <= 1'b0;
							temp2 <= 8'h1B;
						end else if(last_data_received == 8'h22) begin
							able7 <= 1'b1;
							//deletion1 <= 1'b0;
							temp2 <= 8'h22;
						end else if(last_data_received == 8'h23) begin
							able6 <= 1'b1;
							//deletion1 <= 1'b0;
							temp2 <= 8'h23;
						end else if(last_data_received == 8'h21) begin
							able5 <= 1'b1;
							//deletion1 <= 1'b0;
							temp2 <= 8'h21;
						end else if(last_data_received == 8'h2A) begin
							able4 <= 1'b1;
							//deletion1 <= 1'b0;
							temp2 <= 8'h2A;
						end else if(last_data_received == 8'h34) begin
							able3 <= 1'b1;
							//deletion1 <= 1'b0;
							temp2 <= 8'h34;
						end else if(last_data_received == 8'h32) begin
							able2 <= 1'b1;
							//deletion1 <= 1'b0;
							temp2 <= 8'h32;
						end else if(last_data_received == 8'h33) begin
							able1 <= 1'b1;
							//deletion1 <= 1'b0;
							temp2 <= 8'h33;
						end else if(last_data_received == 8'h31) begin
							able0 <= 1'b1;
							//deletion1 <= 1'b0;
							temp2 <= 8'h31;
						end
				1'b0: if(last_data_received == 8'h1A) begin
							able9 <= 1'b0;
						end else if(last_data_received == 8'h1B) begin
							able8 <= 1'b0;
						end else if(last_data_received == 8'h22) begin
							able7 <= 1'b0;
						end else if(last_data_received == 8'h23) begin
							able6 <= 1'b0;
						end else if(last_data_received == 8'h21) begin
							able5 <= 1'b0;
						end else if(last_data_received == 8'h2A) begin
							able4 <= 1'b0;
						end else if(last_data_received == 8'h34) begin
							able3 <= 1'b0;
						end else if(last_data_received == 8'h32) begin
							able2 <= 1'b0;
						end else if(last_data_received == 8'h33) begin
							able1 <= 1'b0;
						end else if(last_data_received == 8'h31) begin
							able0 <= 1'b0;
						end
				default: if(last_data_received == 8'h1A) begin
							able9 <= 1'b1;
							//deletion <= 1'b0;
						end else if(last_data_received == 8'h1B) begin
							able8 <= 1'b1;
							//deletion <= 1'b0;
						end else if(last_data_received == 8'h22) begin
							able7 <= 1'b1;
							//deletion <= 1'b0;
						end else if(last_data_received == 8'h23) begin
							able6 <= 1'b1;
							//deletion <= 1'b0;
						end else if(last_data_received == 8'h21) begin
							able5 <= 1'b1;
							//deletion <= 1'b0;
						end else if(last_data_received == 8'h2A) begin
							able4 <= 1'b1;
							//deletion <= 1'b0;
						end else if(last_data_received == 8'h34) begin
							able3 <= 1'b1;
							//deletion <= 1'b0;
						end else if(last_data_received == 8'h32) begin
							able2 <= 1'b1;
							//deletion <= 1'b0;
						end else if(last_data_received == 8'h33) begin
							able1 <= 1'b1;
							//deletion <= 1'b0;
						end else if(last_data_received == 8'h31) begin
							able0 <= 1'b1;
							//deletion <= 1'b0;
						end
			endcase
		end*/
	
	// TEST
	
	
	
	

	/*interpreter interpreter(
		.last_data_received(last_data_received),
		.operation(operation),
		.clock(clock),
		.reset(reset)
	);*/
	
	reg deletion, deletion1;
	
	/*always@(posedge clock)
		begin
			if(last_data_received == 8'hF0) begin
				deletion <= 1'b1;
			end
			else deletion <= 1'b0;
		end*/
	
	/*always@(*)
		begin
			if(last_data_received == 8'h0) begin
				keys_out = 10'b0;
			end
			else if(last_data_received == 8'h1A) begin
					keys_out[9] = 1'b1;
					end else if (last_data_received == 8'h1B) begin
					keys_out[8] = 1'b1;
					end else if (last_data_received == 8'h22) begin
					keys_out[7] = 1'b1;
					end else if (last_data_received == 8'h23) begin
					keys_out[6] = 1'b1;
					end else if (last_data_received == 8'h21) begin
					keys_out[5] = 1'b1;
					end else if (last_data_received == 8'h2A) begin
					keys_out[4] = 1'b1;
					end else if (last_data_received == 8'h34) begin
					keys_out[3] = 1'b1;
					end else if (last_data_received == 8'h32) begin
					keys_out[2] = 1'b1;
					end else if (last_data_received == 8'h33) begin
					keys_out[1] = 1'b1;
					end else if (last_data_received == 8'h31) begin
					keys_out[0] = 1'b1;
					end 
			end */
			
		always@(posedge clock)
			begin
				if(last_data_received == 8'h0) begin
					keys_out <= 10'b0;
				end
				else if(last_data_received == 8'h1A && able == 1'b0) begin
					keys_out[9] <= 1'b1;
				end
				else if(last_data_received == 8'h1A && able == 1'b1) begin
					keys_out[9] <= 1'b0;
					//deletion1 <= 1'b0;
				end
				else if(last_data_received == 8'h1B && able == 1'b0) begin
					keys_out[8] <= 1'b1;
				end
				else if(last_data_received == 8'h1B && able == 1'b1) begin
					keys_out[8] <= 1'b0;
					//deletion1 <= 1'b0;
				end
				else if(last_data_received == 8'h22 && able == 1'b0) begin
					keys_out[7] <= 1'b1;
				end
				else if(last_data_received == 8'h22 && able == 1'b1) begin
					keys_out[7] <= 1'b0;
					//deletion1 <= 1'b0;
				end
				else if(last_data_received == 8'h23 && able == 1'b0) begin
					keys_out[6] <= 1'b1;
				end
				else if(last_data_received == 8'h23 && able == 1'b1) begin
					keys_out[6] <= 1'b0;
					//deletion1 <= 1'b0;
				end
				else if(last_data_received == 8'h21 && able == 1'b0) begin
					keys_out[5] <= 1'b1;
				end
				else if(last_data_received == 8'h21 && able == 1'b1) begin
					keys_out[5] <= 1'b0;
					//deletion1 <= 1'b0;
				end
				else if(last_data_received == 8'h2A && able == 1'b0) begin
					keys_out[4] <= 1'b1;
				end
				else if(last_data_received == 8'h2A && able == 1'b1) begin
					keys_out[4] <= 1'b0;
					//deletion1 <= 1'b0;
				end
				else if(last_data_received == 8'h34 && able == 1'b0) begin
					keys_out[3] <= 1'b1;
				end
				else if(last_data_received == 8'h34 && able == 1'b1) begin
					keys_out[3] <= 1'b0;
					//deletion1 <= 1'b0;
				end
				else if(last_data_received == 8'h32 && able == 1'b0) begin
					keys_out[2] <= 1'b1;
				end
				else if(last_data_received == 8'h32 && able == 1'b1) begin
					keys_out[2] <= 1'b0;
					//deletion1 <= 1'b0;
				end
				else if(last_data_received == 8'h33 && able == 1'b0) begin
					keys_out[1] <= 1'b1;
				end
				else if(last_data_received == 8'h33 && able == 1'b1) begin
					keys_out[1] <= 1'b0;
					//deletion1 <= 1'b0;
				end
				else if(last_data_received == 8'h31 && able == 1'b0) begin
					keys_out[0] <= 1'b1;
				end
				else if(last_data_received == 8'h31 && able == 1'b1) begin
					keys_out[0] <= 1'b0;
					//deletion1 <= 1'b0;
				end
			end
				
				
			
		
	
	/*always@(*)
		begin
			case(operation)
				1'b1: if(last_data_received == 8'h1A) begin
					keys_out[9] = 1'b0;
					end else if (last_data_received == 8'h1B) begin
					keys_out[8] = 1'b0;
					end else if (last_data_received == 8'h22) begin
					keys_out[7] = 1'b0;
					end else if (last_data_received == 8'h23) begin
					keys_out[6] = 1'b0;
					end else if (last_data_received == 8'h21) begin
					keys_out[5] = 1'b0;
					end else if (last_data_received == 8'h2A) begin
					keys_out[4] = 1'b0;
					end else if (last_data_received == 8'h34) begin
					keys_out[3] = 1'b0;
					end else if (last_data_received == 8'h32) begin
					keys_out[2] = 1'b0;
					end else if (last_data_received == 8'h33) begin
					keys_out[1] = 1'b0;
					end else if (last_data_received == 8'h31) begin
					keys_out[0] = 1'b0;
					end /*else if (last_data_received == 8'h3B) begin
					keys_out[1] = 1'b0;
					end else if (last_data_received == 8'h3A) begin
					keys_out[0] = 1'b0;
					end
				1'b0: if(last_data_received == 8'h1A) begin
					keys_out[9] = 1'b1;
					end else if (last_data_received == 8'h1B) begin
					keys_out[8] = 1'b1;
					end else if (last_data_received == 8'h22) begin
					keys_out[7] = 1'b1;
					end else if (last_data_received == 8'h23) begin
					keys_out[6] = 1'b1;
					end else if (last_data_received == 8'h21) begin
					keys_out[5] = 1'b1;
					end else if (last_data_received == 8'h2A) begin
					keys_out[4] = 1'b1;
					end else if (last_data_received == 8'h34) begin
					keys_out[3] = 1'b1;
					end else if (last_data_received == 8'h32) begin
					keys_out[2] = 1'b1;
					end else if (last_data_received == 8'h33) begin
					keys_out[1] = 1'b1;
					end else if (last_data_received == 8'h31) begin
					keys_out[0] = 1'b1;
					end /*else if (last_data_received == 8'h3B) begin
					keys_out[1] = 1'b1;
					end else if (last_data_received == 8'h3A) begin
					keys_out[0] = 1'b1;
					end
			endcase
		end*/
	


endmodule

// interpreter module below.

module interpreter(last_data_received, operation, clock, reset);

	input [8:0] last_data_received;
	input clock;
	input reset;
	output reg operation;

	parameter MAKE = 3'b01, BREAK = 3'b10;
	
	reg [1:0] state;
	reg [1:0] next_state;
	
	// COMB logic below.
	
	always@(*)
	begin
		next_state = 2'b00;
		case(state)
			MAKE: if(last_data_received == 8'hF0) begin
				next_state = BREAK;
				end else begin
				next_state = MAKE;
				end
			BREAK: if(last_data_received != 8'hF0) begin
				next_state = MAKE;
				end else begin
				next_state = BREAK;
				end
			default: next_state = BREAK;
		endcase
	end
	
	// SEQ logic below.
	
	always@(posedge clock)
	begin
		if(reset == 1'b1) begin
			state <= MAKE;
		end else begin
			state <= next_state;
		end
	end
	
	// OUTPUT logic below.
	
	always@(posedge clock)
	begin
		if(reset == 1'b1) begin
			operation <= 1'b0;
		end
		else begin
			case(state)
				MAKE: begin
					operation <= 1'b0;
					end
				BREAK: begin
					operation <= 1'b1;
					end
				default: begin
					operation <= 1'b1;
					end
			endcase
		end
		end
		
		

endmodule
