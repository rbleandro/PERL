truncate table Labor;
LOAD into table Labor
(
    EQTypeGroupCode          '|:|',
    POHdrPONumber            '|:|',
    POHdrInvoiceNumber       '|:|',
    POHdrType                '|:|',
    POHdrStat                '|:|',
    POHdrDateClosed          '|:|',
    POHdrTotal               '|:|',
    RODetRONumber            '|:|',
    RODetFleetCode           '|:|',
    RODetUnitCode            '|:|',
    RODetEqType              '|:|',
    RODetReasonForRepairCode '|:|',
    RODetRODate              '|:|',
    RODEtROLine              '|:|',
    RODetCompanyCode         '|:|',
    ROlaborStat              '|:|',
    ROLaborType              '|:|',
    ROlaborSys               '|:|',
    ROLaborRegularHours      '|:|',
    ROLaborOverTimehours     '|:|',
    ROlaborRegularRate       '|:|',
    ROLaborOvertimeRate      '|:|',
    EqMake                   '|:|',
    EqMode                   '|:|',
    EqYear                   '|:|',
    MeterReading             '|:|',
    MeterType                '|:|',
    ROGroupCode              '|:|',
    POHdrShippingExpensed    '|:|',
    POHdrTaxesExpensed       '|:|',
    POHdrMiscExpensed        '|:|',
    POHdrShippingApportioned '|:|',
    POHdrTaxesApportioned    '|:|',
    POHdrMiscApportioned     '\n'
)

from '/opt/sybase/bcp_data/cmf_data/Labor_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;
