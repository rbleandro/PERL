use Sys::Hostname;
use strict;
use warnings;
use Getopt::Long qw(GetOptions);

use lib ('/opt/sap/cron_scripts/lib'); use Validation qw( send_alert checkProcessByName showDefaultHelp isProd );

my $action="";
my $file="";
my $return="";
GetOptions(
	'action|a=s' => \$action,
	'file|f=s' => \$file
) or die ();

my $path="/opt/sap/cron_scripts/" . $file . ".pl\n";

if ($action eq "perm"){
    $return = `sudo chmod 755 $path`;
}

if ($return){
    print "$return\n";
}