// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module mac (out, a, b, c, conf);

parameter bw = 4;
parameter psum_bw = 16;
parameter simd = 2;

input conf;
output signed [psum_bw-1:0] out; // sent south
input [bw-1:0] a;  // activation 4 bits changed from signed to nothing.
input [simd*bw-1:0] b;  // weight 8 bits

input signed  [psum_bw-1:0] c; // psum_bw from in_n
wire signed [psum_bw-1:0] product_msb;
wire signed [psum_bw-1:0] product_lsb;
wire signed [bw:0] a_pad_msb;
wire signed [bw:0] a_pad_lsb;
wire signed [bw-1:0] b_msb;
wire signed [bw-1:0] b_lsb;
wire signed [psum_bw-1:0] choice; 

assign a_pad_msb = {3'b000, a[3:2]};
assign a_pad_lsb = {3'b000, a[1:0]};

assign b_lsb = b[(simd-1)*bw-1:0];
assign b_msb = b[simd*bw-1:(simd-1)*bw];

assign product_msb = a_pad_msb * b_msb;
assign product_lsb = a_pad_lsb * b_lsb;

assign choice = (conf == 0) ? product_msb + product_lsb : (product_msb << 2) + product_lsb;
assign out = choice + c;

/*
wire signed [2*bw:0] product;
wire signed [psum_bw-1:0] psum;
wire signed [bw:0]   a_pad;

assign a_pad = {1'b0, a}; // force to be unsigned number
assign product = a_pad * b;

assign psum = product + c;
assign out = psum;
*/
endmodule
