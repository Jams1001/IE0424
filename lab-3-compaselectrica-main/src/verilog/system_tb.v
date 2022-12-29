`timescale 1 ns / 1 ps

module system_tb;
	reg clk = 1;
	reg sw0 = 0;
	always #5 clk = ~clk;
	always #1000000 sw0 = ~sw0;

	reg resetn = 0;
	initial begin
		if ($test$plusargs("vcd")) begin
			$dumpfile("system.vcd");
			$dumpvars(0, system_tb);
		end
		repeat (100) @(posedge clk);
		resetn <= 1;
	end

	wire trap;
	wire [7:0] out_byte, catodos, anodos;
	wire out_byte_en;

	system uut (
		.clk        (clk        ),
		.resetn     (resetn     ),
		.sw0		(sw0		),
		.trap       (trap       ),
		.out_byte   (out_byte   ),
		.out_byte_en(out_byte_en),
		.catodos	(catodos),
		.anodos		(anodos)
	);

	always @(posedge clk) begin
		if (resetn && out_byte_en || sw0 && out_byte_en) begin
			$write("%c", out_byte);
			$fflush;
		end
		if (resetn && trap || sw0 && trap) begin
			$finish;
		end
	end
endmodule
