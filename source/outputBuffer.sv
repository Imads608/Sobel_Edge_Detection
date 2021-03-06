// $Id: $
// File name:   outputBuffer.sv
// Created:     4/17/2017
// Author:      Pradyumna Modukuru
// Lab Section: 337-06
// Version:     1.0  Initial Design Entry
// Description: Output buffer for writing image to SRAM

module outputBuffer(
	input wire clk, n_rst, edge_pixel, out_en, write_out_enable, img_done,
	output reg out_empty, out_full,
	input reg [31:0] endpixel,
	output reg [31:0] out_pixel,
	output wire [31:0] write_addr
);

typedef enum bit [2:0] {IDLE, CHECK_FULL, FULL, WRITE_OUT, DONE} stateType;

stateType current;
stateType next;

reg [5:0] count;
reg full;
reg nextcol;
//reg done;
reg [31:0] currpixel;

reg [5:0] buffcnt;
reg [4:0] ccnt;
reg [8:0] rcnt;
reg [31:0] next_out_pixel;
reg [31:0] next_write_addr;
reg [31:0] curr_addr;

//reg [13:0] donecnt;

//calc write address in SRAM for pixel
//assign next_write_addr = endpixel + donecnt;

//state register
always_ff @ (posedge clk, negedge n_rst)
begin
	if( n_rst == 1'b0)
        begin
		current <= IDLE;
		curr_addr <= endpixel;
	end
		
	else
	begin	
		current <= next;
		curr_addr <= next_write_addr;
	end
end

//32 bit FIFO buffer
flex_stp_sr #(32,0) TXSR(.clk(clk), .n_rst(n_rst), .shift_enable(out_en), .serial_in(edge_pixel), .parallel_out(next_out_pixel));

//buffer counter
flex_counter #6 buffcounter (.clk(clk), .n_rst(n_rst), .count_enable(out_en), .rollover_val(6'd32), .rollover_flag(full), .count_out(buffcnt));

//col count
flex_counter #5 colcnt (.clk(clk), .n_rst(n_rst), .clear(out_en & nextcol), .count_enable(write_out_enable), .rollover_val(5'd19), .rollover_flag(nextcol), .count_out(ccnt));

//row count
flex_counter #9 rowcnt (.clk(clk), .n_rst(n_rst), .count_enable(nextcol), .count_out(rcnt));

//done counter
//flex_counter #14 donecount (.clk(clk), .n_rst(n_rst), .count_enable(write_out_en), .rollover_val(14'd10000), .rollover_flag(done), .count_out(donecnt));

//FSM
always_comb
begin
	next = current;
	case(current)

	IDLE:
	begin
		if (out_en)
		begin
			next = CHECK_FULL;
		end
		if (img_done)
		begin
			next = DONE;
		end
	end
	CHECK_FULL:
	begin
		if (full)
		begin
			next = FULL;
		end
		else
		begin
			next = IDLE;
		end

	end
	FULL:
	begin
		if (write_out_enable)
		begin
			next = WRITE_OUT;
		end
	end
	WRITE_OUT:
	begin
		next = IDLE;
	end
	
	endcase

end

//comb logic
always_comb
begin
	out_full = 0;
	out_empty = 0;
	case(current)
	
	FULL:
	begin
		out_full = 1'b1;
	end
	WRITE_OUT:
	begin
		out_empty = 1'b1;
		if (ccnt <= 18)
		begin
			out_pixel = next_out_pixel;
		end
		else
		begin
			if (rcnt % 2 == 0)
			begin
				out_pixel = {next_out_pixel[31:2], 2'b0};
			end
			else begin
				out_pixel={2'b0, next_out_pixel[29:0]};
			end		
		end
	end
	DONE:
	begin
		out_pixel = 32'd1;
		
	end

	endcase

end

//Calculates the output address for pixel 
always_comb
begin
	next_write_addr = curr_addr;
	if (rcnt % 2 == 0 && write_out_enable && !img_done)
	begin
		next_write_addr = endpixel + (ccnt*4) + (rcnt*20);
	end
	else if (rcnt % 2 == 1 && write_out_enable && !img_done)
	begin
		next_write_addr = curr_addr + 20 - (ccnt*4);
	end
end

//assigns the output
assign write_addr = img_done ? 32'd4 : curr_addr;

endmodule


