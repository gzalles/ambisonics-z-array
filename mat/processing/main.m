% foa_mems_processing(fs, num_stimuli, folder) is just a function. you want
% to write a script to call it. there will be a lot of audio data that you
% need to process so might be better to be ready for this. 

% in the experiment there are three runs, three stimuli and two mics. In
% order to present the microphones in random order we call the AC or CA
% orderings CASES. 

% There are a total of 18 questions, however, each question requires two
% stimuli since we are comparing the two mics. 

% Assuming we get all the recordings completed in one day and that each
% recording is at least 1 minute apart we can use the REAPER naming system
% to our advantage. 

% Just to make sure we are not making mistakes our processing function
% should also ask for the date, not just the folder. 

% In the second "case" (CA) the only thing that changes is the order so we
% do not need to re-record or re-process the sounds, just re-arrange them
% on our Reaper session. 

% The angles is other runs will change so we will have to process and
% record new files. 
clc; clear;

fs = 44100; %remember to record at this fs (always!)
times = ["1903"]; %in this solo case the time was 6:03pm
folder = 'win2020'; %folder for winter 2020
date = '190227'; %the day these stimuli were recorded (year, month, day)

%when you are reasy uncomment 18
%num_stimuli = 18; %total number of stimuli (4 tracks = 1 stimuli)

num_stimuli = 1; %total number of stimuli (4 tracks = 1 stimuli)

foa_mems_processing(fs, times, folder, date, num_stimuli)






