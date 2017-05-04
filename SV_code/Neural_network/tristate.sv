module tristate #(N = 16) (
	input wire Clk, OE,
	input [N-1:0] In,
	output logic [N-1:0] Out,
	inout wire [N-1:0] Data
);

logic [N-1:0] a, b;

assign Data = OE ? a : {N{1'bZ}};
assign Out = b;

always_ff @(posedge Clk)
begin
	b <= Data;
	a <= In;
end

endmodule