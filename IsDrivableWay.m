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

function [isDrivable, isHighway] = IsDrivableWay(tagList)

drivableSet = {'motorway', 'motorway_link', 'trunk', 'trunk_link',...
  'primary', 'primary_link', 'secondary', 'secondary_link',...
  'tertiary', 'tertiary_link', 'road', 'residential', 'living_street',...
  'service', 'services', 'motorway_junction', 'unclassified', 'track'};

[isHighway, valHighway] = find_tag_key(tagList, 'highway');
isRoad = isHighway && any(ismember(drivableSet, valHighway));

% [isBridge, valBridge] = find_tag_key(tagList, 'bridge');
% isBridge = isBridge && strcmp(valBridge, 'yes');

isDrivable = isRoad; % || isBridge;

end