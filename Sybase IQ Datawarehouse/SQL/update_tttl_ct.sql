select * into #tttl_ct_upd from tttl_ct_cod_totals where 1=2;

LOAD into table #tttl_ct_upd
(   scan_time_date            '|:|',
    employee_num              '|:|',
    cod_total_cash            '|:|',
    cod_total_cheque          '|:|',
    cod_total_dts1            '|:|',
    cod_total_dts2            '|:|',
    cod_total_dts3            '|:|',
    cod_audit_total_chng_flag '|:|',
    cod_comments              '|:|',
    terminal_num              '|:|',
    interline_id              '|:|',
    inserted_on_cons          '|:|',
    updated_on_cons           '\n'
)
from '/opt/sybase/bcp_data/cpscan/tttl_ct_upd.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;


update tttl_ct_cod_totals
set     	
    t.scan_time_date            = upd.scan_time_date,
    t.employee_num              = upd.employee_num,
    t.cod_total_cash            = upd.cod_total_cash,
    t.cod_total_cheque          = upd.cod_total_cheque,
    t.cod_total_dts1            = upd.cod_total_dts1,
    t.cod_total_dts2            = upd.cod_total_dts2,
    t.cod_total_dts3            = upd.cod_total_dts3,
    t.cod_audit_total_chng_flag = upd.cod_audit_total_chng_flag,
    t.cod_comments              = upd.cod_comments,
    t.terminal_num              = upd.terminal_num,
    t.interline_id              = upd.interline_id,
    t.updated_on_cons           = upd.updated_on_cons

from tttl_ct_cod_totals t, #tttl_ct_upd upd
where   t.scan_time_date            = upd.scan_time_date and
    	t.employee_num              = upd.employee_num;
