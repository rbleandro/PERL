--truncate table web_putagdetail;
LOAD into table web_putagdetail 
(
    pickup_detail_id      '|:|',
    customer_num          '|:|',
    pickup_name           '|:|',
    pickup_address_line_1 '|:|',
    pickup_address_line_2 '|:|',
    pickup_city           '|:|',
    pickup_province       '|:|',
    pickup_postal_code    '|:|',
    pickup_contact        '|:|',
    pickup_phone          '|:|',
    return_auth_ref       '|:|',
    start_barcode         '|:|',
    start_check_digit     '|:|',
    end_barcode           '|:|',
    end_check_digit       '|:|',
    weight_unit           '|:|',
    number_of_tags        '|:|',
    pickup_comments       '|:|',
    entry_date            '|:|',
    entered_by            '|:|',
    no_charge_flag        '|:|',
    replace_barcode       '|:|',
    pickup_fax            '|:|',
    pickup_email          '|:|',
    cs_entry              '|:|',
    processed             '|:|',
    reference1		  '\n'
)

from '/opt/sybase/bcp_data/eput_db/web_putagdetail.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;
