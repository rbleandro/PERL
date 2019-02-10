LOAD into table cmfservc 
(
    customer_num                  '|:|',
    cod_debit_status              '|:|',
    cod_debit_financial_inst      '|:|',
    cod_debit_transit             '|:|',
    cod_debit_account             '|:|',
    cod_debit_start_datetime      '|:|',
    put_active                    '|:|',
    put_type                      '|:|',
    put_return_auth_reqd          '|:|',
    put_print_fax                 '|:|',
    put_contact                   '|:|',
    put_phone                     '|:|',
    put_phone_ext                 '|:|',
    put_fax                       '|:|',
    put_email_address             '|:|',
    return_flow_active            '|:|',
    return_flow_directory         '|:|',
    return_flow_scans             '|:|',
    return_flow_exception         '|:|',
    return_flow_send_type         '|:|',
    return_flow_edi_account       '|:|',
    return_flow_contact           '|:|',
    return_flow_phone             '|:|',
    return_flow_phone_ext         '|:|',
    return_flow_fax               '|:|',
    return_flow_email             '|:|',
    manifest_downloads            '|:|',
    manifest_download_type        '|:|',
    special_program               '|:|',
    canship_status                '|:|',
    canship_success_datetime      '|:|',
    canship_last_attempt_datetime '|:|',
    papp_status                   '|:|',
    papp_financial_inst           '|:|',
    papp_transit_number           '|:|',
    papp_account_number           '|:|',
    papp_start_datetime           '|:|',
    papp_last_payment_datetime    '|:|',
    papp_day_preference           '|:|',
    papp_payment_terms            '|:|',
    nsr_account                   '\n'
)

from '/opt/sybase/bcp_data/cmf_data/cmfservc_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;
