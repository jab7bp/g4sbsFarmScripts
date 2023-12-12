#!/bin/bash

# ------------------------------------------------------------------------- #
# This script runs g4sbs simulation jobs.                                   #
# ---------                                                                 #
# J Boyd Aug 12, 2023                       #
# ---------                                                                 #

#SBATCH --partition=production
#SBATCH --account=halla
#SBATCH --mem-per-cpu=1500
#SBATCH --time=24:00:00

g4sbsmacrofile=$1
g4sbsfilename=$2
numEvents=$3
jobNum=$4
kine=$5
numEventsKFormat=$6

g4sbsmacroDirectory="/w/halla-scshelf2102/sbs/jboyd/mysim/install/scripts/farmSBS$kine"
echo "g4sbsmacrofile=$1"
echo "g4sbsfilename=$2"
echo "numEvents=$3"
echo "jobNum=$4"
echo "kine=$5"
echo "Number of events: " $numEventsKFormat
echo "Inelastic BG" 

ifarmworkdir=${PWD}
SWIF_JOB_WORK_DIR=$ifarmworkdir

echo -e 'Work directory = '$SWIF_JOB_WORK_DIR

fileBaseName=${g4sbsfilename%.*}
echo "Output file base name: " $fileBaseName
echo ""

runDirCSV='/w/halla-scshelf2102/sbs/jboyd/jlab-HPC/jb_scripts/'${fileBaseName}'.csv'

iteratedCSV=${fileBaseName}$jobNum'.csv'

csvfile=$SWIF_JOB_WORK_DIR/${fileBaseName}'.csv'
# echo "" >> $csvfile
# echo "--------------------"
# echo "CSV file: " $csvfile
# echo "Should be in SWIF_JOB_WORK_DIR:" 
# ls -lthr

# cp /work/halla/sbs/jboyd/jlab-HPC/jb_scripts/$csvfile $SWIF_JOB_WORK_DIR

ls -a
echo "------"
source /site/12gev_phys/softenv.sh 2.5

outputdir='/lustre19/expphy/volatile/halla/sbs/jboyd/simulation/out_dir/MC_OUT_DIR'

# paths to necessary libraries (ONLY User specific part) ---- #
source /work/halla/sbs/jboyd/setup_jb_env.sh
export G4SBS=/work/halla/sbs/jboyd/mysim/install
source /work/halla/sbs/jboyd/mysim/bash_setup_g4sbs.sh
# ----------------------------------------------------------- #

# setup farm environments
source /site/12gev_phys/softenv.sh 2.5

ldd $G4SBS/bin/g4sbs |& grep not
echo "Before simulation we should try and move CSV file from run_script_folder to SWIF_DIR"
echo "Copying runDirCSV: " $runDirCSV
cp $runDirCSV $SWIF_JOB_WORK_DIR

echo "----------------------------"
echo "Before running g4sbs lets see where we are and what is in our directory: "
echo "PWD: " $PWD
echo ""

echo "ls -lthra "
ls -lthra
echo ""
echo "SWIF_JOB_WORK_DIR: " $SWIF_JOB_WORK_DIR

# Setup g4sbs specific environments
source $G4SBS/bin/g4sbs.sh

echo "Running g4sbs on : " $g4sbsmacrofile
g4sbs $g4sbsmacrofile

echo "---------------------------------"
echo "G4SBS simulation macro completed... Job: " $jobNum
echo "---------------------------------"

echo "Should have a written csv file in SWIF_JOB_WORK_DIR."
echo "Lets copy it to the CSV outdir:"

echo " Showing contents of SWIF_JOB_WORK_DIR: " 
ls -lthr

echo "Should include this csv file: " $fileBaseName ".csv"

echo "Copying CSV file: " $csvfile
echo "to Sim_out dir with an iterated appendation: " $iteratedCSV

cp $csvfile /lustre19/expphy/volatile/halla/sbs/jboyd/simulation/out_dir/MC_REPLAY_OUT_DIR/csv/$iteratedCSV

###----------------------------------------------------

iteratedFileName=$fileBaseName$jobNum'.root'

##MOVE the g4sbs file over to the volatile disk with a unique (iterated) filename
preMoveFile="${SWIF_JOB_WORK_DIR}/${g4sbsfilename}"
postMoveFile="${SWIF_JOB_WORK_DIR}/${iteratedFileName}"

echo "Copying g4sbsoutput with iterated job number: " 
echo "g4sbsfilename: " $preMoveFile
echo "iterated filename: " $postMoveFile
cp $preMoveFile $postMoveFile

echo ""
echo ""
echo "Copying iterated filename to MC_OUT_nonDIG director: "
mc_OUT_nonDIG_dir='/lustre19/expphy/volatile/halla/sbs/jboyd/simulation/out_dir/MC_OUT_nonDIG'
echo "/lustre19/expphy/volatile/halla/sbs/jboyd/simulation/out_dir/MC_OUT_nonDIG"
cp $postMoveFile /lustre19/expphy/volatile/halla/sbs/jboyd/simulation/out_dir/MC_OUT_nonDIG/

##Digitization
cp /work/halla/sbs/jboyd/jlab-HPC/jb_scripts/makeSBSDIGinput.sh $SWIF_JOB_WORK_DIR

echo "Creating sbsdig inputfile " 
$SWIF_JOB_WORK_DIR/makeSBSDIGinput.sh $iteratedFileName

echo "output from ls: " 
ls -lthr
source /work/halla/sbs/jboyd/digitization/install/bin/sbsdigenv.sh

alias sbsdig=/work/halla/sbs/jboyd/digitization/build/sbsdig

echo "Running digitizer on the G4SBS output in SWIF_JOB_WORK_DIR"
echo "-------------------------------"

if [[ kine -eq 4 ]]; then
    echo "---- Kinematic 4 ----"
    echo "using: db_gmn_conf_12gemmodules.dat"
	sbsdig /work/halla/sbs/jboyd/digitization/install/db/db_gmn_conf_12gemmodules.dat ./sbsdigInputFile.txt $numEvents
	echo "---- Kinematic 4 ----"
fi

if [[ kine -eq 8 ]]; then
    echo "---- Kinematic 8 ----"
    echo "using: db_gmn_conf_8gemmodules.dat"
	sbsdig /work/halla/sbs/jboyd/digitization/install/db/db_gmn_conf_8gemmodules.dat ./sbsdigInputFile.txt $numEvents
	echo "---- Kinematic 8 ----"
fi

if [[ kine -eq 9 ]]; then
    echo "---- Kinematic 9 ----"
    echo "using: db_gmn_conf_8gemmodules.dat"
	sbsdig /work/halla/sbs/jboyd/digitization/install/db/db_gmn_conf_8gemmodules.dat ./sbsdigInputFile.txt $numEvents
	echo "---- Kinematic 9 ----"
fi

if [[ kine -eq 14 ]]; then
    echo "---- Kinematic 9 ----"
    echo "using: db_gmn_conf_8gemmodules.dat"
	sbsdig /work/halla/sbs/jboyd/digitization/install/db/db_gmn_conf_8gemmodules.dat ./sbsdigInputFile.txt $numEvents
	echo "---- Kinematic 9 ----"
fi

echo "-------------------------------"
echo "Digitzation finished"
digitizedfilename='digitized_'$iteratedFileName
digitizedfilename_base='digitized_'$fileBaseName

echo "" 
echo "Prepending 'digitized' to filename and copying to output directory: "
echo "Filename: "$digitizedfilename
echo ""
echo "Output directory:"
echo $outputdir
itPreMoveFile="${SWIF_JOB_WORK_DIR}/${iteratedFileName}"
itPostMoveFile="${SWIF_JOB_WORK_DIR}/${digitizedfilename}"
cp $itPreMoveFile $itPostMoveFile

ls -l
echo "Copying iterated file name to output dir:"
echo $itPreMoveFile
echo "to: " 
echo $itOutPostMoveFile
itOutPostMoveFile="${outputdir}/${digitizedfilename}"

cp $itPreMoveFile $itOutPostMoveFile

echo ""
echo "-------------------------------"
echo "-------------------------------"

echo "Replaying digitized file: " $digitizedfilename_base

echo "cd-ing to replay folder...." 

cd /work/halla/sbs/jboyd/SBS_OFFLINE/install/run_replay_here/MC/

echo "sourcing: /work/halla/sbs/jboyd/SBS_OFFLINE/install/run_replay_here/MC/FARM_setup_MC_replay.sh"

source /work/halla/sbs/jboyd/SBS_OFFLINE/install/run_replay_here/MC/FARM_setup_MC_replay.sh

echo "Submitting command: /work/halla/sbs/jboyd/SBS_OFFLINE/install/run_replay_here/MC/FARM_G4SBS_run-MC-replay.sh " $jobNum $kine $digitizedfilename_base

/work/halla/sbs/jboyd/SBS_OFFLINE/install/run_replay_here/MC/FARM_G4SBS_run-MC_replay.sh $jobNum $kine $digitizedfilename_base

echo ""
echo ""
echo "Displaying output from ls -l:"
ls -l

echo "-------------------------------"
echo "-------------------------------"

finalReplayFile="/lustre19/expphy/volatile/halla/sbs/jboyd/simulation/out_dir/MC_REPLAY_OUT_DIR/replayed_${digitizedfilename_base}${jobNum}.root"

echo "If successful we should have the final replayed file: "
$finalReplayFile

echo "-------------------------------"
echo "-------------------------------"

echo "Checking if it exist:"

if [ -e "$finalReplayFile" ]; then
    echo "Final Replay File exists."
    echo $finalReplayFile
    # Add actions to perform when the file exists
    echo "-------------------------------"
	echo "-------------------------------"

else
	# Add actions to perform when the file doesn't exist
    echo "Final Replay File does not exist."
    echo $finalReplayFile
    echo "-------------------------------"
	echo "-------------------------------"
	echo " PROBABLY FAILED.............." 
	echo "Error message: $(strerror)" >&2
    exit 1  # Exit the script with an error code (1 in this case)

fi



echo "*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*"
echo "        Simulation and Digitization Complete"
echo "*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*"