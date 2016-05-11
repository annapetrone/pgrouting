
drop table if exists nodes_raw
;
create table nodes_raw
as
select *, sum(case when tag_type = 1 then 1 else 0 end ) over (order by file_line_num) as node_raw_id
from 
(
select *, 
  case when xml_str like '%<node%' then 1 when xml_str like '%</node>%' then -1 else 0 end tag_type
 from osm_raw
where geometry_type = 0
) as a
; 

drop table if exists nodes;

create table nodes
as
select node_raw_id, cast(array_to_string(array_agg(xml_str order by file_line_num),chr(10)) as xml) as node_xml,
cast (null as bigint) as node_id ,
cast (null as decimal) as lon ,
cast (null as decimal) as lat
from nodes_raw
group by 1
;

update nodes
set node_id = (xpath( '//node/@id', node_xml))[1]::text::bigint 
;
update nodes
set lon = (xpath( '//node/@lon', node_xml))[1]::text::decimal
;
update nodes
set lat = (xpath( '//node/@lat', node_xml))[1]::text::decimal
;

create index idx_nodes on nodes(node_id)
;

drop table if exists node_tags
;

create table node_tags
as
 select node_id,  
  unnest( xpath('//node/tag/@k', node_xml) )::text as tag_name,
  unnest( xpath('//node/tag/@v', node_xml) )::text as tag_value
from nodes
;
 
create index idx_node_tags_name on node_tags(tag_name)
;

delete from node_tags
where tag_value is null
;


