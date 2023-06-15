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

## function retval = conv_IRs (IR_ALL, D, Q, Nfft, IR)
##
## Convolve all IRs with some arbitrary IR. Used for example to compensate for
## transfer function applied by speaker. If IR is mat, the use the IRs in 
## sequential order. Used to calibrate AF and BF. 

## Author: Gabriel Zalles <gabrielzalles@Gabriels-MacBook-Pro.local>
## Created: 2023-02-27

function retval = conv_IRs (IR_ALL, D, Q, Nfft, IR)
 
 #sometimes var Q switched for numHarms (during BF calib)
 
 IR_SINGLE = zeros(Nfft, 1); #init mem for single ir FFTd (Nfft by 1)

   if isvector(IR) #used to convolved all IRs with speaker EQ
     for d = 1:1:D
       for q = 1:1:Q
        
        IR_SINGLE(:, 1) = IR_ALL(d, q, :);
        IR_ALL(d, q, :) = IR_SINGLE .* IR; #conv with IR
        
        endfor
      endfor
  
  else #used to convolve all DFRs with AF calib filt, or BF peaks with inv filters
    
    for d = 1:1:D
      for q = 1:1:Q
        
      IR_SINGLE(:, 1) = IR_ALL(d, q, :);#extract one IR 
      H = IR(q, :); #extract one inverse filter (min-phase)
      IR_ALL(d, q, :) = IR_SINGLE .* H'; #conv with filter

      endfor
     endfor
    
  endif

retval = IR_ALL;

endfunction
