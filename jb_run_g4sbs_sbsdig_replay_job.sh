#!/bin/bash

# ------------------------------------------------------------------------- #
# This script runs g4sbs simulation jobs.                                   #
# ---------                                                                 #
# J Boyd Aug 12, 2023                       #
# ---------                                                                 #

#SBATCH --partition=production
#SBATCH --account=halla
#SBATCH --mem-per-cpu=1500

g4sbsmacrofile=$1
g4sbsfilename=$2
numEvents=$3
jobNum=$4
kine=$5

outputdir='/volatile/halla/sbs/jboyd/simulation/out_dir/farm_sim/MC/SBS'$kine

# paths to necessary libraries (ONLY User specific part) ---- #
source /work/halla/sbs/jboyd/setup_jb_env.sh
export G4SBS=/work/halla/sbs/jboyd/mysim/install
source /work/halla/sbs/jboyd/mysim/bash_setup_g4sbs.sh
# ----------------------------------------------------------- #

ifarmworkdir=${PWD}
SWIF_JOB_WORK_DIR=$ifarmworkdir

echo -e 'Work directory = '$SWIF_JOB_WORK_DIR

# setup farm environments
source /site/12gev_phys/softenv.sh 2.5
module load gcc/9.2.0 
ldd $G4SBS/bin/g4sbs |& grep not

# Setup g4sbs specific environments
source $G4SBS/bin/g4sbs.sh

g4sbs $g4sbsmacrofile

echo "---------------------------------"
echo "G4SBS simulation macro completed... Job: " $jobNum
echo "---------------------------------"

fileBaseName=${g4sbsfilename%.*}
echo "Output file base name: " $fileBaseName
echo ""

iteratedFileName=$fileBaseName$jobNum'.root'

##MOVE the g4sbs file over to the volatile disk with a unique (iterated) filename
cp $SWIF_JOB_WORK_DIR/$g4sbsfilename $SWIF_JOB_WORK_DIR/$iteratedFileName

##Digitization
cp /work/halla/sbs/jboyd/jlab-HPC/jb_scripts/makeSBSDIGinput.sh $SWIF_JOB_WORK_DIR

echo "Creating sbsdig inputfile " 
$SWIF_JOB_WORK_DIR/makeSBSDIGinput.sh $iteratedFileName

echo "output from ls: " 
ls -l
source /work/halla/sbs/jboyd/digitization/install/bin/sbsdigenv.sh

alias sbsdig=/work/halla/sbs/jboyd/digitization/build/sbsdig

echo "Running digitizer on the G4SBS output in SWIF_JOB_WORK_DIR"
echo "-------------------------------"

sbsdig /work/halla/sbs/jboyd/digitization/install/db/db_gmn_conf_8gemmodules.dat ./sbsdigInputFile.txt $numEvents


echo "-------------------------------"
echo "Digitzation finished"
digitizedfilename='digitized_'$iteratedFileName

echo "" 
echo "Moving digitized file to prepend filename: "
echo $digitizedfilename
echo "output of ls -l before move and prepend:"
ls -l
echo "" 

mv $SWIF_JOB_WORK_DIR/$iteratedFileName $SWIF_JOB_WORK_DIR/$digitizedfilename
echo "-------------"
echo "Showing output of ls -l AFTER: "
ls -l
echo ""
echo "Copying digitized file over to digitized_only dir:"
echo "./"$digitizedfilename " to " $outputdir"/digitized_only/"

cp ./$digitizedfilename $outputdir/digitized_only/

echo "-------------------------------"
echo "-------------------------------"
echo "Starting replay process...."

source /work/halla/sbs/jboyd/ANALYZER/install/bin/setup.sh

echo "Sourcing SBS_OFFLINE: /work/halla/sbs/jboyd/SBS_OFFLINE/install/bin/sbsenv.sh"
source /work/halla/sbs/jboyd/SBS_OFFLINE/install/bin/sbsenv.sh
echo "sourcing Analyzer: /work/halla/sbs/jboyd/ANALYZER/install/bin/setup.sh"
source /work/halla/sbs/jboyd/ANALYZER/install/bin/setup.sh
echo "sourcing /work/halla/sbs/jboyd/SBS_OFFLINE/install/run_replay_here/MC/FARM_setup_MC_replay.sh"
source /work/halla/sbs/jboyd/SBS_OFFLINE/install/run_replay_here/MC/FARM_setup_MC_replay.sh


echo "Adding SBS-offline to the path directories...."
export PATH="/work/halla/sbs/jboyd/SBS_OFFLINE/SBS-offline/:$PATH"
export C_INCLUDE_PATH="/work/halla/sbs/jboyd/SBS_OFFLINE/SBS-offline/:$C_INCLUDE_PATH"
export CPLUS_INCLUDE_PATH="/work/halla/sbs/jboyd/SBS_OFFLINE/SBS-offline/:$CPLUS_INCLUDE_PATH"
export CPP_INCLUDE_PATH="/work/halla/sbs/jboyd/SBS_OFFLINE/SBS-offline/:$CPP_INCLUDE_PATH"
export C_PATH="/work/halla/sbs/jboyd/SBS_OFFLINE/SBS-offline/:$C_PATH"
export LIBRARY_PATH="/work/halla/sbs/jboyd/SBS_OFFLINE/SBS-offline/:$LIBRARY_PATH"

alias analyzer="/work/halla/sbs/jboyd/ANALYZER/install/bin/analyzer"

echo "-------------------------------"
echo 'working directory = '$PWD
echo 'OUT_DIR='$OUT_DIR
echo 'LOG_DIR='$LOG_DIR
echo 'DB_DIR='$DB_DIR

echo "-------------------------------"
echo "-------------------------------"
# echo "Replay file will generated in SWIF_JOB_WORK_DIR"

# echo "Executing following line: "
# echo "analyzer -b -q '/work/halla/sbs/jboyd/SBS_REPLAY/SBS-replay/replay/FARM_replay_gmn_mc.C+(\""${digitizedfilename%.*}"\", " $kine " )' "
# analyzer -b -q '/work/halla/sbs/jboyd/SBS_REPLAY/SBS-replay/replay/FARM_replay_gmn_mc.C+("'${digitizedfilename%.*}'", ' $kine ' )'

echo "Copying FARM_replay_gmn_mc.C to SWIF_JOB_WORK_DIR..." 
cp /work/halla/sbs/jboyd/SBS_REPLAY/SBS-replay/replay/FARM_replay_gmn_mc.C $SWIF_JOB_WORK_DIR
echo "---------------------"
echo "Copying /work/halla/sbs/jboyd/custom_rootrc/.rootrc to SWIF_JOB_WORK_DIR"

cp /work/halla/sbs/jboyd/custom_rootrc/.rootrc $SWIF_JOB_WORK_DIR 
cp /work/halla/sbs/jboyd/custom_rootrc/.rootrc ./
ls -a
source /site/12gev_phys/softenv.sh 2.6
root -l << EOF
gROOT->GetMacroPath();
.q
EOF

echo "Executing following line: "
echo "analyzer -b -q '/work/halla/sbs/jboyd/SBS_REPLAY/SBS-replay/replay/FARM_replay_gmn_mc.C+(\""${digitizedfilename%.*}"\", " ${kine} " )' "
analyzer -b -q "'/work/halla/sbs/jboyd/SBS_REPLAY/SBS-replay/replay/FARM_replay_gmn_mc.C+(\""${digitizedfilename%.*}"\", " ${kine} " )' "

echo "-------------------------------"
echo "-------------------------------"

echo "Replay finished and output sent to SWIF_JOB_WORK_DIR"

echo "-------------------------------"
echo "-------------------------------"

echo "Replayed filename should be: "
replayedfilename='replayed_'$digitizedfilename
echo ""
echo $replayedfilename
echo ""
echo "-------------"
echo "Showing output from ls -a: "
ls -l
echo ""
echo ""

echo "Copying replayed file to: " $outputdir

cp $SWIF_JOB_WORK_DIR/$replayedfilename $outputdir

echo "*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*"
echo "        Simulation, Digitization, and Replay Complete"
echo "*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*"