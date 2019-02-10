select * into #tttl_cp_upd from tttl_cp_cod_package where 1=2;

LOAD into table #tttl_cp_upd
(   reference_num             '|:|',
    service_type              '|:|',
    shipper_num               '|:|',
    scan_time_date            '|:|',
    employee_num              '|:|',
    cod_label_amount          '|:|',
    status                    '|:|',
    cod_audit_label_chng_flag '|:|',
    cod_comments              '|:|',
    inserted_on_cons          '|:|',
    updated_on_cons           '\n'
)
from '/opt/sybase/bcp_data/cpscan/tttl_cp_upd.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;


update tttl_cp_cod_package
set     	
	t.cod_label_amount          = upd.cod_label_amount,
	t.status                    = upd.status,
	t.cod_audit_label_chng_flag = upd.cod_audit_label_chng_flag,
	t.cod_comments              = upd.cod_comments,
    	t.updated_on_cons           = upd.updated_on_cons

from tttl_cp_cod_package t, #tttl_cp_upd upd
where   t.reference_num             = upd.reference_num and
	t.service_type              = upd.service_type and
	t.shipper_num               = upd.shipper_num and
	t.scan_time_date            = upd.scan_time_date and
	t.employee_num              = upd.employee_num;
