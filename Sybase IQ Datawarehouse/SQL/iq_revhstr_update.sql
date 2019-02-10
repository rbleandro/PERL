select * into #revhstr_upd from revhstr where 1=2;

LOAD into table #revhstr_upd
(   linkage     '|:|',
    shipment_id '|:|',
    DV_charges  '|:|',
    DV_amt      '|:|',
    COD_charges '|:|',
    COD_amt     '|:|',
    PUT_charges '|:|',
    XC_charges  '\n'
)
from '/opt/sybase/bcp_data/rev_hist/revhstr_upd.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;

update revhstr
set iqa.linkage      = upd.linkage,
    iqa.shipment_id     = upd.shipment_id,
    iqa.DV_charges   = upd.DV_charges,
    iqa.DV_amt      = upd.DV_amt,
    iqa.COD_charges           = upd.COD_charges,
    iqa.COD_amt      = upd.COD_amt,
    iqa.PUT_charges         = upd.PUT_charges,
    iqa.XC_charges         = upd.XC_charges    
from revhstr iqa, #revhstr_upd upd    
where   iqa.linkage = upd.linkage
and     iqa.shipment_id = upd.shipment_id;