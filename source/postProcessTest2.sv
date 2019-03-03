// $Id: $
// File name:   postProcessTest2.sv
// Created:     4/28/2017
// Author:      Pradyumna Modukuru
// Lab Section: 337-06
// Version:     1.0  Initial Design Entry
// Description: Test 2


module postProcessTest2();

	//init test array
	reg testarray[640 * 478];
	reg temparray[640 * 478];
	reg [7:0] pparray[80 * 480];
	reg [23:0] output2D [480][640];

	int i = 0;
	int row = 0;
	int col = 0;
	initial begin
		//init pparray
		for (i = 0; i < 80 * 480; i = i + 1)
		begin
			pparray[i] = -1;
		end

		//init testdata array
		for (i = 0; i < 640 * 478; i = i + 1)
		begin
			col = i % 640;

			//track row and col
			if (i != 0 && i % 640 == 0)
			begin
				row = row + 1;
				//col = 0;
			end

			//check even row
			if (row % 2 == 0 && (col == 639 | col == 638))
			begin
				testarray[i] = 0; //padding
			end
			else if (row % 2 == 1 && (col == 0 || col == 1))
			begin
				testarray[i] = 0; //padding
			end
			else begin
				testarray[i] = 1;
			end

		end

		$display("TESTARRAY DATA");
		for (i = 0; i < 10; i = i + 1)
		begin
		$display("Row %d", i);
		$display("Row %d first 2 bits %d", i, {testarray[i*640], testarray[i*640+1]} );
		$display("Row %d rand middle 2 bits: %d", i, {testarray[i*640 + 300], testarray[i*640 + 301]});
		$display("Row %d last 2 bits: %d", i, {testarray[i*640 + 638], testarray[i*640 + 639]} );
		end
		$display("\n");
		

		row = 0;
		col = 0;
		//init first and last 2 bits of each row
		for (i = 0; i < 640*478; i = i + 1) 
		begin
			col = i % 640;

			//track row and col
			if (i != 0 && i % 640 == 0)
			begin
				row = row + 1;
				//col = 0;
			end

			//init first and last bits of each row to 0
			if (col == 0)
			begin
				temparray[i] = 0;
				temparray[i+1] = 0;
			end
			else if (col == 639)
			begin
				temparray[i] = 0;
				temparray[i-1] = 0;
			end
			
		end

		$display("TEMPARRAY DATA 1");
		for (i = 0; i < 10; i = i + 1)
		begin
		$display("Row %d", i);
		$display("Row %d first 2 bits %d", i, {temparray[i*640], temparray[i*640+1]} );
		$display("Row %d rand middle 2 bits: %d", i, {temparray[i*640 + 300], temparray[i*640 + 301]});
		$display("Row %d last 2 bits: %d", i, {temparray[i*640 + 638], temparray[i*640 + 639]} );
		end
		$display("\n");

		row = 0;
		col = 0;
		//copy and format testdata
		for (i = 0; i < 640*478; i = i + 1) 
		begin
			col = i % 640;

			//track row and col
			if (i != 0 && i % 640 == 0)
			begin
				row = row + 1;
				//col = 0;
			end
			
			if (row % 2 == 0)
			begin
				if (col != 639 || col != 638) begin
					temparray[i+1] = testarray[i];
				end

			end
			else if (row % 2 == 1)
			begin
				if (col != 0 || col != 1)
				begin
					temparray[i-1] = testarray[i];
				end
			end
			
		end

		$display("TEMPARRAY DATA");
		for (i = 0; i < 10; i = i + 1)
		begin
		$display("Row %d", i);
		$display("Row %d first 2 bits %d", i, {temparray[i*640], temparray[i*640+1]} );
		$display("Row %d rand middle 2 bits: %d", i, {temparray[i*640 + 300], temparray[i*640 + 301]});
		$display("Row %d last 2 bits: %d", i, {temparray[i*640 + 638], temparray[i*640 + 639]} );
		end
		$display("\n");

/*
		//put into final array

		//add top border to pparray
		for (i = 0; i < 80; i = i + 1) 
		begin
			pparray[i] = 0;
		end

		for (i = 80; i < 80 * 479; i = i + 1)
		begin
			pparray[i] = {temparray[(i-80)*8], temparray[(i-80)*8 + 1], temparray[(i-80)*8 + 2], temparray[(i-80)*8 + 3], temparray[(i-80)*8 + 4], temparray[(i-80)*8 + 5], temparray[(i-80)*8 + 6], temparray[(i-80)*8 + 7]};
 		end 

		//pad last row with 0 (border)
		for (i = 80*479; i < 80*480; i = i + 1) 
		begin
			pparray[i] = 0;
		end

		for (i = 0; i < 10; i = i + 1)
		begin
		$display("Row %d", i);
		$display("Row %d first byte: %d", i, pparray[i*80]);
		$display("Row %d rand middle byte: %d", i, pparray[i*80 + 40]);
		$display("Row %d last byte: %d", i, pparray[i*80 + 79]);
		end

		$display("Row %d", 479);
		$display("Row %d first byte: %d", i, pparray[80*479]);
		$display("Row %d rand middle byte: %d", i, pparray[80*479 + 40]);
		$display("Row %d last byte: %d", i, pparray[80*479 + 79]);*/
		
		//output 24 bit wide 2D array

		//add 0 border to top of image
		row = 0;
		for (col = 0; col < 640; col = col + 1) begin
			output2D[row][col] = 24'd0;
		end

		//copy in image data in 24 bit format
		row = 0;
		col = 0;

		for (row = 1; row < 480; row = row + 1) begin
			for (col = 0; col < 640; col = col + 1) begin
				if (temparray[row*640 + col] == 1)
				begin
					output2D[row][col] = 24'b11111111111111111111111111111111;
				end
				else if (temparray[row*640 + col] == 0)
				begin
					output2D[row][col] = 24'b00000000000000000000000000000000;
				end
			end
		end

		//add 0 border to bottom of image
		row = 479;
		for (col = 0; col < 640; col = col + 1) begin
			output2D[row][col] = 24'd0;
		end
		
		$display("OUTPUT2D DATA");
		for (i = 0; i < 10; i = i + 1)
		begin
		$display("Row %d", i);
		$display("Row %d first 24 bits: %b", i, output2D[i][0]);
		$display("Row %d rand middle 24 bits: %b", i, output2D[i][300]);
		$display("Row %d last 24 bits: %b", i, output2D[i][639]);
		end

		i = 479;
		$display("Row %d", i);
		$display("Row %d first 24 bits: %b", i, output2D[i][0]);
		$display("Row %d rand middle 24 bits: %b", i, output2D[i][300]);
		$display("Row %d last 24 bits: %b", i, output2D[i][639]);

	end
endmodule
