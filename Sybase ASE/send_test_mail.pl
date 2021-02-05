#!/usr/bin/perl -w
my $email = "rleandro\@canpar.com";
my $to = "rleandro\@canpar.com";
my $from = "rleandro\@canpar.com";
my $subject = "TEST";
my $message = "testing mail";
open(MAIL, "|/usr/sbin/sendmail -t");
print MAIL "To: $to\n";
print MAIL "From: $from\n";
print MAIL "Subject: $subject\n\n";
print MAIL $message;
close(MAIL);
