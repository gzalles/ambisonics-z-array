%% MEMS FOA 40720 Subjective Experiment 2020 (GNU Version)
% 
% In the experiment there are three runs, three stimuli and two mics. In
% order to present the microphones in random order we call the AC or CA
% orderings cases. 

% There are a total of 24 questions, however, each question requires two
% stimuli since we are comparing the two mics. This script will just process
% a single microphone. We will combine them later.

% Assuming we get all the recordings completed in one day and that each
% recording is at least 1 minute apart, we can use the REAPER naming system
% to our advantage. 

% Just to make sure we are not making mistakes our processing function
% should also ask for the date, not just the folder. 

% In the second "case" (CA) the only thing that changes is the order so we
% do not need to re-record or re-process the sounds, just re-arrange them
% on our Reaper session. There are only 24 stimuli "pairs" so matching
% those manually is not too bad. (edit)

% We are going to: 
%   1. Helmholtz Resonance Compensate.
%   2. Encode using a simple matrix sum and difference method.
%   3. Export with new names. 

% WE NEED TO EXPORT 24 FILES ALREADY COMBINED INTO ONE MINUTE CLIPS, 
%  THERE SHOULD BE 24 OFF THEM. 

%% Init

%   fs = sample rate
%   times = vector with times at which stimuli were recorded
%   folder = within the raw folder, which folder you want to process.
%   date = '190227' for example, this is a check.
%   num_stimuli = how many A format recordings you want to process.
%   gerzon = boolean to enable gerzon filter

clc; clear;

%be careful, single and double quotes do different things sometimes.

%to create our list of times we are using the cell data structure.
times = {'1013', '1013', '1013'}; %in this solo case the time was 6:03pm
folder = 'feb_2020_mems_foa'; %folder for winter 2020
date = '200201'; %the day these stimuli were recorded (year, month, day)
gerzon = 1; %boolean, do you want to use gerzon filters or not?
N = 1024; %size of gerzon filter

% the methdology is important for this code to work. we wanted to have 3
% mics but we had to settle for two. Each mic has 8 A-format
% recordings (Training, R1, R2, R3, R4) and there are three stimuli.

% Furthermore, the audio was recorded in this specific way. We record 12
% large microphone recordings (4 for noise, speech, music, respectively)
% and then 12 for the small mic. 

% So in order to correctly generate our
% Gerzon filtered stimuli we would need to specify the radius of our array
% using the correct sequence. 

r = 0.147; %large mic, change this MANUALLY per mic...


%when you are ready uncomment 18
%num_stimuli = 18; %total number of stimuli (4 tracks = 1 stimuli)
num_stimuli = size(times, 2); %total number of stimuli (4 tracks = 1 stimuli)

%check that we are doing things right
if num_stimuli ~= length(times)
    error('These two values should be identical');
end

%% get audio data
for i = 1:num_stimuli
    
    time = times(i);
    %here we take the cell data and turn it into a character array
    time = char(time);
    
    %concat string to get paths
    %my channels in the reaper session caused a naming issue. 
    %good to know for next time.
    path1 = strcat('raw/', folder, '/02-FLU-', date, '_', time, '.wav');
    path2 = strcat('raw/', folder, '/03-FRD-', date, '_', time, '.wav');
    path3 = strcat('raw/', folder, '/04-BLD-', date, '_', time, '.wav');
    path4 = strcat('raw/', folder, '/05-BRU-', date, '_', time, '.wav');

    %read
    [flu_i, fs] = audioread(path1); %get sampling rate
    frd_i = audioread(path2);
    bld_i = audioread(path3);
    bru_i = audioread(path4);
    
    %%% filter [helmholtz] %%%
    [flu_o, frd_o, bld_o, bru_o] = ...
        foa_filter_mems_gnu(flu_i, frd_i, bld_i, bru_i, fs);
      
     %%% gerzon filter %%% must happen after encoding! but, the encoder
     %%% saves the files in another folder so you might need to do this
     %%% separately or put the running convolution inside the encoder.
     
     %%% what we need to do is change just the A2B_encoder to output directly if we want... 
     
    if gerzon == 1
        %call function
       [fw, fxyz] = foa_gerzon_filter(N, r, fs); %to do
        g_f = '_GF1'; %string to denote filtering
    else
        %don't call function
        g_f = '_GF0'; %string to denote no filtering
    end
    
    %%% encode A to B format %%%
    ordering = 'ACN';
    my_file_name = strcat('B_', ordering, '_', date, '_', time, g_f, '.wav');
    
    %call function in other repo with encoder
    %   remember to add this to the instructions. (DL, set path)
    b_format_audio = A2B_encoder(flu_o, frd_o, bld_o, bru_o, my_file_name, fs, ordering);
     
    
end


    

    
    
    
