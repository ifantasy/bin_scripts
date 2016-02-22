#!/usr/bin/env perl

# @autogenerated_warning@
# @autogenerated_timestamp@
# @PACKAGE@ @VERSION@
# @PACKAGE_URL@

my $COPYRIGHT="
Copyright (C) 2012-2014 A. Gordon (assafgordon\@gmail.com)
License: GPLv3+
";

use strict;
use warnings;
use Getopt::Long;
use Data::Dumper;
use File::Basename qw/basename/;
use Number::Bytes::Human qw/format_bytes/;

my $VERSION='@VERSION@';
my $PACKAGE_URL='@PACKAGE_URL@';
my $LICENSE='GPLv3+';


my $skip_first_line = undef ;
my $find_first_numeric_column = 1;
my $column_index = undef ;
my $print_human = 1 ;

sub show_help
{
my $BASE = basename($0);
print<<"EOF";
sumcol: sum the values in a given column.
Version: $VERSION
$COPYRIGHT
See: $PACKAGE_URL

This scripts reads the input file (or STDIN),
detects the first numeric column, and prints the sum of the values
in that column.

Usage:
 \$ $BASE [OPTIONS] filename

Options:
 --help       This helpful help screen.
 --header     Skip the first header line (for auto detection)
 --human      Print human sizes (e.g. 3.5GB). This is the default.
 --no-human   Print value as-is.

 -c i
 --column=i   Sum column i (instead of auto-detecting the first numeric column)

Example:
 \$ du /tmp/ | $BASE

 is equivalent to:
 \$ du /tmp/ | awk '{ sum+=\$1 } END { print sum }'


EOF
	exit 0;
}

my $result = GetOptions("header" => \$skip_first_line,
			"column|c=i" => \$column_index,
			"human" => \sub { },
			"no-human" => \sub { $print_human=0 ; },
			"help|h" => \&show_help);
die "Bad command line arguments\n" unless $result;

# make "column_index" into zero-based index
$column_index-- if defined $column_index ;
# Turn off auto-detection, if column is specified on the command line
$find_first_numeric_column = 0 if defined $column_index;

sub nifty_number { defined $_[0] && $_[0] =~ /^([+-]?)(?=\d|\.\d)\d*(\.\d*)?([Ee]([+-]?\d+))?$/; }

my $dummy=<> if $skip_first_line;

my $sum = 0 ;

while (<>) {
	chomp;
	my @fields = split /\t/;

	if ($find_first_numeric_column) {
		foreach my $i ( 0 .. $#fields ) {
			if (nifty_number($fields[$i])) {
				$find_first_numeric_column = 0 ;
				$column_index = $i ;
				last;
			}
		}
	}

	next unless defined $column_index;

	$sum += $fields[$column_index] if length($fields[$column_index]);
}

if ( $print_human ) {
	print format_bytes($sum), "\n";
} else {
	print $sum, "\n";
}