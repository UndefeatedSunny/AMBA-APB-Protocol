`timescale 1ns / 1ps

module APB;

  dut_if dut();

	// Instantiate the Unit Under Test (UUT)
	APB_module uut (.d_if(dut));
	initial 
      begin
        $dumpfile("dump.vcd"); 
        $dumpvars;
      end
	initial 
      begin
		// Initialize Inputs
		dut.PWDATA = 0;
		dut.PWRITE = 0;
		dut.PSEL = 0;
		dut.PENABLE = 0;
		dut.PADDR = 0;
		dut.PCLK = 0;
		dut.PRESETn = 0;
      end
      
	always #5 dut.PCLK =~ dut.PCLK;
	
	initial 
      begin
        @(posedge dut.PCLK);
        @(posedge dut.PCLK);

        dut.PWDATA = 123;
        dut.PWRITE = 1;
        dut.PSEL = 1;
        dut.PADDR = 500;
        dut.PRESETn = 1;

        @(posedge dut.PCLK);
        dut.PENABLE = 1;

        @(posedge dut.PCLK);
        dut.PWRITE = 0;
        dut.PENABLE = 0;

        @(posedge dut.PCLK);
        dut.PENABLE = 1;	


        #10 $finish;
      end
endmodule
