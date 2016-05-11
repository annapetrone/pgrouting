drop table if exists osm_raw
;


create table osm_raw(
file_line_num serial,
xml_str text

);