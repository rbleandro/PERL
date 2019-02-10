select reference_num,service_type,shipper_num into #tttl_pa_del from tttl_pa_parcel where 1=2;

LOAD into table #tttl_pa_del
(   reference_num          '|:|',
    service_type           '|:|',
    shipper_num            '\n'
)
from '/opt/sybase/bcp_data/cpscan/tttl_pa_del.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;

set option query_temp_space_limit=0;
delete tttl_pa_parcel
from tttl_pa_parcel t, #tttl_pa_del del
where 	t.reference_num          = del.reference_num and
    	t.service_type           = del.service_type and
    	t.shipper_num            = del.shipper_num;
