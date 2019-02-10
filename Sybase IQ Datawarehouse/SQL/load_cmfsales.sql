LOAD into table cmfsales 
(
    customer_num          '|:|',
    sales_contact         '|:|',
    sales_contact_title   '|:|',
    sales_phone           '|:|',
    sales_phone_ext       '|:|',
    sales_fax             '|:|',
    sales_email_address   '|:|',
    expected_volume       '|:|',
    other_carrier_A       '|:|',
    other_carrier_B       '|:|',
    other_carrier_C       '|:|',
    commodity_code        '|:|',
    other_canpar_account  '|:|',
    former_canpar_account '|:|',
    former_account_when   '|:|',
    owner_of_business     '|:|',
    years_in_business     '|:|',
    major_creditor        '|:|',
    creditor_phone        '|:|',
    creditor_phone_ext    '|:|',
    creditor_fax          '|:|',
    creditor_email        '\n'
)

from '/opt/sybase/bcp_data/cmf_data/cmfsales_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;
