select * into #tttl_pr_upd from tttl_pr_pickup_record where 1=2;

LOAD into table #tttl_pr_upd
(   pickup_rec_num           '|:|',
    conv_time_date           '|:|',
    employee_num             '|:|',
    num_pickup_packages      '|:|',
    num_pickup_cod           '|:|',
    num_pickup_select        '|:|',
    multiple_pickup_rec_flag '|:|',
    manifest_flag            '|:|',
    not_scanned_flag         '|:|',
    manual_entry_flag        '|:|',
    inserted_on_cons         '|:|',
    updated_on_cons          '\n'
)
from '/opt/sybase/bcp_data/cpscan/tttl_pr_upd.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;


update tttl_pr_pickup_record
set             
    t.num_pickup_packages      = upd.num_pickup_packages,
    t.num_pickup_cod           = upd.num_pickup_cod,
    t.num_pickup_select        = upd.num_pickup_select,
    t.multiple_pickup_rec_flag = upd.multiple_pickup_rec_flag,
    t.manifest_flag            = upd.manifest_flag,
    t.not_scanned_flag         = upd.not_scanned_flag,
    t.manual_entry_flag        = upd.manual_entry_flag,
    t.updated_on_cons          = upd.updated_on_cons
    
from tttl_pr_pickup_record t, #tttl_pr_upd upd
where   t.pickup_rec_num           = upd.pickup_rec_num and
    	t.conv_time_date           = upd.conv_time_date and
    	t.employee_num             = upd.employee_num;
