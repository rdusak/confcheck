#!/bin/sh

echo "Simple test:"
echo
perl paths.pl --input data/1.fsm | tee data/1.paths
echo
perl check.pl --paths data/1.paths --model data/1.fsm
read -n 1 -s -r -p "Press any key to continue"
echo
echo "Graph reduction:"
echo
for i in {18..24}
do
    echo "Reducing ab09.fsm to a graph with $i states (+1 final state)"
    sleep 1
    perl reduce.pl --input data/ab09/ab09.fsm --n $i > data/ab09/$i.fsm
done

echo
for i in {18..24}
do
    echo "Generating paths for reduced graph: $i.fsm"
    sleep 3
    perl paths.pl --input data/ab09/$i.fsm | tee data/ab09/$i.paths
done
echo
read -n 1 -s -r -p "Press any key to continue"
echo
echo "Generating paths for ab09.fsm (this will take some time):"
sleep 3
echo
perl paths.pl --input data/ab09/ab09.fsm | tee data/ab09/ab09.paths
