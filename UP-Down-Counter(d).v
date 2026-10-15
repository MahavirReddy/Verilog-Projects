module dff(input clk, input rst, input set, input in, output reg out);
    always @(posedge clk) begin
        if (rst)      out <= 1'b0;
        else if (set) out <= 1'b1;
        else          out <= in;
    end
endmodule

module Upcounter(input clk, input rst, input [4:0] mod, output [3:0] out);
    wire [3:0] top = mod - 1'b1;          // mod = 2..16
    wire [3:0] D;
    wire clr = rst | (out >= top);        // >= so it recovers if mod is lowered mid-count

    assign D[0] = ~out[0];
    assign D[1] = out[1] ^ out[0];
    assign D[2] = out[2] ^ (out[1] & out[0]);
    assign D[3] = out[3] ^ (out[2] & out[1] & out[0]);

    dff d0(.clk(clk), .rst(clr), .set(1'b0), .in(D[0]), .out(out[0]));
    dff d1(.clk(clk), .rst(clr), .set(1'b0), .in(D[1]), .out(out[1]));
    dff d2(.clk(clk), .rst(clr), .set(1'b0), .in(D[2]), .out(out[2]));
    dff d3(.clk(clk), .rst(clr), .set(1'b0), .in(D[3]), .out(out[3]));
endmodule

module DownCounter(input clk, input rst, input [4:0] mod, output [3:0] out);
    wire [3:0] top = mod - 1'b1;
    wire [3:0] D;
    wire load = rst | (out == 4'b0000);   // reload N-1 when we hit 0

    assign D[0] = ~out[0];
    assign D[1] = out[1] ^ ~out[0];
    assign D[2] = out[2] ^ (~out[1] & ~out[0]);
    assign D[3] = out[3] ^ (~out[2] & ~out[1] & ~out[0]);

    // For each bit: if top[i]=1 -> set on load, if top[i]=0 -> reset on load
    dff d0(.clk(clk), .rst(load & ~top[0]), .set(load & top[0]), .in(D[0]), .out(out[0]));
    dff d1(.clk(clk), .rst(load & ~top[1]), .set(load & top[1]), .in(D[1]), .out(out[1]));
    dff d2(.clk(clk), .rst(load & ~top[2]), .set(load & top[2]), .in(D[2]), .out(out[2]));
    dff d3(.clk(clk), .rst(load & ~top[3]), .set(load & top[3]), .in(D[3]), .out(out[3]));
endmodule

module Practice(input clk, input rst, input sel, input [4:0] mod, output [3:0] out);
    wire [3:0] up_out, down_out;
    Upcounter   A(.clk(clk), .rst(rst), .mod(mod), .out(up_out));
    DownCounter B(.clk(clk), .rst(rst), .mod(mod), .out(down_out));
    assign out = sel ? down_out : up_out;
endmodule
