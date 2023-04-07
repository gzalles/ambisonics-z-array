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

## function [pk_IRs, SH_max_idx] = getSH_peaks(SH_ALL, k, Nfft, numHarms)
##
## A function which returns the IR corresponding to the maximum value in the
## SH at a bin k. I.e. pick 1kHz and obtain the d (meas. direction)
## corresponding to the max of SHs. The extracted IR is used for inv-filtering.
## We call this B-format equalization or calibration. 

## Author: Gabriel Zalles <gabrielzalles@Gabriels-MacBook-Pro.local>
## Created: 2023-02-28

function [pk_IRs, SH_max_idx] = getSH_peaks(SH_ALL, k, Nfft, numHarms)
  
  SH_max_idx = zeros(size(SH_ALL, 2), 1);
 
  #let us find the N indices for these max values
  for harm = 1:1:size(SH_ALL, 2)
    SH = SH_ALL(:, harm, k); #get one harmonic, at bin k (i.e., 1kHz)
    [~, SH_max_idx(harm)] = max(abs(SH)); #get index of max (magnitude)
    #this index corresponds to angle from meas data 
  endfor

  #the better the meas. the better the max idx will be to the true peak of the SH
  # !!! they are a bit off right now
  #   if you want perfect use simulation

  #once we know the angles we want to extract that IR at d (get all bins)
  #and make an inverse filter to flatten the response
  pk_IRs = zeros(numHarms, Nfft); #peak IRs

  #extract numHarm IRs from SH_all (one dir, all bins)
  for harm = 1:size(pk_IRs, 1);
    pkDir = SH_max_idx(harm); #get direction corresponding to max peak @1kHz
    pk_IRs(harm, :) = SH_ALL(pkDir, harm, :); #extract 4 BF IRs
  end

endfunction
