LOAD into table svp_missed_pu
(
    pickup_date		'|:|',
    shipper_num		'|:|',
    missed_pickup_flag	'|:|',
    employee_num	'|:|',
    conv_time_date	'\n'   
)
from '/opt/sybase/bcp_data/cmf_data/svp_missed_pu_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;
