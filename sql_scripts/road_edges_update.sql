
drop table if exists edge_commonness
;
create table edge_commonness
AS
select edge_id, count(*) as commonness 
from  sp_temp
group by 1
;
create index idx_edge_commonness on edge_commonness(edge_id)
;

update road_edges
set commonness = road_edges.commonness + coalesce(b.commonness ,0)
from edge_commonness as b 
where road_edges.edge_id = b.edge_id
;


drop table sp_temp
;

drop table edge_commonness
;
