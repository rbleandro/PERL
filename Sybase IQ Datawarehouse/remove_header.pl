#!/usr/bin/perl -w

    $file = $ARGV[0];
    $old = $file;
    $new = "$file.tmp.$$";
    $bak = "$file.bak";
    $skip_once = 1;

    open(OLD, "< $old")         or die "can't open $old: $!";
    open(NEW, "> $new")         or die "can't open $new: $!";


    # Correct typosdd, preserving case
    while (<OLD>) {
      if ($skip_once == 1)
      {
         $skip_once = 0;
         next;
      }
        (print NEW $_)          or die "can't write to $new: $!";
    }


    close(OLD)                  or die "can't close $old: $!";
    close(NEW)                  or die "can't close $new: $!";

    rename($old, $bak)          or die "can't rename $old to $bak: $!";
    rename($new, $old)          or die "can't rename $new to $old: $!";



