truncate table bcxref_live;
LOAD into table bcxref_live
(   reference_num '|:|',
    service_type  '|:|',
    shipper_num   '|:|',
    linkage       '|:|',
    shipment_id   '\n'
)
from '/opt/sybase/bcp_data/rev_hist/bcxref_live_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0
