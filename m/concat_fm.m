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

## Concatenate filter matrix to use with Sparta VST. Matrix Conv VST.
##
## function concatenated_filters = concat_fm (filt_mat, numHarms, Nfft, Q)


## Author: Gabriel Zalles <gabrielzalles@Gabriels-MacBook-Pro.local>
## Created: 2023-04-19

function concatenated_filters = concat_fm (filt_mat, numHarms, Nfft, Q)

#the SPARTA example filter has 25 channels, one for each harmonic (4oa) 
#and each channel has 32 filters (one for each q)
concatenated_filters = zeros(numHarms, Nfft*Q);

#concatenate filters for export
for harm = 1:numHarms
  #alloc memory for one channel
  one_chan = zeros(Nfft*Q, 1); 
  #go through sensors
  for q = 1:Q;
    #calculate start and end index 
    s_idx = 1 + (q-1)*Nfft; 
    e_idx = Nfft + (q-1)*Nfft;
    #get one filter from matrix 
    one_filt = filt_mat(q, harm, :);
    #concatenate filters for each channel
    one_chan(s_idx:e_idx) = one_filt; 
  endfor
  #put one channel of the file into larger structure
  concatenated_filters(harm, :) = one_chan;
endfor


endfunction
