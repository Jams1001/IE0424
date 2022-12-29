// SPI controller module
// Eleonora Chacon Taylor

`include "spi_controller.vh"

module spi_controller (
    // clk: reloj SCLK (debe ser 1-5 MHz)
    input               clk,
    // resetn: no es utilizado al inicializarse los registros en las declaraciones
    input               resetn,
    // wdata: datos a escribir en registro direccionado por address
    input  [7:0]        wdata,
    // address: direccion del registro a leer/escribir
    input  [7:0]        address,
    // read: indica que debe ejecutarse una lectura al registro direccionado 
    // por address. Debe permanecer en alto hasta que la salida complete
    // sea puesta en alto por el controlador.
    input               read,
    // write: indica que debe ejecutarse una escritura al registro direccionado 
    // por address, usando los datos en wdata. Debe permanecer en alto hasta que
    // la salida complete sea puesta en alto por en controlador.
    input               write,
    // SPI MISO: debe cablearse al pin MISO del ADXL362 
    input               miso,
    // SPI MOSI: debe cablearse al pin MOSI del ADXL362
    output reg          mosi = 0,
    // SPI CS: debe cablearse al pin CS del ADXL362
    output              cs,
    // SPI SCLK: debe cablearse al pin SCLK del ADXL362 
    output              sclk,
    // rdata: contiene los datos leidos del registro direccionado por address. Validez
    // es indicada por la salida complete
    output reg [7:0]    rdata = 0,
    // complete: indica que la transaccion de lectura o escritura ha sido completada.
    // En caso de lecturas, el resultado es contenido en rdata.
    output              complete);


    // inicializacion de registros
    reg  [2:0]  state = `IDLE;
    reg  [2:0]  next_state = `IDLE;
    reg  [7:0]  shift_register = 0;
    reg  [2:0]  bit = 7;
    reg         sclk_en = 0;
   
    // cables
    wire [2:0]  next_bit;
    wire [7:0]  next_shift_register, miso_shift_register;
    
    // cuenta los bits enviados/recibidos por SPI
    assign next_bit = bit + 1;
    
    // desplaza/rota shift register a la izquierda
    assign next_shift_register = {  shift_register[6],
                                    shift_register[5],
                                    shift_register[4],
                                    shift_register[3],
                                    shift_register[2],
                                    shift_register[1],
                                    shift_register[0],
                                    shift_register[7]
    };

    // desplaza shift register a la izquiera, bit 0 proviene de MISO
    assign miso_shift_register = {  shift_register[6],
                                    shift_register[5],
                                    shift_register[4],
                                    shift_register[3],
                                    shift_register[2],
                                    shift_register[1],
                                    shift_register[0],
                                    miso
    };

    always @(posedge clk) begin
        // maquina de estados para acceder registros del ADXL362 a traves de SPI
        // posedge updates next_state and shift register
        case (state)
            // IDLE: no traffic on SPI bus
            // goes to next state if read or write signals are driven high
            // sets apropriate SPI command in shift register
            `IDLE: begin
                if (read|write) begin
                    next_state <= `INST;
                    if (read) shift_register <= `READ_CMD;
                    else if (write) shift_register <= `WRITE_CMD;
                    else shift_register <= 0;
                end else next_state <= `IDLE;
            end
            // INST: sending SPI instruction
            // on last bit, sets next state and
            // sets SPI address in shift register
            `INST: begin
                if (&bit) begin
                    next_state <= `ADDR;
                    // load address on last bit
                    shift_register <= address;
                end else begin
                    next_state <= `INST;
                    shift_register <= next_shift_register;
                end
            end
            // ADDR: sending SPI address
            // on last bit, set corresponding next_state
            // if write, transfers wdata to shift_register
            `ADDR: begin
                if (&bit & read) begin
                    shift_register <= 2'h00;
                    next_state <= `RDATA;
                end else if (&bit & write) begin
                    shift_register <= wdata;
                    next_state <= `WDATA;
                end else begin
                    next_state <= `ADDR;
                    shift_register <= next_shift_register;
                end
            end
            // RDATA: receiving SPI read data
            // sample MISO to shift register LSB
            // on last bit, sets next state idle
            `RDATA: begin
                // sample miso into shift register
                shift_register <= miso_shift_register;
                if (&bit) begin
                    next_state <= `COMP;
                end else begin
                    next_state <= `RDATA;
                end
            end
            // WDATA: sending SPI write data
            // drives MOSI from shift register MSB
            // on last bit, set next state idle
            `WDATA: begin
                if (&bit) begin
                    next_state <= `COMP;
                end else begin
                    next_state <= `WDATA;
                    shift_register <= next_shift_register;
                end
            end
            // COMP: completes SPI transaction
            // transfers shift register to rdata and returns FSM to IDLE
            `COMP: begin
               next_state <= `IDLE;
            end
        endcase
    end   // always @(posedge clk)

    always @(negedge clk) begin
        // negedge updates state, bit and mosi
        // In all states but IDLE, increment bit register and 
        // copies shift register MSB to MOSI
        case (next_state)
            `IDLE: begin
                sclk_en <= 0;
            end
            `INST:  begin
                bit <= next_bit;
                mosi <= shift_register[7];
                sclk_en <= 1;
            end
            `ADDR:  begin
                bit <= next_bit;
                mosi <= shift_register[7];
                sclk_en <= 1;
            end
            `WDATA: begin
                bit <= next_bit;
                mosi <= shift_register[7];
                sclk_en <= 1;
            end
            `RDATA: begin
                bit <= next_bit;
                mosi <= 0;
                sclk_en <= 1;
            end
            `COMP: begin
                bit <= bit;
                rdata <= shift_register;
                sclk_en <= 0;
            end
            default: begin
                bit <= bit;
                mosi <= 0;
                sclk_en <= 0;
            end
        endcase
        state <= next_state;
    end    

    // otras salidas

    // SPI SCLK is active whenever not IDLE or COMP
    assign sclk = clk & sclk_en;
    // CS goes low when not idle nor comp
    assign cs = ~|state;

    // complete flag when FSM goes through COM
    assign complete = (state == `COMP);

endmodule
