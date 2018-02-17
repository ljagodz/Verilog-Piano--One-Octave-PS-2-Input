`timescale 1ns / 1ns

module milestone_two (
	CLOCK_50,
	KEY,
	SW,
	
	AUD_ADCDAT,
	AUD_BCLK,
	AUD_ADCLRCK,
	AUD_DACLRCK,
	AUD_XCK,
	AUD_DACDAT,
	
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
	
//Functioning and assignments below.
	
	pianoTenKey(
		.switches(SW[9:0]),
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
	
	
endmodule

// toneSelector module below (takes in all 10 switches as input to recognize:
// a) whether there are switches that are on, and
// b) which ones are on.

module toneSplitter(switches, en_out, tone_out);

	input [11:0] switches;
	output reg [11:0] en_out;
	output reg [47:0] tone_out;

	always@(*)
		if(switches[11] == 1) begin
			en_out[11] = 1;
			tone_out [47:44] = 4'b0001;
		end
		else en_out[11] = 0;
		
	always@(*)
		if(switches[10] == 1) begin
			en_out[10] = 1;
			tone_out [43:40] = 4'b0010;
		end
		else en_out[10] = 0;
	
	always@(*)
		if(switches[9] == 1) begin
			en_out[9] = 1;
			tone_out [39:36] = 4'b0011;
		end
		else en_out[9] = 0;
		
	always@(*)		
		if(switches[8] == 1) begin
			en_out[8] = 1;
			tone_out [35:32] = 4'b0100;
		end
		else en_out[8] = 0;
		
	always@(*)
		if(switches[7] == 1) begin
			en_out[7] = 1;
			tone_out [31:28] = 4'b0101;
		end
		else en_out[7] = 0;
		
	always@(*)
		if(switches[6] == 1) begin
			en_out[6] = 1;
			tone_out [27:24] = 4'b0110;
		end
		else en_out[6] = 0;
		
	always@(*)
		if(switches[5] == 1) begin
			en_out[5] = 1;
			tone_out [23:20] = 4'b0111;
		end
		else en_out[5] = 0;
		
	always@(*)
		if(switches[4] == 1) begin
			en_out[4] = 1;
			tone_out [19:16] = 4'b1000;
		end
		else en_out[4] = 0;
		
	always@(*)
		if(switches[3] == 1) begin
			en_out[3] = 1;
			tone_out [15:12] = 4'b1001;
		end
		else en_out[3] = 0;
		
	always@(*)
		if(switches[2] == 1) begin
			en_out[2] = 1;
			tone_out [11:8] = 4'b1010;
		end
		else en_out[2] = 0;
		
	always@(*)
		if(switches[1] == 1) begin
			en_out[1] = 1;
			tone_out [7:4] = 4'b1011;
		end
		else en_out[1] = 0;
		
	always@(*)
		if(switches[0] == 1) begin
			en_out[0] = 1;
			tone_out [3:0] = 4'b1100;
		end
		else en_out[0] = 0;

endmodule 

module toneSelector(toneNum, max);

	input [3:0] toneNum;
	output reg [18:0] max;
	
	always@(*)
		if(toneNum == 4'b0001) begin
			max = 18'd183;
		end
		else if(toneNum == 4'b0010) begin
			max = 18'd173;
		end
		else if(toneNum == 4'b0011) begin
			max = 18'd163;
		end
		else if(toneNum == 4'b0100) begin
			max = 18'd154;
		end
		else if(toneNum == 4'b0101) begin
			max = 18'd146;
		end
		else if(toneNum == 4'b0110) begin
			max = 18'd137;
		end
		else if(toneNum == 4'b0111) begin
			max = 18'd130;
		end
		else if(toneNum == 4'b1000) begin
			max = 18'd122;
		end
		else if(toneNum == 4'b1001) begin
			max = 18'd116;
		end
		else if(toneNum == 4'b1010) begin
			max = 18'd109;
		end
		else if(toneNum == 4'b1011) begin
			max = 18'd103;
		end
		else if(toneNum == 4'b1100) begin
			max = 18'd97;
		end
	
		

endmodule

module middleCCounter(clock, allowed, send);

	input clock;
	input allowed;
	output reg send;
	//output reg valid;
	reg [18:0] count;
	
	localparam [18:0] midC = 18'd183;
	
	always@(posedge clock)
		if(count == midC && allowed == 1) begin
			count <= 0;
			send <= !send;
		end
		else if(count == (midC / 2) && allowed == 1) begin
			count <= count + 1;
			send <= !send;
		end
		else if(allowed == 1) count <= count + 1;
	
	/**always@(*)
		begin
			valid <= clock & allowed;
		end**/
			
	
endmodule

module generalCounter(clock, max, allowed, send);

	input clock;
	input allowed;
	input [18:0] max;
	output reg send;

	reg [18:0] count;

	always@(posedge clock)
			if(count == max && allowed == 1) begin
				count <= 0;
				send <= !send;
			end
			else if(count == (max / 2) && allowed == 1) begin
				count <= count + 1;
				send <= !send;
			end
			else if(allowed == 1) count <= count + 1;

endmodule 

module toneGenerator(tone, en, clock, sample, allowed);
	input [3:0] tone;
	input en;
	input clock;
	output [31:0] sample;
	//output valid;
	input allowed;
	
	wire [18:0] max;
	wire send;
	
	toneSelector toneSelector(
		.toneNum(tone),
		.max(max)
	);
	
	generalCounter generalCounter(
		.clock(clock),
		.max(max),
		.allowed(allowed),
		.send(send)
	);
	
	assign sample = {32{en}} & (send ? 32'b101111101011110000100000 : 32'b010000010100001111100000);
	
endmodule

module pianoTenKey(switches, clock, sound, allowed);

	input [11:0] switches;
	input clock;
	//output valid;
	output [31:0] sound;
	input allowed;
	
	wire [11:0] en;
	wire [47:0] tone;
	
	wire [31:0] sample11, sample10, sample9, sample8, sample7, sample6, sample5, sample4, sample3, sample2, sample1, sample0;

	toneSplitter toneSplitter(
		.switches(switches),
		.en_out(en),
		.tone_out(tone)
	);
	
	
	toneGenerator gen11(
		.tone(tone[47:44]),
		.en(en[11]),
		.clock(clock),
		.sample(sample11),
		.allowed(allowed)
	);
	
	toneGenerator gen10(
		.tone(tone[43:40]),
		.en(en[10]),
		.clock(clock),
		.sample(sample10),
		.allowed(allowed)
	);
	
	toneGenerator gen9(
		.tone(tone[39:36]),
		.en(en[9]),
		.clock(clock),
		.sample(sample9),
		.allowed(allowed)
	);
	
	toneGenerator gen8(
		.tone(tone[35:32]),
		.en(en[8]),
		.clock(clock),
		.sample(sample8),
		.allowed(allowed)
	);
	
	toneGenerator gen7(
		.tone(tone[31:28]),
		.en(en[7]),
		.clock(clock),
		.sample(sample7),
		.allowed(allowed)
	);
	
	toneGenerator gen6(
		.tone(tone[27:24]),
		.en(en[6]),
		.clock(clock),
		.sample(sample6),
		.allowed(allowed)
	);
	
	toneGenerator gen5(
		.tone(tone[23:20]),
		.en(en[5]),
		.clock(clock),
		.sample(sample5),
		.allowed(allowed)
	);
	
	toneGenerator gen4(
		.tone(tone[19:16]),
		.en(en[4]),
		.clock(clock),
		.sample(sample4),
		.allowed(allowed)
	);
	
	toneGenerator gen3(
		.tone(tone[15:12]),
		.en(en[3]),
		.clock(clock),
		.sample(sample3),
		.allowed(allowed)
	);
	
	toneGenerator gen2(
		.tone(tone[11:8]),
		.en(en[2]),
		.clock(clock),
		.sample(sample2),
		.allowed(allowed)
	);
	
	toneGenerator gen1(
		.tone(tone[7:4]),
		.en(en[1]),
		.clock(clock),
		.sample(sample1),
		.allowed(allowed)
	);
	
	toneGenerator gen0(
		.tone(tone[3:0]),
		.en(en[0]),
		.clock(clock),
		.sample(sample0),
		.allowed(allowed)
	);
	
	assign sound = sample11 + sample10 + sample9 + sample8 + sample7 + sample6 + sample5 + sample4 + sample3 + sample2 + sample1 + sample0;


endmodule

//////// MILESTONE 3 WORK /////////

module improvedToneGenerator();

	

endmodule
