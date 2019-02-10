select * into #revhstm_upd from revhstm where 1=2;

LOAD into table #revhstm_upd
(
    shipper_num   '|:|',
    rev_reference '|:|',
    type          '|:|',
    entry_date    '|:|',
    amount        '|:|',
    invoice_date  '|:|',
    invoice       '\n'
)
from '/opt/sybase/bcp_data/rev_hist/revhstm_upd.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;

update revhstm
set iqa.shipper_num      = upd.shipper_num,
    iqa.rev_reference     = upd.rev_reference,
    iqa.type   = upd.type,
    iqa.entry_date      = upd.entry_date,
    iqa.amount           = upd.amount,
    iqa.invoice_date      = upd.invoice_date,
    iqa.invoice         = upd.invoice
from revhstm iqa, #revhstm_upd upd    
where   iqa.invoice = upd.invoice
and     iqa.invoice_date = upd.invoice_date;
