#!/usr/bin/perl
use warnings;
use strict;
use Crypt::CBC;
use MIME::Base64;
use Getopt::Long qw(GetOptions);
my $pwd="";

GetOptions(
    'pwd|p=s' => \$pwd
) or die "Password string is mandatory. Usage: $0 --pwd|p passwd\n";

if ($pwd eq ""){
	die "Password string is mandatory. Usage: $0 --pwd|p passwd\n";
}

my $string = $pwd;
#print "input: $string\n";

my $enc = encryptString( $string );
#print "encrypted binary: $enc\n";

my $mime = encode_base64($enc);
print "HASHED PASSWORD (use this on the passwords file): $mime\n";

my $mime_decode = decode_base64($mime);
#print "MIME_decode: $mime_decode\n";

my $dec = decryptString( $enc );
#print "decrypted: $dec\n";

my $mime_dec = decryptString( decode_base64($mime) );
print "decrypted_hash: $mime_dec\n";

#$string = 'you_shall_not_pass';
#print "$string\n";
#
my $obscure =  pack("u",$string);
#print "$obscure\n";
#print "$unobscure\n";

############################################################
sub encryptString {
   my $string = shift;
   my $unobscure = unpack(chr(ord("a") + 19 + print ""),'2>6]U7W-H86QL7VYO=%]P87-S');
   my $cipher = Crypt::CBC->new(
      -key        => $unobscure,
      -cipher     => 'Blowfish',
      -padding  => 'space',
      -add_header => 1
   );

   my $enc = $cipher->encrypt( $string  );
   return $enc; 
}

###################################################################

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