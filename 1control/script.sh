#!/bin/bash     
rm camino.csv
clear
echo "Compiling files.."
echo "Executing gmpl.."
glpsol --model v0.12Al.mod -o solMan.txt
echo "Done!"
