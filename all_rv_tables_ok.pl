open (MAIL, "|C\:\/sendmail\/sendmail.exe -t");

print MAIL "To: adrysdale\@canpar.com, FORourke\@canpar.com, AVasilenco\@canpar.com, KKotur\@canpar.com, Hedia.Bottros\@loomis-express.com, CANPARDatabaseAdministratorsStaffList\@canpar.com\n";
print MAIL "From: DoNotReply <admin\@datastage.com>\n";
print MAIL "Subject: REVHST Data loaded successfully\n\n";

print MAIL "Please proceed with Pre-invoicing\n";
print MAIL "Regards,\n";
print MAIL "Amer\n";
close (MAIL);