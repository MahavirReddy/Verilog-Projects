module fulladder(
    input a,
    input b,
    input c,
    output reg sum,
    output reg carry
);
always @(*) begin
    sum = a ^ b ^ c;
    carry = (a & b) | (b & c) | (a & c);
end
endmodule

module practice(x,y,z,ca,sum);
input wire [3:0]x;
input wire [3:0]y;
input wire z;
wire [2:0]v;
output [3:0]sum;
output ca;
fulladder f1(x[0],y[0],z,sum[0],v[0]);
fulladder f2(x[1],y[1],v[0],sum[1],v[1]);
fulladder f3(x[2],y[2],v[1],sum[2],v[2]);
fulladder f4(x[3],y[3],v[2],sum[3],ca);
endmodule
