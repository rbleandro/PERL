select * into #tttl_us_upd from tttl_us where 1=2;

LOAD into table #tttl_us_upd
(   shipper_num      '|:|',
    service_type     '|:|',
    reference_num    '|:|',
    bc_shipper_num   '|:|',
    conv_time_date   '|:|',
    inserted_on_cons '|:|',
    updated_on_cons  '\n'
)
from '/opt/sybase/bcp_data/cpscan/tttl_us_upd.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;


update tttl_us
set                    
    t.bc_shipper_num   = upd.bc_shipper_num,
    t.conv_time_date   = upd.conv_time_date,
    t.updated_on_cons  = upd.updated_on_cons
    
from tttl_us t, #tttl_us_upd upd
where   t.reference_num       = upd.reference_num and
    	t.service_type        = upd.service_type and
    	t.shipper_num         = upd.shipper_num;
