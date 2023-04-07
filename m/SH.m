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

## -*- texinfo -*-
## function coeffs = SH (phi, theta, order)
##
## calculate SN3D, ACN ordered SHs, real-valued. according to BRS notes
## https://www.blueripplesound.com/notes/bformat
## phi and theta can simply be in degrees. standard ambisonic coordinate system.
## azimuth increases counterclockwise, -90 to 90 for elevation.
## -90 is below listener. 

## Author: Gabriel Zalles <gabrielzalles@Gabriels-MacBook-Pro.local>
## Created: 2023-02-24

function coeffs = SH (phi, theta, order)

%make an array, size is (n+1)^2
coeffs = zeros((order+1)^2, 1); 

phi = deg2rad(phi);
theta = deg2rad(theta);

if order >= 1 
  coeffs(1) = 1;
  coeffs(2) = sin(phi)*cos(theta);
  coeffs(3) = sin(theta);
  coeffs(4) = cos(phi)*cos(theta);
endif 

if order >= 2
  coeffs(5) = sqrt(3/4)*sin(2*phi)*cos(theta)*cos(theta);
  coeffs(6) = sqrt(3/4)*sin(phi)*sin(2*theta);
  coeffs(7) = (1/2)*(3*sin(theta)*sin(theta)-1);
  coeffs(8) = sqrt(3/4)*cos(phi)*sin(2*theta);
  coeffs(9) = sqrt(3/4)*cos(2*phi)*cos(theta)*cos(theta);
 endif 
 
if order >= 3
  coeffs(10) = sqrt(5/8)*sin(3*phi)*cos(theta)*cos(theta)*cos(theta);	
  coeffs(11) = sqrt(15/4)*sin(2*phi)*sin(theta)*cos(theta)*cos(theta);
  coeffs(12) = sqrt(3/8)*sin(phi)*cos(theta)*(5*sin(theta)*sin(theta)-1);
  coeffs(13) = (1/2)*sin(theta)*(5*sin(theta)*sin(theta)-3);
  coeffs(14) = sqrt(3/8)*cos(phi)*cos(theta)*(5*sin(theta)*sin(theta)-1);
  coeffs(15) = sqrt(15/4)*cos(2*phi)*sin(theta)*cos(theta)*cos(theta);
  coeffs(16) = sqrt(5/8)*cos(3*phi)*cos(theta)*cos(theta)*cos(theta);	
endif

endfunction
