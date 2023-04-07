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

## function [H_inv, epsilon] = get_inv_filters(lim_vec, regLow, H_target, 
## ... H_original, Nfft, Fs, cutoff);
##
## Calculate the inverse filters with regularization parameter using Nelson-
## Kirkeby algorithm. The H_inv returned is already min. phase. We use the
## technique developed by JOS.
##
## Used for inv-filter of DFRs, as well as B-format calibration filters. Can
## also be used to get inv-filter of IR for speaker compensation.

## Author: Gabriel Zalles <gabrielzalles@Gabriels-MacBook-Pro.local>
## Created: 2023-02-27

function [H_inv, epsilon] = get_inv_filters(lim_vec, regLow, H_target, ...
  H_original, Nfft, Fs, cutoff);

#num sensors is dim 1 of H_original (could also be numHarms)
Q = size(H_original, 1);

#bin resolution in Hz
binRes = Fs/Nfft; 

#get the limiting values as approximate bin numbers
lim_vec = floor(lim_vec/binRes);

lfLim1Bin = lim_vec(1); #low frequency limit 
lfLim2Bin = lim_vec(2); #upper end of low frequency limit 
hfLim1Bin = lim_vec(3); #high frequency limit
hfLim2Bin = lim_vec(4); #upper end of of high frequency limit

#epsilon is the regularization vector
epsilon = zeros(Nfft/2, 1); 

#if the binRes is too low there will be an index error, this "fixes" it
if lfLim1Bin == 0
  lfLim1Bin = 1;
endif

#in order to use linspace we have to calculate number of bins between limits
epsilon(lfLim1Bin:lfLim2Bin, 1) = linspace(1, regLow, lfLim2Bin - lfLim1Bin + 1); 
epsilon(lfLim2Bin:hfLim1Bin, 1) = regLow; 
epsilon(hfLim1Bin:hfLim2Bin, 1) = linspace(regLow, 1, hfLim2Bin - hfLim1Bin + 1); 

#make it symmetric, since FFT of ir is also symmetric
epsilon = [epsilon; flipud(epsilon)];
H = zeros(Nfft, 1); #temp var for single q sensor DFR (or BF pk)
H_inv = zeros(size(H_original));#these are the inverse filters

#calculate inverse filters
for q =1:Q
  H(1:end) = H_original(q, :); #get the H_original for one sensor (or SH)
  H_inv(q, 1:end) = (H_target .* conj(H)) ./ (conj(H) .* H + epsilon); #perform NK inv 
  #filter formula w/ regularization param
endfor

S = zeros(1, Nfft); #temp var for spectrum 

#now we need to make the filter min-phase
for q =1:Q
  S = H_inv(q, 1:end); #the complex spectrum we want to make min-phase 
  # is the inverse filter
  
  #https://ccrma.stanford.edu/~jos/filters/Matlab_listing_mps_m.html
  H_inv(q, 1:end) = exp( fft( fold( ifft( log( clipdb(S,cutoff) )))));
endfor
 
endfunction
