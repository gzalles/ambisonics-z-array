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

## function ir_all = getIR (s1, D, ir_len, Q)

## A simple function which extracts the IRs from tthe struct created
## by ScanIR. 
##
## s1 = struct from ScanIR
## D = number of directions (how many steps)
## ir_len = length of impulse responses
## Q = number of sensors 

## Author: Gabriel Zalles <gabrielzalles@Gabriels-MacBook-Pro.local>
## Created: 2023-02-27

function ir_all = getIR (s1, D, ir_len, Q)

ir_all = zeros(D, Q, ir_len);

for d = 1:1:D
    ir = s1(d).IR; #get ir for direction d (there are q of these)
    ir_all(d, 1:end, 1:end) = ir'; #place values within mat (transpose)
endfor

endfunction
