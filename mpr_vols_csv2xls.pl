#!/usr/bin/perl -w

use strict;
use Spreadsheet::WriteExcel;
use Text::CSV_XS;

    # Check for valid number of arguments
    if (($#ARGV < 1) || ($#ARGV > 2)) {
       die("Usage: csv2xls csvfile.txt newfile.xls\n");
    };

    # Open the Comma Separated Variable file
    open (CSVFILE, $ARGV[0]) or die "$ARGV[0]: $!";

    # Create a new Excel workbook
    my $workbook  = Spreadsheet::WriteExcel->new($ARGV[1]);
    my $worksheet = $workbook->add_worksheet();

    # Create a new CSV parsing object
    my $csv = Text::CSV_XS->new;

    # Add a general format
    my $bold = $workbook->add_format(bold => 1);
    my $style = $workbook->add_format();
       $style->set_num_format(0x0e);

    $worksheet->write('A1',  'start_date', $bold);
    $worksheet->write('B1',  'end_date', $bold);
    $worksheet->write('C1',  'linehaul_lane', $bold);
    $worksheet->write('D1',  'service', $bold);
    $worksheet->write('E1',  'total_cost', $bold);
    $worksheet->write('F1',  'volume_in_ft', $bold);
    $worksheet->write('G1',  'cost_per_cubic_ft', $bold);


    my $row = 0;

    while (<CSVFILE>) {
        if ($csv->parse($_)) {
            my @Fld = $csv->fields;

            my $col = 0;
            foreach my $token (@Fld) {
		$token =~ s/\s//g;
                $worksheet->write($row, $col, $token);
                $col++;
            }
            $row++;
        }
        else {
            my $err = $csv->error_input;
            print "Text::CSV_XS parse() failed on argument: ", $err, "\n";
        }
    }

