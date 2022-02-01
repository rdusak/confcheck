#!/usr/bin/env perl

my $HELP =
"Description:\
    Script to reduce a graph given in an FSM file by removing lines containing
    a number greater than the one give as a parameter.

Usage:
    reduce --input FILE1 --n NUMBER

Example usage:
    check --input 1.fsm --n 2 > r.fsm

";

use Getopt::Long;
my $input;
my $n;
my $howTo = undef;

GetOptions(
    'input=s'   => \$input,
    'n=i'       => \$n,
    'help=s'    => \$howTo
) or die "Invalid usage.\n";

if (defined $howTo) {
    print $HELP;
    exit 0;
}

if (! $input =~ m/^(.*)\.fsm$/) {
    die "Wrong input file.\n";
}

#$input =~ m/^(.*)(\\|\/).+\.fsm$/;
#$output = $1 . $2 . $n . ".fsm";
open INPUT, $input;
#open OUT, '>', $output;

while (<INPUT>) {
    my ($a, $b, $c) = split / /, $_;
    if ($a > $n || $b > $n) {
        next;
    }
    #print OUT $_;
    print;
}
