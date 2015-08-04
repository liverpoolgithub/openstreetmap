function [hLabels] = plot_road_network(ax, connectivity_matrix, parsed_osm, showLabels)
%
% usage
%   PLOT_ROAD_NETWORK(ax, connectivity_matrix, parsed_osm)
%
% input
%   ax = axes object handle.
%   connectivity_matrix = matrix representing the road network
%                         connectivity, as returned by the function
%                         extract_connectivity.
%   parsed_osm = MATLAB structure containing the OpenStreetMap XML data
%                after parsing, as returned by function
%                parse_openstreetmap.
%
%   See also EXTRACT_CONNECTIVITY, PARSE_OPENSTREETMAP, ROUTE_PLANNER.
%
% File:         plot_road_network.m
% Author:       Ioannis Filippidis, jfilippidis@gmail.com
%               (Modified by) Elias Griffith, e.griffith@liverpool.ac.uk
% Date:         2012.04.24
% Language:     MATLAB R2012a
% Purpose:      plot the nodes and edges connecting them
% Copyright:    Ioannis Filippidis, 2012-

nodes = parsed_osm.node;
node_ids = nodes.id;
node_xys = nodes.xy;

n = size(connectivity_matrix, 2);

hLabels = hggroup;

held = takehold(ax);
nodelist = [];
xyList = [];
spacer = [NaN;NaN];
for curnode=1:n
    curxy = node_xys(:, curnode);
    
    % find neighbors
    curadj = connectivity_matrix(curnode, :);
    neighbors = find(curadj > 0);
    connectivity_matrix(curnode, neighbors) = 0;  % Avoid doubling up
    connectivity_matrix(neighbors, curnode) = 0;  % Avoid doubling up
    neighbor_xy = node_xys(:, neighbors);
    neighbor_dist = full(curadj(neighbors));
    
    % plot edges to each neighbor
    for j=1:size(neighbor_xy, 2)
        otherxy = neighbor_xy(:, j);
        xyPoint = [curxy, otherxy];
        xylabel = (curxy+otherxy)/2;
        str = sprintf('%0.0fm', neighbor_dist(j));
        if (showLabels)
          hTemp = text(xylabel(1), xylabel(2), str);
          set(hTemp, 'Parent', hLabels);
        end
        xyList = cat(2, xyList, spacer, xyPoint, spacer);
    end
    
    % is node connected ?
    if ~isempty(neighbor_xy)
        nodelist = [nodelist, curnode];
    end
end

plotmd(ax, xyList, 'r.--', 'linewidth', 2.0, 'MarkerSize', 15);

%plot_nodes(ax, parsed_osm, nodelist)

givehold(ax, held)
