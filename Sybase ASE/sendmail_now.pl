open (MAIL, "|C\:\/sendmail\/sendmail.exe -t");

print MAIL "To: Amer Khan <amer_Khan\@canpar.com>\n";
print MAIL "From: DataStage <admin\@datastage.com>\n";
print MAIL "Subject: Scanner Data Push Messages\n\n";

print MAIL "This is line 1\n";
print MAIL "This is line 2\n";
close (MAIL);