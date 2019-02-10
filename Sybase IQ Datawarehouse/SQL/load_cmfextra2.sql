truncate table cmfextra2;
LOAD into table cmfextra2
(
customer_num         '|:|',
elec_inv_email_flag  '|:|',
elec_inv_email_to    '|:|',
elec_inv_email_cc    '|:|',
elec_inv_format      '|:|',
elec_inv_misc_flag   '|:|',
elec_inv_cons_store  '|:|',
elec_inv_electronic  '|:|',
elec_inv_append_ref  '|:|',
elec_inv_EDI_trading '|:|',
elec_inv_FTP_flag    '|:|',
elec_inv_FTP_directo '|:|',
invoice_frequency    '|:|',
linehaul_flag        '|:|',
successful_2D        '|:|',
detailed_billing_flag_CW '|:|',
language	    '|:|',
inv_format_csv    '|:|',
inv_format_excel  '|:|',
inv_format_text   '|:|',
inv_format_pdf    '|:|',
inv_format_xml    '|:|',
print_barcode_detail '|:|',
elec_inv_more_email '|:|',
invoice_last_email_date '|:|',
elec_inv_last_email_date '\n'
)

from '/opt/sybase/bcp_data/cmf_data/cmfextra2_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;

