truncate table Graph_Stats_mtl;
LOAD into table Graph_Stats_mtl
(
	time_stamp '|:|',
	total_items '|:|',
	no_reads '|:|',
	sorted_items '|:|',
	chute_full '|:|',
	repl_id '\n'
)

from '/opt/sybase/bcp_data/mtldb/Graph_Stats.txt'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 1000000
IGNORE CONSTRAINT UNIQUE 0;

