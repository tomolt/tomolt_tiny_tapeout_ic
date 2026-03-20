/*
* Copyright (c) 2026 Thomas Oltmann
* SPDX-License-Identifier: Apache-2.0
* vim: sts=2 ts=2 sw=2 et
*/

module serial_div #(parameter WIDTH = 10) (
  input wire clk,
  input wire load,
  input wire [2*WIDTH-1:0] num,
  input wire [WIDTH-1:0] den,
  output reg [WIDTH-1:0] quo,
  output wire [WIDTH-1:0] rem);

  reg [4:0] state;
  reg [2*WIDTH-1:0] accum;

  assign rem = accum[WIDTH-1:0];

  wire next_bit = num[2*WIDTH-1-state];

  wire [2*WIDTH-1:0] next_accum = {accum[2*WIDTH-2:0], next_bit};

  always @(posedge clk) begin
    if (load) begin
      accum <= 0;
      quo   <= 0;
      state <= 0;
    end else begin
      if (state < 2*WIDTH) begin
        if (next_accum >= den) begin
          accum <= next_accum - {{WIDTH{1'b0}}, den};
          quo <= {quo[WIDTH-2:0], 1'b1};
        end else begin
          accum <= next_accum;
          quo <= {quo[WIDTH-2:0], 1'b0};
        end
        state <= state + 1;
      end
    end
  end

endmodule

