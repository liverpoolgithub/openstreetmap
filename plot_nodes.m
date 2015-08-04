function [hNodes] = plot_nodes(ax, parsed_osm, only_node_indices, show_id)
% plot (selected) nodes and label each with index and id
%
% usage
%   PLOT_NODES(ax, parsed_osm, only_node_indices, show_id)
%
% input
%   ax = axes object handle where to plot the nodes.
%   parsed_osm = MATLAB structure containing the OpenStreetMap XML data
%                after parsing, as returned by function
%                parse_openstreetmap.
%   only_node_indices = selected node indices in the global node matrix.
%   show_id = select whether to show or not the ID numbers of nodes as text
%             labes within the plot
%           = 0 (do not show labels) | 1 (show labels)
%
% 2012.04.24 (c) Ioannis Filippidis, jfilippidis@gmail.com
% (Modified by) Elias Griffith, e.griffith@liverpool.ac.uk
%
% See also PARSE_OPENSTREETMAP, ROUTE_PLANNER.

% do not show node id (default)
if nargin < 4
    show_id = 0;
end

nodes = parsed_osm.node;
node_ids = nodes.id;
node_xys = nodes.xy;

% which nodes to plot ?
n = size(node_xys, 2);
if nargin < 3
    only_node_indices = 1:n;
end

if (size(only_node_indices,1)~=1)
  error('only_node_indices must be a ROW vector');
end
  

%% plot
held = takehold(ax);

% nodes selected exist ?
if n < max(only_node_indices)
    warning('only_node_indices contains node indices which are too large.')
    return
end

hNodes = hggroup;

% plot nodes
xy = node_xys(:, only_node_indices);
hTemp = plotmd(ax, xy, 'yo');
%set(hTemp, 'HitTest', 'off');
set(hTemp, 'Parent', hNodes);

% label plots
for i=only_node_indices
    node_id_txt = num2str(node_ids(i));
    if show_id
        curtxt = {['  ', num2str(i) ], ['id=', node_id_txt] }.';
    else
        curtxt = ['  ', num2str(i) ];
    end
    hTemp = textmd(node_xys(:, i), curtxt, 'Parent', ax);
    %set(hTemp, 'HitTest', 'off');
    set(hTemp, 'Parent', hNodes);
end

givehold(ax, held)
