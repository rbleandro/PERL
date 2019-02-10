truncate table tttl_ct_cod_totals;
LOAD into table tttl_ct_cod_totals 
(
    scan_time_date            '|:|',
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
from '/opt/sybase/bcp_data/cpscan/tttl_ct_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;
