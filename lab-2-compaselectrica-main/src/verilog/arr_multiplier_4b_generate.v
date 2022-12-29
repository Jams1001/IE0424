module array_multiplier_4b_generate (
    input resetn,
	input [3:0] A,  
	input [3:0] B,  
	output [7:0] out_generate_4b
);

wire [3:0] wA[3:0];  
wire [3:0] wB[3:0];  
wire [4:0] wCarry[3:0];
wire [3:0] wR[3:0];

genvar row, col; // Counters
    generate
    	for (row = 0; row < 4; row = row + 1) begin

    		assign wCarry[row][0] = 0; 
    		if (row != 3) begin
    			assign out_generate_4b[row] = wR[row][0];  
    		end

    		for (col = 0; col < 4; col = col+1) begin

    			adder_bh arr_adder_bh(
                    .A(wA[row][col]), 
                    .B(wB[row][col]), 
                    .resetn(resetn),
    			    .R(wR[row][col]), 
                    .c_in(wCarry[row][col]), 
                    .c_out(wCarry[row][col+1])
                );

    			assign wA[row][col] = (A[col] & B[row]);

    			if (row == 0) begin
    				assign wB[0][col] = 0;
    			end 
                
                else begin
    				if (col == 3) begin
    					assign wB[row][3] = wCarry[row-1][4];
    				end 
                    else begin
    					assign wB[row][col] = wR[row-1][col+1];
    				end
    			end

    			if (row == 3) begin
    				assign out_generate_4b[3+col] = wR[3][col];
    			end
    		end
    	end
    	assign out_generate_4b[7] = wCarry[3][4];
    
    endgenerate
endmodule


module adder_bh (
	input A,
	input B,
	input c_in,
	input resetn,
	output reg R,
	output reg c_out);
	
	always @(*) begin
	    if (resetn) begin
	        {c_out, R} <= A + B + c_in;
	    end 
        else begin
	        c_out <= 0;
	        R <= 0;
	    end
	end
endmodule