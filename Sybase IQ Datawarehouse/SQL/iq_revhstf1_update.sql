select * into #revhstf1_upd from revhstf1 where 1=2;

LOAD into table #revhstf1_upd
(   linkage        '|:|',
    shipment_id    '|:|',
    rate_code      '|:|',
    rate_alpha     '|:|',
    service_code   '|:|',
    destin_pc      '|:|',
    zone           '|:|',
    shipments      '|:|',
    weight         '|:|',
    pieces         '|:|',
    customer_ref1  '|:|',
    customer_ref2  '|:|',
    base_freight   '|:|',
    discount_flag1 '|:|',
    discount_pct1  '|:|',
    discount_amt1  '|:|',
    net1           '|:|',
    discount_flag2 '|:|',
    discount_pct2  '|:|',
    discount_amt2  '|:|',
    net2           '|:|',
    discount_flag3 '|:|',
    discount_pct3  '|:|',
    discount_amt3  '|:|',
    net_freight    '|:|',
    record_id      '|:|',
    cwflag         '\n'
)
from '/opt/sybase/bcp_data/rev_hist/revhstf1_upd.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;

update revhstf1
set iqa.rate_code      = upd.rate_code,
    iqa.rate_alpha     = upd.rate_alpha,
    iqa.service_code   = upd.service_code,
    iqa.destin_pc      = upd.destin_pc,
    iqa.zone           = upd.zone,
    iqa.shipments      = upd.shipments,
    iqa.weight         = upd.weight,
    iqa.pieces         = upd.pieces,
    iqa.customer_ref1  = upd.customer_ref1,
    iqa.customer_ref2  = upd.customer_ref2,
    iqa.base_freight   = upd.base_freight,
    iqa.discount_flag1 = upd.discount_flag1,
    iqa.discount_pct1  = upd.discount_pct1,
    iqa.discount_amt1  = upd.discount_amt1,
    iqa.net1           = upd.net1,
    iqa.discount_flag2 = upd.discount_flag2,
    iqa.discount_pct2  = upd.discount_pct2,
    iqa.discount_amt2  = upd.discount_amt2,
    iqa.net2           = upd.net2,
    iqa.discount_flag3 = upd.discount_flag3,
    iqa.discount_pct3  = upd.discount_pct3,
    iqa.discount_amt3  = upd.discount_amt3,
    iqa.net_freight    = upd.net_freight,
    iqa.cwflag         = upd.cwflag
from revhstf1 iqa, #revhstf1_upd upd    
where   iqa.linkage = upd.linkage
and     iqa.shipment_id = upd.shipment_id;
