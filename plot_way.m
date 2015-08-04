function [hWays] = plot_way(hAx, parsed_osm, resetMap, map_img_filename)
%PLOT_WAY   plot parsed OpenStreetMap file
%
% usage
%   PLOT_WAY(ax, parsed_osm)
%
% input
%   ax = axes object handle
%   parsed_osm = parsed OpenStreetMap (.osm) XML file,
%                as returned by function parse_openstreetmap
%   map_img_filename = map image filename to load and plot under the
%                      transportation network
%                    = string (optional)
%
% 2010.11.06 (c) Ioannis Filippidis, jfilippidis@gmail.com
% (Modified by) Elias Griffith, e.griffith@liverpool.ac.uk
%
% See also PARSE_OPENSTREETMAP, EXTRACT_CONNECTIVITY.

% ToDo
%   add double way roads

VERBOSE = false;

if (nargin < 4)
  map_img_filename = [];
end

[bounds, node, way, ~] = assign_from_parsed(parsed_osm);

if (VERBOSE)
  disp_info(bounds, size(node.id, 2), size(way.id, 2));
end
if (resetMap)
  show_map(hAx, bounds, map_img_filename);
end


roadway_coords = [];
pathway_coords = [];
other_coords = [];

hWays = hggroup;

for i=1:size(way.id, 2)
  
    
  % Get coords
  way_nd_ids = way.nd{1, i};
  num_nd = size(way_nd_ids, 2);
  nd_coords = zeros(2, num_nd);
  nd_ids = node.id;
  for j=1:num_nd
    cur_nd_id = way_nd_ids(1, j);
    nd_coords(:, j) = node.xy(:, cur_nd_id == nd_ids);
  end
  
  % Pack coords
  spacer = [NaN;NaN];
  tagList = way.tag{i};
  [isDrivable, isHighway] = IsDrivableWay(tagList);
  if (isHighway)
    if (isDrivable)
      roadway_coords = cat(2, roadway_coords, spacer, nd_coords, spacer);
    else
      pathway_coords = cat(2, pathway_coords, spacer, nd_coords, spacer);
    end
  else
    other_coords = cat(2, other_coords, spacer, nd_coords, spacer);
  end

end

% Do plot
hTemp = plotmd(hAx, other_coords, 'g-' , 'linewidth', 1.0);
set(hTemp, 'Parent', hWays);
hTemp = plotmd(hAx, roadway_coords, 'b-' , 'linewidth', 3.0);
set(hTemp, 'Parent', hWays);
if (~isempty(pathway_coords))
  hTemp = plotmd(hAx, pathway_coords, 'm-' , 'linewidth', 3.0);
  set(hTemp, 'Parent', hWays);
end
