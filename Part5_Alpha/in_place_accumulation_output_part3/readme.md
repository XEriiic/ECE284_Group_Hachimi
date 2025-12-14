# In-place accumulation for the psums of the output stationary configuration of part 3

Introducing in-place accumulation for the psums of the output stationary configuration for our design in part 3 has two positive benefits: The number of times required to transport the psums to the output fifo and then to memory is reduced from the number of input channels to 1. Secondly the number of times data is sent to and from the psum memory is greatly reduced for both sending data to the psum and for accumulation in the sfp. The second benefit of implementing this is that it not only reduces the number of cycles required to complete the operation, but it also uses the bus connecting the ofifo to the psum memory much less which can be costly in terms of energy and may reduce the possible achievable frequency of our chip design which is not optimal.

## Improvement:
### Calculation of improvement in terms of clock cycles:

Before in-place accumulation: 
- Sending data to ofifo and then psum memory: (input channels) x (number of output features) + 1
- Sending data to sfp for accumulation and activation to generate all output features: (input channels) + 1

After in-place accumulation:
- Sending data to ofifo and then psum memory: (number of output features) + 1
- Sending data to sfp for accumulation and activation to generate all output features: 1

#### Total Reduction of clock cycles: [{(input channels) x (number of output features) + (input channels) + 2} - {(number of output features) + 2}] = (input channels - 1) x (number of output features) + (input channels)

## Implementation in Hardware:
The hardware implements in-place accumulation by using a control bit called "hold_cq". It is named this weight because in the output stationary configuration of part3's design, cq holds the psums. when hold_cq = 1 applying reset = 1 when mac_tile_version == 1 (which means we are in the output stationary configuration) to flush out the contents in the ififo's and the bq and aq registers does not flush out the contents in the cq register and allows it to accumulate accross all the input channels being processed. This has already been implemented in part3's design. We have added the mac_tile.v and corelet.v files from part3 to this folder for inspection. We note that in the corelet.v file a control bit called "mac_deliver" controls when all the accumulated output features are finally sent down to the ofifo. When this is the case, out_s is assigned to c_q and in_n latches to the port of cq to begin transporting the output feature data from the north to the southernmost cq and then to the ofifo.

This is the code in the testbench used to begin transportation of the contents in the cq registers to the ofifo:
```
///////////Transport c_q's to ofifo///////////////////////
for (i=0; i<row; i=i+1) begin
      #0.5 clk = 1'b0; mac_deliver = 1;
      #0.5 clk = 1'b1;
    end

    
    #0.5 clk = 1'b0; mac_deliver = 0;
    #0.5 clk = 1'b1;   
/////////////////////////////////////////////////////////
```

and this is how the control logic for hold_cq is implemented in mac_tile to hold cq's contents:

```
 if (reset) begin
        inst_q <= 2'b00;
        load_ready_q <= 1'b1;
        a_q <= 0;
        b_q <= 0;
        c_q <= (mac_tile_version == 1 && hold_cq == 1) ? c_q : 0;
```
