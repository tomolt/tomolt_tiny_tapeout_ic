/* 
 * Copyright (c) 2026 Thomas Oltmann
 * SPDX-License-Identifier: Apache-2.0
 * vim: sts=2 ts=2 sw=2 et
 */

`default_nettype none

module tt_um_tomolt_rasterizer (
  input  wire [7:0] ui_in,    // Dedicated inputs
  output wire [7:0] uo_out,   // Dedicated outputs
  input  wire [7:0] uio_in,   // IOs: Input path
  output wire [7:0] uio_out,  // IOs: Output path
  output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
  input  wire       ena,      // always 1 when the design is powered, so you can ignore it
  input  wire       clk,      // clock
  input  wire       rst_n     // reset_n - low to reset
);

  wire hsync;
  wire vsync;
  wire display_on;
  wire [9:0] hpos;
  wire [9:0] vpos;
  wire hvreset = ~rst_n;

  hvsync_generator hvsync_gen(
    .clk(clk),
    .reset(hvreset),
    .hsync(hsync),
    .vsync(vsync),
    .display_on(display_on),
    .hpos(hpos),
    .vpos(vpos)
  );

  wire [23:0] default_vgeometry = {
    4'd4, 4'd2,
    4'd2, 4'd5,
    4'd9, 4'd3
  };

  wire [5:0] default_color = 6'b000011;

`define SERIAL_GEOMETRY 1
`ifdef SERIAL_GEOMETRY
  reg [23:0] vgeometry;
  reg [5:0] color;

  wire [59:0] geometry = {
    vgeometry[23:20], 6'd0, 
    vgeometry[19:16], 6'd0, 
    vgeometry[15:12], 6'd0, 
    vgeometry[11: 8], 6'd0, 
    vgeometry[ 7: 4], 6'd0, 
    vgeometry[ 3: 0], 6'd0
  };

  localparam
    SERIAL_V1X = 3'b000,
    SERIAL_V1Y = 3'b001,
    SERIAL_V2X = 3'b010,
    SERIAL_V2Y = 3'b011,
    SERIAL_V3X = 3'b100,
    SERIAL_V3Y = 3'b101,
    SERIAL_COL = 3'b110;

  wire cs_n = uio_in[0];
  wire mosi = uio_in[1];
  wire sck  = uio_in[3];

  reg [2:0] serial_state;
  reg [3:0] serial_count;

  reg sck_prev;

  always @(negedge rst_n or posedge clk) begin
    if (~rst_n) begin
      vgeometry <= default_vgeometry;
      color <= default_color;
      sck_prev <= 0;
      serial_state <= SERIAL_V1X;
      serial_count <= 0;

    end else begin
      if (~cs_n) begin

        if (~sck_prev && sck) begin
          // Handling 'geometry' as one big shift register causes the PDK
          // to insert an excessive number of delay buffers and eventually
          // fail the timing checks. So instead, we treat every 10-bit word
          // as its own little shift register.
          case (serial_state)
            SERIAL_V1X: vgeometry[23:20] <= {vgeometry[23-1:20], mosi};
            SERIAL_V1Y: vgeometry[19:16] <= {vgeometry[19-1:16], mosi};
            SERIAL_V2X: vgeometry[15:12] <= {vgeometry[15-1:12], mosi};
            SERIAL_V2Y: vgeometry[11: 8] <= {vgeometry[11-1: 8], mosi};
            SERIAL_V3X: vgeometry[ 7: 4] <= {vgeometry[ 7-1: 4], mosi};
            SERIAL_V3Y: vgeometry[ 3: 0] <= {vgeometry[ 3-1: 0], mosi};
            SERIAL_COL: color <= {color[5-1:0], mosi};
            default:;
          endcase

          if (serial_count == 9) begin
            if (serial_state == SERIAL_COL) begin
              serial_state <= SERIAL_V1X;
            end else begin
              serial_state <= serial_state + 1;
            end
            serial_count <= 0;
          end else begin
            serial_count <= serial_count + 1;
          end
        end
        sck_prev <= sck;

      end else begin
        sck_prev <= 0;
        serial_state <= SERIAL_V1X;
        serial_count <= 0;
      end
    end
  end
`else
  wire [59:0] geometry = default_geometry;
  wire [5:0] color = default_color;
`endif

  /*
  reg [4:0] permut_1;
  reg [4:0] permut_2;

  reg permut_1_dir;
  reg permut_2_dir;

  // Animate the geometry just a tiny bit to make it more interesting.
  always @(posedge vsync or negedge rst_n) begin
    if (~rst_n) begin
      permut_1 <= 0;
      permut_1_dir <= 1;
      permut_2 <= 0;
      permut_2_dir <= 1;
    end else begin
      if (permut_1_dir) begin
        if (permut_1 == 5'b11111) begin
          permut_1_dir <= 0;
        end else begin
          permut_1 <= permut_1 + 1;
        end
      end else begin
        if (permut_1 == 5'b00000) begin
          permut_1_dir <= 1;
        end else begin
          permut_1 <= permut_1 - 1;
        end
      end

      if (permut_2_dir) begin
        if (permut_2 == 5'b11101) begin
          permut_2_dir <= 0;
        end else begin
          permut_2 <= permut_2 + 1;
        end
      end else begin
        if (permut_2 == 5'b00001) begin
          permut_2_dir <= 1;
        end else begin
          permut_2 <= permut_2 - 1;
        end
      end
    end
  end
  */

  /*
  wire [59:0] geometry_1 = {
    10'd100 + {6'b000000, permut_1[4:1]}, 10'd1,
    10'd150 + {5'b00000, permut_2}, 10'd100,
    10'd200, 10'd60 + {5'b00000, permut_1}
  };
  */

 /*
  wire [59:0] geometry_1 = {
    10'd100, 10'd1,
    10'd150, 10'd100,
    10'd200, 10'd60
  };

  wire [59:0] geometry_3 = {
    10'd300, 10'd350,
    10'd150, 10'd400,
    10'd250, 10'd440
  };

  reg [2:0] geometry_sel;

  always @(posedge clk) begin
    if (hpos == 640) begin
      if (vpos+1 < geometry_2[49:40]) begin
        geometry_sel <= 3'b001;
        geometry <= geometry_1;
      end else if (vpos+1 < geometry_3[49:40]) begin
        geometry_sel <= 3'b010;
        geometry <= geometry_2;
      end else begin
        geometry_sel <= 3'b100;
        geometry <= geometry_3;
      end
    end
  end
  */

  wire fill;

  triscan tscan(
    .clk(clk),
    .rst_n(rst_n),
    .hpos(hpos),
    .vpos(vpos),
    .geometry(geometry),
    .fill(fill)
  );

  wire [5:0] pixel = (display_on && fill) ? color : 6'b000000;

  // TinyVGA PMOD
  assign uo_out[0] = pixel[1];
  assign uo_out[1] = pixel[3];
  assign uo_out[2] = pixel[5];
  assign uo_out[3] = vsync;
  assign uo_out[4] = pixel[0];
  assign uo_out[5] = pixel[2];
  assign uo_out[6] = pixel[4];
  assign uo_out[7] = hsync;

  // Unused outputs assigned to 0.
  assign uio_out = 0;

  // Configure all UIO pins as inputs.
  assign uio_oe  = 0;

  // Suppress unused signals warning
  wire _unused_ok = &{ena, ui_in, uio_in};

endmodule

