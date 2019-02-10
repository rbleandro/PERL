truncate table cmfrev05;
LOAD into table cmfrev05 
(
    customer_num          '|:|',
    ground_revenue_1      '|:|',
    ground_revenue_2      '|:|',
    ground_revenue_3      '|:|',
    ground_revenue_4      '|:|',
    ground_revenue_5      '|:|',
    ground_revenue_6      '|:|',
    ground_revenue_7      '|:|',
    ground_revenue_8      '|:|',
    ground_revenue_9      '|:|',
    ground_revenue_10     '|:|',
    ground_revenue_11     '|:|',
    ground_revenue_12     '|:|',
    ground_revenue_13     '|:|',
    select_revenue_1      '|:|',
    select_revenue_2      '|:|',
    select_revenue_3      '|:|',
    select_revenue_4      '|:|',
    select_revenue_5      '|:|',
    select_revenue_6      '|:|',
    select_revenue_7      '|:|',
    select_revenue_8      '|:|',
    select_revenue_9      '|:|',
    select_revenue_10     '|:|',
    select_revenue_11     '|:|',
    select_revenue_12     '|:|',
    select_revenue_13     '|:|',
    usa_revenue_1         '|:|',
    usa_revenue_2         '|:|',
    usa_revenue_3         '|:|',
    usa_revenue_4         '|:|',
    usa_revenue_5         '|:|',
    usa_revenue_6         '|:|',
    usa_revenue_7         '|:|',
    usa_revenue_8         '|:|',
    usa_revenue_9         '|:|',
    usa_revenue_10        '|:|',
    usa_revenue_11        '|:|',
    usa_revenue_12        '|:|',
    usa_revenue_13        '|:|',
    ground_cod_charges_1  '|:|',
    ground_cod_charges_2  '|:|',
    ground_cod_charges_3  '|:|',
    ground_cod_charges_4  '|:|',
    ground_cod_charges_5  '|:|',
    ground_cod_charges_6  '|:|',
    ground_cod_charges_7  '|:|',
    ground_cod_charges_8  '|:|',
    ground_cod_charges_9  '|:|',
    ground_cod_charges_10 '|:|',
    ground_cod_charges_11 '|:|',
    ground_cod_charges_12 '|:|',
    ground_cod_charges_13 '|:|',
    sel_cod_charges_1     '|:|',
    sel_cod_charges_2     '|:|',
    sel_cod_charges_3     '|:|',
    sel_cod_charges_4     '|:|',
    sel_cod_charges_5     '|:|',
    sel_cod_charges_6     '|:|',
    sel_cod_charges_7     '|:|',
    sel_cod_charges_8     '|:|',
    sel_cod_charges_9     '|:|',
    sel_cod_charges_10    '|:|',
    sel_cod_charges_11    '|:|',
    sel_cod_charges_12    '|:|',
    sel_cod_charges_13    '|:|',
    usa_cod_charges_1     '|:|',
    usa_cod_charges_2     '|:|',
    usa_cod_charges_3     '|:|',
    usa_cod_charges_4     '|:|',
    usa_cod_charges_5     '|:|',
    usa_cod_charges_6     '|:|',
    usa_cod_charges_7     '|:|',
    usa_cod_charges_8     '|:|',
    usa_cod_charges_9     '|:|',
    usa_cod_charges_10    '|:|',
    usa_cod_charges_11    '|:|',
    usa_cod_charges_12    '|:|',
    usa_cod_charges_13    '|:|',
    ground_dv_charges_1   '|:|',
    ground_dv_charges_2   '|:|',
    ground_dv_charges_3   '|:|',
    ground_dv_charges_4   '|:|',
    ground_dv_charges_5   '|:|',
    ground_dv_charges_6   '|:|',
    ground_dv_charges_7   '|:|',
    ground_dv_charges_8   '|:|',
    ground_dv_charges_9   '|:|',
    ground_dv_charges_10  '|:|',
    ground_dv_charges_11  '|:|',
    ground_dv_charges_12  '|:|',
    ground_dv_charges_13  '|:|',
    sel_dv_charges_1      '|:|',
    sel_dv_charges_2      '|:|',
    sel_dv_charges_3      '|:|',
    sel_dv_charges_4      '|:|',
    sel_dv_charges_5      '|:|',
    sel_dv_charges_6      '|:|',
    sel_dv_charges_7      '|:|',
    sel_dv_charges_8      '|:|',
    sel_dv_charges_9      '|:|',
    sel_dv_charges_10     '|:|',
    sel_dv_charges_11     '|:|',
    sel_dv_charges_12     '|:|',
    sel_dv_charges_13     '|:|',
    usa_dv_charges_1      '|:|',
    usa_dv_charges_2      '|:|',
    usa_dv_charges_3      '|:|',
    usa_dv_charges_4      '|:|',
    usa_dv_charges_5      '|:|',
    usa_dv_charges_6      '|:|',
    usa_dv_charges_7      '|:|',
    usa_dv_charges_8      '|:|',
    usa_dv_charges_9      '|:|',
    usa_dv_charges_10     '|:|',
    usa_dv_charges_11     '|:|',
    usa_dv_charges_12     '|:|',
    usa_dv_charges_13     '|:|',
    service_charges_1     '|:|',
    service_charges_2     '|:|',
    service_charges_3     '|:|',
    service_charges_4     '|:|',
    service_charges_5     '|:|',
    service_charges_6     '|:|',
    service_charges_7     '|:|',
    service_charges_8     '|:|',
    service_charges_9     '|:|',
    service_charges_10    '|:|',
    service_charges_11    '|:|',
    service_charges_12    '|:|',
    service_charges_13    '|:|',
    put_charges_1         '|:|',
    put_charges_2         '|:|',
    put_charges_3         '|:|',
    put_charges_4         '|:|',
    put_charges_5         '|:|',
    put_charges_6         '|:|',
    put_charges_7         '|:|',
    put_charges_8         '|:|',
    put_charges_9         '|:|',
    put_charges_10        '|:|',
    put_charges_11        '|:|',
    put_charges_12        '|:|',
    put_charges_13        '|:|',
    other_charges_1       '|:|',
    other_charges_2       '|:|',
    other_charges_3       '|:|',
    other_charges_4       '|:|',
    other_charges_5       '|:|',
    other_charges_6       '|:|',
    other_charges_7       '|:|',
    other_charges_8       '|:|',
    other_charges_9       '|:|',
    other_charges_10      '|:|',
    other_charges_11      '|:|',
    other_charges_12      '|:|',
    other_charges_13      '|:|',
    tot_revenue_1         '|:|',
    tot_revenue_2         '|:|',
    tot_revenue_3         '|:|',
    tot_revenue_4         '|:|',
    tot_revenue_5         '|:|',
    tot_revenue_6         '|:|',
    tot_revenue_7         '|:|',
    tot_revenue_8         '|:|',
    tot_revenue_9         '|:|',
    tot_revenue_10        '|:|',
    tot_revenue_11        '|:|',
    tot_revenue_12        '|:|',
    tot_revenue_13        '|:|',
    ara_amount_1          '|:|',
    ara_amount_2          '|:|',
    ara_amount_3          '|:|',
    ara_amount_4          '|:|',
    ara_amount_5          '|:|',
    ara_amount_6          '|:|',
    ara_amount_7          '|:|',
    ara_amount_8          '|:|',
    ara_amount_9          '|:|',
    ara_amount_10         '|:|',
    ara_amount_11         '|:|',
    ara_amount_12         '|:|',
    ara_amount_13         '|:|',
    total_revenue         '|:|',
    total_ara_amount      '\n'
)

from '/opt/sybase/bcp_data/cmf_data/cmfrev05_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;
