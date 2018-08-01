open (MAIL, "|C\:\/sendmail\/sendmail.exe -t");

print MAIL "To: Amer Khan <amer_Khan\@canpar.com>\n";
print MAIL "Cc: Amer Arain <amer_arain\@canpar.com>\n";
print MAIL "From: DataStage <admin\@datastage.com>\n";
print MAIL "Subject: ma tables loaded successfully\n\n";

print MAIL "Please proceed with invoicing\n";
print MAIL "Regards,\n";
print MAIL "Amer\n";
close (MAIL);