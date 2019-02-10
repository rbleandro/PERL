open (MAIL, "|C\:\/sendmail\/sendmail.exe -t");

print MAIL "To: adrysdale\@canpar.com, FORourke\@canpar.com, AVasilenco\@canpar.com, KKotur\@canpar.com, Hedia.Bottros\@loomis-express.com, AKhan\@canpar.com, aarain\@canpar.com\n";print MAIL "From: DoNotReply <admin\@datastage.com>\n";
print MAIL "Subject: INVOICE Data Sent To PMS\n\n";

print MAIL "Please Check\n";
print MAIL "Regards,\n";
print MAIL "Amer\n";
close (MAIL);