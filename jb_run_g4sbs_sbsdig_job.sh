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

outputdir='/volatile/halla/sbs/jboyd/simulation/out_dir/farm_sim/MC/SBS'$kine/digitized_only

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
echo "Prepending 'digitized' to filname and copying to output directory: "
echo "Filename: "$digitizedfilename
echo ""
echo "Output directory:"
echo $outputdir
cp $SWIF_JOB_WORK_DIR/$iteratedFileName $outputdir/$digitizedfilename

echo ""
echo "-------------------------------"
echo "-------------------------------"

echo ""
echo ""
echo "Displaying output from ls -l:"
ls -l

echo "-------------------------------"
echo "-------------------------------"



echo "*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*"
echo "        Simulation and Digitization Complete"
echo "*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*"