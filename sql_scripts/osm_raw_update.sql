alter table osm_raw add column geometry_type int
;

create index idx_osm_raw_num on osm_raw(file_line_num)
;

update osm_raw
set geometry_type = 0 
where file_line_num >= (select min(file_line_num) from osm_raw where xml_str like '%<node%')
and file_line_num <= (select max(file_line_num) from osm_raw where xml_str like '%</node>%' or xml_str like '%<node%')
;


create index idx_osm_raw_type on osm_raw(geometry_type)
;

update osm_raw
set geometry_type = 1 
where geometry_type is NULL 
and file_line_num >= (select min(file_line_num) from osm_raw where xml_str like '%<way%')
and file_line_num <= (select max(file_line_num) from osm_raw where xml_str like '%</way>%' or xml_str like '%<way')
;