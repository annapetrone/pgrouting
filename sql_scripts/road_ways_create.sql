drop table if exists road_ways
;

create table road_ways
as select way_id, tag_value as road_type, 0::int as is_one_way
from way_tags
where tag_name = 'highway'
;

-- remove pedestrian ways 
delete from road_ways
where road_type in ('footway', 'cycleway', 'path', 'steps', 'pedestrian', 'corridor')
;

-- identify roads that are one-way. then for the non-one-way roads, create way in the opposite direction 
drop table if exists one_way_ways
; -- http://wiki.openstreetmap.org/wiki/OSM_tags_for_routing#Oneway
create table one_way_ways
as 
select way_id
from (

select way_id
from way_tags
where tag_name = 'oneway'
and tag_value in ('yes','-1')

UNION

select way_id
from road_ways
where road_type = 'motorway'

UNION

select way_id
from way_tags
where tag_name = 'junction'
and tag_value = 'roundabout'


) as w 
group by 1
;

delete from one_way_ways
where way_id in
  (select way_id from way_tags where tag_name = 'oneway' and tag_value = 'no')
;

update road_ways
set is_one_way = 1
where way_id in (select way_id from one_way_ways)
;

drop table one_way_ways
;


drop table if exists road_way_nodes
;
create table road_way_nodes
as select a.way_id, node_id, node_order
from way_nodes as a 
join road_ways as b 
on a.way_id = b.way_id
;

insert into road_way_nodes
select -1*way_id, node_id, row_number() over (partition by way_id order by node_order desc) as node_order
from road_way_nodes
where way_id in (select way_id from road_ways where is_one_way = 0)
;

create index idx_road_way_nodes on road_way_nodes(node_id)
;

insert into road_ways
select -1*way_id, road_type, is_one_way
from road_ways
where -way_id in (select way_id from road_way_nodes group by 1)
;


drop table if exists road_nodes
;
create table road_nodes
as
select *, cast(row_number() over (order by 1) as int4) as vertex_id, ST_SetSRID(ST_makePoint(lon,lat),4326) as the_geom
from nodes
where node_id in (select node_id from road_way_nodes group by 1)
;

create index idx_roads_nodes on road_nodes(node_id)
;

/*
create table road_lines
as
select way_id, ST_makeline ( ST_SetSRID(ST_makepoint(lon,lat), 4326 ) order by node_order) as the_geom

from road_way_nodes as a
join nodes as b 
on a.node_id = b.node_id
group by 1;

*/