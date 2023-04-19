%% polar single script 

%{
Load a single ScanIR data file and plot several frequencies. Use a tukey
window. One can set the tapper amount. We only need 180 degrees for our
polar measurement since we can assume symmetry. There is a bug so we
actually end up getting 181 steps in the ScanIR data. In this script we are
taking the output of a single capsule and plotting it. The windowing and
truncating are used to remove and reflections that might affect the
measurement. Since we don't have an anechoic chamber this is very useful.
We don't really need to worry about the frequency response of the speaker
since it is the same everytime and we are normalizing the response.
%}

%% clear space and load data

%clear workspace and command window
clear; clc; close ALL;

%set the path
path = 'data/mar16/';

%load the test data
fileName = 'smallSingleFrontFar.mat';

%concatenate path and filename
fileName = strcat(path, fileName);

load(fileName);
dataName = 'SMALL';

%make a vector for freqs we want to plot
freq2plot_lo = 2;
freq2plot_hi = 4.22;
numBands2plot = 4;

%n logarithmically spaced bands between specified ranges
%logspace creates N points between 10^x1 and 10^x2

freqs2plot = [732 5126 12451 17578];
%freqs2plot = linspace(400, 16000, 5);
%freqs2plot = logspace (freq2plot_lo, freq2plot_hi, numBands2plot);

%% variable declaration

%declare some variables
numIRs = size(data, 2); %number of IRs in our data (deconvolved)
fs = specs.sampleRate;  %sampling rate
Ts = 1/fs;              %time sample
Nfft = 2^16;            %number of points for FFT
winSize = 2^8;          %size for half tukey window, use power of 2
c = 343;                %speed of sound in meters (approximate)
winDist = Ts * winSize * c; 
winTime = Ts * winSize;
tapper = 0.5;          %tapper amount

fprintf('Number of points used for FFT: %1.3f. \n', Nfft);
fprintf('Number of points used for tukey window: %1.3f. \n', winSize);
fprintf('Distance between first reflection and mic: %1.3f meters. \n', winDist);
fprintf('Time between first reflection and mic: %1.3f seconds. \n', winTime);

%% calculate IR time and distance after Tukey

winSizeT = winSize * Ts;%size of the window in seconds. 
winSizeD = winSizeT * c;%impulse response as distance

fprintf('Window length in milliseconds: %1.3f. \n', winSizeT * 1000);
fprintf('Window length meters: %1.3f. \n', winSizeD);

%% get IRs from struct, truncate + window, take FFT.

irLen = length(data(1).IR);%original length of impulse response

%allocate memory for IRs
ir_win = zeros(winSize, numIRs);    %use one for windowed audio
IR = zeros(Nfft, numIRs);           %use this one for FFT 

w = tukeywin(winSize*2, tapper);%0.5 tapper, window will be split in half
w = w(end/2+1:end);%use only the second half

fprintf('Tapper amount for Tukey: %1.3f. \n', tapper);

%get IRs from the struct. 
for i = 1:1:numIRs
    
    curIR = data(i).IR;%get the current IR, entire response
    ir_win(:, i) = curIR(1:winSize) .* w;%window selected region of IR
    
end

ir = ir_win; %reassign variable

%turn all the audio data into magnitudes
for i = 1:1:numIRs
    cur_ir = ir(:, i);                  %get the current IR
    IR(:, i) = abs(fft(cur_ir, Nfft));  %get the magnitude of FFT
end

%chop off mirrored half of FFT, remove FFT symmetry.
IR = IR(1:end/2, :);

%% copy, flip and append symmetric polar data

% get indices 2 to 100 (99 total) corresponding to degrees 1.8 to 178.2 and
% flip them. Then append them to the end of the data to create other half
% of polar. After index 101 we should go back to 100 and down to 2;

cpyIdxLo = 2;
cpyIdxHi = 100;

IR_cpy = IR;                            %copy the data 
IR_cpy = IR_cpy(:, cpyIdxLo:cpyIdxHi);  %get rest of data w/o doubling vals
IR_cpy = fliplr(IR_cpy);                %flip left/right
IR = [IR IR_cpy];                       %append data


%% make a vector of frequencies to use polar plot function

degreesPerStep = 1.8;   %resolution of stepper
maxDegrees = 360;       %full rotation in degrees       

%create the vector of frequencies
freqs = 0 : degreesPerStep : maxDegrees - degreesPerStep;

%convert degrees to radians
freqs = deg2rad(freqs); 

%% processing

%normalize along steps
for i = 1:1:size(IR, 1)
    %get all steps in this bin
   curBand = IR(i, :); 
   %normalize
   curBand = (curBand - min(curBand))/(max(curBand)-min(curBand));
   %replace
   IR(i, :) = curBand;
end

% %normalize along bins?
% 
% for i = 1:1:size(IR, 2)
%    curIR = IR(:, i); %all bins in this step
%    curIR = (curIR - min(curIR))/(max(curIR)-min(curIR));
%    IR(:, i) = curIR;
% end

%convert each IR to dB?
% for i = 1:1:size(IR, 2)
%     curIR = IR(:, i); %get all bins in this step
%     curIR = mag2db(curIR);
%     IR(:, i) = curIR;
% end

%% get bin resolution and plot

%calculate the bin resolution
binRes = fs/Nfft; 

%divide freqs by resolution to get approximate bins
binNums = freqs2plot./binRes;

%round to find closest available bin (rounded down to avoid indexing problems)
binNums = floor(binNums);

%calculate the (approximate) frequency of the band we are plotting
%should differ slighlty from what we asked, used for plotting
binResVec = binRes .* binNums;

%tranpose to fix legend for plot
binResVec = binResVec';

figure(1)
%get vectors with desired bins across steps
for i = 1:length(binNums)
    %get all magnitudes from a single freq band
    polarMags = IR(binNums(i), :);
    %use polar to plot it
    polarplot(freqs, polarMags);
    %overlay the plots
    hold on
end

%round to the nearest hundredth
binResVec = round(binResVec, 2);

%add title and legend
hold off; 
grid on; 
strTitle = strcat('Polar Plot (Single Capsule): ', {' '}, dataName);
title(strTitle);
%use bin resolution vector to create legend
strLegend = strcat(num2str(binResVec), ' Hz');
legend(strLegend, 'Location','NorthEastOutside');

% Plot the Tukey window if you want. It is not very interesting though.
% figure(2)
% plot(w); 
% title('Tukey window');
% xlabel('Samples');
% ylabel('Amplitude');







