## Copyright (C) 2021 Gabriel Zalles
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

## -*- texinfo -*-
## @deftypefn {} {@var{retval} =} sn3d (@var{input1}, @var{input2})
##
## @seealso{}
## @end deftypefn

## Author: Gabriel Zalles <gabrielzalles@Gabriels-MacBook-Pro.local>
## Created: 2021-10-23

## n is the ambisonic order (0 to N)
## m is the ambisonic degree (-M to M)

function norm_coeff = sn3d (n, m)

m = abs(m); #we always use the abs val of ambisonic deg.

if m == 0
  delta = 1;
  else
  delta = 0;
endif

norm_coeff = sqrt( (2 - delta) * ( factorial(n - m) / factorial(n + m) ) );

endfunction

# perhaps we should include a note about the 1/4pi factor. or an option to include it?
