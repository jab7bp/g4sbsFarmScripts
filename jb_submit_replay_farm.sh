#!/bin/bash

digitizedFileName=$1
kine=$2

workflowname="farm_MC"
g4sbsjobname="farm_replay_test"

# Setting necessary environments via setenv.sh
source /site/12gev_phys/softenv.sh 2.5
source /work/halla/sbs/jboyd/setup_jb_env.sh

replayScript='/work/halla/sbs/jboyd/jlab-HPC/jb_scripts/jb_run_replay_job.sh'
g4sbsScriptDir='/work/halla/sbs/jboyd/mysim/install/scripts/'

echo "Submitting " $numbjobs " farm jobs starting with JobNum: " $firstjob

# for ((i=$firstjob; i<$((numbjobs+njobs)); i++))
# do
	echo "Submitting Job Number: " $i
	swif2 add-job -workflow $workflowname -partition production -name $g4sbsjobname -cores 1 -disk 5GB -ram 1500MB $replayScript $digitizedFileName $kine
# done
