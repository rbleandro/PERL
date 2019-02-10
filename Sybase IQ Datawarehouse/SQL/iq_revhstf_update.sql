select * into #revhstf_upd from revhstf where 1=2;

LOAD into table #revhstf_upd
(   linkage          '|:|',
    shipment_id      '|:|',
    rate_code        '|:|',
    service_code     '|:|',
    destin_pc        '|:|',
    zone             '|:|',
    shipments        '|:|',
    weight           '|:|',
    pieces           '|:|',
    customer_ref1    '|:|',
    customer_ref2    '|:|',
    discount_flag    '|:|',
    discount_percent '|:|',
    base_freight     '|:|',
    discount_amt     '|:|',
    net_freight      '\n'
)
from '/opt/sybase/bcp_data/rev_hist/revhstf_upd.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;

update revhstf
set iqa.rate_code   = upd.rate_code,
    iqa.service_code      = upd.service_code,
    iqa.destin_pc           = upd.destin_pc,
    iqa.zone      = upd.zone,
    iqa.shipments      = upd.shipments,
    iqa.weight         = upd.weight,
    iqa.pieces         = upd.pieces,
    iqa.customer_ref1  = upd.customer_ref1,
    iqa.customer_ref2  = upd.customer_ref2,    
    iqa.discount_flag = upd.discount_flag,
    iqa.discount_percent  = upd.discount_percent,
    iqa.base_freight  = upd.base_freight,
    iqa.discount_amt           = upd.discount_amt,
    iqa.net_freight    = upd.net_freight
from revhstf iqa, #revhstf_upd upd    
where   iqa.linkage = upd.linkage
and     iqa.shipment_id = upd.shipment_id;