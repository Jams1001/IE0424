
module cache_direct #(
    parameter CACHE_SIZE = 1*1024, 
	parameter WORDS = 2)(
    input clk,
    input resetn,
	input trap,

    // Señales a picorv 
    input mem_valid_p,
    input mem_instr_p,
    input [31:0] mem_addr_p,
    input [31:0] mem_wdata_p,
    input [3:0] mem_wstrb_p,
    output reg [31:0] mem_rdata_p,
    output reg mem_ready_p,

    // Señales memoria principal
    output reg mem_valid_mem,
    output reg mem_instr_mem,
    output reg [31:0] mem_addr_mem,
    output reg [31:0] mem_wdata_mem,
    output reg [3:0] mem_wstrb_mem,
    input [31:0] mem_rdata_mem,
    input mem_ready_mem
    //input [31:0] mem_la_addr,
    //input mem_la_write,
    //input [3:0] mem_la_wstrb,
    //input [31:0] mem_la_wdata,
	//output reg [31:0] number
);

// Parámetros de datos a utilizar en la caché
parameter BLOCK_SIZE = WORDS*4;
parameter OFFSET_SIZE = $clog2(BLOCK_SIZE);
parameter BLOCKS = CACHE_SIZE/BLOCK_SIZE;
parameter INDEX_SIZE = $clog2(BLOCKS);
parameter TAG_SIZE = 32 - INDEX_SIZE - OFFSET_SIZE;
parameter WORD_SIZE = 32;
parameter DATA_SIZE = WORDS*WORD_SIZE;
parameter MEM_SIZE = DATA_SIZE;         // Tamaño cache; tamaño de datos
parameter WORDS_ITR = $clog2(WORDS);    // Iteración


// Estructura de datos de cache
// valores actuales de cpu a cache
// reg dirty  
// reg valid
reg [TAG_SIZE-1:0] tag;

reg [OFFSET_SIZE-1:0] offset;
reg [INDEX_SIZE-1:0] index;    
reg [WORDS_ITR-1:0] word_count;
reg Hit;
reg Miss;
reg [31:0] hit_count;
reg [31:0] miss_count;
reg [31:0] total_count;

 
 /*
wire [`INDEX-1:0] core_index;
wire [`OFFSET-1:0] core_offset;
wire [`TAG-1:0] core_tag;

assign core_offset = core_mem_addr[`OFFSET-1:0];
assign core_index = core_mem_addr[`INDEX+`OFFSET-1:`OFFSET];
assign core_tag = core_mem_addr[`ADDR-1:`INDEX+`OFFSET];

// Arreglos de la cache
reg [`BLOCKSIZE-1:0]    data    [0:`CACHESIZE-1];
reg [`TAG-1:0]          tag     [0:`CACHESIZE-1];
reg                     valid   [0:`CACHESIZE-1];
reg                     dirty   [0:`CACHESIZE-1];
*/

always@(posedge clk) begin
    if(!reset) begin
        pre_state <= RESET; 
    end
    else begin
        pre_state <= nxt_state;
    end
end

reg [1:0] pre_state, nxt_state;


parameter RESET = 3'b000;  
parameter IDLE = 3'b001;
parameter COMPARE_TAG = 3'b010; 
parameter ALLOCATE = 3'b100; 
parameter WRITE_BACK = 3'b101; 

 always @(posedge clk) begin

        case(pre_state)
            RESET: begin
                
                read <= 0;
                write <= 0;
                mem
                nxt_state <= IDLE;
            end

            IDLE: begin
                mem_ready_p <= 0;
                Hit <= 0;
                Miss <= 0;
                offset <= mem_addr_p[OFFSET_SIZE-1:0];
				index <= mem_addr_p[(OFFSET_SIZE+INDEX_SIZE)-1:OFFSET_SIZE];
				tag <= mem_addr_p[31:INDEX_SIZE+OFFSET_SIZE];
                    
                if(mem_valid_p) begin
                    nxt_state <= COMPARE_TAG;
                end 
                else begin
                    nxt_state <= IDLE;
                end
            end

            COMPARE_TAG: begin
                
                if() begin
                end 
                else begin
                end
            end
            ALLOCATE: begin
                if() begin
                end r
                else begin
                end
            end
            WRITE_BACK: begin
                if() begin
                end 
                else begin
                end
            end


        endcase
    end

endmodule 