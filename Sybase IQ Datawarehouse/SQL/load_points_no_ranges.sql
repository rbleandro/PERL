truncate table points_no_ranges;
load into table points_no_ranges
(
Terminal	'|:|',
Interline	'|:|',
City	'|:|',
Delay	'|:|',
Service	'|:|',
Week1	'|:|',
Week2	'|:|',
PCode_From	'|:|',
PCode_To	'|:|',
Additional_Days	'|:|',
Sort_Terminal	'|:|',
Point_Served	'|:|',
postal_code	'|:|',
province_code	'|:|',
minor_city	'\n'
)
from '/opt/sybase/bcp_data/cmf_data/points_no_ranges_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0
