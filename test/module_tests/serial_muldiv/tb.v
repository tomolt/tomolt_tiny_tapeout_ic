`default_nettype none
`timescale 1ns / 1ps

/* This testbench just instantiates the module and makes some convenient wires
   that can be driven / tested by the cocotb test.py.
*/
module tb ();

  // Dump the signals to a FST file. You can view it with gtkwave or surfer.
  initial begin
    $dumpfile("tb.fst");
    $dumpvars(0, tb);
    #1;
  end

  localparam WIDTH = 10;

  // Wire up the inputs and outputs:
  reg clk;
  reg load;
  reg [WIDTH-1:0] mu1;
  reg [WIDTH-1:0] mu2;
  reg [WIDTH-1:0] den;
  wire [WIDTH-1:0] quo;
  wire [WIDTH-1:0] rem;

  serial_muldiv #(.WIDTH(WIDTH)) serial_muldiv (
	  .clk(clk),
	  .load(load),
	  .mu1(mu1),
	  .mu2(mu2),
	  .den(den),
	  .quo(quo),
	  .rem(rem)
  );

endmodule
