module SerialShifter (
    input clk,
    input [7:0] data,
    input rst,
    output [3:0] q
);

    reg [7:0] data_reg;
    integer i;

    always @(posedge clk) begin
        if (rst) begin
            i <= 0;
            data_reg <= data;
        end
        else if (i < $bits(data_reg)) begin
            i <= i + 1;
        end
    end

    dff d1 (.clk(clk), .rst(rst), .in(data_reg[i]), .out(q[0]));
    dff d2 (.clk(clk), .rst(rst), .in(q[0]), .out(q[1]));
    dff d3 (.clk(clk), .rst(rst), .in(q[1]), .out(q[2]));
    dff d4 (.clk(clk), .rst(rst), .in(q[2]), .out(q[3]));

endmodule


module dff (
    input clk,
    input rst,
    input in,
    output reg out
);

    always @(posedge clk) begin
        if (rst)
            out <= 1'b0;
        else
            out <= in;
    end

endmodule
