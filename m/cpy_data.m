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

## This is a function which duplicates data in the event that only 100
## steps were measured. 

## function IR_ALL = cpy_data (IR_ALL, D)

## Author: Gabriel Zalles <gabrielzalles@Gabriels-MacBook-Pro.local>
## Created: 2023-04-17

function IR_ALL = cpy_data (IR_ALL, D)
  
  if D ~= 100
    error("D not equal to 100, error in cpy_data.");
  endif
  
  %% duplicate symmetric half
  %% to get 360 degrees. 
  temp = IR_ALL;                %copy the data 
  #already removed the last IR previously
  temp = flipud(temp);          %flip left/right
  IR_ALL = [IR_ALL; temp];      %append data
  clear temp;                   %we can get rid of the copy

endfunction
