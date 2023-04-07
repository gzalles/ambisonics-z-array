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

## function norm_coeffs = sn3d_all(numHarms, N);
##
## Calculate a vector with SN3D normalization coefficients. N is the ambisonic
## order (i.e. 3 for third order ambisonics). When we perform B-format 
## EQualization we need to apply these gains to target filters, otherwise the
## normalization will be off. 

## Author: Gabriel Zalles <gabrielzalles@Gabriels-MacBook-Pro.local>
## Created: 2023-02-28

function norm_coeffs = sn3d_all(numHarms, N);
  
  #norm_coeffs_all = zeros(16, 1); #up to 3OA
  norm_coeffs = zeros(numHarms, 1);

  # n, m (ambi order, ambi degree)
  # M = linspace(-N, N, 2*N + 1); #M always goes from -N to N
  
  # FOA = 4SHs (top layer has 3) ... 2N + 1 with N = 1
  # 2OA = 9SHs (top layer has 5) ... 2N + 1 with N = 2
  # 3OA = 16SHs (top layer has 7) ... 2N + 1 wiith N = 3
  
  SHs_max_N = 2*N + 1; #number of SHs at top order
  
   n = 0; #ambi order
   p = 1; #index for array
   
   for SHs_in_n = 1:2:SHs_max_N #how many SHs forr n = 0, 1, 2

    M = linspace(-n, n, SHs_in_n); #M always goes from -n to n
    Mlen = length(M);#length of M
    
    for t = 1:Mlen #go through ambisonic degrees
      
      m = M(t);#ambi degreee
      norm_coeffs(p) = sn3d(n, m);#calculate one coeff
      p = p + 1;#inc index for main arrray
      
    endfor
    
    n = n + 1;#inc index for ambi order
    endfor
  
endfunction

  ##  norm_coeffs_all(1) = sn3d (0, 0);       :: 1 SH at this order
  ##  norm_coeffs_all(2) = sn3d (1, -1);      :: 3
  ##  norm_coeffs_all(3) = sn3d (1, 0);       :: 3
  ##  norm_coeffs_all(4) = sn3d (1, +1);      :: 3
  ##  norm_coeffs_all(5) = sn3d (2, -2);      :: 5
  ##  norm_coeffs_all(6) = sn3d (2, -1);      :: 5
  ##  norm_coeffs_all(7) = sn3d (2, 0);       :: 5
  ##  norm_coeffs_all(8) = sn3d (2, 1);
  ##  norm_coeffs_all(9) = sn3d (2, 2);
  ##  norm_coeffs_all(10) = sn3d (3, -3);     :: 7, etc.
  ##  norm_coeffs_all(11) = sn3d (3, -2);
  ##  norm_coeffs_all(12) = sn3d (3, -1);
  ##  norm_coeffs_all(13) = sn3d (3, 0);
  ##  norm_coeffs_all(14) = sn3d (3, 1);
  ##  norm_coeffs_all(15) = sn3d (3, 2);
  ##  norm_coeffs_all(16) = sn3d (3, 3);


