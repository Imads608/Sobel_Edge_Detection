// $Id: $
// File name:   sobel.sv
// Created:     4/4/2017
// Author:      Aaorn Kaiser
// Lab Section: 337-06
// Version:     1.0  Initial Design Entry
// Description: Sobel Edge Algorithm Module
module sobel
(
	// INPUTS
	input wire sobel_en,
	input wire [2:0][2:0][7:0] comp_matrix,
	// OUTPUTS
	output reg output_pixel,
	output reg sobel_done
);

	reg signed [15:0] f1_x, f2_x, f3_x, f4_x;
	reg signed [15:0] f1_y, f2_y, f3_y, f4_y;
	reg unsigned [15:0] g1_x, g2_x, g3_x, g_x;
	reg unsigned [15:0] g1_y, g2_y, g3_y, g_y;
	reg unsigned [15:0] gradient;

	//reg signed [2:0][2:0][7:0] kernal_x = {{1, 0, -1},
					       //{2, 0, -2},
					       //{1, 0, -1}};

	//reg signed [2:0][2:0][7:0] kernal_y  = {{ 1,  2,  1},
					       // { 0,  0,  0},
					        //{-1, -2, -1}};
	always_comb begin
		f1_x = {8'b10000000, comp_matrix[2][0]};		// Mult -1
		f2_x = {7'b0000000, comp_matrix[1][2], 1'b0};	// Mult 2
		f3_x = {7'b1000000, comp_matrix[1][0], 1'b0};	// Mult -2
		f4_x = {8'b10000000, comp_matrix[0][0]};		// Mult -1

		f1_y = {7'b0000000, comp_matrix[2][1], 1'b0};    // Mult 2
		f2_y = {8'b10000000, comp_matrix[0][2]};		// Mult -1
		f3_y = {7'b1000000, comp_matrix[0][1], 1'b0};	// Mult -2
		f4_y = {8'b10000000, comp_matrix[0][0]};		// Mult -1

		g1_x = f1_x + f2_x;
		g2_x = f3_x + f4_x;
		g3_x = comp_matrix[2][2] + comp_matrix[0][2];
		g_x = g1_x + g2_x + g3_x;				// X Gradient

		g1_y = f1_y + f2_y;
		g2_y = f3_y + f4_y;
		g3_y = comp_matrix[2][0] + comp_matrix[2][2];
		g_y = g1_y + g2_y + g3_y;				// Y Gradient	

		gradient = g_x + g_y;	

		if(gradient > 16'd127) begin
			output_pixel = 1'b1;
		end else begin
			output_pixel = 1'b0;
		end
		sobel_done = 1;
	end
endmodule
