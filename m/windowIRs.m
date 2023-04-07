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

## function retval = windowIRs(ir_all, D, Q, win);
##
## A function to window all the IRs in the struct and zero out the first 
## value, to avoid spectral leakage during FFT and remove reflections.

## Author: Gabriel Zalles <gabrielzalles@Gabriels-MacBook-Pro.local>
## Created: 2023-02-27

function retval = windowIRs(ir_all, D, Q, win);
  
#window data

for d =1:1:D
  for q = 1:1:Q
    ir_single(:, 1) = ir_all(d, q, :); #extract a single ir from mat
    ir_single(1, 1) = 0; #zero first val.
    ir_single = ir_single .* win; #window ir with second half of window
    ir_all(d, q, :) = ir_single;
  endfor
endfor

retval = ir_all;

endfunction
