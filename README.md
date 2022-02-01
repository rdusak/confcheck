# confcheck
A conformance checking set of tools for FSM models

## Description

This set of tools (`paths.pl`, `check.pl`, `reduce.pl`) was made for 
conformance checking business processes by analyzing labeled directed graphs.

A business process is a set of events, activites and decisions which colletively 
lead to a result beneficial for a client of some organization.

Conformance checking refers to the analysis between the expected behaviour of a process
and the actual behaviour noted within the process log.

It is a custom to use the FSM (_finite state machine_)  notation for the process model.
Depth-first search is used in order to find all possible paths within the graph.
Cycles are ignored.

## Usage

### Demo
```console
$ ./run.sh
```

### Normal
* Find all paths with the FSM and write them into a file
```console
$ perl paths.pl --input some.fsm > found.paths
```

* Check whether all paths within the file can be found with the FSM model
```console
$ perl check.pl --paths found.paths --model some.fsm 
```

_Note: certain graphs can generate an enourmous amount of data (>1GB)_
_For such  graphs it may be wiser to first reduce its size 
and perform an analysis on the reduced graph, and making estimates for the real one._

* Reduce a graph
```console
perl reduce.pl --input big.fsm --n 7 > small.fsm # n is the maximum number of states
```
