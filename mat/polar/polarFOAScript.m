% Gabriel Zalles - 2019
%
% Script which takes the struct from ScanIR and makes polar
% plots. The polar plot shown depends on the frequency band in question.
% The number of available frequency bands depends on the number of FFT
% points used and the sampling rate.
%
% The legend of the plot shows the frequencies being plotted. Multiple
% frequencies are plotted over each other.
%
% This specific script is strictly for FOA polar plots. 
%
% In FOA the number of input channels equals the number of spherical
% harmonics. For higher orders this will not always be the case. This
% script is for FOA. 
%
% No tukey window since ScanIR gave us 1024 samples. We still need to
% calculate what time that corresponds to. We might change this if we redo
% the measurements. 

%% initialize 

% clear CW and WP, close all figures
clc; clear; close ALL;

%load data, give it a name for plot
load data/may25/smlMulti2_side.mat;
%load data/mar18/lrgMulti.mat;
dataName = 'SMALL ';

%load FIR gerzon filter 
wFilt = audioread('fwLRG.wav');
xyzFilt = audioread('fxyzLRG.wav');

%boolean for gerzon filtering
gerzon = 0;

%boolean for normalization
norm = 1;

% define number of points to be used for fft
nfft = 2^16;

%find sample rate
fs = specs.sampleRate;

%find bin resolution
binRes = fs/nfft;

bins2plot = [500 3500 8500 12000]; %frequency bins we want to plot
harm2plot = 3; %W, X, Y, Z [harmonic we choose to plot]

%if max bin is above 20kHz print error
if max(bins2plot) * binRes > 20000
    error('Bin above hearing range')
end

% this is the step size resolution of our motor
stepSize = 1.8;
% our motor always does one more step than requested (101 [bug])
numSteps = size(data, 2);

%% prepare to analyze

% find size of one IR (could be 44100 or small number of samples, ScanIR
% has multiple settings for this)
irLen = size(data(1).IR, 1);

%figure out number of channels in each IR (multichannel)
%for FOA number of inputs = number of harmonics

numHarms = size(data(1).IR, 2); %number of columns = num inputs

% preallocate space (order in FOA >>> W, X, Y, Z for 3rd dimension)
% this is the FuMA ordering
ir = zeros(numSteps, irLen, numHarms);

% use for loop to extract all data from struct
%   each iteration a matrix of [ir_len by 4] is added to the data structure
%   a step, in essence, is added every iteration
for i = 1:1:numSteps
    ir(i, :, :) = data(i).IR;
end

%% duplicate symmetric half

%duplicate the data to get 360 degrees. 
cpyIdxLo = 2;                   %index low
cpyIdxHi = 100;                 %index high

irCpy = ir;                     %copy the data 
irCpy = irCpy(2:100, :, :);     %get rest of data without doubling values
irCpy = flipud(irCpy);          %flip left/right
ir = [ir; irCpy];               %append data

clear irCpy;                    %we can get rid of the copy

%recalculate number of steps
numSteps = size(ir, 1); 

%% encoding

%evaluate conditional (error checking)
if numHarms == 4

    % separate each channel into its own matrix of IRs
    %   this makes it a bit easier to encode (clarity)
    flu = ir(:, :, 1);
    frd = ir(:, :, 2);
    bld = ir(:, :, 3);
    bru = ir(:, :, 4);

    %preallocate for W, X, Y, Z
    w = zeros(numSteps, irLen);
    x = zeros(numSteps, irLen);
    y = zeros(numSteps, irLen);
    z = zeros(numSteps, irLen);

    %get vectors one at a time and encode
    for i = 1:numSteps
        w(i,:) = flu(i,:)+frd(i,:)+bld(i,:)+bru(i,:);%sum all
        x(i,:) = flu(i,:)+frd(i,:)-bld(i,:)-bru(i,:);%front - back
        y(i,:) = flu(i,:)-frd(i,:)+bld(i,:)-bru(i,:);%left - right
        z(i,:) = flu(i,:)-frd(i,:)-bld(i,:)+bru(i,:);%up - down
    end
else
    error('This is not a multichannel FOA IR measurement.');
end

%% tukey

% %before we take the FFT we need to window
% winSize = 2^8;
% tapper = 0.25;
% win = tukeywin(winSize * 2, tapper);
% %multiply win size by 2 since we cut in half
% win = win(end/2+1:end, 1);
% 
% for i = 1:4
%     %remove extra rows (truncate IRs)
%      w = w(:, 1:winSize); 
%      x = x(:, 1:winSize);
%      y = y(:, 1:winSize);
%      z = z(:, 1:winSize);
%      
%      %window impulse responses
%     if i == 1 % W
%         %window using tukey W
%         for j = 1:numSteps
%             temp = w(j, :);
%             w(j, :) = temp .* win';
%         end
%     elseif i == 2
%         %window using tukey X
%         for j = 1:numSteps
%             temp = x(j, :);
%             x(j, :) = temp .* win';
%         end
%     elseif i == 3
%         %window using tukey Y
%         for j = 1:numSteps
%             temp = y(j, :);
%             y(j, :) = temp .* win';
%         end
%     else
%         %window using tukey Z
%         for j = 1:numSteps
%             temp = z(j, :);
%             z(j, :) = temp .* win';
%         end
%     end
% end     
% %the sampling period times the window size is our IR time
% Ts = 1/fs; 

%% Convolve impulse responses with Gerzon filter (optional)

%{
The length of the convolution is M + N - 1.
Zero pad both in the time domain. Take the FFT and multiply. 

pseudo:
* load gerzon FIR 
* calculate convLen (M + N - 1)
    * 1024 + 2048 - 1 = 3071
    * ir_len + gerzonLen - 1
* pad both signals in the time domain to match convLen
* use FFT on both signals
* multiply 
%}

%get length of gerzon filter
gerzonLen = length(wFilt);

%calculate convolution length 
convLen = gerzonLen + irLen - 1;

%use same number of points as FFT for impulse responses. Dont remove
%complex conjugate until after.
W_FILT = fft(wFilt, nfft);
XYZ_FILT = fft(xyzFilt, nfft);

%% get the FFT of all our microphone IRs (use Gerzon filter)

if gerzon == 1
    
    %pad both time domain signals to match convLen
    w = [w zeros(numSteps, convLen - irLen)];
    x = [x zeros(numSteps, convLen - irLen)];
    y = [y zeros(numSteps, convLen - irLen)];
    z = [z zeros(numSteps, convLen - irLen)];

    wFilt = [wFilt; zeros(convLen - length(wFilt), 1)];
    xyzFilt = [xyzFilt; zeros(convLen - length(xyzFilt), 1)];

    % preallocate for FFTs
    % (note: due to multichannel our matrix is 3-dimensional)
    IR_FFT = zeros(numSteps, nfft, numHarms);
    
    for i = 1:numHarms %4 in this case
        for j = 1:1:numSteps %200 in this case
            if i == 1
                IR_FFT(j, :, i) = fft(w(j, :), nfft) .* W_FILT';
            elseif i == 2
                IR_FFT(j, :, i) = fft(x(j, :), nfft) .* XYZ_FILT';
            elseif i == 3
                IR_FFT(j, :, i) = fft(y(j, :), nfft) .* XYZ_FILT';
            elseif i == 4
                IR_FFT(j, :, i) = fft(z(j, :), nfft) .* XYZ_FILT';
            end
        end
    end
    
else
    %else case, don't apply Gerzon filter
    %dont pad or convolve
    IR_FFT = zeros(numSteps, nfft, numHarms);
    
    for i = 1:numHarms %4 in this case
        for j = 1:1:numSteps %200 in this case
            if i == 1
                IR_FFT(j, :, i) = fft(w(j, :), nfft); %1 = W
            elseif i == 2
                IR_FFT(j, :, i) = fft(x(j, :), nfft); %2 = X
            elseif i == 3
                IR_FFT(j, :, i) = fft(y(j, :), nfft); %3 = Y
            elseif i == 4
                IR_FFT(j, :, i) = fft(z(j, :), nfft); %4 = Z
            end
        end
    end
    
end

%remove the complex conjugate
IR_FFT = IR_FFT(:, 1:end/2+1, :);

%next we need to get the magnitude, since right now we just have complex
%values
IR_FFT = abs(IR_FFT);

%get values in dB?
%IR_FFT = 20*log10(IR_FFT);

%% normalize along steps
% for j = 1:1:numHarms
%     for i = 1:1:size(IR_FFT, 1)
%         %get all steps in this specific bin (i) in this specific
%         %harmonic (j)
%         curBandinHarm = IR_FFT(:, i, j);
%         %normalize
%         curBandinHarm = (curBandinHarm - min(curBandinHarm))/...
%             (max(curBandinHarm)-min(curBandinHarm));
%         %replace
%         IR_FFT(:, i, j) = curBandinHarm;
%     end
% end

%% pick a bin to plot and a harmonic to plot

% plot all data in evenly spaced intervals between 0 and 2pi
% the second value is the bin and the third the harmonic 

degreesPerStep = 1.8;   %resolution of stepper
maxDegrees = 360;       %full rotation in degrees

%make vector for polar plot
freqs = 0 : degreesPerStep : maxDegrees - degreesPerStep;

%convert degrees to radians
freqs = freqs * pi /180; 
 
%convert bins to Hz
freq2plot = bins2plot * binRes;

%make string with harmonics for plot
%harmonicStr = ['W', 'X', 'Y', 'Z'];
harmonicStr = ['W', 'X', 'Y', 'Z'];

figure(1);
%overlay various frequencies
for i = 1:length(bins2plot)
    oneHarm = IR_FFT(:, bins2plot(i), harm2plot);
    if norm == 1
        %along steps (= flat freq res)
        oneHarm = normalize(oneHarm, 'range'); %normalize (optional)
    end
    polarplot(freqs, oneHarm);
    hold on;
end

hold off;

%title, legend - fig 1
strTitle = strcat('Polar Plot (FOA): ', {'  '}, dataName, ...
    {' - Harmonic: '}, harmonicStr(harm2plot));
title(strTitle);
strLegend = strcat(num2str(freq2plot'), ' Hz');
legend(strLegend, 'Location','NorthEastOutside');

%gerzon plot 
if gerzon == 1
    
    FW_shift = fft(wFilt, nfft);
    
    figure(2);
    subplot(2,1,1);
    plot(20*log10(abs(FW_shift(1:end/2+1))));
    grid on; axis tight;
    title('Magnitude of W filter in dB');
    
    subplot(2,1,2);
    plot(angle(FW_shift(1:end/2+1)));
    grid on; axis tight;
    title('Phase of shifted W filter');
end


%% print params to command win

% how many degrees of data we gathered
degrees = numSteps * stepSize;

% display number of steps to plot
fprintf('We present %0i steps. \n', numSteps);
fprintf('That is a total of %0.00f degrees. \n', degrees);

%display bin resolution
fprintf('Our bin resolution is %0.00f Hz. \n', binRes);

%display bin we are plotting
fprintf('Plotting %0.00f Hz. \n', binRes * bins2plot);

%display harmonic being plotted
fprintf('Plotting harmonic %s. \n', harmonicStr(harm2plot));


