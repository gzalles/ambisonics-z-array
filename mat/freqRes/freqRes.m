% make a script that takes a single impulse response and plots the 
%frequency response 

clc; clear; 

load 'smallFreqRes_365.mat';

audio_data = data.IR;
fs = length(audio_data); %only works for IR length 1 sec
Nfft = 1024;

%get the magnitude of the FFT 
AUDIO_DATA = abs(fft(audio_data, Nfft));

%only plot half of the FFT
AUDIO_DATA = AUDIO_DATA(1:end/2);

%plot with both axis logarithmically scalled
loglog(AUDIO_DATA);

axis tight;
grid on;


