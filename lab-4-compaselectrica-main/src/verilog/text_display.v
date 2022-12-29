module text_display(
    input [3:0] selector,
    input clk,
    input reset,
    input enable,
    output [7:0] catodos,
    output [7:0] anodos
    );

    reg [47:0] Mux_out;

    always @(*) begin
        case (selector)
            4'd0: begin                 // Start
                Mux_out[5:0] <= 6'd29;  // t
                Mux_out[11:6] <= 6'd27; // r
                Mux_out[17:12] <= 6'd10;// a
                Mux_out[23:18] <= 6'd29;// t
                Mux_out[29:24] <= 6'd28;// S
            end 
            4'd1: begin                 // Select
                Mux_out[5:0] <= 6'd29;  // t
                Mux_out[11:6] <= 6'd12; // c
                Mux_out[17:12] <= 6'd14;// e
                Mux_out[23:18] <= 6'd21;// l
                Mux_out[29:24] <= 6'd14;// e
                Mux_out[35:30] <= 6'd28;// S
            end 
            4'd2: begin                 // Paper
                Mux_out[5:0] <= 6'd27;  // r
                Mux_out[11:6] <= 6'd14; // e
                Mux_out[17:12] <= 6'd25;// p
                Mux_out[23:18] <= 6'd11;// a
                Mux_out[29:24] <= 6'd25;// P
            end 
            4'd3: begin                 // Scissors
                Mux_out[5:0] <= 6'd28;  // s
                Mux_out[11:6] <= 6'd27; // r
                Mux_out[17:12] <= 6'd24;// o
                Mux_out[23:18] <= 6'd28;// s
                Mux_out[29:24] <= 6'd28;// s
                Mux_out[35:30] <= 6'd18;// i
                Mux_out[41:36] <= 6'd12;// c
                Mux_out[47:42] <= 6'd28;// S
            end 
            4'd4: begin                 // Rock
                Mux_out[5:0] <= 6'd20;  // k
                Mux_out[11:6] <= 6'd12; // c
                Mux_out[17:12] <= 6'd24;// o
                Mux_out[23:18] <= 6'd27;// R
            end 
            4'd5: begin                 // Rival
                Mux_out[5:0] <= 6'd21;  // l
                Mux_out[11:6] <= 6'd10; // a
                Mux_out[17:12] <= 6'd31;// v
                Mux_out[23:18] <= 6'd18;// i
                Mux_out[29:24] <= 6'd27;// R
            end 
            4'd6: begin                 // YouWon
                Mux_out[5:0] <= 6'd23;  // n
                Mux_out[11:6] <= 6'd25; // o
                Mux_out[17:12] <= 6'd32;// W
                Mux_out[23:18] <= 6'd30;// u
                Mux_out[29:24] <= 6'd24;// o
                Mux_out[35:30] <= 6'd34;// Y
            end 
            4'd7: begin                 // YouLost
                Mux_out[5:0] <= 6'd29;  // t
                Mux_out[11:6] <= 6'd28; // s
                Mux_out[17:12] <= 6'd24;// o
                Mux_out[23:18] <= 6'd21;// L
                Mux_out[29:24] <= 6'd30;// u
                Mux_out[35:30] <= 6'd24;// o
                Mux_out[41:36] <= 6'd34;// Y
            end 
            4'd8: begin                 // YouLost
                Mux_out[5:0] <= 6'd14;  // e
                Mux_out[11:6] <= 6'd18; // i
                Mux_out[17:12] <= 6'd29;// T
            end 
            default: Mux_out <= 0;
        endcase
    end

        seven_segment_hex_2 seven_segment_hex_0 (
        .clk        (clk    ),
        .num        (Mux_out),
        .anodos     (anodos ),
        .catodos    (catodos));

endmodule


module seven_segment_hex_2(
    input [47:0] num,
    input clk,
    output reg [7:0] catodos,
    output reg [7:0] anodos
);


reg [31:0] counter = 0;
reg [5:0] mux_out;


always@(posedge clk )begin 
    if (counter == 32'hFFFFFFFF) begin
        counter <= 0;
    end
     counter = counter + 1;
end

always@(*) begin 

    case(counter[16:14])
        3'd0: mux_out <= num[5:0];
        3'd1: mux_out <= num[11:6];
        3'd2: mux_out <= num[17:12];
        3'd3: mux_out <= num[23:18];
        3'd4: mux_out <= num[29:24];
        3'd5: mux_out <= num[35:30];
        3'd6: mux_out <= num[41:36];
        3'd7: mux_out <= num[47:42];
        default: mux_out <= 4'h0;
    endcase 
end

always@(*) begin 

    case(counter[16:14])
        3'd0: anodos <= 8'b1111_1110;
        3'd1: anodos <= 8'b1111_1101;
        3'd2: anodos <= 8'b1111_1011;
        3'd3: anodos <= 8'b1111_0111;
        3'd4: anodos <= 8'b1110_1111;
        3'd5: anodos <= 8'b1101_1111;
        3'd6: anodos <= 8'b1011_1111;
        3'd7: anodos <= 8'b0111_1111;
        default: anodos <= 8'b1111_1110;
    endcase 
end

always@(*) begin 

    case(mux_out)
        6'd0: catodos <= 8'b0000_0011; //Last bit: dot
        6'd1: catodos <= 8'b1001_1111;
        6'd2: catodos <= 8'b0010_0101;
        6'd3: catodos <= 8'b0000_1101;
        6'd4: catodos <= 8'b1001_1001;
        6'd5: catodos <= 8'b0100_1001;
        6'd6: catodos <= 8'b0100_0001;
        6'd7: catodos <= 8'b0001_1111;
        6'd8: catodos <= 8'b0000_0001;
        6'd9: catodos <= 8'b0000_1001;
        //Letras de aquí para abajo
        6'd10: catodos <= 8'b0000_010_1; //a 
        6'd11: catodos <= 8'b1100_000_1; //b
        6'd12: catodos <= 8'b1110_010_1; //c
        6'd13: catodos <= 8'b1000_010_1; //d
        6'd14: catodos <= 8'b0110_000_1; //E
        6'd15: catodos <= 8'b0111_000_1; //F
        6'd16: catodos <= 8'b0100_001_1; //G
        6'd17: catodos <= 8'b1101_000_1; //h
        6'd18: catodos <= 8'b0111_011_1; //i
        6'd19: catodos <= 8'b1010_011_1; //j
        6'd20: catodos <= 8'b0101_000_1; //K
        6'd21: catodos <= 8'b1110_001_1; //L
        6'd22: catodos <= 8'b0101_010_1; //M
        6'd23: catodos <= 8'b1101_010_1; //n
        6'd24: catodos <= 8'b1100_010_1; //o
        6'd25: catodos <= 8'b0011_000_1; //P
        6'd26: catodos <= 8'b0001_100_1; //q
        6'd27: catodos <= 8'b1111_010_1; //r
        6'd28: catodos <= 8'b0100_101_1; //S
        6'd29: catodos <= 8'b1110_000_1; //t
        6'd30: catodos <= 8'b1100_011_1; //u
        6'd31: catodos <= 8'b1010_101_1; //v
        6'd32: catodos <= 8'b1010_100_1; //W
        6'd33: catodos <= 8'b1101_011_1; //x
        6'd34: catodos <= 8'b1000_100_1; //y
        6'd35: catodos <= 8'b0010_011_1; //Z
        6'd36: catodos <= 8'b0001_011_1; //@
        default: catodos <= 8'b1101_011_1;
    endcase
end

endmodule