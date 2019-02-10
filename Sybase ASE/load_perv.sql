set temporary option ISQL_PRINT_RESULT_SET = 'NONE';
select ltrim(rtrim(FTERM))+'||'+ltrim(rtrim(FTERM3))+'||'+ltrim(rtrim(FREGION))+'||'+ltrim(rtrim(FMD))+'||'+ltrim(rtrim(FMM))+'||'+ltrim(rtrim(FMDY))+'||'+ltrim(rtrim(FDD))+'||'+ltrim(rtrim(FYY))+'||'+ltrim(rtrim(FPUPCS))+'||'+ltrim(rtrim(FDEPCS))+'||'+ltrim(rtrim(FSTPPI))+'||'+ltrim(rtrim(FSTPDE))+'||'+ltrim(rtrim(FMPUPS))+'||'+ltrim(rtrim(FNA))+'||'+ltrim(rtrim(FSA))+'||'+ltrim(rtrim(FMSORT))+'||'+ltrim(rtrim(FPDHRG))+'||'+ltrim(rtrim(FPDHOT))+'||'+ltrim(rtrim(FHUBHRS))+'||'+ltrim(rtrim(FPREHRS))+'||'+ltrim(rtrim(FOFCHRS))+'||'+ltrim(rtrim(FLNHRS))+'||'+ltrim(rtrim(FSLSHRS))+'||'+ltrim(rtrim(FAVGREV))+'||'+ltrim(rtrim(FPDWGR))+'||'+ltrim(rtrim(FPDWGO))+'||'+ltrim(rtrim(FLHWG))+'||'+ltrim(rtrim(FPREWG))+'||'+ltrim(rtrim(FHUBWG))+'||'+ltrim(rtrim(FOFWG))+'||'+ltrim(rtrim(FSLSWG))+'||'+ltrim(rtrim(FPDMILE))+'||'+ltrim(rtrim(FLHMILE))+'||'+ltrim(rtrim(FLDHR))+'||'+ltrim(rtrim(FLDWG))+'||'+ltrim(rtrim(FCAR))+'||'+ltrim(rtrim(FINT))+'||'+ltrim(rtrim(FCCAR))+'||'+ltrim(rtrim(FCINT))+'||' from "Flash Master";
output to '/opt/sap/cmf_data/asa/flash_master.txt'
format fixed;
select * from "QMAPARMS";
output to '/opt/sap/cmf_data/asa/qmaparms.txt'
format fixed;
select * from "QuotaTer";
output to '/opt/sap/cmf_data/asa/quotater.txt'
format fixed;
select * from "RSALTLNK";
output to '/opt/sap/cmf_data/asa/rsaltlnk.txt'
format fixed;

