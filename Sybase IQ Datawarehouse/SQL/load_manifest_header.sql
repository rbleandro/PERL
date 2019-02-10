truncate table manifest_header;
insert into manifest_header IGNORE CONSTRAINT UNIQUE 0 location 'CPDB1.cpscan' packetsize 1024{ select * from manifest_header };
