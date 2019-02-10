truncate table driver_stats;
LOAD into table driver_stats 
(
    employee_num             '|:|',
    terminal_num             '|:|',
    conv_time_date           '|:|',
    route_num                '|:|',
    emp_start_shift_time     '|:|',
    emp_left_terminal_time   '|:|',
    emp_start_del_time       '|:|',
    emp_end_del_time         '|:|',
    emp_start_lunch_time     '|:|',
    emp_end_lunch_time       '|:|',
    emp_start_pickup_time    '|:|',
    emp_end_pickup_time      '|:|',
    emp_start_break1_time    '|:|',
    emp_end_break1_time      '|:|',
    emp_start_break2_time    '|:|',
    emp_end_break2_time      '|:|',
    emp_return_terminal_time '|:|',
    emp_end_shift_time       '|:|',
    emp_regular_hours        '|:|',
    emp_overtime_hours       '|:|',
    eod_cod_cash             '|:|',
    eod_cod_cheque           '|:|',
    eod_cod_dts              '|:|',
    eod_cod_total_labels     '|:|',
    num_delivery_stops       '|:|',
    num_delivery_recs        '|:|',
    num_delivered_packages   '|:|',
    num_delivered_cod        '|:|',
    num_pickup_recs          '|:|',
    num_missed_pickups       '|:|',
    num_send_again           '|:|',
    num_cod_no_money         '|:|',
    num_refused              '|:|',
    num_return_to_sender     '|:|',
    num_not_home             '|:|',
    num_pickup_tags          '|:|',
    num_cancel_cod           '|:|',
    num_hold_for_pickup      '|:|',
    num_cannot_locate        '|:|',
    num_split_shipment       '|:|',
    num_change_of_address    '|:|',
    num_misroute             '|:|',
    num_nonattempt           '|:|',
    num_return_cod           '|:|',
    num_no_sign_required     '|:|',
    num_pickup_stops         '|:|',
    num_pickup_packages      '|:|',
    num_pickup_cod           '|:|',
    num_pickup_select        '|:|',
    num_pickup_hvr           '|:|',
    eod_comments2            '|:|',
    emp_start_break3_time    '|:|',
    emp_end_break3_time      '|:|',
    inserted_on_cons         '|:|',
    updated_on_cons          '\n'
)
from '/opt/sybase/bcp_data/cpscan/driver_stats_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;

