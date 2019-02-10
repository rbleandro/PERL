select * into #tttl_mb_upd from tttl_mb_multiple_barcodes where 1=2;

LOAD into table #tttl_mb_upd
(   secondary_reference_num '|:|',
    secondary_service_type  '|:|',
    secondary_shipper_num   '|:|',
    primary_reference_num   '|:|',
    primary_service_type    '|:|',
    primary_shipper_num     '|:|',
    manual_entry_flag       '|:|',
    inserted_on_cons        '|:|',
    updated_on_cons         '\n'
)
from '/opt/sybase/bcp_data/cpscan/tttl_mb_upd.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;


update tttl_mb_multiple_barcodes
set     
    t.primary_reference_num   = upd.primary_reference_num,
    t.primary_service_type    = upd.primary_service_type,
    t.primary_shipper_num     = upd.primary_shipper_num,
    t.manual_entry_flag       = upd.manual_entry_flag,
    t.updated_on_cons         = upd.updated_on_cons
    
from tttl_mb_multiple_barcodes t, #tttl_mb_upd upd
where   t.secondary_reference_num = upd.secondary_reference_num and
    	t.secondary_service_type  = upd.secondary_service_type and
    	t.secondary_shipper_num   = upd.secondary_shipper_num;
