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

## function DFR = getDFR(IR_ALL, D, Q, Nfft);
##
## Function used to calculate the diffuse field response from a set of meas. 
## Can also be used to get DFR of SHs.
##
## See: Middlicott 2019 Calibration Paper

## Author: Gabriel Zalles <gabrielzalles@Gabriels-MacBook-Pro.local>
## Created: 2023-02-27

function DFRs = getDFR(IR_ALL, D, Q, Nfft);

DFRs = zeros(Q, Nfft); #init memory for DFRs matrix

for q = 1:1:Q #move through sensors
  for d = 1:1:D #move through meas
    
    IR_SINGLE(:, 1) = IR_ALL(d, q, :); #copy a single meas
    IR_SINGLE(:, 1) = abs(IR_SINGLE); #get mag
    IR_SINGLE(:, 1) = IR_SINGLE.^2; #square 
    
    DFRs(q, :) = DFRs(q, :) + IR_SINGLE'; #add all the vectors together
    
  endfor
  
  DFRs(q, 1:end) = DFRs(q, 1:end) .* 1/D; #take average (1/D) 
  DFRs(q, 1:end) = sqrt(DFRs(q, 1:end)); #take square root 
  
endfor

endfunction
