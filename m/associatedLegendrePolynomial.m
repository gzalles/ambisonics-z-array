function P = associatedLegendrePolynomial(ambiOrder, sphIdx, x)

%function P = associatedLegendrePolynomial(ambiOrder, sphIdx, x)
%
%returns the associated legendre polynomial up to fourth order ambisonics. 
%check this works versus MATLAB's legendre function.
%
%example: P = associatedLegendrePolynomial(1, 1, sin(pi))
%
%sauce: http://mathworld.wolfram.com/AssociatedLegendrePolynomial.html
%m is superscript, l is subscript (l = n = ambisonic order)

order = ambiOrder;
degree = sphIdx; 

if order == 0 && degree == 0
P = 1;                                %order 0 degree 0
elseif order == 1 && degree == 0
P = x;                                %order 1 degree 0
elseif order == 1 && degree == 1 
P =	-(1-x^2)^(1/2);             	    %order 1 degree 1
elseif order == 2 && degree == 0
P = 1/2*(3*x^2-1);                    %order 2 degree 0
elseif order == 2 && degree == 1
P = -3*x*(1-x^2)^(1/2);         	    %order 2 degree 1   
elseif order == 2 && degree == 2 
P = 3*(1-x^2);                  	    %order 2 degree 2 
elseif order == 3 && degree == 0
P = 1/2*x*(5*x^2-3);                  %order 3 degree 0
elseif order == 3 && degree == 1
P = 3/2*(1-5*x^2)*(1-x^2)^(1/2);	    %order 3 degree 1
elseif order == 3 && degree == 2
P = 15*x*(1-x^2);               	    %order 3 degree 2
elseif order == 3 && degree == 3
P = -15*(1-x^2)^(3/2);          	    %order 3 degree 3
end
    
%P_5^0(x)	=	1/8x(63x^4-70x^2+15) 

%matlab has these functions built-in. we can double check our results with
%those. 

end