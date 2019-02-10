truncate table costing_residential;
LOAD into table costing_residential
(
    customer '\n'
)

from '/opt/sybase/bcp_data/cmf_data/costing_residential_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;

