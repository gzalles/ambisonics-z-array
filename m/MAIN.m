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

## Author: Gabriel Zalles <gabrielzalles@Gabriels-MacBook-Pro.local>
## Created: 2021-10-23

## Test all your functions. 

clc; clear; 

# load IR from REW taken with u-mic (includes calibration file)
cd spkr-resp;
[spkr_resp, Fs] = audioread("MA329-win-on-min-phase-calib-44-1.wav");
cd ..
##this signal is just the ir corresponding to the single meas. we need to invert


# calculate the reflection window based on 1st order reflection. 
# REW can also window your IR but you will need this for other meas. 

lambda = 2; #wavelength of direct path 

# calculate the 1st order reflection 
d2f = 1; #distance to floor is 1 meter
hypot = sqrt(lambda^2 + d2f^2); #pythagorean theorem
f_o_r = d2f + hypot; #first order reflection (in meters)

c = 343; #speed of sound in m/s
f = c/f_o_r; #freq of longest wave in Hz
T = 1/f; #period of longest wave in sec
Ts = 1/Fs; #sampling period in seconds
Tss = ceil(T/Ts); #length of f_o_r in samples

##printf ("L %d%% of '%s'.\nPlease be patient.\n",
##        pct, filename);



