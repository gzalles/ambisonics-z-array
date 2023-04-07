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

## enc_mat = calc_enc_mat(Q_pos, N, Q);
#
# Calculate encoding matrix for array based on sensor positions. 
# Q_pos should be in degrees and use standard ambi coord system.

## Author: Gabriel Zalles <gabrielzalles@Gabriels-MacBook-Pro.local>
## Created: 2023-02-27

function enc_mat = calc_enc_mat(Q_pos, N, Q);

enc_mat = zeros(Q, (N+1)^2);#var for encoding matrix

#get the SH coefficients for our array (in some cases we need to invert)
#if the array is not regular 
for q = 1:Q 
  phi = Q_pos(q, 1); 
  theta = Q_pos(q, 2); 
  coeffs = SH(phi, theta, N);
  enc_mat(q, :) = coeffs;
endfor

endfunction
