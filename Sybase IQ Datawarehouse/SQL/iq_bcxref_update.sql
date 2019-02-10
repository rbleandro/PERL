select * into #bcxref_upd from bcxref where 1=2;

LOAD into table #bcxref_upd
(   reference_num '|:|',
    service_type  '|:|',
    shipper_num   '|:|',
    linkage       '|:|',
    shipment_id   '|:|',
    record_id     '\n'
)
from '/opt/sybase/bcp_data/rev_hist/bcxref_upd.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;

update bcxref
set iqa.reference_num      = upd.reference_num,
    iqa.service_type     = upd.service_type,
    iqa.shipper_num      = upd.shipper_num,
    iqa.linkage           = upd.linkage,
    iqa.shipment_id      = upd.shipment_id
    
from bcxref iqa, #bcxref_upd upd    
where   iqa.reference_num      = upd.reference_num and
    	iqa.service_type     = upd.service_type and
    	iqa.shipper_num      = upd.shipper_num and
    	iqa.linkage           = upd.linkage and
    	iqa.shipment_id      = upd.shipment_id;
