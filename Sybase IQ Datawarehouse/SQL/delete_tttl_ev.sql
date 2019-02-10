select reference_num,service_type,shipper_num,conv_time_date,employee_num into #tttl_ev_del from tttl_ev_event where 1=2;

LOAD into table #tttl_ev_del
(   reference_num          '|:|',
    service_type           '|:|',
    shipper_num            '|:|',
    conv_time_date         '|:|',
    employee_num           '\n'
)
from '/opt/sybase/bcp_data/cpscan/tttl_ev_del.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;

set option query_temp_space_limit=0;
delete tttl_ev_event
from tttl_ev_event t, #tttl_ev_del del
where 	t.reference_num          = del.reference_num and
    	t.service_type           = del.service_type and
    	t.shipper_num            = del.shipper_num and
        t.conv_time_date         = del.conv_time_date and
        t.employee_num           = del.employee_num;
