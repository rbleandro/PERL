truncate table can_cost;
LOAD into table can_cost
(
    terminal                  '|:|',
    pcs_per_month             '|:|',
    sort_pcs_per_month        '|:|',
    am_sort_load              '|:|',
    pm_sort_load              '|:|',
    urban_pu_stop_time        '|:|',
    urban_pu_inc_time_per_pc  '|:|',
    urban_del_stop_time       '|:|',
    urban_del_inc_time_per_pc '|:|',
    urban_maint_per_stop      '|:|',
    rural_pu_stop_time        '|:|',
    rural_pu_inc_time_per_pc  '|:|',
    rural_del_stop_time       '|:|',
    rural_del_inc_time_per_pc '|:|',
    rural_maint_per_stop      '|:|',
    res_del_stop_time         '|:|',
    res_del_inc_time_per_pc   '|:|',
    tractor_pu_time_per_pc    '|:|',
    tractor_del_time_per_pc   '|:|',
    tractor_maint_per_stop    '|:|',
    tractor_rate              '|:|',
    pnd_rate                  '|:|',
    hub_rate                  '|:|',
    am_sort_time_per_pc       '|:|',
    pm_unload_time_per_pc     '|:|',
    preload_time              '|:|',
    hub_time                  '|:|',
    var_overhead              '|:|',
    fix_overhead              '\n'
)

from '/opt/sybase/bcp_data/cmf_data/can_cost_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;

