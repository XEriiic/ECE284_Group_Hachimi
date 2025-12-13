module sfp (clk, reset, acc, in, out, act);

parameter bw = 4;
parameter psum_bw = 16;
parameter thresh_val = 10;
parameter shift_val = 3;

input clk;
input reset;

input [1:0] act;
input acc;
//input relu; // Decide the function of sfp.v (either accumulate or ReLU)

input signed [psum_bw-1:0] in;
output signed [psum_bw-1:0] out;
reg signed [psum_bw-1:0] psum_q;

assign out = (act == 0) ? psum_q : ((act == 1) ? ((psum_q[psum_bw-1] == 0)? psum_q : 0) : ((act == 2) ? ((psum_q[psum_bw-1] == 0)? psum_q : psum_q >> shift_val) : ((psum_q > thresh_val) ? psum_q - thresh_val : ((psum_q > -thresh_val) ? 0 : psum_q + thresh_val))) );

always @(posedge clk) begin
	if (reset == 1)begin
        psum_q <= 0;
end
    else begin
	   if (acc == 1)begin
        psum_q <= psum_q + in;
end
else if (acc == 0) begin
        psum_q <= psum_q;
end
    end
        
end

endmodule
