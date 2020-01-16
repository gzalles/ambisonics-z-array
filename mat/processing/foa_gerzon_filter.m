%{

ref: http://pcfarina.eng.unipr.it/Public/B-format/A2B-conversion/A2B.htm

Fw = ( 1 + jwr/c - 1/3(wr/c)^2 ) / ( 1 + 1/3jwr/c )
Fxyz = sqrt(6) * ( 1 + jwr/c - 1/3(wr/c)^2 ) / ( 1 + 1/3jwr/c )

r = distance of each capsule from the center of the tetra in m
w = angular frequency in rad/s (w = 2pif)
c = speed of sound in m/s (343 m/s)

%}

N = 1024; %number of points in the filter
r = 0.147; %large mic
c = 343; %speed of sound

%define the sampling frequency
fs=96000;

%your vector of 1024+1 frequencies must span the range from 0 to Fs/2:
f = linspace(0,fs,1024+1);
w = 2*pi*f; %angular frequency vector in radians/second

%compute the filters.
Fw = ( 1 + 1j*w*r/c - 1/3*(w*r/c).^2 ) ./ ( 1 + 1/3*1j*w*r/c );
Fxyz = sqrt(6) * ( 1 + 1j*w*r/c - 1/3*(w*r/c).^2 ) ./ ( 1 + 1/3*1j*w*r/c );

% When we have a filter in frequency domain as a (1024+1)-lines complex 
% spectrum (ranging from DC to nyquist) you can easily convert to a FIR 
% filter in time domain by IFFT. In this case we have two filters, named 
% Fw and Fxyz, each made of 1024+1 complex values. To convert them into 
% the time domain we do the following:

% the code below belongs to Angelo Farina:
fw=fftshift(ifft(Fw,2048,'symmetric'));
fwmax=max(fw);%find max
fw=fw/fwmax;%normalize

%audiowrite('fw.wav',fw,fs,'BitsPerSample',24);%get wav

fxyz=fftshift(ifft(Fxyz,2048,'symmetric'));
fxyz=fxyz/fwmax;

%audiowrite('fxyz.wav',fxyz,fs,'BitsPerSample',24);

nfft = 2^9;
FW_shift = fft(fw, nfft);

figure(1);
subplot(2,1,1);
plot(20*log10(abs(FW_shift(1:end/2+1))));
grid on; axis tight;
title('Magnitude of W filter in dB');

subplot(2,1,2);
plot(angle(FW_shift(1:end/2+1)));
grid on; axis tight;
title('Phase of shifted W filter');







