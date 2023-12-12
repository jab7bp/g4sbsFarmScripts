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
nOrp=$7

g4sbsmacroDirectory="/w/halla-scshelf2102/sbs/jboyd/mysim/install/scripts/farmSBS$kine"
echo "g4sbsmacrofile=$1"
echo "g4sbsfilename=$2"
echo "numEvents=$3"
echo "jobNum=$4"
echo "kine=$5"
echo "Number of events: " $numEventsKFormat
echo "n or p? -----  " $nOrp

ifarmworkdir=${PWD}
SWIF_JOB_WORK_DIR=$ifarmworkdir

echo -e 'Work directory = '$SWIF_JOB_WORK_DIR

simcFile="simc_qelas_dee${nOrp}_gmn_sbs${kine}_${numEventsKFormat}_FARM.root"

echo "Simc File to generate in SWIF_JOB_WORK_DIR: " $simcFile

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

echo "...."
echo "cd-ing to /work/halla/sbs/jboyd/simc/simc_gfortran Running ./run_simc_tree simc_qelas_dee${nOrp}_gmn_sbs8_${numEventsKFormat}_FARM"
cd /work/halla/sbs/jboyd/simc/simc_gfortran
echo "Sourcing 2.3 stuff..."
source /site/12gev_phys/2.3/Linux_CentOS7.2.1511-x86_64-gcc4.8.5/root/6.14.04/bin/thisroot.sh
command=simc_qelas_dee${nOrp}_gmn_sbs${kine}_${numEventsKFormat}_FARM
echo "Input .inp file: " $command ".inp"
echo "-----"
randNum=$RANDOM

###NEED TO DECLARE THE NAME OF THE HIST FILE THAT GETS AUTOMATICALLY GENERATED SO THAT WE CAN COPY IT AFTER RUNNING:
histFile="simc_qelas_dee${nOrp}_gmn_sbs${kine}_${numEventsKFormat}_FARM_${randNum}.hist"
histFileFinal=${fileBaseName}$jobNum'.hist'
histDirOrig="/w/halla-scshelf2102/sbs/jboyd/simc/simc_gfortran/outfiles"
histDirFinal="/lustre19/expphy/volatile/halla/sbs/jboyd/simulation/out_dir/MC_REPLAY_OUT_DIR/hist"



echo "To prevent the risk of overwriting this file for other farm jobs lets copy and append a random number."
echo "Random number: " $randNum

RandCommand=simc_qelas_dee${nOrp}_gmn_sbs${kine}_${numEventsKFormat}_FARM_$randNum
RandCommandFile=$RandCommand.inp

echo "New Random Number .inp file: " $RandCommandFile
echo "Look in infiles directory: "
ls -lthr ./infiles/
echo "cp ./infiles/$command.inp ./infiles/$RandCommandFile"
cp ./infiles/$command.inp ./infiles/$RandCommandFile
echo "Should see the new random number .INP file:"
ls /work/halla/sbs/jboyd/simc/simc_gfortran/infiles -lthr

infilesDir=$PWD

RandCommandRootFile=$RandCommand.root

source /site/12gev_phys/2.3/Linux_CentOS7.2.1511-x86_64-gcc4.8.5/root/6.14.04/bin/thisroot.sh
echo "Running command: ./run_simc_tree " $RandCommand " in while loop until the output is created..."

counter=0

while [ ! -f "/work/halla/sbs/jboyd/simc/simc_gfortran/worksim/$RandCommandRootFile" ]; do
	if [[ counter -eq 15 ]]; then
		echo "Maximum tries to create simc rootfile reached: 15"
		rm ./infiles/$RandCommandFile
		echo "Removing ./infiles/"$RandCommandFile
		exit
	fi
	let counter=counter+1
	echo "Attempt at creating simc rootfile: " $counter

	source /site/12gev_phys/2.3/Linux_CentOS7.2.1511-x86_64-gcc4.8.5/root/6.14.04/bin/thisroot.sh

	./run_simc_tree $RandCommand
	if [ ! -f "/work/halla/sbs/jboyd/simc/simc_gfortran/worksim/$RandCommandRootFile" ]; then
		echo "Attempt failed.... trying again."
		bash
		source /site/12gev_phys/softenv.sh 2.5
		cd /work/halla/sbs/jboyd/simc/simc_gfortran/
		source /site/12gev_phys/2.3/Linux_CentOS7.2.1511-x86_64-gcc4.8.5/root/6.14.04/bin/thisroot.sh
	fi
done

if [ -f "/work/halla/sbs/jboyd/simc/simc_gfortran/worksim/$RandCommandRootFile" ]; then
	echo "Successfully created simc rootfile! Moving on....."
else
	echo "*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&"
	echo "Could not create simc rootfile. Ending script now....."
	echo "*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&"
	echo "Removing ./infiles/"$RandCommandFile
	rm ./infiles/$RandCommandFile
	exit
fi

echo "----*******-----"
echo "Removing newly created .inp since we done with it..." 
rm ./infiles/$RandCommandFile
echo "removed"
echo "----*******-----"
echo "----*******-----"

echo "Running ls worksim/*RandCommandRootFile*.... for kine " ${kine}
ls /work/halla/sbs/jboyd/simc/simc_gfortran/worksim/simc_qelas_deep_gmn_sbs${kine}* -lthr
echo "Random Command ROOT file: " $RandCommandRootFile
echo "Let's move it to SWIF_JOB_WORK_DIR"

# mv /w/halla-scshelf2102/sbs/jboyd/simc/simc_gfortran/worksim/worksim/${RandCommandRootFile} $SWIF_JOB_WORK_DIR
echo ""
echo "Done running that. Now lets move that to SWIF_JOB_WORK_DIR"
echo "BEFORE MOVE"
ls /work/halla/sbs/jboyd/simc/simc_gfortran/worksim/${RandCommand}* -lthr
# echo "Command file: " $commandFile
mv /work/halla//sbs/jboyd/simc/simc_gfortran/worksim/${RandCommandRootFile} $SWIF_JOB_WORK_DIR/$simcFile

echo "--------------------"
echo "cd-ing back to SWIF_JOB_WORK_DIR..."
cd $SWIF_JOB_WORK_DIR

echo "copying simc File /work/halla/sbs/jboyd/simc/simc_gfortran/worksim/worksim/$RandCommandRootFile to ./ as $simcFile" 
cp /work/halla/sbs/jboyd/simc/simc_gfortran/worksim/$RandCommandRootFile ./$simcFile

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
echo "Looking for SIMC file: " $simcFile " and for CSV file"
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

echo "-------------------------------"
echo "-------------------------------"
echo "Attempting to move hist file from: "

histOrigFileToMove="${histDirOrig}/${histFile}"
histFinalFileMoved="${histDirFinal}/${histFileFinal}"

echo $histOrigFileToMove
echo ""
echo "to: " $histFinalFileMoved

mv $histOrigFileToMove $histFinalFileMoved 
echo "-------------------------------"
echo "-------------------------------"

# echo "Showing contents of final hist dir:" 
# ls -lthr $histDirFinal
echo "-------------------------------"
echo "-------------------------------"

echo ""
echo "-------------------------------"
echo "-------------------------------"

echo "Replaying digitized file: " $digitizedfilename_base

echo "cd-ing to replay folder...." 

cd /work/halla/sbs/jboyd/SBS_OFFLINE/install/run_replay_here/MC/

echo "sourcing: /work/halla/sbs/jboyd/SBS_OFFLINE/install/run_replay_here/MC/FARM_setup_MC_replay.sh"

source ./FARM_setup_MC_replay.sh

echo "Submitting command: ./FARM_SIMC_run-MC_replay.sh " $jobNum $kine $digitizedfilename_base

./FARM_SIMC_run-MC_replay.sh $jobNum $kine $digitizedfilename_base

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


# cp $SWIF_JOB_WORK_DIR/$iteratedCSV /lustre19/expphy/volatile/halla/sbs/jboyd/simulation/out_dir/MC_REPLAY_OUT_DIR/csv

# echo "REMOVING files..."
# echo ""
# echo "$infilesDir/infiles/$RandCommandFile...."
# rm -f $infilesDir/infiles/$RandCommandFile
# echo ""
# echo "$infilesDir/worksim/$RandCommandRootFile"
# rm -f $infilesDir/worksim/$RandCommandRootFile

# digitizedReplayedFilename=$outputdir'/'$digitizedfilename_base$jobNum'.root'

# mv $digitizedReplayedFilename /lustre19/expphy/volatile/halla/sbs/jboyd/simulation/out_dir/MC_REPLAY_DIR/'replayed_'$digitizedReplayedFilename

echo "*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*"
echo "        Simulation and Digitization Complete"
echo "*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*"