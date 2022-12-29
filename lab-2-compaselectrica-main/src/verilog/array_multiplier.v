
module array_multiplier_4b (
  input [3:0] A,
	input [3:0] B,
	input resetn,
	output reg [7:0] out);

  wire [5:0] R;
	wire [10:0] carry;
	wire [7:0] out_test;
	wire r1, r2;

	// Fila 1
	assign out_test[0] = A[0] & B[0];  // R0
	assign r1 = A[1] & B[0];
	assign r2 = A[0] & B[1];
	assign {carry[0], out_test[1]} = (A[0] & B[1]) + (A[1] & B[0]);  // R1
	assign {carry[1], R[0]} = (A[2] & B[0]) + (A[1] & B[1]) + carry[0];
	assign {carry[2], R[1]} = (A[3] & B[0]) + (A[2] & B[1]) + carry[1];
	assign {carry[3], R[2]} = A[3] & B[1] + 0 + carry[2];

	// Fila 2
	assign {carry[4], out_test[2]} = (A[0] & B[2]) + R[0];  // R2
	assign {carry[5], R[3]} = (A[1] & B[2]) + R[1] + carry[4];
	assign {carry[6], R[4]} = (A[2] & B[2]) + R[2] + carry[5];
	assign {carry[7], R[5]} = (A[3] & B[2]) + carry[3] + carry[6];

	// Fila 3
	assign {carry[8], out_test[3]} = (A[0] & B[3]) + R[3]; // R3
	assign {carry[9], out_test[4]} = (A[1] & B[3]) + R[4] + carry[8];
	assign {carry[10], out_test[5]} = (A[2] & B[3]) + R[5] + carry[9];
	assign {out_test[7], out_test[6]} = (A[3] & B[3]) + carry[7] + carry[10];

	always @(*) begin
		out <= out_test;
	end

endmodule // array_multiplier_4b
