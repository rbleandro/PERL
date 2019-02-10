truncate table cost_service_type;
LOAD into table cost_service_type
(
    postal_code  '|:|',
    service_type '\n'
)

from '/opt/sybase/bcp_data/cmf_data/cost_service_type_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;

