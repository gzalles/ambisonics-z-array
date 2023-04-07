#this script is used to test a naive approach to helmholtz resonance reduction
#in the ics 40720. according to our initial measurements we want to attenuate by 20dB
#starting at 1kHz up to 20kHz. 

#utlimately we picked the attenuation by visual inspection, and confirmed auditorily.
#the value you pick 36, 42, 48, is a matter of taste, to some extent. 

#this might also change for 4, 16, 64 capsules added together. 
#while the IR was taken in anechoic conditions, the soprano audio file was taken 
#in CPMC365 with a specific speaker, so it's not "perfect"

#note: the measurement we took differs from the ICS40720 specs. we are using our own meas.
#see figure 5, AES143 paper Zalles et al.

#https://en.wikipedia.org/wiki/Helmholtz_resonance

#this script uses the signal package 'pkg install -forge signal' [requires control]
pkg load signal;

close all; #close any open figures
clc;clear all; #clear workspace, and command window 

plot_on = 1; #plot on/off variable
cd data/aes143
load mems_1.mat; #load mems measurement ICS-40720 (anechoic), ScanIR
cd ../..

ir = data(1).IR; #get just the first measurement (on-axis)

#passband edge frequency (where do we start to attenuate?)
w_p = 1000; #in Hz

#stopband edge frequency (where does the filter end?)
w_s = 16000; #in Hz

Fs = specs.sampleRate; #sample rate
dB = 36; #X dB of attenuation at w_s
Nfft = length(ir); #size of FFT
freqVec = linspace(0, Fs/2, Nfft/2); #freq vector for plotting (W)

delta_f = w_s - w_p; #bandwidth of transition band

#https://www.allaboutcircuits.com/technical-articles/design-of-fir-filters-design-octave-matlab/
N = dB*Fs/(22*delta_f); #equation from site

%apparently we want N to be odd? (TODO) see link above.

#N gives us the length of the filter 

f =  [w_p]/(Fs/2); #convert to radians
hc = fir1(round(N)-1, f,'low'); #create filter
HC = fft(hc, Nfft); #FFT the FIR

#plot
if plot_on == 1
  figure(1)
  plot(freqVec, 20*log10(abs(HC(1:end/2))));%filter response
  axis([0 20000 -40 20])
  title('Filter Frequency Response')
  grid on;
  hold on;

  #we created a filter of this type before using designfilt in matlab
  #but we want to use octave

  IR = fft(ir, Nfft); #FFT of ir
  plot(freqVec, 20*log10(abs(IR(1:end/2))));%original

  ir_f = filter(hc,1,ir);%filter the audio (signal pkg)

  IR_F = fft(ir_f, Nfft); #FFT the filtered signal (aka ir)
  plot(freqVec, 20*log10(abs(IR_F(1:end/2))));%filtered
  
  %add legend 
  legend('filter response', 'original', 'filtered');
endif 

#let's listen how it sounds.
#[x, xfs] = audioread('soprano-ics40720.wav'); %read audio from mems mic
#x_f = filter(hc,1,x); #filter the music (signal pkg)
#audiowrite("f36dB-soprano-ics40720.wav", x_f, xfs);

#let's export the simple filter to use in other scripts. 
#audiowrite("naive-helm.wav", hc, Fs);