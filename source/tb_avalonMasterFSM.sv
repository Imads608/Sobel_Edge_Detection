// $Id: $
// File name:   tb_avalonMasterFSM.sv
// Created:     4/13/2017
// Author:      Nivedita Nighojkar
// Lab Section: 337-006
// Version:     1.0  Initial Design Entry
// Description: master test bench for avalon

`timescale 1ns / 10ps
module tb_avalonMasterFSM();
	localparam CLK_PERIOD	= 2.5;
	//input declarations
	reg tb_clk, tb_n_rst; 
	reg [31:0] tb_readdata;
	
	//module test data inputs
	reg tb_readen, tb_writen;
	reg [31:0] tb_wdata, tb_inaddr;

	//module test data outputs
	reg tb_read, tb_write, tb_dataready;
	reg [31:0] tb_address, tb_writedata;

	//expected output declarations
	reg exp_read, exp_write, exp_dataready;
	reg [31:0] exp_address, exp_writedata;
	reg [31:0] exp_readdata;

	//clock generation
	always begin
		tb_clk = 1'b0;
		#(CLK_PERIOD / 2.0);
		tb_clk = 1'b1;
		#(CLK_PERIOD/2.0);
	end

	//portmap
	avalonMasterFSM MASTER(   .clk(tb_clk),
				.n_rst(tb_n_rst),
				.write(tb_write),
				.read(tb_read),
				.address(tb_address),
				.writedata(tb_writedata),
				.readdata(tb_readdata),
				.readen(tb_readen),
				.writen(tb_writen),
				.wdata(tb_wdata),
				.inaddr(tb_inaddr),	
				.dataready(tb_dataready) );

	int i = 0;
	int index = 0;

	reg [31:0] testAddr;
	//initialize an array
	reg [7:0] testarray[10];

	initial begin
		//initializations

		//init test array
		for (index = 0; index < 10; index = index + 1) begin
			testarray[index] = (index+1) << 2;
		end

		//print testarray
		for (index = 0; index < 10; index = index + 1) begin
			$info("Testarray %d: %d", index, testarray[index]);
		end

		//inputs
		tb_n_rst = 0;
		tb_readen = 0;
		tb_writen = 0;
		tb_readdata = 0;
		tb_wdata = 0;
		tb_inaddr = 0;

		testAddr = 0;
		
		//outputs
		tb_read = 0;
		tb_write = 0;
		tb_dataready = 0;
		tb_address = 0;
		tb_writedata = 0;

		//expected
		exp_read = 0;
		exp_write = 0;
		exp_dataready = 0;
		exp_address = 0;
		exp_writedata = 0;

		//test case 1: test reset
		i = i + 1;
		$info("Test Case %d\n", i);
		#CLK_PERIOD
		tb_n_rst = 1'b0;
		exp_read = 0;
		exp_write = 0;
		exp_dataready = 0;
		exp_address = 0;
		exp_writedata = 0;
		exp_readdata = testarray[testAddr[30:0]];

		#CLK_PERIOD
		#CLK_PERIOD

		//test tb_read
		if (exp_read == tb_read) begin
			$info("Test case %d read passed",i);
		end
		else begin
			$error("Test case %d read failed",i);
		end
		//test tb_write
		if (exp_write == tb_write) begin
			$info("Test case %d write passed",i);
		end
		else begin
			$error("Test case %d write failed",i);
		end
		//test tb_dataready
		if (exp_dataready == tb_dataready) begin
			$info("Test case %d dataready passed",i);
		end
		else begin
			$error("Test case %d dataready failed",i);
		end
		//test tb_address
		if (exp_address == tb_address) begin
			$info("Test case %d address passed",i);
		end
		else begin
			$error("Test case %d address failed",i);
		end
		//test tb_writedata
		if (exp_writedata == tb_writedata) begin
			$info("Test case %d writedata passed",i);
		end
		else begin
			$error("Test case %d writedata failed",i);
		end
		//test tb_readdata
		if (exp_readdata == tb_readdata) begin
			$info("Test case %d readdata passed",i);
		end
		else begin
			$error("Test case %d readdata failed",i);
		end


		//test case 2: test read from addr
		i = i + 1;
		$info("Test Case %d\n", i);
		#CLK_PERIOD
		
		//inputs
		tb_n_rst = 1'b1;
		tb_readen = 1;
		tb_writen = 0;
		//tb_readdata = 32'd1000;
		tb_wdata = 0;
		tb_inaddr = testAddr;
		
		//expected outputs
		exp_read = 1;
		exp_write = 0;
		exp_dataready = 1;
		exp_address = testAddr;
		exp_writedata = 0;

		#CLK_PERIOD
		
		tb_readen = 0;
		
		#CLK_PERIOD

		//read from input image array (testArray)
		if (tb_address[31] == 0 && tb_read == 1) begin
			tb_readdata = testarray[testAddr[30:0]];
		end
		else begin
			tb_readdata = -1;
		end

		//test read
		if (exp_read == tb_read) begin
			$info("Test case %d read passed",i);
		end
		else begin
			$error("Test case %d read failed",i);
		end
		//test write
		if (exp_write == tb_write) begin
			$info("Test case %d write passed",i);
		end
		else begin
			$error("Test case %d write failed",i);
		end
		//test dataready
		if (exp_dataready == tb_dataready) begin
			$info("Test case %d dataready passed",i);
		end
		else begin
			$error("Test case %d dataready failed",i);
		end
		//test address
		if (exp_address == tb_address) begin
			$info("Test case %d address passed",i);
		end
		else begin
			$error("Test case %d address failed",i);
		end
		//test writedata
		if (exp_writedata == tb_writedata) begin
			$info("Test case %d writedata passed",i);
		end
		else begin
			$error("Test case %d writedata failed",i);
		end
		//test tb_readdata
		if (exp_readdata == tb_readdata) begin
			$info("Test case %d readdata passed",i);
		end
		else begin
			$error("Test case %d readdata failed",i);
		end


		for (index = 0; index < 9; index = index + 1)
		begin 
		//test case 3: test read from addr
		i = i + 1;
		testAddr = testAddr + 1;
		$info("Test Case %d\n", i);
		#CLK_PERIOD
		#CLK_PERIOD
		//#CLK_PERIOD
		
		//inputs
		tb_n_rst = 1'b1;
		tb_readen = 1;
		tb_writen = 0;
		//tb_readdata = 32'd1000;
		tb_wdata = 0;
		tb_inaddr = testAddr;
		
		//expected outputs
		exp_read = 1;
		exp_write = 0;
		exp_dataready = 1;
		exp_address = testAddr;
		exp_writedata = 0;
		exp_readdata = 8;

		#CLK_PERIOD

		tb_readen = 0;

		#CLK_PERIOD

		//read from input image array (testArray)
		if (tb_address[31] == 0 && tb_read == 1) begin
			tb_readdata = testarray[testAddr[30:0]];
		end
		else begin
			tb_readdata = -1;
		end

		//test read
		if (exp_read == tb_read) begin
			$info("Test case %d read passed",i);
		end
		else begin
			$error("Test case %d read failed",i);
		end
		//test write
		if (exp_write == tb_write) begin
			$info("Test case %d write passed",i);
		end
		else begin
			$error("Test case %d write failed",i);
		end
		//test dataready
		if (exp_dataready == tb_dataready) begin
			$info("Test case %d dataready passed",i);
		end
		else begin
			$error("Test case %d dataready failed",i);
		end
		//test address
		if (exp_address == tb_address) begin
			$info("Test case %d address passed",i);
		end
		else begin
			$error("Test case %d address failed",i);
		end
		//test writedata
		if (exp_writedata == tb_writedata) begin
			$info("Test case %d writedata passed",i);
		end
		else begin
			$error("Test case %d writedata failed",i);
		end
		//test tb_readdata
		if (exp_readdata == tb_readdata) begin
			$info("Test case %d readdata passed",i);
		end
		else begin
			$error("Test case %d readdata failed",i);
		end

		end


	end

endmodule
