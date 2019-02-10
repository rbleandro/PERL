my $outputError = $ARGV[0];
open (MAIL, "|C\:\/sendmail\/sendmail.exe -t");

print MAIL "To: akhan\@canpar.com\n";#CANPARDatabaseAdministratorsStaffList\@canpar.com\n";
print MAIL "From: DoNotReply <admin\@datastage.com>\n";
print MAIL "Subject: REVHST Data loaded successfully\n\n";

print MAIL "Error Received: $outputError\n";
print MAIL "Regards,\n";
print MAIL "Amer\n";
close (MAIL);