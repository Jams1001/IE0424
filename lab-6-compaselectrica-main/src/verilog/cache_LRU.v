`timescale 1 ns / 1 ps

module cache_LRU #(
	parameter CACHE_SIZE = 1*1024,   // 1 kB
	parameter WORDS = 2
) (
	input               clk,
	input               resetn,

	input               mem_instr,
	input               mem_valid,
  	input             	mem_ready_m,
	input [31:0]        mem_rdata_m,
	input [31:0]        mem_wdata,
	input [3:0]         mem_wstrb,
	input [31:0]        mem_addr,
	output reg [31:0]   mem_rdata,
  	output reg          mem_ready,
  	output reg          mem_valid_m,
	output reg          mem_instr_m,
  	output reg [31:0]   mem_addr_m,
	output reg [31:0]   mem_wdata_m,
	output reg [3:0]    mem_wstrb_m
	);

	// Parámetros de datos de cache
	parameter BLOCK_SIZE = WORDS*4;
	parameter OFFSET_SIZE = $clog2(BLOCK_SIZE);
	parameter BLOCKS = CACHE_SIZE/BLOCK_SIZE;
	parameter INDEX_SIZE = $clog2(BLOCKS);
	parameter TAG_SIZE = 32 - INDEX_SIZE - OFFSET_SIZE;
	parameter WORD_SIZE = 32;
	parameter DATA_SIZE = WORDS*WORD_SIZE;
	parameter MEM_SIZE = DATA_SIZE;   // Tamano total del caché
	parameter WORDS_ITR = $clog2(WORDS);

	// Estados a utilizar
	parameter IDLE = 0;
	parameter LEER = 1;
	parameter ESCRIBIR = 2;
	parameter LEER_HIT = 3;
	parameter ESCRIBIR_HIT = 4;
	parameter LEER_MISS = 5;
	parameter ESCRIBIR_MISS = 6;
	parameter ESCRIBIR_BACK = 7;
	parameter ACCESO_MEM = 8;
	parameter OUT = 9;
	parameter ESPERA = 10;
	parameter ESPERA_ACCESO_MEM = 11;

	// Registros para guardar tag, index, offset, misses y hits
	reg [TAG_SIZE-1:0] tag;
	reg [OFFSET_SIZE-1:0] offset;
	reg [INDEX_SIZE-1:0] index;
	reg hit;
	reg miss;
	reg [31:0] cont_hits;
	reg [31:0] cont_misses;
	reg [31:0] cuenta_total;
	reg [3:0] estado;

	//  registros para cada bloque
	reg dirty_bit [BLOCKS-1:0][1:0];
	reg valid_bit [BLOCKS-1:0][1:0];
	reg [TAG_SIZE-1:0] tags [BLOCKS-1:0][1:0];
	reg [MEM_SIZE-1:0] cache [BLOCKS-1:0][1:0];

	reg read_write;  // Indicador para saber cuando hay lectura o escritura (1 read, 0 write)
  reg actual_way;
  //wire random_bit; no se usa
	reg LRU;  //política de remplazo LRU


	integer word_i, via, set, LRU_int;


	always @(posedge clk ) begin
		mem_instr_m <= mem_instr; // directo a la memoria

		// Inicialización
		if (!resetn) begin
			for (set = 0; set < BLOCKS; set = set+1) begin
				for (via = 0; via < 2 ; via = via+1) begin
					cache[set][via] <= 0;
					dirty_bit[set][via] <= 0;
					valid_bit[set][via] <= 0;
					tags[set][via] <= 0;
				end
			end
			hit <= 0;
			cont_hits <= 0;
			cont_misses <= 0;
			cuenta_total <= 0;
			estado <= IDLE;
		end
		else begin
			case (estado)
				IDLE: begin
					actual_way <= 0; // cualquiera de los 2 ways
					mem_ready <= 0; // En 0 para que CPU inice nueva transacción
					hit <= 0;
					miss <= 0;
					word_i <= 0;
					read_write <= 0;
					set <= 0;
					via <= 0;
					LRU <= 0; // Política LRU
					LRU_int<= 0;

					// Actualiza con datos actuales
					offset <= mem_addr[OFFSET_SIZE-1:0];
					index <= mem_addr[(OFFSET_SIZE+INDEX_SIZE)-1:OFFSET_SIZE];
					tag <= mem_addr[31:INDEX_SIZE+OFFSET_SIZE];

					if (mem_valid) begin
						if (mem_addr >= 'hFFFF) begin
							estado <= OUT;
						end

						else if (!mem_wstrb)	 begin
							cuenta_total <= cuenta_total+1;
							estado <= LEER;
							via <= 0;
							read_write <= 1;
						end

						else begin // Request para write
							cuenta_total <= cuenta_total+1;
							estado <= ESCRIBIR;
							read_write <= 0;
						end
					end
					else estado <= IDLE;  // No hay datos para transferir
					end

				LEER: begin
					if (via < 2) begin   // Se comparan los tags del way
						if ((tags[index][via] == tag) && valid_bit[index][via]) begin // hit en una via
							hit <= 1;
							cont_hits <= cont_hits+1;
							estado  <= LEER_HIT;
							actual_way <= via;
							word_i <= 0;
							LRU_int <= via + 1; // política LRU_int
							LRU <= LRU_int;
						end
						else begin				// no hit, siguiente via
							via <= via +1;
							estado <= LEER;
						end
					end

					else begin // Hay miss
						miss <= 1;
						hit <= 0;
						cont_misses <= cont_misses+1;
						estado <= LEER_MISS;
					end


				end

				LEER_HIT: begin

					// Se compara offset con la palabra
					if (offset[2+:OFFSET_SIZE-2] == word_i) begin
						mem_rdata <= cache[index][actual_way][word_i*32 +: 32];  // se pasa la palabra a la interfaz del CPU
						mem_ready <= 1;
						estado <= ESPERA;
					end
					else begin  // Caso en que el la palabra no es igual al offset
						mem_ready <= 0;
						word_i <= word_i + 1;
						estado <= LEER_HIT;
					end

				end

				LEER_MISS: begin
					if (dirty_bit[index][LRU] == 0) begin
						word_i <= 0;  // Buscar la palabra desde e
						mem_addr_m <= mem_addr & (32'hFFFFFFFF<<(OFFSET_SIZE));
						estado <= ACCESO_MEM;   // Si no está dirty no hay se debe mandar a memoria
					end else begin  // Remplazar dirty bit
						word_i <= 0;
						estado <= ESCRIBIR_BACK;
					end
				end


		// Estado para que no se pasa a IDLE cuando se sube mem_ready
		ESPERA: begin
		mem_ready <= 0;
		estado <= IDLE;
		end

				ACCESO_MEM: begin
					mem_wstrb_m <= 0;
					mem_valid_m <= 1;
					if (mem_ready_m) begin
						cache[index][actual_way][word_i*32 +: 32] <= mem_rdata_m;
						if (word_i == WORDS-1) begin
							valid_bit[index][actual_way] <= 1;
							dirty_bit[index][actual_way] <= 0;
							tags[index][actual_way] <= tag;
							mem_valid_m <= 0;
							miss <= 0;
							if (read_write) begin
								estado <= LEER_HIT;
								word_i <= 0;
							end else begin
								estado <= ESCRIBIR_HIT;
								word_i <= 0;
							end
						end
						else begin
							word_i <= word_i + 1;
							mem_ready <= 0;
							mem_valid_m <= 0;
							mem_addr_m <= mem_addr_m + 4;
							estado <= ACCESO_MEM;
						end
					end else begin
						estado <= ACCESO_MEM;
					end
				end

				ESCRIBIR: begin
					if (via < 2) begin
						if ((tags[index][via] == tag) && valid_bit[index][via]) begin  // Ocurre hit
							hit <= 1;
							miss <= 0;
							actual_way <= via;
							cont_hits <= cont_hits+1;
							estado <= ESCRIBIR_HIT;
							word_i <= 0;
							LRU_int <= via + 1; // Política LRU
							LRU <= LRU_int;
						end else begin
							via = via+1;
							estado <= ESCRIBIR;
						end
					end

						else begin // Ocurre miss
							miss <= 1;
							hit <= 0;
							cont_misses <= cont_misses+1;
							estado <= ESCRIBIR_MISS;
						end
					end


				ESCRIBIR_BACK: begin
					mem_valid_m <= 1;
					mem_wstrb_m <= 4'hF;
					mem_addr_m <= {tags[index][actual_way], index, {OFFSET_SIZE{1'b0}}} + 4*word_i;
					if (mem_ready_m) begin
						valid_bit[index][actual_way] <= 0;
						mem_wdata_m <= cache[index][actual_way][word_i*32 +: 32];
						if (word_i == WORDS-1) begin
							estado <= ESPERA_ACCESO_MEM;
							word_i <= 0;
						end
						else begin
							word_i <= word_i + 1;
							mem_ready <= 0;
							estado <= ESCRIBIR_BACK;
						end
					end else begin
						estado <= ESCRIBIR_BACK;
					end
				end

				ESCRIBIR_MISS: begin
					if (dirty_bit[index][LRU] == 0) begin  // Dato no está dirty no se remplaza
						mem_addr_m <= mem_addr & (32'hFFFFFFFF<<(OFFSET_SIZE));
						estado <= ACCESO_MEM;  // se escoje el Tag correcto
						word_i <= 0;
					end else begin
						estado <= ESCRIBIR_BACK;
						word_i <= 0;
					end
				end

				ESCRIBIR_HIT: begin
					if (offset[2+:OFFSET_SIZE-2] == word_i) begin  // cuando el dato está en la palabra del offset
						dirty_bit[index][actual_way] <= 1;
						cache[index][actual_way][word_i*32 +: 32] <= mem_wdata;
						mem_ready <= 1; // poner en bajo para siguiente ciclo
						estado <= ESPERA;
					end else begin
						word_i <= word_i + 1;
						estado <= ESCRIBIR_HIT;
						mem_ready <= 0;
					end
				end



				ESPERA_ACCESO_MEM: begin
					mem_valid_m <= 0;
					mem_addr_m <= mem_addr & (32'hFFFFFFFF<<(OFFSET_SIZE));
					estado <= ACCESO_MEM;
				end

				OUT: begin
					mem_valid_m <= 1;
					mem_addr_m <= mem_addr;
					mem_wstrb_m <= mem_wstrb;
					if (|mem_wstrb) mem_wdata_m <= mem_wdata;
					if (mem_ready_m) begin
						if (~|mem_wstrb) mem_rdata <= mem_rdata_m;
						mem_ready <= 1;
						mem_valid_m <= 0;
						mem_wstrb_m <= 0;
						mem_wdata_m <= 0;
						estado <= IDLE;

					end
				end
			endcase

		end
	end
endmodule
