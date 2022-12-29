module seven_segment_hex(
    input [31:0] num,
    input clk,
    output  reg [7:0] catodos,
    output  reg [7:0] anodos
);


reg [31:0] counter = 0;
reg [3:0] mux_out;


always@(posedge clk )begin 
    if (counter == 32'hFFFFFFFF) begin
        counter <= 0;
    end
     counter = counter + 1;
end

always@(*) begin 

    case(counter[16:14])
        3'd0: mux_out <= num[3:0];
        3'd1: mux_out <= num[7:4];
        3'd2: mux_out <= num[11:8];
        3'd3: mux_out <= num[15:12];
        3'd4: mux_out <= num[19:16];
        3'd5: mux_out <= num[23:20];
        3'd6: mux_out <= num[27:24];
        3'd7: mux_out <= num[31:28];
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
        4'h0: catodos <= 8'b0000_0011; //Last bit: dot
        4'h1: catodos <= 8'b1001_1111;
        4'h2: catodos <= 8'b0010_0101;
        4'h3: catodos <= 8'b0000_1101;
        4'h4: catodos <= 8'b1001_1001;
        4'h5: catodos <= 8'b0100_1001;
        4'h6: catodos <= 8'b0100_0001;
        4'h7: catodos <= 8'b0001_1111;
        4'h8: catodos <= 8'b0000_0001;
        4'h9: catodos <= 8'b0000_1001;
        4'hA: catodos <= 8'b0001_0001;
        4'hB: catodos <= 8'b1100_0001;
        4'hC: catodos <= 8'b0110_0011;
        4'hD: catodos <= 8'b1000_0101;
        4'hE: catodos <= 8'b0110_0001;
        4'hF: catodos <= 8'b0111_0001;
        default: catodos <= 8'b0000_0010;
    endcase 

end

endmodule


