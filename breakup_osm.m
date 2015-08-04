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
% Cuts up the network extracted from the OSM data so that each road segment
% has a single beginning and end node - with "NO BRANCHING OFF" in between.
% 
% This should fix most connectivity issues (E.g skipping nodes along route) 
% caused by an overly connected matrix connecting every node on the path.
%
% WARNING: Generates extra paths to achieve this, so labelling with differ 
%          from the original OSM XML.
 
function [osmData] = breakup_osm(osmData, refLLA)

CALC_ROAD_DISTANCES = (nargin==2);

node = osmData.node;
way = osmData.way;

ways_num = size(way.id, 2);
ways_node_sets = way.nd;

roadWays = [];
for curway=1:ways_num
  % highway/bridge?
  tagList = way.tag{curway};
  isDrivable = IsDrivableWay(tagList);
  if (isDrivable)
    roadWays = cat(1, roadWays, curway);
  end  
end

% Dest struct
wayIndex = 1;
new_way.id = [];
new_way.nd = {};
new_way.dist = [];
new_way.tag = {};

node_ids = node.id;
for curway=1:ways_num
  
  % highway/bridge?
  tagList = way.tag{curway};
  isDrivable = IsDrivableWay(tagList);
  if (~isDrivable)
    % Store
  	new_way.id = cat(2, new_way.id, wayIndex);
    new_way.nd = cat(2, new_way.nd, way.nd{curway});
    new_way.dist = cat(2, new_way.dist, 0.0);
    new_way.tag = cat(2, new_way.tag, way.tag(curway));
    
    wayIndex = wayIndex + 1;
    continue;  % NON_DRIVABLE SO SKIP!
  end
  
  % current way node set
  nodeset = ways_node_sets{curway};
  nodes_num = size(nodeset, 2);
  
  % Split path  
  m = 1;
  startNode = nodeset(1);
  newSegmentNodes = [];
  newSegmentNodes{m} = startNode;  % Start node
  
  startNode_index = find(nodeset(1) == node_ids);
  endNode_index = find(nodeset(end) == node_ids);
   
  % Dont include start point or end point in checks
  for n = 2:(nodes_num-1)
    
    currentNode = nodeset(n);
    newSegmentNodes{m} = cat(2,newSegmentNodes{m},currentNode);
    
    % Find all parts of path that also have endpoints on them
    found = false;
    for ind = roadWays'
      
      nodesToSearch = ways_node_sets{ind};
      
      % If comparing against same way (e.g. self loop)
      if (ind==curway)
        % Be sure to remove self from the check
        nodesToSearch(n) = [];
      end
      
      % Check
      found = any(nodesToSearch == currentNode);
      if (found)
        % This mid-point node is also part of another "way" somewhere
        break;
      end
    end
    if (found)
      % Has an endpoint here so start a new path
      m = m+1;
      % START A NEW SEGMENT at this node
      newSegmentNodes{m} = currentNode;
    end
    
  end
  lastNode = nodeset(end);
  newSegmentNodes{m} = cat(2,newSegmentNodes{m},lastNode); % End node
  
  % Has new ways?
  for m=1:length(newSegmentNodes) 
    
    item.id = wayIndex;
    item.nd = newSegmentNodes{m};
    if (CALC_ROAD_DISTANCES)
      item.dist = calc_path_dist(item.nd, node, refLLA);
    else
      item.dist = 1.0;  % Unit distance
    end
    item.tag = way.tag{curway};  % Current tag
    new_way.id = cat(2, new_way.id, item.id);
    new_way.nd = cat(2, new_way.nd, item.nd);
    new_way.dist = cat(2, new_way.dist, item.dist);
    new_way.tag = cat(2, new_way.tag, {item.tag});
    
    wayIndex = wayIndex+1;
  end
  
end

% Use these ways now
osmData.way = new_way;
 