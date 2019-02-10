select * into #tttl_rt_upd from tttl_rt_return_to_shipper where 1=2;

LOAD into table #tttl_rt_upd
(   rts_reference_num '|:|',
    rts_service_type  '|:|',
    FSA               '|:|',
    reference_num     '|:|',
    service_type      '|:|',
    shipper_num       '|:|',
    inserted_on_cons  '|:|',
    updated_on_cons   '\n'
)
from '/opt/sybase/bcp_data/cpscan/tttl_rt_upd.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;


update tttl_rt_return_to_shipper
set                
    t.FSA               = upd.FSA,
    t.reference_num     = upd.reference_num,
    t.service_type      = upd.service_type,
    t.shipper_num       = upd.shipper_num,
    t.updated_on_cons   = upd.updated_on_cons
    
from tttl_rt_return_to_shipper t, #tttl_rt_upd upd
where   t.rts_reference_num = upd.rts_reference_num and
    	t.rts_service_type  = upd.rts_service_type;
