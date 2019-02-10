truncate table tmtrace;
LOAD into table tmtrace 
(
    trace_number            '|:|',
    priority                '|:|',
    trace_type              '|:|',
    open_date               '|:|',
    customer_num            '|:|',
    billto_account          '|:|',
    contact_name            '|:|',
    contact_phone_1         '|:|',
    contact_phone_2         '|:|',
    contact_phone_3         '|:|',
    contact_extention       '|:|',
    ship_date               '|:|',
    total_packages          '|:|',
    total_packages_missing  '|:|',
    inspector_id            '|:|',
    consignee_name          '|:|',
    consignee_address_1     '|:|',
    consignee_city          '|:|',
    consignee_province      '|:|',
    consignee_postal_code_1 '|:|',
    consignee_postal_code_2 '|:|',
    consignee_phone_1       '|:|',
    consignee_phone_2       '|:|',
    consignee_phone_3       '|:|',
    consignee_phone_4       '|:|',
    consignee_contact       '|:|',
    consignee_terminal      '|:|',
    days_late               '|:|',
    type_of_request         '|:|',
    form_sent_type          '|:|',
    form_sent_date          '|:|',
    inspector_type          '|:|',
    merchandise_at          '|:|',
    trace_charge_amount     '|:|',
    "status"                '|:|',
    call_back_operator      '|:|',
    cod_number              '|:|',
    cod_amount              '|:|',
    claimant                '|:|',
    fax_number_1            '|:|',
    fax_number_2            '|:|',
    fax_number_3            '|:|',
    consignee_agent         '|:|',
    shipment_value          '\n'
)
from '/opt/sybase/bcp_data/cmf_data/tmtrace_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;
