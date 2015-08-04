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
%
% Calculates distances (metres) along paths specified in (Lat,Lng,Alt)
% using a local NED coordinate system

function [distM] = calc_path_dist(pathNodes, nodes, refLLA)

prev_posNE = [];
distM = 0;
numNodesInPath = length(pathNodes);
for n=1:numNodesInPath
  
  % Look up node
  id = pathNodes(n);
  posLL = nodes.xy(:, nodes.id==id);
  posLL = flipud(posLL);
  posLLA = [posLL;0];
  posLLA = deg2rad_LLA(posLLA);
  posNE = LLA2NED(posLLA, refLLA);
  % Diff from previous pos
  if (~isempty(prev_posNE))
    % Dist
    dN = posNE(1) - prev_posNE(1);
    dE = posNE(2) - prev_posNE(2);
    dR = sqrt(dN*dN+dE*dE);
    distM = distM + dR;
  end
  prev_posNE = posNE;
  
end

end