`timescale 1 ns / 1 ps

module system_tb;

	reg clk = 1;
	//reg [31:0] int = 0;
	always #5 clk = ~clk;
	//always #100000 int[31] = ~int[31];


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
	wire [7:0] out_byte;
	wire out_byte_en;
	wire [7:0] catodos, anodos;
	wire MISO;
	wire MOSI;
	wire CS;
	wire SCLK;

	system uut (
		.clk        (clk        ),
		.resetn     (resetn     ),
		//.int		(int		),
		.trap       (trap       ),
		.out_byte_en(out_byte_en),
		.out_byte   (out_byte   ),
		.catodos	(catodos),
		.anodos		(anodos),
		.MISO		(MISO),
		.MOSI		(MOSI),
		.CS			(CS),
		.SCLK		(SCLK)
);

	always @(posedge clk) begin
		if (resetn && out_byte_en) begin
			$write("%c", out_byte);
			$fflush;
		end
		if (resetn && trap) begin
			$finish;
		end
	end
endmodule
