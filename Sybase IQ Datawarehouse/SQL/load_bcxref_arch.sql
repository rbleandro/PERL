truncate table bcxref_arch;
LOAD into table bcxref_arch
(   reference_num '|:|',
    service_type  '|:|',
    shipper_num   '|:|',
    linkage       '|:|',
    shipment_id   '\n'
)
from '/opt/sybase/bcp_data/rev_hist/bcxref_arch_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 1000000
IGNORE CONSTRAINT UNIQUE 0

