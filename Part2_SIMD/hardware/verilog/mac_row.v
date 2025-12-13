// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module mac_row (clk, out_s, in_w, in_n, valid, inst_w, reset, conf);

  parameter bw = 4;
  parameter psum_bw = 16;
  parameter col = 8;
  parameter simd = 2;

  input  clk, reset, conf;
  output [psum_bw*col-1:0] out_s; //[127:0]
  output [col-1:0] valid;         //[7:0]
  input  [(simd*bw)-1:0] in_w;           //[3:0]
  input  [1:0] inst_w; // inst[1]:execute, inst[0]: kernel loading
  input  [psum_bw*col-1:0] in_n;  //[127:0]

  wire   [(col+1)*(simd*bw)-1:0] temp;    //[63:0]
  assign temp[(simd*bw)-1:0]   = in_w;   //temp[3:0]
  
  wire   [(col+1)*2-1:0] inst_temp;
  assign inst_temp[1:0] = inst_w; // Pass instruction through column
  
  
  genvar i;
  generate
      for (i=1; i < col+1 ; i=i+1) begin : col_num

          
          mac_tile #(.bw(bw), .psum_bw(psum_bw)) mac_tile_instance (
             .clk(clk),
             .reset(reset),
         .in_w( temp[(simd*bw)*i-1:(simd*bw)*(i-1)]), //[3:0], [7:4]... needs changing size of east and west is going to be different.
         .out_e(temp[(simd*bw)*(i+1)-1:(simd*bw)*i]), //[7:4], [11:8]
         
         .inst_w(inst_temp[2*i-1:2*(i-1)]), //[1:0], [3:2]
         .inst_e(inst_temp[2*(i+1)-1:2*i]),
         
         .in_n(in_n[psum_bw*i-1:psum_bw*(i-1)]),    //[15:0], [31:16]
         .out_s(out_s[psum_bw*i-1:psum_bw*(i-1)]),
	 .conf(conf)
         ); //[15:0], [31:16]
         
         assign valid[i-1] = inst_temp[2*(i+1)-1]; 
      end
      
      
  endgenerate
  
endmodule




