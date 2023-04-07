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

## function ir_all = resampleIRs(newFs, oldFs, ir_all, D, Q, ir_len);
##
## In case Fs is not matching, use this function to resample IRs to correct Fs.

## Author: Gabriel Zalles <gabrielzalles@Gabriels-MacBook-Pro.local>
## Created: 2023-02-27

function retval = resampleIRs(newFs, oldFs, ir_all, D, Q, ir_len);
 
  #example:
  #   y = resample (x,1,2);  
  #     downsample to 22500 from 44100 
  y = zeros(ir_len, 1); #temp var for resampled data

  for d = 1:1:D #loop through directions (meas. number)
      for q = 1:1:Q #loop through sensors
        
            ir_single(:, 1) = ir_all(d, q, :); #extract a single ir from mat
            [temp, ~] = resample(ir_single, newFs, oldFs); #downsample 
            y(1:length(temp)) = temp; #place resampled data in zeros vec
            ir_all(d, q, :) =  y; #put vec in mat 
      endfor
  endfor
  
  clear y;
  retval = ir_all; #input can't be named same as output
  
endfunction
