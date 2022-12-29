`timescale 1 ns / 1 ps
`include "memory.v"
`include "cache_2_way_random.v"
`include "cache_LRU.v"

module system (
	input            clk,
	input            resetn,
	output           trap,
	output reg [7:0] out_byte,
	output reg       out_byte_en
);
	// Set this to 0 for better timing but less performance/MHz
	parameter FAST_MEMORY = 0; // Se cambia a cero para el ejercico 2

	// 4096 32bit words = 16kB memory
	parameter MEM_SIZE = 65536;

	wire mem_la_read;
	wire mem_la_write;
	wire [31:0] mem_la_addr;
	wire [31:0] mem_la_wdata;
	wire [3:0] mem_la_wstrb;

	// Picorv (p)
	wire mem_valid_p;
	wire mem_instr_p;
	wire mem_ready_p;
	wire [31:0] mem_addr_p;
	wire [31:0] mem_wdata_p;
	wire [3:0] mem_wstrb_p;
	wire [31:0] mem_rdata_p;

	// Memoria (m)
	wire mem_valid_m;
	wire mem_instr_m;
	wire mem_ready_m;
	wire [31:0] mem_addr_m;
	wire [31:0] mem_wdata_m;
	wire [3:0] mem_wstrb_m;
	wire [31:0] mem_rdata_m;

	picorv32 picorv32_core (
		.clk         (clk         ),
		.resetn      (resetn      ),
		.trap        (trap        ),
		.mem_valid   (mem_valid_p ),
		.mem_instr   (mem_instr_p ),
		.mem_ready   (mem_ready_p ),
		.mem_addr    (mem_addr_p  ),
		.mem_wdata   (mem_wdata_p ),
		.mem_wstrb   (mem_wstrb_p ),
		.mem_rdata   (mem_rdata_p ),
		.mem_la_read (mem_la_read ),
		.mem_la_write(mem_la_write),
		.mem_la_addr (mem_la_addr ),
		.mem_la_wdata(mem_la_wdata),
		.mem_la_wstrb(mem_la_wstrb)
	);

	// Ejercicio 3
	memory memory_1(
    .clk		 	(clk),
	.resetn		 	(resetn),
	.mem_valid	 	(mem_valid_m),
    .mem_instr	 	(mem_instr_m),
	.mem_addr	 	(mem_addr_m),
	.mem_wdata	 	(mem_wdata_m),
    .mem_wstrb	 	(mem_wstrb_m),
	.mem_ready	 	(mem_ready_m),
    .mem_rdata	 	(mem_rdata_m),
	.mem_la_addr 	(mem_la_addr),
	.mem_la_write 	(mem_la_write),
    .mem_la_wstrb 	(mem_la_wstrb),
	.mem_la_wdata 	(mem_la_wdata),
	.out_byte_en 	(wout_byte_en),
	.out_byte	 	(wout_byte),
	.number		 	(number)
	);

	cache_LRU cache_2_way_random_1(
	//Inputs
    .clk		 	(clk),
	.resetn		 	(resetn),
	.mem_valid	 	(mem_valid_p),
	.mem_instr	 	(mem_instr_p),
	.mem_addr	 	(mem_addr_p),
	.mem_wdata	 	(mem_wdata_p),
	.mem_wstrb	 	(mem_wstrb_p),
	.mem_ready_m	 	(mem_ready_m),
	.mem_rdata_m	 	(mem_rdata_m),


	//Outputs
	.mem_ready	 	(mem_ready_p),
  	.mem_rdata	 	(mem_rdata_p),
	.mem_valid_m    (mem_valid_m),
	.mem_instr_m    (mem_instr_m),
	.mem_addr_m 	(mem_addr_m ),
	.mem_wdata_m 	(mem_wdata_m),
	.mem_wstrb_m 	(mem_wstrb_m)
	);

endmodule
