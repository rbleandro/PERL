scp -p /opt/sybase/db_backups/stripe11/cpscan.dmp1 sybase\@CPSYBTEST.canpar.com:/opt/sybase/db_backups/stripe11/
scp -p /opt/sybase/db_backups/stripe12/cpscan.dmp2 sybase\@CPSYBTEST.canpar.com:/opt/sybase/db_backups/stripe12/
scp -p /opt/sybase/db_backups/stripe13/cpscan.dmp3 sybase\@CPSYBTEST.canpar.com:/opt/sybase/db_backups/stripe13/
scp -p /opt/sybase/db_backups/stripe14/cpscan.dmp4 sybase\@CPSYBTEST.canpar.com:/opt/sybase/db_backups/stripe14/
scp -p /opt/sybase/db_backups/stripe15/cpscan.dmp1a sybase\@CPSYBTEST.canpar.com:/opt/sybase/db_backups/stripe15/
scp -p /opt/sybase/db_backups/stripe16/cpscan.dmp2a sybase\@CPSYBTEST.canpar.com:/opt/sybase/db_backups/stripe16/
scp -p /opt/sybase/db_backups/stripe17/cpscan.dmp3a sybase\@CPSYBTEST.canpar.com:/opt/sybase/db_backups/stripe17/
scp -p /opt/sybase/db_backups/stripe18/cpscan.dmp4a sybase\@CPSYBTEST.canpar.com:/opt/sybase/db_backups/stripe18/
scp -p /opt/sybase/db_backups/stripe15/cpscan.dmp1b sybase\@CPSYBTEST.canpar.com:/opt/sybase/db_backups/stripe15/
scp -p /opt/sybase/db_backups/stripe16/cpscan.dmp2b sybase\@CPSYBTEST.canpar.com:/opt/sybase/db_backups/stripe16/
scp -p /opt/sybase/db_backups/stripe17/cpscan.dmp3b sybase\@CPSYBTEST.canpar.com:/opt/sybase/db_backups/stripe17/
scp -p /opt/sybase/db_backups/stripe18/cpscan.dmp4b sybase\@CPSYBTEST.canpar.com:/opt/sybase/db_backups/stripe18/

ssh CPSYBTEST.canpar.com /opt/sybase/cron_scripts/load_db.pl CPSYBTEST cpscan 0 8 1


