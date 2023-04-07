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


function [rw] = fold(r) #JOS function
% [rw] = fold(r) 
% Fold left wing of vector in "FFT buffer format" 
% onto right wing 
% J.O. Smith, 1982-2002
  
   [m,n] = size(r);
   if m*n ~= m+n-1
     error('fold.m: input must be a vector'); 
   end
   flipped = 0;
   if (m > n)
     n = m;
     r = r.';
     flipped = 1;
   end
   if n < 3, rw = r; return; 
   elseif mod(n,2)==1, 
       nt = (n+1)/2; 
       rw = [ r(1), r(2:nt) + conj(r(n:-1:nt+1)), ...
             0*ones(1,n-nt) ]; 
   else 
       nt = n/2; 
       rf = [r(2:nt),0]; 
       rf = rf + conj(r(n:-1:nt+1)); 
       rw = [ r(1) , rf , 0*ones(1,n-nt-1) ]; 
   end; 

   if flipped
     rw = rw.';
   end
endfunction 


