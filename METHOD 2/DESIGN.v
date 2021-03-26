`timescale 1ns / 1ps

interface dut_if;
  logic [31:0]PRDATA;
  logic PREADY;
  logic [31:0]PWDATA;
  logic PWRITE;
  logic PSEL;
  logic PENABLE;
  logic [31:0]PADDR;
  logic PCLK;
  logic PRESETn;
  endinterface

module APB_module(dut_if d_if);

reg [31:0]memory[1023:0];                                      
// [(width-1):1]memory[(depth-1):0]

reg [1:0]state;   															 
// Becoz -> 1(00)> IDLE  2(01)> SETUP  3(10)>ACCESS

parameter IDLE=2'b00;
parameter SETUP=2'b01;
parameter ACCESS=2'b10;

  always @(posedge d_if.PCLK or negedge d_if.PRESETn)
begin

  if(d_if.PRESETn==1'b0)
	begin
		d_if.PREADY <= 1'b1;
		state <= IDLE;
	end
  else if(d_if.PRESETn==1'b1)
	begin
		case(state)
			IDLE :begin 
              if(d_if.PSEL==1'b0 && d_if.PENABLE==1'b0)  
// PSELECT may be anything but if PENABLE is not active nothing process will be done Afterwards.
							state<=IDLE;
              else if(d_if.PSEL==1'b1 && (d_if.PENABLE==1'b1 || d_if.PENABLE==1'b0))
							state<=SETUP;
						else
							state<=IDLE;
					end
	
			SETUP :begin 
						if(d_if.PSEL==1'b1 && d_if.PENABLE==1'b1 && d_if.PREADY==1'b1)
						begin
							if(d_if.PWRITE)
								memory[d_if.PADDR]<=d_if.PWDATA;
							else
								d_if.PRDATA<=memory[d_if.PADDR];
							state<=ACCESS;
						end
						else if(d_if.PSEL==1'b1 && d_if.PENABLE==1'b0)
							state<=SETUP;
						else if(d_if.PSEL==1'b0)
							state<=IDLE;
					 end
						
			ACCESS :begin
						if(d_if.PREADY==1'b1 && d_if.PSEL==1'b0 && d_if.PENABLE==1'b0)
							state<=IDLE;
						else if(d_if.PREADY==1'b1 && d_if.PSEL==1'b1 && d_if.PENABLE==1'b0)
							state<=SETUP;  
						else if(d_if.PREADY==1'b1 && d_if.PSEL==1'b1 && d_if.PENABLE==1'b0)
							state<=IDLE;
					 end
		endcase
	end
end
endmodule
