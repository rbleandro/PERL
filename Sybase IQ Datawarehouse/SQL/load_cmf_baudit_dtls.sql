truncate table cmf_baudit_dtls;
LOAD into table cmf_baudit_dtls
(
customer        '|:|',
audit_date      '|:|',
pickup_number   '|:|',
shipping_date   '|:|',
packages        '|:|',
orig_amount     '|:|',
audited_amount  '|:|',
reason          '|:|',
auditor		'\n'
)

from '/opt/sybase/bcp_data/cmf_data/cmf_baudit_dtls_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;

