truncate table costing_tractor_cust;
LOAD into table costing_tractor_cust
(
    customer '\n'
)

from '/opt/sybase/bcp_data/cmf_data/costing_tractor_cust_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;

