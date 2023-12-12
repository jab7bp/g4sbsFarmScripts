#!/bin/bash

simcMacro=$1 ##Include extension
kine=$2
nOrp=$3
numEvents=$4
firstjob=$5
numbjobs=$6

maxtime='2days'

numbEventsKformat=$((1 * numEvents/1000))'k'

echo "Num events: " $numbEventsKformat

fileBaseName=${simcMacro%.mac}
filename=${fileBaseName##*/}'.root'
echo 
echo "Filename created from macro script name: " 
echo $filename
echo

echo "Output file base name: " $fileBaseName
echo ""

csvfile=${fileBaseName}'.csv'

echo "" > $csvfile

iteratedFileName=$fileBaseName$jobNum'.root'

g4sbsFarmRunScript='/work/halla/sbs/jboyd/jlab-HPC/jb_scripts/jb_run_simc_sbsdig_replay_job.sh'
g4sbsScriptDir='/work/halla/sbs/jboyd/mysim/install/scripts/'

simcjobname=$simcMacro
workflowname='simc_sbsdig_and_replay_SBS'$kine

# Setting necessary environments via setenv.sh
source /site/12gev_phys/softenv.sh 2.5
# source setenv.sh
source /work/halla/sbs/jboyd/setup_jb_env.sh

echo "Submitting " $numbjobs " farm jobs starting with JobNum: " $firstjob " to : " $((firstjob+numbjobs))
echo "........................................."

for ((i=$firstjob; i<$((firstjob+numbjobs)); i++))
do
	echo "Submitting Job Number: " $i
	echo "-----"
	echo "Macro being called: " $g4sbsScriptDir'farmSBS'$kine'/'$simcMacro
	echo ""
	echo "*-*-*-*-*-*-*-*-*-*-*-*"
	echo "Workflow: " $workflowname
	swif2 add-job -workflow $workflowname -partition production -name $simcjobname -cores 1 -disk 5GB -ram 1500MB -time $maxtime $g4sbsFarmRunScript $g4sbsScriptDir'farmSBS'$kine'/'$simcMacro $filename $numEvents $i $kine $numbEventsKformat $nOrp $fileBaseName
	echo "*-*-*-*-*-*-*-*-*-*-*-*"
	echo ""

done

# rm ${fileBaseName##*/}'.csv'