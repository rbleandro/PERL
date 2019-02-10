truncate table street_search;
LOAD into table street_search
(
artificial_id		'|:|',
fast_search_key		'|:|',
terminal_num		'|:|',
street_name		'|:|',
address_range_part_1	'|:|',
address_range_part_2	'|:|',
postal_code		'|:|',
inserted_on_cons	'|:|',
updated_on_cons    	'\n'  
)
from '/opt/sybase/bcp_data/cpscan/street_search_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0
