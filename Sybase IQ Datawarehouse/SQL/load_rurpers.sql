truncate table rurpers;
LOAD into table rurpers
(
sales_terr      '|:|',
sales_terr_name '|:|',
address1        '|:|',
address2        '|:|',
city            '|:|',
Prov            '|:|',
postal_code     '|:|',
terminal        '|:|',
title           '|:|',
sales_only      '|:|',
phone           '|:|',
fax             '|:|',
mobile_phone    '|:|',
region          '|:|',
language        '|:|',
email1          '|:|',
email2          '|:|',
email3          '|:|',
email4          '|:|',
email5          '|:|',
extn            '|:|',
goldmine_id	'|:|',
rsm_num		'\n'
)

from '/opt/sybase/bcp_data/cmf_data/rurpers_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;

