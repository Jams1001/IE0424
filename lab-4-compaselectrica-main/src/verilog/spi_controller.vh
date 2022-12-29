// SPI controller module
// Eleonora Chacon Taylor

// sequencer FSM states
`define WRITE_1 3'b001
`define READ_1  3'b101
`define READ_2  3'b110

// SPI controller FSM states

`define IDLE    3'b000
`define INST    3'b001
`define ADDR    3'b010
`define WDATA   3'b110
`define RDATA   3'b101
`define COMP    3'b100

// SPI commands for ADXL362

`define READ_CMD  8'h0B
`define WRITE_CMD 8'h0A

// SPI addresses on ADXL362
`define DEVID_ID        8'h00
`define DEVID_MST       8'h01
`define PARTID          8'h02
`define XDATA           8'h08
`define YDATA           8'h09
`define ZDATA           8'h0A
`define STATUS          8'h0B
`define ACT_INACT_CTL   8'h27
`define FILTER_CTL      8'h2C
`define POWER_CTL       8'h2D
