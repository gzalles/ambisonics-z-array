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

## SH_ALL_FM = encode_IRs_FM2 (IR_ALL, filt_mat, D, Q, Nfft);

## Author: Gabriel Zalles <gabrielzalles@Gabriels-MacBook-Pro.local>
## Created: 2023-04-18

function SH_ALL_FM = encode_IRs_FM2(IR_ALL, filt_mat, D, Q, Nfft)

numHarms = size(filt_mat, 2); #num of harmonics
FILT_MAT = zeros(size(filt_mat));

#FFT the ir 
for q = 1:Q
  for harm = 1:numHarms
      one_h = filt_mat(q, harm, :);
      ONE_H = fft(one_h, Nfft);
      FILT_MAT(q, harm, :) = ONE_H;
endfor
endfor 

#enc_mat_sign = sign(enc_mat); #get signs from original encoding matrix

# FILT_MAT has dimensions (Q, numHarms, Nfft)
# IR_ALL has dimensions (D, Q, Nfft)
X = zeros(Q, numHarms); #temporary encoding matrix variable 
AF_bin_vec = zeros(Q, 1); #store complex values from IR_ALL
SH_ALL_FM = zeros(D, numHarms, Nfft); #output variable

# I can't use matrix of bins, the phase gets ignored. I have to take each filter
# and fully convolve the signals one at a time.
for d = 1:1:D
  for q = 1:1:Q
    for harm = 1:1:numHarms
     
     #one q (single sensor)
     AF_IR_single = IR_ALL(d, q, :); #get one IR from AF from single direction
     #current filter we need to use 
     CURR_H = FILT_MAT(q, harm, :);
     
     #SH_ALL_FM = zeros(D, numHarms, Nfft);
     SH_ALL_FM(d, harm, :) = SH_ALL_FM(d, harm, :) + CURR_H.* AF_IR_single;
     
    endfor
    
  endfor
endfor

disp("There might be some circular conv going on!");


## old code bad

### we need to take one Q by 1 vector from IR_ALL and multiply by corresponding 
### encoding matrix at that bin. the marix is the same for all D but different for each k
##
##for d = 1:1:D
##  
##  for k = 1:1:Nfft
##    
##    X = FILT_MAT(:, :, k); #get one encoding matrix at bin k
##    #X = X .* enc_mat_sign; #apply sign values back to matrix
##    AF_bin_vec = IR_ALL(d, :, k); #get one bin from dir d
##    SH_ALL_FM(d, :, k) =  X * AF_bin_vec'; #multiply mat by vec, get BF vec at bin k 
##    
##  endfor
##endfor

# FILT_MAT are complex, output will have complex values (IR_ALL is complex)
# the output SH_ALL_FM will have dimensions (D, numHarms, Nfft); 
endfunction
