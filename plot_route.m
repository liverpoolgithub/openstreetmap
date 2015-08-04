function [hRoute] = plot_route(ax, route, parsed_osm, lineColour)
% plot (over map) the route found by route planner
%
% usage
%   PLOT_ROUTE(ax, route, parsed_osm)
%
% input
%   ax = axes object handle.
%   route = matrix of nodes traversed along route, as returned by the
%           route_planner function.
%   parsed_osm = parsed OpenStreetMap XML data, as returned by the
%                parse_openstreetmap function.
%
% 2012.04.24 (c) Ioannis Filippidis, jfilippidis@gmail.com
% (Modified by) Elias Griffith, e.griffith@liverpool.ac.uk
%
% See also ROUTE_PLANNER, PARSE_OPENSTREETMAP.

if (nargin<4)
  lineColour = 'k';
end

% empty path ?
if isempty(route)
    warning('path is empty. This means that the planner found no path.')
    return
end

nodexy = parsed_osm.node.xy;
start_xy = nodexy(:, route.id(1) );
path_xy = nodexy(:, route.id);
path_end = nodexy(:, route.id(end) );

held = takehold(ax);

hRoute = hggroup;

hTemp = plotmd(ax, start_xy, 'Color', lineColour, 'Marker', 'o', 'MarkerSize', 10, 'LineWidth',2);
set(hTemp, 'Parent', hRoute);
hTemp = plotmd(ax, path_xy, 'Color', lineColour, 'LineStyle', '--', 'LineWidth', 4);
set(hTemp, 'Parent', hRoute);
hTemp = plotmd(ax, path_end, 'Color', lineColour, 'Marker', 's', 'MarkerSize', 10, 'LineWidth',2);
set(hTemp, 'Parent', hRoute);

givehold(ax, held)
