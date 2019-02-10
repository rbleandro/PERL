truncate table tttl_incompat;
LOAD into table tttl_incompat
(   
reference_num		'|:|',
shipper_num		'|:|',
service_type		'|:|',
scan_time_date		'|:|',
employee_num		'|:|',
processed_time_date	'|:|',
status			'|:|',
inserted_on_cons	'|:|',
updated_on_cons         '|:|',
MiscChgID		'|:|',
BilledDate		'\n'
)
from '/opt/sybase/bcp_data/cpscan/tttl_incompat_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0
