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

function routeDetails = expand_route(routeConn, parsed_osm)

nodes = parsed_osm.node;
node_ids = nodes.id;
node_xys = nodes.xy;

way = parsed_osm.way;
wayLists = way.nd;

numWays = length(wayLists);
startNodeIdList = zeros(numWays,1);
endNodeIdList = zeros(numWays,1);
for n = 1:numWays
  startNodeIdList(n) = wayLists{n}(1);
  endNodeIdList(n) = wayLists{n}(end);
end

routeFull = [];
numNodes_con = length(routeConn);
for n = 1:numNodes_con-1
  
  startNodeId = node_ids(routeConn(n));
  endNodeId = node_ids(routeConn(n+1));
   
  % Find "way" with startNode and endNode as endpoints
  % FORWARD CHECK
  reversed = false;
  ind = find((startNodeIdList==startNodeId) & (endNodeIdList==endNodeId));
  if (isempty(ind))
    % REVERSE CHECK
    reversed = true;
    ind = find((startNodeIdList==endNodeId) & (endNodeIdList==startNodeId));
  end
  % Sanity check
  if (isempty(ind))
    error('Unknown way in route - route and map dont appear to match up');
  end
  
  % Extract intermediate nodes
  intNodes = wayLists{ind};
  if (reversed)
    intNodes = fliplr(intNodes);
  end
  
  % Add to route
  if (isempty(routeFull))
    routeFull = intNodes;
  else
    routeFull = cat(2, routeFull, intNodes(2:end));  % Note the 2:end to avoid dupe endpoints
  end
end

% Convert from Ids to node indices
[temp, routeFull] = ismember(routeFull, node_ids);

% Attach lat,lng of nodes to the route
routeDetails.id = routeFull;
routeDetails.longitude = node_xys(1, routeFull);
routeDetails.latitude = node_xys(2, routeFull);

end
