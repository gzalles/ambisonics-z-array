## Copyright (C) 2021 Gabriel Zalles
## 
## This program is free software: you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
## 
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
## 
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see
## <https://www.gnu.org/licenses/>.

## -*- texinfo -*- 
## @deftypefn {Function file} {@var{H_inv} =} inv_filt_f (@var{H}, @var{H_target}, @var{epsilon})
##
## Inverse filter function. The goal is to use the Nelson/Kirkeby algorithm from
## Middlicott paper to equalize the MEMS A-format signals before B-format calibration. 
## The Helmholtz resonance of the MEMS makes them bad for hi-fi recording. 
## 
## The function should take the original on-axis impulse response of the capsule,
## the target response, and the regularization vector (all in the frequency domain).
## 
## The function returns the inverse filter, which when convolved with each capsule
## results in the equalized signals. This creates a single filter for all capsules.
## Can also be used for individual capsule calibration, just feed multiple H.
##
## A few more notes: H ideally is taken in anechoic conditions, if not certain 
## additional processing must be done. The speaker response ideally should also
## be compensated for.
##
## Charlie Middlicott and Bruce Wiggins. Calibration approaches for higher order 
## ambisonic microphones. Audio Engineering Society, 2019.
## @seealso{}
## @end deftypefn

## Author: Gabriel Zalles <gabrielzalles@Gabriels-MacBook-Pro.local>
## Created: 2021-10-11

function H_inv = inv_filt_f(H, H_target, epsilon)
  
  H_inv = (H_target .* conj(H)) ./ (conj(H) .* H + epsilon);
  
  #conj flips imaginary value, same frequency, different phase?
  
  #the product of complex numbers results in sum of angles (argument)
  #magnitude of the two values multiply
  
  #recall division means deconvolution in freq domain.

endfunction
