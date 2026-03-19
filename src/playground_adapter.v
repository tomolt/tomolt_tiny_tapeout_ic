/* 
 * Copyright (c) 2026 Thomas Oltmann
 * SPDX-License-Identifier: Apache-2.0
 * vim: sts=2 ts=2 sw=2 et
 */

`include "hvsync_generator.v"
`include "triscan.v"
`include "rasterizer.v"
`include "serial_div.v"

/* Use this module as the main module if you want to simulate this project
 * with the Verilog VGA playground hosted at https://8bitworkshop.com .
 */
module playground_adapter (
  input wire clk,
  input wire reset,
  output wire hsync,
  output wire vsync,
  output wire [2:0] rgb
);

  wire rst_n = !reset;
  wire [7:0] ui_in = 0;
  wire [7:0] uo_out;
  wire [7:0] uio_in = 0;
  wire [7:0] uio_out;
  wire [7:0] uio_oe = 0;
  wire ena = 1;
  
  tt_um_tomolt_rasterizer rasterizer(
    .clk(clk),
    .rst_n(rst_n),
    .ena(ena),
    .ui_in(ui_in),
    .uo_out(uo_out),
    .uio_in(uio_in),
    .uio_out(uio_out),
    .uio_oe(uio_oe)
  );

  assign hsync = uo_out[7];
  assign vsync = uo_out[3];
  assign rgb = uo_out[2:0];

endmodule

