#!/usr/bin/perl
use strict;
use warnings;

use Spreadsheet::WriteExcel;
use Text::CSV::Simple;

my $infile = shift;
usage()  unless defined $infile && -f $infile;
my $parser = Text::CSV::Simple->new ({ sep_char => '|' });
my @data = $parser->read_file($infile);
my $headers = shift @data;

my $outfile = shift || $infile . ".xls";
my $subject = shift || 'worksheet';

sub usage {
	print "csv2xls infile [outfile] [subject]\n";
	exit;
}
    
my $workbook = Spreadsheet::WriteExcel->new($outfile);
my $bold = $workbook->add_format();
$bold->set_bold(1);
import_data($workbook, $subject, $headers, \@data);

# Add a worksheet
sub import_data {
	my $workbook  = shift;
	my $base_name = shift;
	my $colums    = shift;
	my $data      = shift;
	#my $limit     = shift || 50_000;
	my $start_row = shift || 1;
	my $worksheet = $workbook->add_worksheet($base_name);
	$worksheet->add_write_handler(qr[\w], \&store_string_widths);
	my $w = 1;
	$worksheet->write('A' . $start_row, $colums, ,$bold);
	my $i = $start_row;
	my $qty = 0;
	for my $row (@$data) {
	    $qty++;
	    #if ($i > $limit) {
			 #$i = $start_row;
			 #$w++;
			 #$worksheet = $workbook->add_worksheet("$base_name - $w");
			 #$worksheet->write('A1', $colums,$bold);
		#}
		$worksheet->write($i++, 0, $row);
		#print $row . '\n';
	}
	
	autofit_columns($worksheet);
	warn "Convereted $qty rows.";
	return $worksheet;
}


###############################################################################
###############################################################################
#
# Functions used for Autofit.
#

###############################################################################
#
# Adjust the column widths to fit the longest string in the column.
#
sub autofit_columns {

    my $worksheet = shift;
    my $col       = 0;

    for my $width (@{$worksheet->{__col_widths}}) {

        $worksheet->set_column($col, $col, $width) if $width;
        $col++;
    }
}


###############################################################################
#
# The following function is a callback that was added via add_write_handler()
# above. It modifies the write() function so that it stores the maximum
# unwrapped width of a string in a column.
#
sub store_string_widths {

    my $worksheet = shift;
    my $col       = $_[1];
    my $token     = $_[2];

    # Ignore some tokens that we aren't interested in.
    return if not defined $token;       # Ignore undefs.
    return if $token eq '';             # Ignore blank cells.
    return if ref $token eq 'ARRAY';    # Ignore array refs.
    return if $token =~ /^=/;           # Ignore formula

    # Ignore numbers
    #return if $token =~ /^([+-]?)(?=\d|\.\d)\d*(\.\d*)?([Ee]([+-]?\d+))?$/;

    # Ignore various internal and external hyperlinks. In a real scenario
    # you may wish to track the length of the optional strings used with
    # urls.
    return if $token =~ m{^[fh]tt?ps?://};
    return if $token =~ m{^mailto:};
    return if $token =~ m{^(?:in|ex)ternal:};


    # We store the string width as data in the Worksheet object. We use
    # a double underscore key name to avoid conflicts with future names.
    #
    my $old_width    = $worksheet->{__col_widths}->[$col];
    my $string_width = string_width($token);

    if (not defined $old_width or $string_width > $old_width) {
        # You may wish to set a minimum column width as follows.
        #return undef if $string_width < 10;

        $worksheet->{__col_widths}->[$col] = $string_width;
    }


    # Return control to write();
    return undef;
}


###############################################################################
#
# Very simple conversion between string length and string width for Arial 10.
# See below for a more sophisticated method.
#
sub string_width {

    return length $_[0];
}