#!/usr/bin/perl

use strict;
use warnings;
use MIME::Lite;

# Configure smtp server - required one time only
MIME::Lite->send ("smtp", "smtp.canpar.com"); 

my $msg = MIME::Lite->new
  (
  From    => 'sybase@CPDB2.com',
  To      => 'rleandro@canpar.com',
  Data    => "A simple test message\n",
  Subject => "Test",
  );

$msg->send ();