Part3_Reconfigurable software folder

The ece284_part3 notebook contains the required python code to train a quantized VGGNet16 with its 27th feature being a 8x8 input channel x output channel layer. We will not be using that layer though, instead we will used the first layer with 3 input channels and 64 output channels. For the output stationary design, activations are passed from west to east and weights are passed from north to south. Each row is an O_nij and each column represents an outupt channel. We tested the correctness of our design in generating the first 8 output feautures of the first 8 output channels. In order to generate the correct data, our python processed the input activations and weight activations in this way:

- Each row in the mac represents a feature in the output feature mape
 - Each column is the output channel of that feature in the output feature map
 - The time for loading weights and activations to the fifo's is equal to 3, because we have a set of 3 input channels to sum over to produce the output feature map
 - Each row in the Mac has to be the window of convolution over the activatino map which maps to the respective output feature in the output feature map, so row 1 is o_nij = 0 and row 8 is o_nij = 7. The time for each PE represents the index of the activation that is multiplied with the respective kij for that convolution operation.
 - The weight file contains rows that represent each kij from kij = 0 to kij = 8 for each of the output channels, 0 to 8.

The output txt file was generated in this way:

- Each row is a different O_nij, we note that in our testbench we test the correctness of each output feature from the 7th output feature down to the 0th output feature map, so the first row in the output txt file is output feature 7 going down ot output feature 0. We only tested the correctness of the first 8 output features for the first 8 output channels out of the 64 output channels.
