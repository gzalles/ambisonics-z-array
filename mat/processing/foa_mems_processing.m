function foa_mems_processing(fs, times, folder, date, num_stimuli)
%function foa_mems_processing(fs, times, folder, date, num_stimuli)
%
%this function is used to filter all the stimuli recorded with the mems
%foa microphone. The filter dampens frequencies above 10k by 15dB per
%octave.
%
%there should also be an option to apply gerzon filters and finally, the
%filtered signals should be encoded using the encoder found in the
%repository foa_a2b_encoder. 
%
%   fs = sample rate
%   times = vector with times at which stimuli were recorded
%   folder = within the raw folder, which folder you want to process.
%   date = '190227' for example, this is a check.
%   num_stimuli = how many A format recordings you want to process.


%% mems
for i = 1:num_stimuli
    
    time = times(i);
    
    %concat string to get paths
    path1 = strcat('raw/', folder, '/01-FLU-', date, '_', time, '.wav');
    path2 = strcat('raw/', folder, '/02-FRD-', date, '_', time, '.wav');
    path3 = strcat('raw/', folder, '/03-BLD-', date, '_', time, '.wav');
    path4 = strcat('raw/', folder, '/04-BRU-', date, '_', time, '.wav');

    
    %read
    flu_i = audioread(path1);
    frd_i = audioread(path2);
    bld_i = audioread(path3);
    bru_i = audioread(path4);
    
    %filter
    [flu_o, frd_o, bld_o, bru_o] = ...
        foa_filter_mems(flu_i, frd_i, bld_i, bru_i, fs);
    
    filename = strcat('test.wav');
    ordering = 'acn';
    
    A2B_encoder(flu_o, frd_o, bld_o, bru_o, filename, fs, ordering)
    
end


%% ambeo

% for i = 1:num_stimuli
%     
%     %convert index into string i_s (index as string)
%     i_s = num2str(i);
%     
%     %concat string to get paths
%     path1 = strcat('raw/ambeo/', i_s, '/ambeo_', i_s , '_flu.wav');
%     path2 = strcat('raw/ambeo/', i_s, '/ambeo_', i_s , '_frd.wav');
%     path3 = strcat('raw/ambeo/', i_s, '/ambeo_', i_s , '_bld.wav');
%     path4 = strcat('raw/ambeo/', i_s, '/ambeo_', i_s , '_bru.wav');
%     
%     %read
%     flu_i = audioread(path1);
%     frd_i = audioread(path2);
%     bld_i = audioread(path3);
%     bru_i = audioread(path4);
%     
%     %DONT FILTER!
%     
%     filename = strcat('Ambeo_',i_s,'.wav');
%     ordering = 'acn';
%     
%     A2B_encoder(flu_i, frd_i, bld_i, bru_i, filename, fs, ordering)
    
end
    

    
    
    
