select * into #revhstd_upd from revhstd where 1=2;

LOAD into table #revhstd_upd
(   shipper_num  '|:|',
    discount_amt '|:|',
    invoice_date '|:|',
    invoice_num  '\n'
)
from '/opt/sybase/bcp_data/rev_hist/revhstd_upd.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;

update revhstd
set iqa.discount_amt     = upd.discount_amt,
    iqa.invoice_date   = upd.invoice_date
from revhstd iqa, #revhstd_upd upd    
where   iqa.shipper_num = upd.shipper_num
and     iqa.invoice_num = upd.invoice_num;