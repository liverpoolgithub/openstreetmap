function [connectivity_dist, connectivity_way, intersection_node_indices] = extract_connectivity(parsed_osm)
%EXTRACT_CONNECTIVITY   extract road connectivity from parsed OpenStreetMap
%   [connectivity_matrix, intersection_nodes] = EXTRACT_CONNECTIVITY(parsed_osm)
%   extracts the connectivity of the road network of the OpenStreetMap
%   file. This yields a set of nodes where the roads intersect.
%
%   Some intersections may appear multiple times, because different roads
%   may meet at the same intersection and because multiple directions are
%   considered different roads. For this reason, in addition to the
%   connectivity matrix, the unique nodes are also identified.
%
% usage
%   [connectivity_matrix, intersection_nodes] = ...
%                                   EXTRACT_CONNECTIVITY(parsed_osm)
%
% input
%   parsed_osm = parsed OpenStreetMap (.osm) XML file,
%                as returned by function parse_openstreetmap
%
% output
%   connectivity_matrix = adjacency matrix of the directed graph
%                         of the transportation network
%                       = adj(i, j) = 1 (if a road leads from node i to j)
%                                   | 0 (otherwise)
%   intersection_nodes = the unique nodes of the intersections
%
% See also PARSE_OPENSTREETMAP, PLOT_WAY.
%
% File:         extract_connectivity.m
% Author:       Ioannis Filippidis, jfilippidis@gmail.com
%               (Modified by) Elias Griffith, e.griffith@liverpool.ac.uk
% Date:         2010.11.20
% Language:     MATLAB R2011b
% Purpose:      extract road connectivity from parsed osm structure
% Copyright:    Ioannis Filippidis, 2010-

[~, node, way, ~] = assign_from_parsed(parsed_osm);

ways_num = size(way.id, 2);
ways_node_sets = way.nd;
ways_dists = way.dist;
node_ids = node.id;

%% FILTER
roadWays = [];
for curWay=1:ways_num
  % highway/bridge?
  tagList = way.tag{curWay};
  isDrivable = IsDrivableWay(tagList);
  if (isDrivable)
    roadWays = cat(2, roadWays, curWay);
  end
end

%% CONNECT
connectivity_dist = sparse([]);
connectivity_way = sparse([]);
intersection_node_indices = [];
for curWay=roadWays
  % Get path
  nodeset = ways_node_sets{curWay};
  % Get points connected by path
  startNode = nodeset(1);
  endNode = nodeset(end);
  if (startNode~=endNode)
    
    curDist = ways_dists(curWay);
    
    startNode_index = find(node_ids == startNode);
    endNode_index = find(node_ids == endNode);  
    
    try
      prevDist = connectivity_dist(startNode_index, endNode_index);
    catch
      prevDist = 0;
    end
    
    if (prevDist==0)
      connectivity_dist(startNode_index, endNode_index) = curDist;
      connectivity_dist(endNode_index, startNode_index) = curDist;
      connectivity_way(startNode_index, endNode_index) = curWay;
      connectivity_way(endNode_index, startNode_index) = curWay;
    else
%       warning('Path already exists - TODO: Handle multiple direct paths between two nodes');
%       disp('(For now I only connect the shortest path between two nodes, which may remove possible starting roads)');
%       disp('One option would be a 3D connectivity matrix!')
      if (curDist<prevDist)
        % disp('-> RESULT: Using path with shorter distance!');
        connectivity_dist(startNode_index, endNode_index) = curDist;
        connectivity_dist(endNode_index, startNode_index) = curDist;
        connectivity_way(startNode_index, endNode_index) = curWay;
        connectivity_way(endNode_index, startNode_index) = curWay;
      else
        % disp('-> RESULT: Path ignored!');
      end
    end
    
    intersection_node_indices = cat(2, intersection_node_indices, startNode_index, endNode_index);
  end
end
intersection_node_indices = unique(intersection_node_indices);

end