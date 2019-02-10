truncate table tttl_up_US_parcels;
LOAD into table tttl_up_US_parcels 
(
    reference_num       '|:|',
    service_type        '|:|',
    shipper_num         '|:|',
    u_reference_num     '|:|',
    forwarded_time_date '|:|',
    checked_ind         '|:|',
    inserted_on_cons    '|:|',
    updated_on_cons     '\n'
)
from '/opt/sybase/bcp_data/cpscan/tttl_up_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;
