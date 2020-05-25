#!/usr/bin/perl -w

#Script:       This scripts retrieves passwords for logins from file named
#              passwords. It is only accessible by sybase
#Date		      Name		      Description
#12/19/03	   Amer Khan	   Originally created
#May 15 2020   Rafael Bahia   Added encryption logic

use lib '/opt/sybase/perl5/lib/perl5';
use warnings;
use strict;
use Crypt::CBC;
use MIME::Base64;

my $login = $ARGV[0];
$login =~ s/\n//g;
my @passLine;
my $pass;

open (PASS,"</opt/sybase/cron_scripts/passwords/passwords") or die "Can't Open password file: $!\n\n";

while (<PASS>){
   @passLine = split(/\t/,$_);

   if ($login eq $passLine[0]){
      $passLine[1] =~ s/\n//g;
      $pass=decryptString( decode_base64($passLine[1]) );
      print "$pass";
   }
}

sub decryptString {
   my $string = shift;
   my $unobscure = unpack(chr(ord("a") + 19 + print ""),'2>6]U7W-H86QL7VYO=%]P87-S');
   my $cipher = Crypt::CBC->new(
      -key        => $unobscure,
      -cipher     => 'Blowfish',
      -padding  => 'space',
      -add_header => 1
   );

   my $dec = $cipher->decrypt( $string  );
   return $dec;
}