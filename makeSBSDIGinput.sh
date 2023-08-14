#!/bin/bash
g4sbsfile=$1
fullg4sbsfilepath=$SWIF_JOB_WORK_DIR'/'$g4sbsfile

# Define the file name
filename=$SWIF_JOB_WORK_DIR'/sbsdigInputFile.txt'

# Text to write into the file
text=$fullg4sbsfilepath

# Create and write to the file
echo "$text" > "$filename"

echo "sbsdig input File "$filename
echo "" 
echo "created with the path: " $text