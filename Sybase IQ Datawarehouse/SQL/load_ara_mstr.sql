truncate table ara_mstr;
LOAD into table ara_mstr
(
customer_num       '|:|',
ara_number         '|:|',
ara_clerk          '|:|',
ara_datetime       '|:|',
source             '|:|',
statement_datetime '|:|',
many_statements    '|:|',
close_datetime     '|:|',
exit_datetime      '|:|',
exit_department    '|:|',
ara_amount         '|:|',
adjusted_amount    '|:|',
adjusted_GST       '|:|',
adjusted_HST       '|:|',
adjusted_QST       '|:|',
collect_amount     '|:|',
not_outstanding    '|:|',
pur_nos            '|:|',
follow_up_dept     '|:|',
ara_cause          '|:|',
collect_cause      '|:|',
collector          '|:|',
action	     	   '\n'
)

from '/opt/sybase/bcp_data/cmf_data/ara_mstr_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;

