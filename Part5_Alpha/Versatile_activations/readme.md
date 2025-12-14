# Applying LeakyRelu and the SoftShrink activation functions to both Part2 and Part3's designs:

  To make our designs more versatile to different convolutional networks, we wanted to implement additional activation functions in the sfp module. We chose LeakyRelu and SoftShrink for these reasaons:
  
   - Leaky ReLU is important for some convolutional networks because it prevents neurons from dying by allowing a small, non-zero gradient for negative inputs, improving training stability and feature learning.
   - Softshrink is important for some convolutional networks because it suppresses small-magnitude noise while preserving meaningful signal structure, a property that is especially valuable in medical imaging applications such as MRI, CT, and ultrasound, where reducing artifacts and enhancing subtle anatomical features can significantly improve diagnostic accuracy.
     - An example of such a network used for EEG analysis is the ID3RSNet which uses soft shrinkage to adaptively eliminate redundant information and select the most discriminative useful features during feature learning. Thus, giving our designs the ability to apply this function allows networks such as this to utilize our designs for AI acceleration.

## Application in SFP:
To apply these 2 extra activation functions in the sfp, we equipped the sfp with a control register of size 2 bits called "act" which control which activation function to apply.
 - act == 0: no activation function
 - act == 1: Relu
 - act == 2: LeakyRelu
 - act == 3: SoftShrink

The amount of bits to shift to the right for relu is controlled by a reconfigurable parameter called shift_val, and the lambda threshold for soft shrinkage is also a reconfigurable parameter in the design called "thresh_val".

This line of code was used to implement the combinational logic for this functionality: 
assign out = (act == 0) ? psum_q : ((act == 1) ? ((psum_q[psum_bw-1] == 0)? psum_q : 0) : ((act == 2) ? ((psum_q[psum_bw-1] == 0)? psum_q : psum_q >> shift_val) : ((psum_q > thresh_val) ? psum_q - thresh_val : ((psum_q > -thresh_val) ? 0 : psum_q + thresh_val))) );

## LeakyRelu Application:
To apply leaky relu before dequantizing the output feature map, bit shifting by 3 to the right is almost equivalent to multiplication by 0.1 which is the negative slope of the LeakyRelu activation function (2^-3 = 0.125 ~ 0.1), so applying this before dequantization is almost equivalent to applying it after dequantizing and introduces only negligable error.
To emulate this in python and use it to produce output txt files for texting, this is the function used in the alpha_leaky notebook:

<img width="447" height="403" alt="image" src="https://github.com/user-attachments/assets/a0b8ede7-1c6f-440b-9e25-cbd230e7126c" />

## SoftShrink Application:
Soft shrinkage is an activation function which zero's out a symmetrical region around the point 0, [-λ,λ],which is delimited by a threshold λ, set to 0.5 for our experiments. for the region (-∞,λ): f(x) = x + λ and for the region (λ,+∞): f(x) = x - λ.

However, we cannot apply the floating point lambda as the threshold to use in our design. Therefore, we will need to find the equivalent λ in the quantized domain to apply to the quantized output feature map. To find this threshold which we use as our thresh_val parameter in the sfp module, we need to find an integer c such that:

$$
T
<
\left|
(c+1)
\left( \frac{\alpha_{\text{act}}}{2^{\alpha_a} - 1} \right)
\left( \frac{\alpha_{w}}{2^{\alpha_w - 1} - 1} \right)
\right|
\quad \text{and} \quad
T \ge
\left|
c
\left( \frac{\alpha_{\text{act}}}{2^{\alpha_a} - 1} \right)
\left( \frac{\alpha_{w}}{2^{\alpha_w - 1} - 1} \right)
\right|
\quad (1)
$$

This can be achieved by this operation 
$$
\lambda_{\text{int}} = \text{round}\left(\frac{\lambda}{\Delta_{\text{out}}}\right)
$$

This is emulated in the alpha_soft_shrink notebook using this function:

<img width="685" height="482" alt="image" src="https://github.com/user-attachments/assets/71369473-9cdf-4776-a1b4-7e176e031b85" />

