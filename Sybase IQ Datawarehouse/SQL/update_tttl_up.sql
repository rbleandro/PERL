select * into #tttl_up_upd from tttl_up_US_parcels where 1=2;

LOAD into table #tttl_up_upd
(   reference_num       '|:|',
    service_type        '|:|',
    shipper_num         '|:|',
    u_reference_num     '|:|',
    forwarded_time_date '|:|',
    checked_ind         '|:|',
    inserted_on_cons    '|:|',
    updated_on_cons     '\n'
)
from '/opt/sybase/bcp_data/cpscan/tttl_up_upd.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;


update tttl_up_US_parcels
set                
    t.u_reference_num     = upd.u_reference_num,
    t.forwarded_time_date = upd.forwarded_time_date,
    t.checked_ind         = upd.checked_ind,
    t.updated_on_cons     = upd.updated_on_cons
    
from tttl_up_US_parcels t, #tttl_up_upd upd
where   t.reference_num       = upd.reference_num and
    	t.service_type        = upd.service_type and
    	t.shipper_num         = upd.shipper_num;
