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

## retval = FFT_IRs(ir_all, D, Q, Nfft);
##
## FFT all the impulse responses in the data structure.

## Author: Gabriel Zalles <gabrielzalles@Gabriels-MacBook-Pro.local>
## Created: 2023-02-27

function retval = FFT_IRs(ir_all, D, Q, Nfft);
  
  ir_len = size(ir_all, 3);
  
  ir_single = zeros(ir_len, 1); #temp var for single IR (one q, at one d)
  IR_ALL = zeros(D, Q, Nfft); #temp var for FFTd ir_all

for d = 1:1:D
  for q = 1:1:Q
    
    ir_single(:, 1) = ir_all(d, q, :); #extract one ir
    IR_ALL(d, q, :) = fft(ir_single, Nfft); #fft and index
    
  endfor
endfor

retval = IR_ALL;

endfunction
