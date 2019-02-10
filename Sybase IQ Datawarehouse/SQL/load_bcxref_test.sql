--truncate table bcxref_test;
LOAD into table bcxref_test
(   reference_num '|:|',
    service_type  '|:|',
    shipper_num   '|:|',
    linkage       '|:|',
    shipment_id   '\n'
)
from '/opt/sybase/bcp_data/rev_hist/bcxref_test.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0
