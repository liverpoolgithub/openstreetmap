% example script for using the OpenStreetMap functions
%
% use the example map.osm file in the release on github
%
% or
%
% download an OpenStreetMap XML Data file (extension .osm) from the
% OpenStreetMap website:
%   http://www.openstreetmap.org/
% after zooming in the area of interest and using the "Export" option to
% save it as an OpenStreetMap XML Data file, selecting this from the
% "Format to Export" options. The OSM XML is specified in:
%   http://wiki.openstreetmap.org/wiki/.osm
%
% See also PARSE_OPENSTREETMAP, PLOT_WAY, EXTRACT_CONNECTIVITY,
%          GET_UNIQUE_NODE_XY, ROUTE_PLANNER, PLOT_ROUTE, PLOT_NODES.
%
% 2010.11.25 (c) Ioannis Filippidis, jfilippidis@gmail.com
% (Modified by) Dr. Elias Griffith, e.griffith@liverpool.ac.uk
%
% Beware: Uses modified OpenStreetMap functions from "LiverpoolGithub" branch!!!


clear;
close all;
clc;
drawnow;

dbstop if error;

addpath(genpath(strcat(pwd,'/depends')));

%% Loading
filename = 'bayeux.osm';
filename_image = strrep(filename, '.osm', '.png');
filename_cached = strrep(filename, '.osm', '.mat');
loadTimer = tic;
try
  %% Load cached mat file
  load(filename_cached);
catch err
  %% On failure (re)parse xml
  fprintf('Cached file ''%s'' not found, parsing ''%s''\n', filename_cached, filename);
  
  %% Read XML - uses a function xml2mat that reads EVERYTHING at once.
  parsed_osm = parse_openstreetmap(filename);
  
  %% NED Origin - Use the mean latitude-longitude as local NED origin
  refLL = mean(parsed_osm.node.xy, 2);
  refLLA = [refLL(2); refLL(1);0];
  refLLA = deg2rad_LLA(refLLA);
  
  %% Break up user drawn roads into a standard method of connecting nodes.
  parsed_osm = breakup_osm(parsed_osm, refLLA);  % CHANGES NODE IDS !!!

  %% Read through tags and add arrays to "parsed_osm.way"
  save(filename_cached, 'parsed_osm', 'refLLA');
end
loadTime = toc(loadTimer);
fprintf('Load time = %0.2f\n', loadTime);


%% Connectivity
disp('Determinining Connectivity');
[connectivity_matrix, intersection_nodes] = extract_connectivity(parsed_osm);

%% Route finding - in this example, "Route via node 305"
ROUTING = true;
if (ROUTING)
  disp('Calculating route');  % Node numbers specific to "bayeux.osm"
  [route1] = route_planner(connectivity_matrix, 15875, 305);
  [route2] = route_planner(connectivity_matrix, 305, 6);
  route = [route1, route2(2:end)];
  routeDetailed = expand_route(route, parsed_osm);
end

%% Figure
disp('Plotting map...');
tic;
hFig = figure(1);
hAx = axes('parent', hFig);

DISP_NODES = true;  % Nodes are already labelled with matrix index.
DISP_NODE_IDS = false;  % Additionally, show the OpenStreetMap node ids.  

%% Roads
plot_way(hAx, parsed_osm, true, filename_image);

%% Connectivity
plot_road_network(hAx, connectivity_matrix, parsed_osm, false);
if (DISP_NODES)
  [i,j] = find(connectivity_matrix>0);
  plot_nodes(hAx, parsed_osm, i', DISP_NODE_IDS);
end

%% Routes
if (ROUTING)
  plot_route(hAx, routeDetailed, parsed_osm);
end

disp('Map plotted');
toc