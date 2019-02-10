truncate table disp_msg;
LOAD into table disp_msg
(
region             '|:|',
msg_type           '|:|',
display_date       '|:|',
created_by         '|:|',
create_date        '|:|',
resolved_by        '|:|',
resolved_date      '|:|',
resolved           '|:|',
customer           '|:|',
name               '|:|',
addr1              '|:|',
addr2              '|:|',
city               '|:|',
post_cd            '|:|',
phone_a            '|:|',
phone_num          '|:|',
phone_ext          '|:|',
route              '|:|',
notified_by        '|:|',
email_notification '|:|',
requested_by       '|:|',
conv_time_date     '|:|',
employee_num       '|:|',
msgSync            '|:|',
comments           '|:|',
inserted_on_cons   '|:|',
updated_on_cons    '\n'
)

from '/opt/sybase/bcp_data/cmf_data/disp_msg_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;

