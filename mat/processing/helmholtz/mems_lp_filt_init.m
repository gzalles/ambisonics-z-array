%I need to make a 15dB per octave filter to compensate for the Helmholtz
%resonance of the MEMS capsule.

clc; 
clear;

%% load ambeo_single.mat
cd data;
load mems_single.mat; %this file must be found in the folder
pre_filt_IR = data.IR; %get the IR from the struct
load ambeo_multi_1.mat;
ambeo_IR = data(1).IR;
cd ..

fs = 44100; %define Fs
nfft = 2^7; %define number of points used for FFT

% the FFT of the IR should get us the frequency response of the capsule.
% The only caveat is that the speaker itself has a frequency response. We
% have to figure out how to cancel that out. 

% design filter
d = designfilt('lowpassfir', 'FilterOrder', 10, ... 
    'PassbandFrequency', 10000, 'StopbandFrequency', ...
    fs/2, 'SampleRate', fs);

fvtool(d); %optional, display filter...

%zero-phase filters the input data, using a digital filter, d.
post_filt_IR = filtfilt(d, pre_filt_IR);

%get both f-responses based on IR
[POST_FILT_IR,~] = freqz(post_filt_IR, 1, nfft, fs);
[PRE_FILT_IR,~] = freqz(pre_filt_IR, 1, nfft, fs);
[AMBEO_IR,F] = freqz(ambeo_IR, 1, nfft, fs);

%get the magnitude of the resulting vectors 
MAG_PRE_FILT_IR = abs(PRE_FILT_IR);
MAG_POST_FILT_IR = abs(POST_FILT_IR);
MAG_AMBEO_IR = abs(AMBEO_IR);

%normalize
NORM_MAG_PRE_FILT_IR = (MAG_PRE_FILT_IR - min(MAG_PRE_FILT_IR)) ...
    / ( max(MAG_PRE_FILT_IR) - min(MAG_PRE_FILT_IR) );

NORM_MAG_POST_FILT_IR = (MAG_POST_FILT_IR - min(MAG_POST_FILT_IR)) ...
    / ( max(MAG_POST_FILT_IR) - min(MAG_POST_FILT_IR) );

NORM_MAG_AMBEO_IR = (MAG_AMBEO_IR - min(MAG_AMBEO_IR)) /  ...
    ( max(MAG_AMBEO_IR) - min(MAG_AMBEO_IR) );
 
%plot it in dB
semilogx(F,mag2db(NORM_MAG_PRE_FILT_IR));
hold on; %overlay the three plots
semilogx(F,mag2db(NORM_MAG_POST_FILT_IR));
semilogx(F,mag2db(NORM_MAG_AMBEO_IR));

%add title, labels and legends
title('Filter Response - Normalized');
xlabel('Frequency (Hz)'); 
ylabel('Magnitude (dB)'); 
legend('Pre-filtering', 'Post-filtering', 'Ambeo', 'Location','northwest');

%limit scope of plot 
ylim([-30 0]) 
xlim([0 20000]);
hold off;

%todo: make a calculation of the mems capsule helmholtz resonance based on
%the speed of sound (c) in milimeters.
