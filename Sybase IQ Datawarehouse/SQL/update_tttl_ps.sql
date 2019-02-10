select * into #tttl_ps_upd from tttl_ps_pickup_shipper where 1=2;

LOAD into table #tttl_ps_upd
(   shipper_num           '|:|',
    conv_time_date        '|:|',
    employee_num          '|:|',
    multiple_shipper_flag '|:|',
    no_package_flag       '|:|',
    missed_pickup_flag    '|:|',
    manual_entry_flag     '|:|',
    terminal_num          '|:|',
    inserted_on_cons      '|:|',
    updated_on_cons       '\n'
)
from '/opt/sybase/bcp_data/cpscan/tttl_ps_upd.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;


update tttl_ps_pickup_shipper
set                
    t.multiple_shipper_flag = upd.multiple_shipper_flag,
    t.no_package_flag       = upd.no_package_flag,
    t.missed_pickup_flag    = upd.missed_pickup_flag,
    t.manual_entry_flag     = upd.manual_entry_flag,
    t.terminal_num          = upd.terminal_num,
    t.updated_on_cons       = upd.updated_on_cons
    
from tttl_ps_pickup_shipper t, #tttl_ps_upd upd
where   t.shipper_num           = upd.shipper_num and
    	t.conv_time_date        = upd.conv_time_date and
    	t.employee_num          = upd.employee_num;
