module lsfr(
    input clk,
    input reset,
    output number
);


reg [3:0] lsfr;

wire lazo;

assign lazo = (lsfr[3]^lsfr[0]);
assign number = lsfr[0];

always @(posedge clk) begin
    if (~reset)
        lsfr <= 4'b111;
    else

        lsfr <= {lsfr[2:0], lazo};
end

endmodule
