function Y = sphericalHarmonic(azi, elev, ambiOrder, sphIdx, norm) 
%function Y = sphericalHarmonic(N, P, azi, elev, order, degree) 
%
%uses Normalization formulas as well as legendre() to get spherical harmonic.
%
%Y = N * P(sin(azi))*cos(abs(m)*elev) if m >= 0 
%Y = N * P(sin(azi))*sin(abs(m)*elev) if m <  0 
%
%n = ambisonic order (aka l)
%m = degree (spherical harmonic # :: W=0,Y=1,etc.)
%norm = 'sn3d' or 'n3d'
%azi = in degrees from 0 to 360 (increase counter-clockwise)
%elev = in degree
%
%
%example
%
%Y = sphericalHarmonic(azi, elev, ambiOrder, sphIdx, norm) 

azi = deg2rad(azi); #times pi / 180
elev = deg2rad(elev; #convert to radians

%% redefinition
m = sphIdx; 

%% associated legendre polynomial
P = associateLegendreFunction(ambiOrder, sphIdx, sin(azi));


%% normalization
if strcmp(norm, 'sn3d')
    N = sn3d(ambiOrder, sphIdx);
elseif strcmp(norm, 'n3d')
    N = n3d(ambiOrder, sphIdx);
else
    error('Select either sn3d or n3d as norm');
end

%% main function
if m >= 0 
    Y = N * P*cos(abs(m)*elev);
elseif m < 0
    Y = N * P*sin(abs(m)*elev);

end