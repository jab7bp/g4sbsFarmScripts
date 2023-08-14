#!/bin/bash

# ------------------------------------------------------------------------- #
# This script runs replays of digizited g4sbs jobs.                                   #
# ---------                                                                 #
# J Boyd Aug 12, 2023                       #
# ---------                                                                 #

#SBATCH --partition=production
#SBATCH --account=halla
#SBATCH --mem-per-cpu=1500

source /site/12gev_phys/softenv.sh 2.5
source /w/halla-scshelf2102/sbs/jboyd/setup_jb_env.sh
source /w/halla-scshelf2102/sbs/jboyd/SBS_OFFLINE/install/run_replay_here/MC/FARM_setup_MC_replay.sh

digitizedFileName=$1
kine=$2

export DATA_DIR="/volatile/halla/sbs/jboyd/simulation/out_dir/farm_sim/MC/SBS$kine/digitized_only/"

source /w/halla-scshelf2102/sbs/jboyd/ANALYZER/install/bin/setup.sh

echo "Sourcing SBS_OFFLINE: /w/halla-scshelf2102/sbs/jboyd/SBS_OFFLINE/install/bin/sbsenv.sh"
source /w/halla-scshelf2102/sbs/jboyd/SBS_OFFLINE/install/bin/sbsenv.sh
echo "sourcing Analyzer: /w/halla-scshelf2102/sbs/jboyd/ANALYZER/install/bin/setup.sh"
source /w/halla-scshelf2102/sbs/jboyd/ANALYZER/install/bin/setup.sh
echo "sourcing /w/halla-scshelf2102/sbs/jboyd/SBS_OFFLINE/install/run_replay_here/MC/FARM_setup_MC_replay.sh"
source /w/halla-scshelf2102/sbs/jboyd/SBS_OFFLINE/install/run_replay_here/MC/FARM_setup_MC_replay.sh


echo "Adding SBS-offline to the path directories...."
export C_PATH="/w/halla-scshelf2102/sbs/jboyd/SBS_OFFLINE/SBS-offline/:$C_PATH"
export LIBRARY_PATH="/w/halla-scshelf2102/sbs/jboyd/SBS_OFFLINE/SBS-offline/:$LIBRARY_PATH"

alias analyzer="/w/halla-scshelf2102/sbs/jboyd/ANALYZER/install/bin/analyzer"

echo "-------------------------------"
echo 'working directory = '$PWD
echo 'OUT_DIR='$OUT_DIR
echo 'LOG_DIR='$LOG_DIR
echo 'DB_DIR='$DB_DIR

echo "Copying FARM_replay_gmn_mc.C to SWIF_JOB_WORK_DIR..." 
cp /w/halla-scshelf2102/sbs/jboyd/SBS_REPLAY/SBS-replay/replay/FARM_replay_gmn_mc.C $SWIF_JOB_WORK_DIR
echo "---------------------"
echo "Copying /w/halla-scshelf2102/sbs/jboyd/custom_rootrc/.rootrc to SWIF_JOB_WORK_DIR"

# cp /w/halla-scshelf2102/sbs/jboyd/custom_rootrc/.rootrc $SWIF_JOB_WORK_DIR 
# cp /w/halla-scshelf2102/sbs/jboyd/custom_rootrc/.rootrc ./
# ls -a

digitizedFileNameBase=${digitizedFileName%.*}

echo "-------------------------------"
echo "-------------------------------"
echo "Starting replay process...."

echo "Executing following line: "
echo "analyzer -b -q '/w/halla-scshelf2102/sbs/jboyd/SBS_REPLAY/SBS-replay/replay/FARM_replay_gmn_mc.C+(\""${digitizedFileName%.*}"\", " ${kine} " )' "
analyzer -b -q '/w/halla-scshelf2102/sbs/jboyd/SBS_REPLAY/SBS-replay/replay/FARM_replay_gmn_mc.C+("'$digitizedFileNameBase'", 8 )'

ls -a

cp ./replayed*.root /volatile/halla/sbs/jboyd/simulation/out_dir/farm_sim/MC/SBS${kine}/replayed