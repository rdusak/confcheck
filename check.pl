#!/usr/bin/env perl

my $HELP =
"Description:\
    Script to check how many paths in a given file are conforming to a given
    model i.e. how many paths are generatable from the given automata, where
    the model is represented through either a combination of a .fsm file and
    a .syms file, a single .fsm file or a .att/.fsa file (whose format is
    [general]...[initial states]...).

Usage:
    check --paths FILE1 --model FILE2 [FILE3]

Example usage:
    check --paths 1.paths --model 1.fsm

    check --paths 1.paths --model 1.fsm 1.syms

    check --model 1.fsa --paths 1.paths
";

use strict;
use warnings;
use Getopt::Long;

my %files = ("fsm"  => undef,
             "syms" => undef);
my @inputFiles  = ();
my $paths       = undef;
my $inputFile   = undef;
my ($FLAG_FSM, $FLAG_SYMS, $FLAG_FSA);
my ($total, $ok, $notok) = (0,0,0);
my $howTo       = undef;

GetOptions(
    'model=s{1,2}'  => \@inputFiles, # FSM, FSM+SYMS, FSA
    'paths=s'       => \$paths,
    'help=s'        => \$howTo
) or die "Invalid usage.\n";


if (defined $howTo) {
    print $HELP;
    exit 0;
}

if ($#inputFiles == 0) {
    $inputFile = $inputFiles[0];
    if (! $inputFile =~ m/^(.*)\.(fsa|att|fsm|fatH)$/) {
        die "Incorrect input file.\n";
    }
} else {
    foreach my $i (0..1) {
        my $f = $inputFiles[$i];
        if (! $f =~ /^.*\.[0-9a-zA-Z]+$/) {
            die "Invalid argument: ", $f, "\n";
        }
        # take the extension of each argument
        my $extension = (split /\./, $f)[-1];
        $files{$extension} = $f;
        # check if the extension is allowed
        if (!( grep {$_ eq $extension} (keys %files) )) {
            die "Wrong file format: ", $i + 1, ". argument.\n";
        }
    }
    if ((! defined $files{"syms"}) || (! defined $files{"fsm"})) {
        die "Input files are the same format.\n";
    }
}
if (! $paths =~ m/^.*\.(paths|PATHS)$/) {
    die "Incorrect paths file.\n";
}

open PATHS, $paths;
my %syms = ();
my %model = ();

if (! defined $inputFile) {
    open INPUT_FSM, "$files{\"fsm\"}";
    open INPUT_SYMS, "$files{\"syms\"}";
    $FLAG_SYMS = 1;
    while (<INPUT_SYMS>) {
        chomp;
        my @x = split;
        $syms{$x[1]} = $x[0]; # reversed, we are checking from paths backwards
    }
    close INPUT_SYMS;
    while (<INPUT_FSM>) {
        chomp;
        $model{$_} = 1;
    }
    close INPUT_FSM;
} else {
    open INPUT, $inputFile;
    if ($inputFile =~ m/^.*\.fsm/) {
        $FLAG_FSM = 1;
        while (<INPUT>) {
            chomp;
            $model{$_} = 1;
        }
    }
    else {
        $FLAG_FSA = 1;
        while (<INPUT>) {
            chomp;
            $model{$_} = 1;
        }
    }
    close INPUT;
}

sub checkModel {
    my ($start, $end, $label) = @_;
    my $result = 0;
    if ($FLAG_SYMS) {
        if (! defined $syms{$label}) {
            return 0;
        }
        my $t = "$start $end " . $syms{$label};
        if ($model{$t}) {
            $result = 1;
        }
    }
    if ($FLAG_FSM) {
        my $t = "$start $end $label";
        if ($model{$t}) {
            $result = 1;
        }
    }
    if ($FLAG_FSA) {
        my $t = "\t$start, $label, $end;";
        if ($model{$t}) {
            $result = 1;
        }
    }
    return $result;
}

while (<PATHS>) {
    my $pathok = 1;
    chomp;
    my $path = $_;
    $path =~ s/ -\(/ /g;
    $path =~ s/\)-> / /g;
    my @visited = split / /, $path;
    if ($#visited == 0) {
        #$pathok = checkModel($visited[0], "", ""); # only works for FSM
        next;
    }
    my $i = 0;
    while ($i + 2 <= $#visited) {
        my $start = $visited[$i];
        my $label = $visited[$i + 1];
        my $end = $visited[$i + 2];
        my $match = checkModel($start, $end, $label);
        if (! $match) {
            print "++++++++++++++++++\n";
            print "In path: " . $_ . "\n";
            print "Transition missing: " . $start . " -(" . $label . ")-> " . $end . "\n";
            print "++++++++++++++++++\n";
            $pathok = 0;
        }
        $i += 2;
    }
    $ok += $pathok;
    $notok += 1 - $pathok;
    #if ($pathok) {
    #    $ok += 1;
    #} else {
    #    $notok += 1;
    #}
    $total += 1;
}
printf "%*3\$d/%d conforming paths.\n", $ok, $total, length $total;
printf "%*3\$d/%d non-conforming paths.\n", $notok, $total, length $total;
