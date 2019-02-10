truncate table truck_stats;
LOAD into table truck_stats 
(
    employee_num             '|:|',
    terminal_num             '|:|',
    conv_time_date           '|:|',
    route_num                '|:|',
    truck_num                '|:|',
    check_exterior_damage    '|:|',
    check_tires              '|:|',
    check_oil                '|:|',
    check_engine_coolant     '|:|',
    check_washer_fuild       '|:|',
    check_headlights         '|:|',
    check_brakelights        '|:|',
    check_signal_lights      '|:|',
    check_emergency_flashers '|:|',
    check_wipers             '|:|',
    check_horn               '|:|',
    truck_check_l            '|:|',
    truck_check_m            '|:|',
    truck_check_n            '|:|',
    truck_check_o            '|:|',
    truck_check_p            '|:|',
    truck_check_q            '|:|',
    km_left_terminal         '|:|',
    km_start_delivery        '|:|',
    km_finish_delivery       '|:|',
    km_start_pickup          '|:|',
    km_finish_pickup         '|:|',
    km_return_terminal       '|:|',
    eod_comments1            '|:|',
    is_rental_truck          '|:|',
    inserted_on_cons         '|:|',
    updated_on_cons          '\n'
)
from '/opt/sybase/bcp_data/cpscan/truck_stats_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;
