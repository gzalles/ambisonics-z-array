%this script is used to take the frequency response of the speaker plus
%room using the umic microphone.

clc;clear;
load data/aes147/feb24/earthworks_365_freqRes.mat;

ir = data.IR;
fs = length(ir); %only works for 1 second IR
nfft = 2^15; %define number of points used for FFT

%% get IR and freq vector (for plotting)
[IR,F] = freqz(ir, 1, nfft, fs);

%% get the magnitude 
MAG_IR = abs(IR);

%% normalize the magnitude
NORM_MAG_IR = (MAG_IR - min(MAG_IR)) ...
    / ( max(MAG_IR) - min(MAG_IR) );

%% plot it in dB
plot(F, 20*log10(NORM_MAG_IR));
%loglog(F, NORM_MAG_IR);

% add title, labels and legends
title('Frequency Response "normalized" - Speaker + Room (365)');
xlabel('Frequency (Hz)'); 
ylabel('Magnitude (dB)'); 
legend('Earthworks', 'Location','northwest');

% limit scope of plot 
ylim('auto')
xlim([0 20000]);
hold off;

