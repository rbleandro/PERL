LOAD into table tttl_pd 
(
    pod_request_num       '|:|',
    pod_request_time_date '|:|',
    trace_agent_num       '|:|',
    pod_mail_flag         '|:|',
    pod_delrec_require    '|:|',
    pod_customer_prov     '|:|',
    pod_postal_code1      '|:|',
    pod_postal_code2      '|:|',
    pod_contact_name      '|:|',
    pod_customer_name     '|:|',
    pod_customer_address1 '|:|',
    pod_customer_address2 '|:|',
    pod_comments          '|:|',
    pod_phone_num         '|:|',
    pod_fax_num           '|:|',
    pod_french            '|:|',
    pod_print_queue       '\n'
)
from '/opt/sybase/bcp_data/cpscan/tttl_pd_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;
