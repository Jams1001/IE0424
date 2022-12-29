
`timescale 1 ns / 1 ps
`include "lut_multiplier.v"
`include "array_multiplier.v"
`include "arr_multiplier_4b_generate.v"


module system (
	input            clk,
	input            resetn,
	output           trap,
	output reg [7:0] out_byte,
	output reg       out_byte_en

);
  	//Ejercricio 1
  	reg [31:0] out_fact;

  	//Ejercicio 3
	reg [31:0] A;
	reg [3:0] B;
	wire [35:0] out_mult;

	//Ejercicio 4
	reg [31:0] A_32b_lut;
	reg [31:0] B_32b_lut;
	wire [63:0] out_mult_lut_32b;

  	//Ejercicio 5
 	 reg [3:0] multB_4b_array;
	reg [3:0] multA_4b_array;
	wire [7:0] out_array;

	//Ejercicio 6
	reg [3:0] multA_4b_generate;
  	reg [3:0] multB_4b_generate;
	wire [7:0] out_generate;



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

	// Instancia ejercicio 3
	lut_multiplier_4b mult_lut_4b (
		.resetn	(resetn),
		.A		(A), 
		.B		(B), 
		.R		(out_mult)
		);

	// Instancia ejercicio 4
	lut_multiplier_32b mult_lut_32b( 
		.resetn	(resetn),
		.A		(A_32b_lut), 
		.B		(B_32b_lut), 
		.R		(out_mult_lut_32b)
		);

  	// Instancia ejercicio 5
  	array_multiplier_4b mult_array_4b(
    	.resetn		(resetn),
    	.A			(multA_4b_array),
    	.B			(multB_4b_array),
    	.out		(out_array)
    );

	// Instancia ejercicio 6
  	array_multiplier_4b_generate mult_generate_4b(
    	.resetn				(resetn),
    	.A					(multA_4b_generate),
    	.B					(multB_4b_generate),
    	.out_generate_4b	(out_generate)
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
			if (mem_la_write && mem_la_addr == 32'h1000_0000) begin
				out_byte_en <= 1;
				out_byte <= mem_la_wdata;
				out_fact <= mem_la_wdata;

			// Direcciones de memoria utilizadas en ejercio 3
			end else if (mem_la_write && mem_la_addr == 32'h1000_0004) begin
				A <= mem_la_wdata;
			end else if (mem_la_write && mem_la_addr == 32'h1000_0008) begin
				B <= mem_la_wdata;
			end
			//Direcciones de memoria ejercico 4
			else if (mem_la_write && mem_la_addr == 32'h1000_000C) begin
				A_32b_lut <= mem_la_wdata;
			end else if (mem_la_write && mem_la_addr == 32'h1000_0010) begin
				B_32b_lut <= mem_la_wdata;
			end

			////Direcciones de memoria ejercicio 5
      		//else if (mem_la_write && mem_la_addr == 32'h0FFF_FFF0) begin
			//	multA_4b_array <= mem_la_wdata;  // Ej 5
			//end else if (mem_la_write && mem_la_addr == 32'h0FFF_FFF4) begin
			//	multB_4b_array <= mem_la_wdata;  // Ej 5
			//end else if (mem_la_read && mem_la_addr == 32'h0FFF_FFF8) begin
			//	mem_rdata[31:8] <= 0;
			//	mem_rdata[7:0] <= out_array;
			//end

			//Direcciones de memoria ejercicio 5 y  6
      		else if (mem_la_write && mem_la_addr == 32'h0FFF_FFF0) begin
				multA_4b_array <= mem_la_wdata;  	// Ejercicio 5
				multA_4b_generate <= mem_la_wdata;  // Ejercicio 6
			end else if (mem_la_write && mem_la_addr == 32'h0FFF_FFF4) begin
				multB_4b_array <= mem_la_wdata;  	// Ejercicio 5
				multB_4b_generate <= mem_la_wdata;  // Ejercicio 6
			end else if (mem_la_read && mem_la_addr == 32'h0FFF_FFF8) begin
				mem_rdata[31:8] <= 0;
				mem_rdata[7:0] <= out_array;		// Ejercicio 5
				mem_rdata[7:0] <= out_generate;		// Ejercicio 6
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
