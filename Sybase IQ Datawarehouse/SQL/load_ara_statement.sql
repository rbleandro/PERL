truncate table ara_statement;
LOAD into table ara_statement
(
customer         '|:|',
ara_number       '|:|',
statement_date   '|:|',
statement_amount '|:|',
adjusted_amount  '|:|',
adjusted_GST     '|:|',
adjusted_HST     '|:|',
adjusted_QST     '|:|',
collect_amount   '|:|',
not_outstanding  '\n'
)

from '/opt/sybase/bcp_data/cmf_data/ara_statement_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;

