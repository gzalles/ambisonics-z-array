% make a script that takes a two impulse responses and plots the 
%frequency response side by side. we use this to determine if the frequency
%response capture in the anechoic chamber differs from out new
%measurements. I filtered both responses with our helmholtz filter.

%memsOldSingle.wav is the first step gathered from our old anechoic
%measurements. I used audiowrite to export the audio. 

clc; clear; 

%load the new microphone IR
load 'feb24/singleCap/smallFreqRes_365.mat';
new = data.IR;
fs1 = length(new); %only works for IR length 1 sec

%load the old microphone IR
[old, fs2] = audioread('wav/singleCap/memsOldSingle.wav');

%filter with our LOP filter
new = memsLopFilt(new, fs1);
old = memsLopFilt(old, fs2);

% %filter out DC and everything below 20Hz
% Fstop = 20;
% Fpass = 50;
% Astop = 65;
% Apass = 0.5;
% 
% d1 = designfilt('highpassfir','StopbandFrequency',Fstop, ...
%   'PassbandFrequency',Fpass,'StopbandAttenuation',Astop, ...
%   'PassbandRipple',Apass,'SampleRate',fs1,'DesignMethod','equiripple');
% 
% d2 = designfilt('highpassfir','StopbandFrequency',Fstop, ...
%   'PassbandFrequency',Fpass,'StopbandAttenuation',Astop, ...
%   'PassbandRipple',Apass,'SampleRate',fs2,'DesignMethod','equiripple');
%
% new = filtfilt(d1, new);
% old = filtfilt(d2, old);

%pick fft size
nFFT = 2^12;

% get freq response and freq vector (for plotting)
[NEW, F1] = freqz(new, 1, nFFT, fs1);
[OLD, F2] = freqz(old, 1, nFFT, fs2);

% get the magnitudes
NEW_mag = abs(NEW);
OLD_mag = abs(OLD);

%normalize 
NEW_mag = (NEW_mag - min(NEW_mag)) / ...
    ( max(NEW_mag) - min(NEW_mag) );
OLD_mag = (OLD_mag - min(OLD_mag)) / ...
    ( max(OLD_mag) - min(OLD_mag) );

%% plot it in dB
plot(F1, 20*log10(NEW_mag));
hold on;
plot(F2, 20*log10(OLD_mag));

axis tight;
grid on;
legend('NEW (small)','OLD (large)','Location','NorthEastOutside')

% limit scope of plot 
ylim([-50 0]) 
xlim([20 20000]);
hold off;
