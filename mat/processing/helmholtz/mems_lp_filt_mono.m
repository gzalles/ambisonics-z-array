function y = mems_lp_filt_mono(x, fs)
%function y = mems_lp_filt_mono(x, fs)
%
%Apply a 15dB per octave filter to compensate for the Helmholtz
%resonance of the MEMS capsule. 
%
%Input: x - ir in the time domain (to plot, can also be true signal)
%       fs - sample rate
%% design filter

filtOrder = 10; 
passBand = 7000; 
stopBand = 20000;

d = designfilt('lowpassfir', 'FilterOrder', filtOrder, ... 
    'PassbandFrequency', passBand, 'StopbandFrequency', ...
    stopBand, 'SampleRate', fs);

% fvtool(d); %optional, display filter...

%% zero-phase filter the input data, using a digital filter, d.

y = filtfilt(d, x);

end
