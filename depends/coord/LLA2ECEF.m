% Copyright (c) 2014, Elias Griffith (e.griffith@liverpool.ac.uk)
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are
% met:
% 
%     * Redistributions of source code must retain the above copyright
%       notice, this list of conditions and the following disclaimer.
%     * Redistributions in binary form must reproduce the above copyright
%       notice, this list of conditions and the following disclaimer in
%       the documentation and/or other materials provided with the distribution
% 
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
% POSSIBILITY OF SUCH DAMAGE.

function [XYZ] = LLA2ECEF(LLA)

%------------------------
% XPLANE
%------------------------
f = 1/298.257223563;
%------------------------

%------------------------
% Common WGS84 parameters
%------------------------
a = 6378137;
%f = 1 / 298.257223563;
b = a * (1 - f);
ecc = sqrt( (a^2 - b^2) / a^2 );
ecc_prime = sqrt( (a^2 - b^2) / b^2 ); %#ok<NASGU>
%------------------------

%------------------------
% Split vector
%------------------------
lat = LLA(1);
lng = LLA(2);
alt = LLA(3);
%------------------------

%------------------------
% Intermediate step
%------------------------
N = a / ( sqrt(1 - ecc^2 * sin(lat)^2) );
%------------------------

%------------------------
% Conversions
%------------------------
X = (N + alt) * cos(lat) * cos(lng);
Y = (N + alt) * cos(lat) * sin(lng);
Z = (N * (b^2/a^2) + alt) * sin(lat);
%------------------------

%------------------------
% Reconstruct vector
%------------------------
XYZ = zeros(3,1);
XYZ(1) = X;
XYZ(2) = Y;
XYZ(3) = Z;
%------------------------

%------------------------
% Clean small values
%------------------------
SMALL_VALUE = 1E-9;      % 1 nanometre
for n=1:3
  if (abs(XYZ(n))<SMALL_VALUE)
    XYZ(n) = 0.0;
  end
end
%------------------------

end





