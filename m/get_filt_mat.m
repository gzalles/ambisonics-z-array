## Copyright (C) 2023 Gabriel Zalles
##
## This program is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <https://www.gnu.org/licenses/>.

## Function used to generate filter matrices by solving system of linear equations. 
##
## function filt_mat = get_filt_mat (SH_ideal, Nfft, D, numHarms, IR_ALL, Q, enc_mat, cutoff)


## Author: Gabriel Zalles <gabrielzalles@Gabriels-MacBook-Pro.local>
## Created: 2023-04-17

function filt_mat = get_filt_mat (SH_ideal, Nfft, D, numHarms, IR_ALL, Q, enc_mat, cutoff)
  
  #alloc mem for filter mat
  FILT_MAT_ALL = zeros(Q, numHarms, Nfft, D); #larger data structure for all D
  FILT_MAT = zeros(Q, numHarms, Nfft); 
  X = zeros(Q, numHarms); #X is a 4x4 matrix corresponding to single k
  
  #get filt matrix 

  for d = 1:1:D
    
    b = SH_ideal(d, :); #get ideal SH for one direction, all SHs [same for all k]
    b = abs(b); #use only positive values
    
    if size(b, 2) ~= numHarms #check that the dim is correct
      b = b';
    endif
    
    for k = 1:1:Nfft
      #aX = b so X = a^-1 * b
      
      a = IR_ALL(d, :, k);#get IRs for one bin, and one direction
      a = abs(a); #get magnitudes
      
      if size(a, 2) ~= Q #check that the dim is correct
        a = a';
      endif
      
      a_inv = pinv(a); #get inverse of a
      X = a_inv * b; #find 4x4 mat 
      
      if size(X, 1) ~= Q || size(X, 2) ~= numHarms
        error("Matrix dims off in get_filt_mat");
      endif
      
      FILT_MAT(:, :, k) = X; #place mat for bin k in struct
    
     endfor

     FILT_MAT_ALL(:, :, :, d) = FILT_MAT; #place 4x4xNfft mat (for one d) in struct
      
  endfor
  
  #get average along dimension 4 (directions)
  FILT_MAT = sqrt(mean(FILT_MAT_ALL.^2, 4)); #DFR
  
  #DC bins 1 and Nyq
  FILT_MAT(:, :, 1) = zeros(Q, numHarms); #DC bin = 0
  FILT_MAT(:, :, Nfft) = zeros(Q, numHarms); #DC bin = 0

  #alloc mem for
  filt_mat = zeros(size(FILT_MAT));#time domain filt matrix
  
  #we need + and - values. this adds back the required sign (phase).
  enc_mat_sign = sign(enc_mat); #re-apply phase term to filters.
  
  #disp(enc_mat_sign);#debug 
  
  bm = blackman(Nfft*2); #make window function
  win = zeros(Nfft, 1); #init mem for window
  win(1:Nfft) = bm(end/2+1:end); #put bm in win var
 
  S = zeros(Nfft, 1);
  
  #FILT_MAT values are magnitudes, we need to iFFT to turn it to time domain
  for q = 1:1:Q
    for harm = 1:1:numHarms
      
      #get one sign coefficient from enc_mat (+/- 1)
      enc_mat_sign_c = enc_mat_sign(q, harm);
      
      #get one filter in freq domain (mags), make min phase, iFFT
      S(1:end) = FILT_MAT(q, harm, :); #the complex spectrum we want to make min-phase 
      
      #disp("Size of S"); disp(size(S));
      
      ONE_H = exp( fft( fold( ifft( log( clipdb(S, cutoff) )))));#make min phase (TODO make function)
      one_h = real(ifft(ONE_H, Nfft));#more taps = better resolution (but slower)
      one_h(1) = 0; #make first value 0 to avoid spectral leakage
      #one_h = one_h .* win; #window ir to smooth out
      filt_mat(q, harm, :) = one_h * enc_mat_sign_c;
      #FILT_MAT(q, harm, :) = ONE_H;#one H min. phase
      
    endfor
  endfor

endfunction
