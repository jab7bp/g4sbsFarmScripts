#!/bin/bash

g4sbsMacro=$1
kine=$2
numEvents=$3
firstjob=$4
numbjobs=$5

fileBaseName=${g4sbsMacro%.mac}
filename=${fileBaseName##*/}'.root'
echo 
echo "Filename created from macro script name: " 
echo $filename
echo

echo "Output file base name: " $fileBaseName
echo ""

csvfile=${fileBaseName##*/}'.csv'

echo "" > $csvfile

iteratedFileName=$fileBaseName$jobNum'.root'

g4sbsFarmRunScript='/work/halla/sbs/jboyd/jlab-HPC/jb_scripts/jb_run_g4sbs_sbsdig_job.sh'
g4sbsScriptDir='/work/halla/sbs/jboyd/mysim/install/scripts/'

g4sbsjobname=$g4sbsMacro
workflowname='farm_g4sbs_and_digiOnly'

# Setting necessary environments via setenv.sh
source /site/12gev_phys/softenv.sh 2.5
# source setenv.sh
source /work/halla/sbs/jboyd/setup_jb_env.sh

echo "Submitting " $numbjobs " farm jobs starting with JobNum: " $firstjob
echo "........................................."

for ((i=$firstjob; i<$((numbjobs+njobs)); i++))
do
	echo "Submitting Job Number: " $i
	echo "-----"
	echo "Macro being called: " $g4sbsScriptDir'farmSBS'$kine'/'$g4sbsMacro
	echo ""
	echo "*-*-*-*-*-*-*-*-*-*-*-*"
	echo "Workflow: " $workflowname
	swif2 add-job -workflow $workflowname -partition production -name $g4sbsjobname -cores 1 -disk 5GB -ram 1500MB $g4sbsFarmRunScript $g4sbsScriptDir'farmSBS'$kine'/'$g4sbsMacro $filename $numEvents $i $kine
	echo "*-*-*-*-*-*-*-*-*-*-*-*"
	echo ""
done
