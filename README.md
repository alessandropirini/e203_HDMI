# HDMI Display IP

This directory contains the custom RTL developed for the HDMI display peripheral. The other project-specific logic is the firmware entry point in `firmware/hello_world/src/main.c` (the `firmware/src/main.c` file referred to in the report/request).

The design connects a Hummingbird/e203 CPU to an HDMI output on the Tang Primer 20K board. At reset it first shows vertical color bars, then switches to a character-display mode. In character mode the CPU receives UART characters, looks up their 16x16 bitmap rows in firmware, and writes those rows into this peripheral through a memory-mapped ICB register. The RTL stores the rows in dual-port RAM and scans them out as white/black pixels on a 1280x720 HDMI display.

| Project Information | Details |
| --- | --- |
| Contributors | Tommaso Calzolari, Alessandro Pirini |
| Course | Intelligent Chip Design |
| University | Tongji University |
| Location | Shanghai, China |
| Professor | Zhang Lei |
| Project Period | March 2024 - July 2024 |

## Main Files

- `icb_bus_HDMI.v`: memory-mapped ICB slave at `0x10014004`. Firmware writes 32-bit commands/data here, and the register output is forwarded to the HDMI IP.
- `address_gen.v`: decodes the 32-bit value written by firmware. The upper bits carry control flags for startup-text delete, backspace, enter, character positioning, and terminal mode. The row index and 16-bit bitmap row are converted into DPRAM write address/data.
- `HDMI.v`: generates the HDMI timing, startup color bars, display-enable signal, and DPRAM read address. In text mode it maps each DPRAM bit to black or white pixels. The 1280x720 implementation reuses the original 640x480-style character memory by expanding each character pixel over a 2x2 display area.
- `final.v`: top wrapper for the display path. It connects `address_gen`, the Gowin dual-port RAM, `HDMI_module`, the PLL/clock divider, and the Gowin `DVI_TX` block that emits TMDS clock/data pairs.
- `data.v`: simple data source used to test the display path without the CPU.
- `test_*.v` and `write_test.sv`: simulation benches used while developing the address generator, color bars, HDMI addressing, and CPU-to-display flow.
- `dvi_tx/`, `gowin_clkdiv/`, `gowin_dpb/`, and `gowin_dpb.v`: generated Gowin IP used by the final FPGA implementation.

## Firmware Interface

The firmware in `firmware/hello_world/src/main.c` reads UART data from the UART peripheral at base `0x10013000`, offset `0x004`. When a character is available, it indexes the bitmap table and writes sixteen 32-bit words to the HDMI register:

- bits `[19:16]`: bitmap row number from 0 to 15
- bits `[15:0]`: one 16-bit row of the selected character bitmap
- high control bits: optional flags used by `address_gen.v`

The firmware also writes the startup message, erases it when the first UART character arrives, supports enter/backspace behavior, and can set the initial character position using the character-position flag.

## Display Behavior

1. After reset, `HDMI.v` displays eight vertical color strips for the startup interval.
2. Firmware writes `Press any key to start` at a chosen character position.
3. On first UART input, firmware overwrites the startup text with spaces and resets the terminal write position.
4. Later UART characters are displayed from the top-left terminal area, with enter moving to the next character row and backspace overwriting the previous character cell.
5. `final.v` sends the RGB, sync, and data-enable signals through the Gowin DVI transmitter so the board can drive a 1280x720 HDMI display.
