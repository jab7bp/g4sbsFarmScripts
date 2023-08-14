#!/bin/bash

g4sbsMacro=$1
filename=$2
firstjob=$3
numbjobs=$4

g4sbsFarmRunScript='/work/halla/sbs/jboyd/jlab-HPC/jb_run_g4sbs_job.sh'
g4sbsScriptDir='/work/halla/sbs/jboyd/mysim/install/scripts/'

g4sbsjobname=$g4sbsMacro
workflowname='farm_MC'

# Setting necessary environments via setenv.sh
source /site/12gev_phys/softenv.sh 2.5
source setenv.sh
source /work/halla/sbs/jboyd/setup_jb_env.sh

echo "Submitting " $numbjobs " farm jobs starting with JobNum: " $firstjob

for ((i=$firstjob; i<$((numbjobs+njobs)); i++))
do
	echo "Submitting Job Number: " $i
	swif2 add-job -workflow $workflowname -partition production -name $g4sbsjobname -cores 1 -disk 5GB -ram 1500MB $g4sbsFarmRunScript $g4sbsScriptDir$g4sbsMacro $filename
done
