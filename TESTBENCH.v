`timescale 1ns / 1ps

module APB;
	reg [31:0] PWDATA;
	reg PWRITE;
	reg PSEL;
	reg PENABLE;
	reg [31:0] PADDR;
	reg PCLK;
	reg PRESETn;
	wire [31:0] PRDATA;
	wire PREADY;
  
  reg [31:0]array[]; // (Dynamic)
  reg [31:0]expected_data[];  //Expected for check purpose
  integer i;
  reg [1:8*30] user_in;
  integer t_count=0;
  integer m_count=0;
  
  integer No_of_loc;
  
  APB_module dut (.PRDATA(PRDATA),.PREADY(PREADY),.PWDATA(PWDATA),.PWRITE(PWRITE),.PSEL(PSEL),.PENABLE(PENABLE),.PADDR(PADDR),.PCLK(PCLK), .PRESETn(PRESETn));

	initial begin
      $dumpfile("dump.vcd"); $dumpvars();
    end
  initial begin
    PCLK=0;
    forever #5 PCLK = ~ PCLK;
  end
  
  initial begin 
    PRESETn=1'b0;
    #10 PRESETn=1'b1;
  end
  
  task idle();
		PWDATA = 0;
		PWRITE = 0;
		PSEL = 0;
		PENABLE = 0;
		PADDR = 0;
  endtask
  
  task write(input integer NUM);
    array=new[NUM];
    expected_data=new[NUM];
    for(i=0; i<NUM; i=i+1)begin
      
     @(negedge PCLK);
     PADDR=$urandom_range(0,1023);
     PWDATA=$random;;
     PSEL=1;
     PWRITE=1;
     PENABLE=0;
      @(negedge PCLK);
     PENABLE=1;
     wait(PREADY);
      array[i]=PADDR;  // So the we can fetch it later
      expected_data[i]=PWDATA;
	end
 endtask
  
  task read(input integer NUM);
    for(i=0; i<NUM; i=i+1)begin
        PWRITE=0;
        PADDR=array[i];
        PENABLE=0;
        PSEL=1;
        @(negedge PCLK);
		 PENABLE=1;
        @(negedge PCLK);
      wait(PREADY);
      $display("PRDATA=%x , EXPECTED_DATA=%x",PRDATA,expected_data[i]);
      check(PRDATA,expected_data[i]);
	 end
    endtask

  
  initial begin
	 PRESETn=0;
	 repeat(1)@(posedge PCLK);
  	 idle();
     repeat(1)@(posedge PCLK);
	 PRESETn=1;

    $value$plusargs("testname=%s",user_in);
	
    case(user_in)

		 "single_wr":begin
			 write(1);

		 end
		 "multiple_wr":begin
			 write(10);
		 end
		 "single_wr_rd":begin
           write(1);
           repeat(2) @(negedge PCLK);
           read(1);
		 end
       
		 "multiple_wr_rd":begin
           idle();
           No_of_loc=$urandom_range(6,20);
           write(No_of_loc);
           repeat(2) @(negedge PCLK);
           read(No_of_loc);
		 end
	 endcase
 end
  
    
  task check(reg [31:0]x1, reg[31:0]x2);
    t_count++;
    if(x1==x2)
      begin
        $display("TEST PASS");
               m_count++;
               end
               else
                 $display("TEST FAIL");
                          endtask
  
  
  
 initial 
   begin
	#200;
     foreach (expected_data[i])     // METHOD-1
     begin
       $display("Expected Data=%x",expected_data[i]);
     end

     for(int i=0;i<$size(expected_data);i++)             // METHOD-2
       $display("EXPECTED DATA = %x",expected_data[i]);

     $display("Total TestCase=%x, Matched TestCase=%x",t_count,m_count);

     $finish;
  end 
endmodule
