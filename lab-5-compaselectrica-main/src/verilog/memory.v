module memory (
    input               clk,
    input               resetn,
	  input               trap,
    input               mem_valid,
    input               mem_instr,
    input [31:0]        mem_addr,
    input [31:0]        mem_wdata,
    input [3:0]         mem_wstrb,
    output reg [31:0]   mem_rdata,
    output reg          mem_ready,
	  output reg          out_byte_en,
	  output reg [7:0]    out_byte,
    input [31:0]        mem_la_addr,
    input               mem_la_write,
    input [3:0]         mem_la_wstrb,
    input [31:0]        mem_la_wdata,
	  output reg [31:0]   number
);

parameter FAST_MEMORY = 0;
parameter MEM_SIZE = 16384;


reg [31:0] memory [0:MEM_SIZE];

`ifdef SYNTHESIS
    initial $readmemh("../firmware/firmware.hex", memory);
`else
	initial $readmemh("firmware.hex", memory);
`endif

reg [31:0] m_read_data;
reg m_read_en;
reg [31:0] address;

// Registros para generar retarasos de lectura y escritura
reg [3:0] read_count = 0;
reg read_valid;
reg [3:0] write_count = 0;
reg write_valid;


	generate if (FAST_MEMORY) begin
		always @(posedge clk) begin
			mem_ready <= 1;
			out_byte_en <= 0;
      if (resetn) begin
          number = 32'h0000000F;
      end
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
				number <= mem_la_wdata;
			end
			if (mem_la_write && mem_la_addr == 32'h1000_000C) begin
				address <= mem_la_wdata;
			end
		end
	end else begin

  // Lógica para retraso en la memoria
  always @(posedge clk) begin
      // Lectura con retraso de 10 ciclos
      if (mem_valid && !mem_ready && !mem_wstrb) begin
        if (read_count >= 9) begin
            read_count = 0;
            read_valid = 1;
        end else begin
            read_count <= read_count + 1;
            read_valid = 0;
        end
        end

        // Escritura con retraso de 15 ciclos
        if (mem_valid && !mem_ready && |mem_wstrb) begin
          if (write_count >= 14) begin
              write_count = 0;
              write_valid = 1;
          end else begin
              write_count <= write_count + 1;
              write_valid = 0;
          end
          end

  			m_read_en <= 0;
  			mem_ready <= mem_valid && !mem_ready && m_read_en;

  			m_read_data <= memory[mem_addr >> 2];
  			mem_rdata <= m_read_data;

  			out_byte_en <= 0;

  			(* parallel_case *)
  			case (1)
  				mem_valid && !mem_ready && !mem_wstrb && (mem_addr >> 2) < MEM_SIZE: begin

  				if (read_valid == 1) begin
  				    m_read_en <= 1;    // Se realiza retrazo en lectura
  				end
  				end
  				mem_valid && !mem_ready && |mem_wstrb && (mem_addr >> 2) < MEM_SIZE: begin
  					if (mem_wstrb[0]) memory[mem_addr >> 2][ 7: 0] <= mem_wdata[ 7: 0];
  					if (mem_wstrb[1]) memory[mem_addr >> 2][15: 8] <= mem_wdata[15: 8];
  					if (mem_wstrb[2]) memory[mem_addr >> 2][23:16] <= mem_wdata[23:16];
  					if (mem_wstrb[3]) memory[mem_addr >> 2][31:24] <= mem_wdata[31:24];
  				if (write_valid == 1) begin
  				    mem_ready <= 1;  // Se realiza retraso en escritura
  				end
  				end

  				// Escritura para senales diferentes
  				mem_valid && !mem_ready && |mem_wstrb && mem_addr == 32'h1000_0000: begin
  				   out_byte_en <= 1;
  					 number <= mem_wdata;
  				   if (write_valid == 1) begin
  				       mem_ready <= 1;  // Se realiza retraso en escritrua
  				   end
  				end
  				mem_valid && !mem_ready && |mem_wstrb && mem_addr == 32'h1000_000C: begin
  				    address <= mem_la_wdata;
  				    if (write_valid == 1) begin
  				        mem_ready <= 1;  // Se realiza retraso en escritura
  				    end
  				end
  			endcase

  		end
  	end endgenerate
  endmodule
