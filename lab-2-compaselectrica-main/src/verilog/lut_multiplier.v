
module lut_multiplier_2b (
    input [31:0] A,
    input [1:0] B,
    input resetn,
    output reg [33:0] R);

    always @(*) begin
    if (resetn) begin
        case (B)
            2'b00: R <= 0;
            2'b01: R <= A;
            2'b10: R <= A<<1;
            2'b11: R <= (A<<1) + A;
       endcase
    end else R <= 0;
    end
endmodule

module lut_multiplier_4b (
    input [31:0] A,
    input [3:0] B,
    input resetn,
    output reg [35:0] R);

    wire [33:0] rest1;
    wire [33:0] rest2;

    lut_multiplier_2b lsb (
    .A(A), .B(B[1:0]), .resetn(resetn), .R(rest1));


    lut_multiplier_2b msb (
    .A(A), .B(B[3:2]), .resetn(resetn), .R(rest2));


    always @(*) begin
        if (resetn) begin
            R <= rest1 + (rest2<<2);
        end else R <= 0;
    end
endmodule

// Multiplicador de 8 bits
module lut_multiplier_8b (
    input [31:0] A,
    input [7:0] B,
    input resetn,
    output reg [39:0] R);

    wire [35:0] rest1;
    wire [35:0] rest2;

    lut_multiplier_4b mult1 (
    .A(A), .B(B[3:0]), .resetn(resetn), .R(rest1));

    lut_multiplier_4b mult2 (
    .A(A), .B(B[7:4]), .resetn(resetn), .R(rest2));


    always @(*) begin
        if (resetn) begin
            R <= rest1 + (rest2<<4);
        end else R <= 0;
    end
endmodule


// Multiplicador de 16 bits
module lut_multiplier_16b (
    input [31:0] A,
    input [15:0] B,
    input resetn,
    output reg [47:0] R);

    wire [39:0] rest1;
    wire [39:0] rest2;

    lut_multiplier_8b mult1 (
    .A(A), .B(B[7:0]), .resetn(resetn), .R(rest1));

    lut_multiplier_8b mult2 (
    .A(A), .B(B[15:8]), .resetn(resetn), .R(rest2));


    always @(*) begin
        if (resetn) begin
            R <= rest1 + (rest2<<8);
        end else R <= 0;
    end
endmodule

//Multiplicador de 32 bits
module lut_multiplier_32b (
    input [31:0] A,
    input [31:0] B,
    input resetn,
    output reg [63:0] R);

    wire [47:0] rest1;
    wire [47:0] rest2;

    lut_multiplier_16b mult1 (
    .A(A), .B(B[15:0]), .resetn(resetn), .R(rest1));

    lut_multiplier_16b mult2 (
    .A(A), .B(B[31:16]), .resetn(resetn), .R(rest2));


    always @(*) begin
        if (resetn) begin
            R <= rest1 + (rest2<<16);
        end else R <= 0;
    end
endmodule
