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

## SH_ALL = encode_IRs(enc_mat, D, Q, Nfft, IR_ALL);
##
## Function used to encode the AF signals using encoding matrix.

## Author: Gabriel Zalles <gabrielzalles@Gabriels-MacBook-Pro.local>
## Created: 2023-02-27

function SH_ALL = encode_IRs(enc_mat, D, Q, Nfft, IR_ALL);

#columns = numHarms, pre-transpose
numHarms = size(enc_mat, 2); 

#tranpose the enc mat
enc_mat = enc_mat'; 
bin_vec = zeros(Q, 1); #encode one bin at a time (for all Q)
SH_ALL = zeros(D, numHarms, Nfft); #new variable to avoid confusion

#note: numHarms does not always equal to Q
for d = 1:1:D
  for k = 1:1:Nfft
    #get the first bin of each IR in P1
    bin_vec = IR_ALL(d, :, k);
    bin_vec = enc_mat * bin_vec'; #perform dot product operation [4x1] encoded
    SH_ALL(d, :, k) = bin_vec;
  endfor 
endfor

endfunction
