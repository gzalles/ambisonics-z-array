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
## @deftypefn {} {@var{retval} =} dfr_s (@var{input1}, @var{input2})
##
## @seealso{}
## @end deftypefn

## Author: Gabriel Zalles <gabrielzalles@Gabriels-MacBook-Pro.local>
## Created: 2021-10-22

#we'll makee it into a function later...
##function retval = dfr_s (input1, input2)
##
##endfunction

#the DFR will be used as the target for the NK algorithm to find the matching
#filter(s) for the a-format signals. It is unclear if the diffuse field response 
#will be averaged, or if each capsule should use it's own DFR as target. Works 
#with data from ScanIR 

pkg load signal;
clear all; clc; close all; 
plot_on = 1; 

#CPMC365 (see AES147 paper)
cd data/aes147/may25;
load smlMulti2_side.mat; #load mems measurement ICS-40720 (non-anechoic), ScanIR
cd ../../..;

#Anechoic Chamber - Cooper Union (see AES143 paper)
#on-axis, single capsule
#load mems_1.mat; #load mems measurement ICS-40720, ScanIR

#params
D = size(data, 2); #get number of meas in data 
ir = data.IR; #get the first ir
ir_len = size(ir, 1); #get length of ir
Q = size(ir, 2); #determine the number of sensors
Nfft = ir_len; #set the FFT size to be equal to the length of ir
Fs = specs.sampleRate; #get sampling rate of ir
ir_all = zeros(D, Q, ir_len); #init mem for all ir
ir_single = zeros(ir_len, 1); #temp var for single IR (one q, at one d)

#load in filter coefficients for helmholtz filt. (naive)
#the capsules have resonance above 10kHz, the helmholtz filter
#is used to equalize the A-format data
[h, ~] = audioread("naive-helm.wav");

## h is an wav file but only has 5 values corresponding to filter coeffs.
#the sample rate does not matter.

#
#the helm filter can either be created via NK (Nelson-Kirkeby) or a naive 
#filter designed via observation. here we will use the naive helm filter

#extract all the ir in struct
for d = 1:1:D
    ir = data(d).IR; #get ir for direction d (there are q of these)
    ir_all(d, 1:end, 1:end) = ir'; #place values within mat (transpose)
endfor

#careful with dimensions for FFT, we will have to transpose back

#removing last response corresponding to 180 degs. 0 degs should be symmetrical.
ir_all = ir_all(1:D-1, :, :); 
D = size(ir_all, 1); #recalculate D

#here you should remove the speaker response (TODO)
#here - convolve with inverse filter

#window for ir
bm = blackman(ir_len); #make window function
win = zeros(ir_len, 1); #init mem for window
win(1:length(bm)/2) = bm(end/2+1:end); #put bm in win var
  
#helmholtz filter (remove resonance above 10kHz) for MEMS capsules
for d =1:1:D
  for q = 1:1:Q
    ir_single(:, 1) = ir_all(d, q, :); #extract a single ir from mat
    ir_single(1, 1) = 0; #zero first val.
    ir_single = ir_single .* win; #window ir with second half of window
    #1 = feedback coefficients
    ir_all(d, q, :) =  filter(h, 1, ir_single);#filter the ir (signal pkg)
  endfor
endfor

IR_ALL = zeros(size(ir_all)); #init mem for FFTd ir_all
IR_SINGLE = zeros(size(ir_single)); #init mem for single ir FFTd (Nfft by 1)

#first we need to FFT all the ir (which we've EQd [with helmholtz filter])
for d = 1:1:D
  for q = 1:1:Q
    ir_single(:, 1) = ir_all(d, q, :);
    IR_ALL(d, q, :) = fft(ir_single, Nfft);
  endfor
endfor

#a plot of the last ir and the windowing function
if plot_on
  figure(1)
  plot(ir_single/max(abs(ir_single)))#normalized
  hold on;
  plot(win);#window
  title("Windowing Function and Example IR (Normalized)");
  ylabel("Amplitude");
  xlabel("Samples");
  axis tight; grid on;
  hold off;
endif

DFRs = zeros(Q, Nfft); #init memory for DFRs matrix

#get Q DFRs
for q = 1:1:Q #move through sensors
  for d = 1:1:D #move through meas
    
    IR_SINGLE(:, 1) = IR_ALL(d, q, :); #copy a single meas
    IR_SINGLE(:, 1) = abs(IR_SINGLE); #get mag
    IR_SINGLE(:, 1) = IR_SINGLE.^2; #square 
    
    DFRs(q, :) = DFRs(q, :) + IR_SINGLE'; #add all the vectors together
    # there might be a built in MATLAB function for this...
    # https://www.mathworks.com/help/matlab/ref/sum.html
    
  endfor
  
  DFRs(q, 1:end) = DFRs(q, 1:end) .* 1/D; #take average (1/D) 
  DFRs(q, 1:end) = sqrt(DFRs(q, 1:end)); #take square root 
  
endfor

#each row of DFRs is one DFR. these DFRs are based on horizontal measurements
#the array was set to "pose" 1. >>> e.g. sampling @ elev = 0.

#let's plot these DFRs
freqVec = linspace(0, Fs/2, Nfft/2); #freq vector for plotting (W)

if plot_on
  figure(2);
  hold on;
  
  for q = 1:1:Q
    
    DFR = DFRs(q, :); #extract first DFR
    #these are magnitudes already 
    plot(freqVec, 20*log10(DFR(1:end/2)));#decibel
  endfor
  
    axis tight; grid on;
    xlim([0 20000]); #set x limits for plot
    ylim([-50 0]); #set x limits for plot
    hold off;
    title("DFRs");
    ylabel("Magnitude in dB");
    xlabel("Frequency in Hz");
    
endif

# we can use this to plot afterwards to compare the DFR of the Q sensors
# after the inverse filter has been applied

#at this point we decide if we use multiple DFRs or a single global DFR as target. 
#we want all the capsules to be as closely matched as possible so a single DFR makes
#more sense 

#average the DFRs 
#   If A is a matrix, then sum(A) returns a row vector containing the sum of each column.
#   DFRs is a Q by Nfft data structure, so we sum column-wise and divide by Q
DFR_global = (sum(DFRs)) ./ Q;

#plot global DFR
if plot_on
  figure(3);
  hold on;
    
    #these are magnitudes already 
    plot(freqVec, 20*log10(DFR_global(1:end/2)));#decibel
    axis tight; grid on;
    xlim([0 20000]); #set x limits for plot
    ylim([-50 0]); #set x limits for plot
    hold off;
    title("DFR Global (average)");
    ylabel("Magnitude in dB");
    xlabel("Frequency in Hz");
    
endif

#next we need to extract Q ir vectors corresponding to the closest azimuth of our sensors
#so we can use these values for the inv filt function

Q_pos = zeros(Q, 2); #positions of sensors have azi & elev

% FLU - front left up
% FRD - front right down
% BLD - back left down
% BRU - back right up

#remember the stepper increase clockwise, but ambi increases counterclockwise

numSteps = 200; #stepper motor total steps
stepRes = 1.8;#stepper resolution
stepAngles = linspace(0, 360 - stepRes, numSteps);#to double check logic
Q_pos_azi = Q_pos(:,1);#ignore the sensor elevation 

#add 360 to all values under 0
for i = 1:1:length(Q_pos_azi)
  if Q_pos_azi(i) < 0
    Q_pos_azi(i) = Q_pos_azi(i) + 360;
  endif
endfor

Q_pos_azi_neg = Q_pos_azi .* -1; #invert values to match stepper 
Q_pos_azi_step = abs(floor(Q_pos_azi_neg./stepRes)); #find step corresponding to angle
Q_pos_azi_step = Q_pos_azi_step .+ 1; #everything was off by one

IRs = zeros(Q, Nfft);#data structure for our IRs (Q of these)

#in case the only got 180 degrees
if D == 100
  %% duplicate symmetric half
  %% to get 360 degrees. 
  temp = IR_ALL;                %copy the data 
  #already removed the last IR previously
  temp = flipud(temp);          %flip left/right
  IR_ALL = [IR_ALL; temp];      %append data
  clear temp;                    %we can get rid of the copy
endif

#get Q IRs from data to create Q inv filts
for i = 1:1:Q
  cur_step = Q_pos_azi_step(i); #get current step
  IRs(i, :) = IR_ALL(cur_step, i, :); #extract IR for closest azi
endfor 

#each column in IRs is one H (complex values) and includes symmetric half

#we might have multiple "poses" measured with array tilted some amount. this
#is a naive case when we don't, and have a FOA array. 









