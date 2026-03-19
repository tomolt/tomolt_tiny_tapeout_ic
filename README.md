![](../../workflows/gds/badge.svg) ![](../../workflows/docs/badge.svg) ![](../../workflows/test/badge.svg) ![](../../workflows/fpga/badge.svg)

# Thomas Oltmann's Tiny Triangle Rasterizer

A crude hardware realization of a triangle rasterizer, outputting VGA signals.

Intended to be used with the TinyVGA PMOD adapter, as it is sold in the TinyTapeout shop.

## Testing / Simulating

Some submodules are tested separately with cocotb.
These tests can be found under `tests/module_tests`.
Simply run `make` in the directory.

The whole project can also be uploaded to the Verilog VGA playground hosted at (8bitworkshop.com)[https://8bitworkshop.com].
In the playground, the module `playground_adapter` must be selected as your main module.
This module is not present on the ASIC.
