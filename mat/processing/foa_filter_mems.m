% function [flu_o, frd_o, bld_o, bru_o] = ... 
%   foa_filter_mems(flu_i, frd_i, bld_i, bru_i, fs)
% 
%   Filters the output of the ICS-40720 with a 10th order FIR filter
%
function [flu_o, frd_o, bld_o, bru_o] = ... 
    foa_filter_mems(flu_i, frd_i, bld_i, bru_i, fs)

% design filter
d = designfilt('lowpassfir', 'FilterOrder', 10, ... 
    'PassbandFrequency', 10000, 'StopbandFrequency', ...
    fs/2, 'SampleRate', fs);

%zero-phase filters the input data, using a digital filter, d.
flu_o = filtfilt(d, flu_i);
frd_o = filtfilt(d, frd_i);
bld_o = filtfilt(d, bld_i);
bru_o = filtfilt(d, bru_i);

end




