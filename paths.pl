#!/usr/bin/env perl

my $HELP =
"Description:\
    Script to find and print out all the possible paths from the starting
    state to all final states for a given graph represented through either a
    combination of a .fsm file and a .syms file, a single .fsm file or a
    .att/.fsa file (whose format is [general]...[initial states]...).

Usage:
    bpm-wfm-pa-cc-allpaths-perl-rd --input FILE1 [FILE2] [--output OUTPUTFILE]

    If no OUTPUTFILE is provided, STDOUT is used.
    At least one input file should be provided.
    Output format used is:
        state -(label)-> state

Example usage:
    ./bpm-wfm-pa-cc-allpaths-perl-rd --input a.fsm b.syms

    ./bpm-wfm-pa-cc-allpaths-perl-rd --input a.fsm b.syms --output c.paths

    ./bpm-wfm-pa-cc-allpaths-perl-rd --input a.fsa --output b.paths

    ./bpm-wfm-pa-cc-allpaths-perl-rd --input a.att

    ./bpm-wfm-pa-cc-allpaths-perl-rd --input a.fsm | tee b.paths
";

use strict;
use warnings;
use Getopt::Long;

#use Data::Dumper qw(Dumper); # debug

my %files = ("fsm"  => undef,
             "syms" => undef);
my @inputFiles  = (); # list to temporarily store files given for checking
my $output      = undef;
my $howTo       = undef;
my $inputFile   = undef; # if a sigle file is given, for ease of access

GetOptions(
    'input=s{1,2}'  => \@inputFiles,
    'output=s'      => \$output,
    'help'          => \$howTo
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
        if (! $f =~ /^.*\.[0-9a-zA-Z]+$/) { # does it even have an extension?
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

if (! defined $inputFile) {
    open INPUT_FSM, "$files{\"fsm\"}";
    open INPUT_SYMS, "$files{\"syms\"}";
} else {
    open INPUT, $inputFile;
}

my %syms            = ();
my $initialState    = undef;
my @finalStates     = ();
my %graph           = ();
my $u               = 0; # unique identifier for cases where the same label
                         # leads to two or more different states
                         # since keys in a haskmap have to be unique

# %graph = ($state1 => ($label1 => $nextState1,
#                       $label2 => $nextState2,
#                       ...),
#           ...);

if (! defined $inputFile) {
    # store numeric representation of a label
    while (<INPUT_SYMS>) {
        chomp;
        my @x = split;
        $syms{$x[0]} = $x[1];
    }
    close INPUT_SYMS;
    while (<INPUT_FSM>) {
        chomp;
        if (/^[0-9]{1}\s*$/) { # final state found
            $_ =~ s/\s+$//; # trim trailing whitespace
            push @finalStates, $_;
            next;
        }
        my ($start, $end, $label) = split;
        if (! defined $initialState) { # only one initial state
            $initialState = $start;
        }
        if (! defined $graph{$start}{$syms{$label}}) {
            $graph{$start}{$syms{$label}} = $end;
        } else {
            if ($graph{$start}{$syms{$label}} eq $end) {
                next; # already have this combination
            }
            $graph{$start}{$syms{$label} . "-" . $u} = $end;
            # one label leads to multiple different states
            # keys must be unique
            $u += 1;
        }

    }
    close INPUT_FSM;
} else {
    if ($inputFile =~ m/^(.*)\.fsm$/) {
        while (<INPUT>) {
            chomp;
            if (/^[0-9]{1}\s*$/) { # final state found
                $_ =~ s/\s+$//; # trim trailing whitespace
                push @finalStates, $_;
                next;
            }
            my ($start, $end, $label) = split;
            if (! defined $initialState) { # only one initial state
                $initialState = $start;
            }
            if (! defined $graph{$start}{$label}) {
                $graph{$start}{$label} = $end;
            } else {
                if ($graph{$start}{$label} eq $end) {
                    next;
                }
                $graph{$start}{$label . "-" . $u} = $end;
                # one label leads to multiple different states
                # keys must be unique
                $u += 1;
            }

        }
        close INPUT;
    } else {
        while (<INPUT>) {
            s/\s+//g; # remove all whitespace
            if (/^[^0-9]/) { # line doesn't start with a number
                next;
            }
            s/;//g; # remove ;
            if (! defined $initialState) {
                $initialState = $_; # only one initial state
                next;
            }
            if (! @finalStates) {
                @finalStates = split /,/; # possibly multiple final states
                next;
            }
            my ($start, $label, $end) = split /,/;


            if (! defined $graph{$start}{$label}) {
                $graph{$start}{$label} = $end;
            } else {
                if ($graph{$start}{$syms{$label}} eq $end) {
                    next;
                }
                $graph{$start}{$label . "-" . $u} = $end;
                # one label leads to multiple different states
                # keys must be unique
                $u += 1;
            }

        }
        close INPUT;
    }
}

# %node = (state => state of the node,
#          parent => parent node,
#          label => which label was used to get here)

sub expand {
    my ($n) = @_;
    my @r;
    foreach my $newLabel (keys %{$graph{$n->{state}}}) {
        my %nextNode = (state   => $graph{$n->{state}}{$newLabel},
                        parent  => $n,
                        label   => $newLabel);
        push @r, \%nextNode;
    }

    return \@r;
}

sub path {
    my ($n) = @_;
    if (! defined $n->{parent}) {
        return $n->{state};
    }
    my $realLabel = (split /-/, $n->{label})[0];
    return path($n->{parent}) . " -(" . $realLabel . ")-> " . $n->{state};
}

sub depthFirstSearch {
    my ($s0, $goal) = @_;
    my @opened;
    my %initial = (state => $s0, parent => undef, label => undef);
    push @opened, \%initial;

    while ($#opened + 1 > 0) {
        my $n = shift @opened;

        if ($goal eq $n->{state}) {
            my $p = path($n) . "\n";
            print $p;
            next;
        }
        my $visited = path($n);
        $visited =~ s/ -\([0-9a-z]+\)-> / /g;
        my @visited = split / /, $visited;
        my $exr = expand($n);
        my $m;
        foreach $m (@$exr) {
            if (( grep {$_ eq $m->{state}} @visited )) {
                next;
            }
            unshift @opened, $m;
            #push @opened, $m; # BFS
        }
        undef $exr;
        undef @visited;
        undef $visited;
        undef $m;
    }

    return 0;
}

if (defined $output) {
    open OUT, '>>', $output;
    select OUT;
}

foreach (@finalStates) {
    depthFirstSearch($initialState, $_);
}
#print Dumper \%graph; # for debugging purposes
