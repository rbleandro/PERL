truncate table linehaul_costs;
LOAD into table linehaul_costs
(
    fromterm       '|:|',
    toterm         '|:|',
    costperpound   '|:|',
    selectperpound '|:|',
    costperskid    '\n'
)

from '/opt/sybase/bcp_data/cmf_data/linehaul_costs_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;

