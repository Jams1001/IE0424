`timescale 1 ns / 1 ps
//`include "text_display.v"
`include "seven_segment_hex.v"
`include "accelerometer_reader.v"
module system (
	input           	clk,
	input           	resetn,
	//input [31:0]		int,
	output           	trap,
	output reg       	out_byte_en,
	output reg [7:0]	out_byte,
	output [7:0]		catodos, 
	output [7:0]		anodos,
	input               MISO,
	output              MOSI,
	output              CS,
	output              SCLK
);
	// set this to 0 for better timing but less performance/MHz
	parameter FAST_MEMORY = 1;

	// 4096 32bit words = 16kB memory
	parameter MEM_SIZE = 4096;

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
	wire [31:0] intMask = 0; 



	reg [3:0] selector;

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
		//.irq	 	 (int)
	);
/*
	//Ejercicio 2
	text_display text_display_0 (
		.clk	(clk),
		.reset	(resetn),
		.selector (selector),
		.enable (enable),
		.catodos (catodos),
		.anodos (anodos)
	);
*/
	//Ejercicio 3
	wire [7:0] ACCEL_Y, ACCEL_Z; 
	reg [31:0] 	ACCEL_Y_Z = 0;

	
	accelerometer_reader accelerometer_reader_0 (
		.MISO		(MISO	),
		.MOSI   	(MOSI	),
		.reset 	 	(resetn	),
		.SCLK   	(SCLK	),
		.CS    	 	(CS		),
		.clk    	(clk	),
		.ACCEL_Y	(ACCEL_Y),
		.ACCEL_Z 	(ACCEL_Z)
	);

	seven_segment_hex seven_segment_hex_1 (
		.num		(ACCEL_Y_Z		),
		.clk		(clk			),
		.catodos	(catodos		),
		.anodos 	(anodos			)
	);

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
			// Ejercicio 1
			if (mem_la_write && mem_la_addr == 32'h1100_0000) begin
				out_byte_en <= 1;
				out_byte <= mem_la_wdata;
			end
			// Ejercicio 2
			if (mem_la_write && mem_la_addr == 32'h1000_0010) begin
				out_byte_en <= 1;
				out_byte <= mem_la_wdata;
				selector <= mem_la_wdata;
			end
			// Ejercicio 3
			if (mem_la_write && mem_la_addr == 32'h1000_0000) begin
				out_byte_en <= 1;
				ACCEL_Y_Z <= mem_la_wdata;
			end
			if (mem_la_read && mem_la_addr == 32'h2000_0000) begin
				out_byte_en <= 1;
				mem_rdata <= ACCEL_Y;
			end

			if (mem_la_read && mem_la_addr == 32'h3000_0000) begin
				out_byte_en <= 1;
				mem_rdata <= ACCEL_Z;
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
