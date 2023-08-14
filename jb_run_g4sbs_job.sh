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
jobNum=$3

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

fileBaseName=${g4sbsfilename%.*}
echo "Output file base name: " $fileBaseName
echo ""

iteratedFileName=$fileBaseName$jobNum'.root'

cp $SWIF_JOB_WORK_DIR/$g4sbsfilename /volatile/halla/sbs/jboyd/simulation/out_dir/farm_sim/MC/$iteratedFileName

