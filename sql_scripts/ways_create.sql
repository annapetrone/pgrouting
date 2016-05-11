
drop table if exists ways_raw
;
create table ways_raw
as
select *, sum(case when tag_type = 1 then 1 else 0 end ) over (order by file_line_num) as way_raw_id
from 
(
select *, 
  case when xml_str like '%<way%' then 1 when xml_str like '%</way>%' then -1 else 0 end tag_type
 from osm_raw
where geometry_type = 1
) as a
; 

drop table if exists ways;

create table ways
as
select way_raw_id, cast(array_to_string(array_agg(xml_str order by file_line_num),chr(10)) as xml) as way_xml,
cast (null as bigint) as way_id  
from ways_raw
group by 1
;

update ways
set way_id = (xpath( '//way/@id', way_xml))[1]::text::bigint 
;

create index idx_ways on ways(way_id)
;

drop table if exists way_tags
;

create table way_tags
as
 select way_id,  
  unnest(xpath('//way/tag/@k', way_xml))::text as tag_name,
  unnest(xpath('//way/tag/@v', way_xml))::text as tag_value
from ways
;

create index idx_way_tags_name on way_tags(tag_name)
;

delete from way_tags
where tag_value is null
;




drop table if exists way_nodes
;

create table way_nodes
as

select way_id, unnest(nd_ref)::text::bigint as node_id,  generate_subscripts(nd_ref,1) as node_order
from 
(
select way_id,  xpath('//way/nd/@ref', way_xml) as nd_ref
from ways
) as a
;  

create index idx_way_nodes on way_nodes(way_id)
;
