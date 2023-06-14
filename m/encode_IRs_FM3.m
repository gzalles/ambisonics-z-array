## Copyright (C) 2023 Gabriel Zalles
##
## This program is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <https://www.gnu.org/licenses/>.

## This function should take AF IRs and encode them using a filter matrix
## rather than a static matrix of coefficients. The filter matrix can 
## be derived either using measurements or simulations. The purpose of this
## operation is to determine if the FM (filter matrix) has any benefit to
## to the simple BF equalization (it allows us to see the response of the
## array at multiple frequencies). 
##
## Note: due to spherical properties of HOA we need to run this various times
## using different "poses" as are input data. I.e. can't sample Z using horizontal
## meas. 

## SH_ALL_FM = encode_IRs_FM3 (ir_all, filt_mat, D, Q, Nfft);

## Author: Gabriel Zalles <gabrielzalles@Gabriels-MacBook-Pro.local>
## Created: 2023-04-18

# this versions tries to make sure we don't do any circular convolution. 

function SH_ALL_FM = encode_IRs_FM3(ir_all, filt_mat, D, Q, Nfft)

numHarms = size(filt_mat, 2); #num of harmonics

# FILT_MAT has dimensions (Q, numHarms, Nfft)
# IR_ALL has dimensions (D, Q, Nfft)

AF_ir_single = zeros(Nfft*2, 1); #AF impulse response (just one)
curr_h = zeros(Nfft, 1); #current filter 
CURR_SH = zeros(Nfft, 1); #current spherical harmonic

SH_ALL_FM = zeros(D, numHarms, Nfft); #output variable
convLen = size(ir_all, 3) + size(filt_mat, 3) - 1; #conv_len (M + N -1)
convResult = zeros(convLen, 1); 

# I can't use matrix of bins, the phase gets ignored. I have to take each filter
# and fully convolve the signals one at a time. 
for d = 1:1:D
  for q = 1:1:Q
    for harm = 1:1:numHarms
     
     #one q (single sensor)
     AF_ir_single(1:end) = ir_all(d, q, :); #get one IR from AF from single direction
     
     #current filter we need to use 
     curr_h(1:end) = filt_mat(q, harm, :);
     
     #convolve and fft
     convResult(1:end) = conv(AF_ir_single, curr_h, "full");
     CONV_RESULT = fft(convResult, Nfft);
     
     #get current spherical harmonic output vector
     CURR_SH(1:end, 1) = SH_ALL_FM(d, harm, :);
     
     #sum each Q convolved with corresponding filter to output channel
     SH_ALL_FM(d, harm, :) = CURR_SH + CONV_RESULT;
     
    endfor
    
  endfor
endfor

# FILT_MAT are complex, output will have complex values (IR_ALL is complex)
# the output SH_ALL_FM will have dimensions (D, numHarms, Nfft); 

endfunction
