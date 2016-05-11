drop table if exists road_edges
;

create table road_edges
as
select way_id, node_order as edge_order, node_id as node_id_1, lead(node_id) over (partition by way_id order by node_order) as node_id_2,
cast(null as int4) as vertex_id_1, cast(NULL as int4) as vertex_id_2,
cast(NULL as decimal) as lat_1, cast(NULL as decimal) as lon_1,
cast(NULL as decimal) as lat_2, cast(NULL as decimal) as lon_2,
cast(NULL as decimal) as azimuth_angle,
cast(NULL as geometry(LINESTRING)) as the_geom,
cast(NULL as geography(LINESTRING)) as the_geog,
cast(NULL as decimal) as length_meters,
1::decimal as commonness_scaled,
0::bigint  as commonness

from road_way_nodes
;
alter table road_edges add column edge_id serial not null
;
create index idx_road_edges_vertex1 on road_edges(vertex_id_1);
create index idx_road_edges_vertex2 on road_edges(vertex_id_2);
 
create index idx_road_edges_node1 on road_edges(node_id_1);
create index idx_road_edges_node2 on road_edges(node_id_2);

create index idx_road_edges_edge on road_edges(edge_id)
;
create index idx_road_edges_comm on road_edges(commonness)
;
create index idx_road_edges_comm_scaled on road_edges(commonness_scaled)
;

delete from road_edges
where node_id_2 is null
;

update road_edges
set lat_1 = b.lat ,
lon_1 = b.lon, 
vertex_id_1 = b.vertex_id
from road_nodes as b 
where road_edges.node_id_1 = b.node_id
;

update road_edges
set lat_2 = b.lat ,
lon_2 = b.lon, 
vertex_id_2 = b.vertex_id
from road_nodes as b 
where road_edges.node_id_2  = b.node_id
;
 
update road_edges
set the_geom = ST_makeline(ST_setsrid(ST_makepoint(lon_1,lat_1),4326) , ST_setsrid(ST_makepoint(lon_2,lat_2),4326) )
;
update road_edges
set the_geog  = geography(the_geom)
;
create index geo_road_edges on road_edges using gist (the_geog)
; 


update road_edges set length_meters = ST_length(the_geog)
;

update road_edges
set azimuth_angle = 
degrees(ST_azimuth(  
 ST_startpoint(the_geom),
 ST_endpoint(the_geom)  
))
;
