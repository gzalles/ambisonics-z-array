feb 26 - I tried grabbing the ambeo IR's but it seems like they are 
indentical to the mems IRs. I might just need to take new measurements. I
have not yet gotten polar plot for the old microphone. I am not sure if
this filter is right, I think it will be as important to listen to it as it
is to plot it. I was using clear at the top of the script but I am not sure
it was really working. 

feb 26 - i figured it out, everytime I load data in the workspace is overwritten.

feb 28 - i fixed some issues i was having like the ambeo was clearly louder, 
I think it would be better to normalize both IRs before getting FFT than doing this weird method. 
I still have not figured out how to cancel out the f-response of the speaker. 

I tried normalizing now but it looks worse than before, I am not sure this is the right way to do it
Maybe I have to normalize the bins rather than the IR raw audio data.

-----everything before was 2018.

jan 15, 2020 

these are the files I worked on when I was figuring out what kind of filter i wanted to make. they are no longer needed, just here to show the process.