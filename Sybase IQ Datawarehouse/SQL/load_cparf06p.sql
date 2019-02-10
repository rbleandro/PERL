truncate table cparf06p;
LOAD into table cparf06p
(
customer     '|:|',
invoice_date '|:|',
sequence     '|:|',
type         '|:|',
pay_amount   '|:|',
pay_date     '|:|',
batch        '|:|',
reason       '\n'
)

from '/opt/sybase/bcp_data/cmf_data/cparf06p_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;

