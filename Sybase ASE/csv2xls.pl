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


    $worksheet->write('A1',  '', $bold);
    $worksheet->write('B1',  '', $bold);
    $worksheet->write('C1',  '', $bold);

    $worksheet->write('A2',  '', $bold);
    $worksheet->write('B2',  '', $bold);
    $worksheet->write('C2',  '', $bold);

    $worksheet->write('A3',  '', $bold);
    $worksheet->write('B3',  '', $bold);
    $worksheet->write('C3',  '', $bold);

    $worksheet->write('A4',  '', $bold);
    $worksheet->write('B4',  '', $bold);
    $worksheet->write('C4',  '', $bold);

    $worksheet->write('A5',  'Barcode', $bold);
    $worksheet->write('B5',  'Postal Code', $bold);
    $worksheet->write('C5',  'Weight', $bold);

    # Row and column are zero indexed, But Per Kanya, need to skip first four rows and the fifth row is headings.Amer
    my $row = 5;

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

