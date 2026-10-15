module Upcounter(input clk, input rst, output [3:0] out);
wire [3:0] D_inputs;

assign D_inputs[0] = ~out[0];
assign D_inputs[1] = out[1] ^ out[0];
assign D_inputs[2] = out[2] ^ (out[1] & out[0]);
assign D_inputs[3] = out[3] ^ (out[2] & out[1] & out[0]);

dff d1(.clk(clk), .rst(rst), .in(D_inputs[0]), .out(out[0]));
dff d2(.clk(clk), .rst(rst), .in(D_inputs[1]), .out(out[1]));
dff d3(.clk(clk), .rst(rst), .in(D_inputs[2]), .out(out[2]));
dff d4(.clk(clk), .rst(rst), .in(D_inputs[3]), .out(out[3]));

endmodule


module DownCounter(input clk, input rst, output [3:0] out);
wire [3:0] D_inputs;

assign D_inputs[0] = ~out[0];
assign D_inputs[1] = out[1] ^ (~out[0]);
assign D_inputs[2] = out[2] ^ (~out[1] & ~out[0]);
assign D_inputs[3] = out[3] ^ (~out[2] & ~out[1] & ~out[0]);

dff d1(.clk(clk), .rst(rst), .in(D_inputs[0]), .out(out[0]));
dff d2(.clk(clk), .rst(rst), .in(D_inputs[1]), .out(out[1]));
dff d3(.clk(clk), .rst(rst), .in(D_inputs[2]), .out(out[2]));
dff d4(.clk(clk), .rst(rst), .in(D_inputs[3]), .out(out[3]));

endmodule


module dff(input clk, input rst, input in, output reg out);

always @(posedge clk)
begin
    if (rst)
        out <= 1'b0;
    else
        out <= in;
end

endmodule


module Practice(input clk, input rst, input sel, output [3:0] out);
wire [3:0] up_out;
wire [3:0] down_out;

Upcounter A(.clk(clk), .rst(rst), .out(up_out));
DownCounter B(.clk(clk), .rst(rst), .out(down_out));

assign out = sel ? down_out : up_out;

endmodule
