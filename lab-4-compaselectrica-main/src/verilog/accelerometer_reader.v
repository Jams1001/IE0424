`include "spi_controller.v"
`include "sclk_gen.v"

module accelerometer_reader(

    input MISO,
    input clk,
    input reset,
    output MOSI,
    output SCLK,
    output CS,
    output   [7:0] ACCEL_Y,
    output   [7:0] ACCEL_Z
);

    wire [7:0] wdata, address, rdata;
    wire read, write, complete, SCLK_gen;

    sclk_gen sclk_gen_0 ( 
		.clk	(clk),
	    .sclk   (SCLK_gen)
	);

	spi_controller spi_controller_0 (
		.clk        (SCLK_gen ),
		.resetn     (reset  ),
		.wdata      (wdata  ),
		.address    (address ),
		.read       (read),
        .write      (write),
        .miso       (MISO),
        .mosi       (MOSI),
        .cs         (CS),
        .sclk       (SCLK),
        .rdata      (rdata),
        .complete   (complete)
	);

    fsm fsm_0 (
        .clk        (SCLK_gen),
		.rdata      (rdata),
		.complete   (complete),
        .reset      (reset),
		.write      (write  ),
        .read       (read),
		.address    (address  ),
        .wdata      (wdata),
        .ACCEL_Y    (ACCEL_Y),
        .ACCEL_Z    (ACCEL_Z)
	);

endmodule



module fsm(
    input clk,
    input [7:0] rdata,
    input complete,
    input reset,
    output reg write,
    output reg read,
    output reg [7:0] address,
    output reg [7:0] wdata,
    output reg [7:0] ACCEL_Y,
    output reg [7:0] ACCEL_Z
);

    // States
    parameter RESET = 2'b00, WRITE_POWER_CTL = 2'b01, READ_YDATA = 2'b10, READ_ZDATA = 2'b11;  

    reg [1:0] pre_state, nxt_state;

    always@(posedge clk) begin
        if(!reset) begin
            pre_state <= RESET; 
        end
        else begin
            pre_state <= nxt_state;
        end
    end

    initial begin
        ACCEL_Y <= 0;
        ACCEL_Z <= 0;
    end

    always @(*) begin

        case(pre_state)

            RESET: begin
                read <= 0;
                write <= 0;
                nxt_state <= WRITE_POWER_CTL;
            end

            WRITE_POWER_CTL: begin
                read    <= 0;
                write   <= 1; 
                address <= 8'h2D;
                wdata   <= 8'h02;
                if (complete) begin
                    nxt_state <= READ_YDATA;
                end
                else begin
                    nxt_state <= WRITE_POWER_CTL;
                end
            end

            READ_YDATA: begin
                read    <= 1;
                write   <= 0;
                address <= 8'h09;
                if (complete) begin
                    read <= 0;
                    write   <= 0;
                    ACCEL_Y <= rdata;
                    nxt_state <= READ_ZDATA;
                end
                else begin
                    nxt_state <= READ_YDATA;
                end
                
            end
            READ_ZDATA: begin
                read    <= 1;
                write   <= 0;
                address <= 8'h0A;
                if (complete) begin
                    read <= 0;
                    write   <= 0;
                    ACCEL_Z <= rdata;
                    nxt_state <= READ_YDATA;
                end
                else begin
                    nxt_state <= READ_ZDATA;
                end

            end
        endcase
    end
endmodule

