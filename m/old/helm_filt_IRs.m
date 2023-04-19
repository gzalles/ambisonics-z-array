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

## function retval = helm_filt_IRs (ir_all, D, Q, helm)
##
## A simple function which applies the helmholtz filter to the MEMS capsules.
## The helmholtz filter is used to remove the resonance above 10kHz 
## that many MEMS sensors exhibit. 

## Author: Gabriel Zalles <gabrielzalles@Gabriels-MacBook-Pro.local>
## Created: 2023-02-27

function retval = helm_filt_IRs (ir_all, D, Q, helm)
  
#apply helmholtz filter to IRs

for d =1:1:D
  for q = 1:1:Q
    ir_single(:, 1) = ir_all(d, q, :); #extract a single ir from mat
    ir_all(d, q, :) =  filter(helm, 1, ir_single);#filter the ir (signal pkg) 
    # [helmholtz]
  endfor
endfor

retval = ir_all;

endfunction
