truncate table cparf06i;
LOAD into table cparf06i
(
customer          '|:|',
invoice_date      '|:|',
original_amt      '|:|',
outstanding_amt   '|:|',
highseq           '|:|',
full_payment_date '|:|',
POA_batch         '|:|',
invoice_number    '\n'
)

from '/opt/sybase/bcp_data/cmf_data/cparf06i_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;

