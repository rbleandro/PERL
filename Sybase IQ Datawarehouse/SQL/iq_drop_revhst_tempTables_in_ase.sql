use tempdb
go	
IF OBJECT_ID('dbo.bcxref_ins') IS NOT NULL
BEGIN
    DROP TABLE dbo.bcxref_ins
    IF OBJECT_ID('dbo.bcxref_ins') IS NOT NULL
        PRINT '<<< FAILED DROPPING TABLE dbo.bcxref_ins >>>'
    ELSE
        PRINT '<<< DROPPED TABLE dbo.bcxref_ins >>>'
END
go    
IF OBJECT_ID('dbo.revhstd1_ins') IS NOT NULL
BEGIN
    DROP TABLE dbo.revhstd1_ins
    IF OBJECT_ID('dbo.revhstd1_ins') IS NOT NULL
        PRINT '<<< FAILED DROPPING TABLE dbo.revhstd1_ins >>>'
    ELSE
        PRINT '<<< DROPPED TABLE dbo.revhstd1_ins >>>'
END
go    
IF OBJECT_ID('dbo.revhstd_ins') IS NOT NULL
BEGIN
    DROP TABLE dbo.revhstd_ins
    IF OBJECT_ID('dbo.revhstd_ins') IS NOT NULL
        PRINT '<<< FAILED DROPPING TABLE dbo.revhstd_ins >>>'
    ELSE
        PRINT '<<< DROPPED TABLE dbo.revhstd_ins >>>'
END
go    
IF OBJECT_ID('dbo.revhstf1_ins') IS NOT NULL
BEGIN
    DROP TABLE dbo.revhstf1_ins
    IF OBJECT_ID('dbo.revhstf1_ins') IS NOT NULL
        PRINT '<<< FAILED DROPPING TABLE dbo.revhstf1_ins >>>'
    ELSE
        PRINT '<<< DROPPED TABLE dbo.revhstf1_ins >>>'
END
go    
IF OBJECT_ID('dbo.revhstf_ins') IS NOT NULL
BEGIN
    DROP TABLE dbo.revhstf_ins
    IF OBJECT_ID('dbo.revhstf_ins') IS NOT NULL
        PRINT '<<< FAILED DROPPING TABLE dbo.revhstf_ins >>>'
    ELSE
        PRINT '<<< DROPPED TABLE dbo.revhstf_ins >>>'
END
go    
IF OBJECT_ID('dbo.revhsth_ins') IS NOT NULL
BEGIN
    DROP TABLE dbo.revhsth_ins
    IF OBJECT_ID('dbo.revhsth_ins') IS NOT NULL
        PRINT '<<< FAILED DROPPING TABLE dbo.revhsth_ins >>>'
    ELSE
        PRINT '<<< DROPPED TABLE dbo.revhsth_ins >>>'
END
go    
IF OBJECT_ID('dbo.revhstm_ins') IS NOT NULL
BEGIN
    DROP TABLE dbo.revhstm_ins
    IF OBJECT_ID('dbo.revhstm_ins') IS NOT NULL
        PRINT '<<< FAILED DROPPING TABLE dbo.revhstm_ins >>>'
    ELSE
        PRINT '<<< DROPPED TABLE dbo.revhstm_ins >>>'
END
go    
IF OBJECT_ID('dbo.revhstr_ins') IS NOT NULL
BEGIN
    DROP TABLE dbo.revhstr_ins
    IF OBJECT_ID('dbo.revhstr_ins') IS NOT NULL
        PRINT '<<< FAILED DROPPING TABLE dbo.revhstr_ins >>>'
    ELSE
        PRINT '<<< DROPPED TABLE dbo.revhstr_ins >>>'
END
go    
IF OBJECT_ID('dbo.revhstz_ins') IS NOT NULL
BEGIN
    DROP TABLE dbo.revhstz_ins
    IF OBJECT_ID('dbo.revhstz_ins') IS NOT NULL
        PRINT '<<< FAILED DROPPING TABLE dbo.revhstz_ins >>>'
    ELSE
        PRINT '<<< DROPPED TABLE dbo.revhstz_ins >>>'
END
go   
 
IF OBJECT_ID('dbo.dimweight_ins') IS NOT NULL
BEGIN
    DROP TABLE dbo.dimweight_ins
    IF OBJECT_ID('dbo.dimweight_ins') IS NOT NULL
        PRINT '<<< FAILED DROPPING TABLE dbo.dimweight_ins >>>'
    ELSE
        PRINT '<<< DROPPED TABLE dbo.dimweight_ins >>>'
END
go   
 
