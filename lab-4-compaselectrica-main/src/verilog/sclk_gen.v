`timescale 1 ns / 1 ps

module sclk_gen(
    input clk,
    output sclk
    );

    reg [5:0] counter =  0;
    always @(posedge clk) begin
        counter <= counter + 1;
    end
    assign sclk = counter[4];
endmodule