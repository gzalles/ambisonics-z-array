function S = projectionDecoding(W, X, Y, Z, azi, elev, dirFactor)

%function S = projectionDecoding(W, X, Y, Z, azi, elev, dirFactor)
%
%projectionDecoding appropriate for simple regular loudspeaker layouts.
%Parameters include four audio channels and the azimuth and elevation of
%the speaker.dirFactor ranges between 0 and 2, higher values are more
%directive (dir stands for directivity). Azi values range between 0 and
%359 and increase counterclockwise. Elev values range between -180 and 180. 
%
%example: S = projectionDecoding(W, X, Y, Z, 180, 0, 1);

%% error checking
if dirFactor > 2 || dirFactor < 0 
    error('dirFactor must be between 0 and 2');
elseif azi > 359 || azi < 0 
    error('azi must be between 0 and 359');
elseif elev < -180 || elev > 180 
    error('elev must be between -180 and 180');
end

%% main function
g_w = sqrt(2);
g_x = cos(azi)*cos(elev);
g_y = sin(azi)*cos(elev);
g_z = sin(elev);

S = 0.5 * ( (2-dirFactor)* g_w*W + dirFactor(g_x*X + g_y*Y + g_z*Z) );

end
