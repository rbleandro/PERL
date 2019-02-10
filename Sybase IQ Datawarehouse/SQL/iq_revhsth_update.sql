select * into #revhsth_upd from revhsth where 1=2;

LOAD into table #revhsth_upd
(   shipper_num     '|:|',
    pickup_rec_num  '|:|',
    pickup_rec_date '|:|',
    data_entry_date '|:|',
    billto_type     '|:|',
    bt422           '|:|',
    units           '|:|',
    assoc_code      '|:|',
    origin_pc       '|:|',
    ZW_discount     '|:|',
    ZW_alpha        '|:|',
    RBF_paper       '|:|',
    RBF_file        '|:|',
    filenum         '|:|',
    release_as      '|:|',
    invoice         '|:|',
    invoice_date    '|:|',
    linkage         '\n'
)
from '/opt/sybase/bcp_data/rev_hist/revhsth_upd.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;


update revhsth
set iqa.shipper_num     = upd.shipper_num,
    iqa.pickup_rec_num  = upd.pickup_rec_num,
    iqa.pickup_rec_date = upd.pickup_rec_date,
    iqa.data_entry_date = upd.data_entry_date,
    iqa.billto_type     = upd.billto_type,
    iqa.bt422           = upd.bt422,
    iqa.units           = upd.units,
    iqa.assoc_code      = upd.assoc_code,
    iqa.origin_pc       = upd.origin_pc,
    iqa.ZW_discount     = upd.ZW_discount,
    iqa.ZW_alpha        = upd.ZW_alpha,
    iqa.RBF_paper       = upd.RBF_paper,
    iqa.RBF_file        = upd.RBF_file,
    iqa.filenum         = upd.filenum,
    iqa.release_as      = upd.release_as,
    iqa.invoice         = upd.invoice,
    iqa.invoice_date    = upd.invoice_date

from revhsth iqa, #revhsth_upd upd
where iqa.linkage = upd.linkage;
