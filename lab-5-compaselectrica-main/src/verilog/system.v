// Ejercicio 1
/*
`timescale 1 ns / 1 ps
`include "seven_segment_hex.v"

module system (
	input            clk,
	input            resetn,
	output           trap,
	output reg [7:0] out_byte,
	output reg       out_byte_en,
	output 	[7:0]		catodos, 
	output 	[7:0]		anodos
);
	// set this to 0 for better timing but less performance/MHz
	parameter FAST_MEMORY = 1;

	// 4096 32bit words = 16kB memory
	parameter MEM_SIZE = 65536;

	wire mem_valid;
	wire mem_instr;
	reg mem_ready;
	wire [31:0] mem_addr;
	wire [31:0] mem_wdata;
	wire [3:0] mem_wstrb;
	reg [31:0] mem_rdata;

	wire mem_la_read;
	wire mem_la_write;
	wire [31:0] mem_la_addr;
	wire [31:0] mem_la_wdata;
	wire [3:0] mem_la_wstrb;
	reg [31:0] number;

	picorv32 picorv32_core (
		.clk         (clk         ),
		.resetn      (resetn      ),
		.trap        (trap        ),
		.mem_valid   (mem_valid   ),
		.mem_instr   (mem_instr   ),
		.mem_ready   (mem_ready   ),
		.mem_addr    (mem_addr    ),
		.mem_wdata   (mem_wdata   ),
		.mem_wstrb   (mem_wstrb   ),
		.mem_rdata   (mem_rdata   ),
		.mem_la_read (mem_la_read ),
		.mem_la_write(mem_la_write),
		.mem_la_addr (mem_la_addr ),
		.mem_la_wdata(mem_la_wdata),
		.mem_la_wstrb(mem_la_wstrb)
	);
	wire [7:0] anodos2, catodos2;
	seven_segment_hex seven_segment (
		.clk      (clk     ),
		.num      (number ),
		.anodos   (anodos2 ),
		.catodos  (catodos2)
	);

	assign catodos = catodos2;
	assign anodos = anodos2;


	reg [31:0] memory [0:MEM_SIZE-1];

`ifdef SYNTHESIS
    initial $readmemh("../firmware/firmware.hex", memory);
`else
	initial $readmemh("firmware.hex", memory);
`endif

	reg [31:0] m_read_data;
	reg m_read_en;

	generate if (FAST_MEMORY) begin
		always @(posedge clk) begin
			mem_ready <= 1;
			out_byte_en <= 0;
			mem_rdata <= memory[mem_la_addr >> 2];
			if (mem_la_write && (mem_la_addr >> 2) < MEM_SIZE) begin
				if (mem_la_wstrb[0]) memory[mem_la_addr >> 2][ 7: 0] <= mem_la_wdata[ 7: 0];
				if (mem_la_wstrb[1]) memory[mem_la_addr >> 2][15: 8] <= mem_la_wdata[15: 8];
				if (mem_la_wstrb[2]) memory[mem_la_addr >> 2][23:16] <= mem_la_wdata[23:16];
				if (mem_la_wstrb[3]) memory[mem_la_addr >> 2][31:24] <= mem_la_wdata[31:24];
			end
			else
			if (mem_la_write && mem_la_addr == 32'h1000_0000) begin
				out_byte_en <= 1;
				out_byte <= mem_la_wdata;
				number <= mem_la_wdata;
			end
		end
	end else begin
		always @(posedge clk) begin
			m_read_en <= 0;
			mem_ready <= mem_valid && !mem_ready && m_read_en;

			m_read_data <= memory[mem_addr >> 2];
			mem_rdata <= m_read_data;

			out_byte_en <= 0;

			(* parallel_case *)
			case (1)
				mem_valid && !mem_ready && !mem_wstrb && (mem_addr >> 2) < MEM_SIZE: begin
					m_read_en <= 1;
				end
				mem_valid && !mem_ready && |mem_wstrb && (mem_addr >> 2) < MEM_SIZE: begin
					if (mem_wstrb[0]) memory[mem_addr >> 2][ 7: 0] <= mem_wdata[ 7: 0];
					if (mem_wstrb[1]) memory[mem_addr >> 2][15: 8] <= mem_wdata[15: 8];
					if (mem_wstrb[2]) memory[mem_addr >> 2][23:16] <= mem_wdata[23:16];
					if (mem_wstrb[3]) memory[mem_addr >> 2][31:24] <= mem_wdata[31:24];
					mem_ready <= 1;
				end
				mem_valid && !mem_ready && |mem_wstrb && mem_addr == 32'h1000_0000: begin
					out_byte_en <= 1;
					out_byte <= mem_wdata;
					mem_ready <= 1;
				end
			endcase
		end
	end endgenerate
endmodule
*/





// *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-
`timescale 1 ns / 1 ps
`include "memory.v"
`include "cache_direct.v"
`include "seven_segment_hex.v"

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
/*
	// Memoria principal Ejercicio 2
	memory memory_1(
     	.clk		 	(clk),
		.resetn		 	(resetn),
		.mem_valid	 	(mem_valid_p),
     	.mem_instr	 	(mem_instr_p),
	    .mem_addr	 	(mem_addr_p),
	    .mem_wdata	 	(mem_wdata_p),
     	.mem_wstrb	 	(mem_wstrb_p),
	    .mem_ready	 	(mem_ready_p),
    	.mem_rdata	 	(mem_rdata_p),
	    .mem_la_addr 	(mem_la_addr),
	    .mem_la_write 	(mem_la_write),
     	.mem_la_wstrb 	(mem_la_wstrb),
	   	.mem_la_wdata 	(mem_la_wdata),
	   	.out_byte_en 	(wout_byte_en),
	   	.out_byte	 	(wout_byte),
	   	.number		 	(number)
	);
*/
	wire [7:0] anodos2, catodos2;
	seven_segment_hex seven_segment (
		.clk      (clk     ),
		.num      (number ),
		.anodos   (anodos2 ),
		.catodos  (catodos2)
	);

	assign catodos = catodos2;
	assign anodos = anodos2;


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

	cache_direct cache_direct_1(
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
