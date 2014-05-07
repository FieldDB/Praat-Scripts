#!/bin/bash
echo "======================================================="

echo "renaming all files from mp3 to amr (as that is their real encoding)" 
#rename 's/mp3/amr/g' ./*


for i in $@

do
stem=${i%.mp3}      # Strip off the "amr" suffix. 
echo ==Converting mp3/amr $stem.amr to pcm/wav $stem.wav
#ffmpeg -y -i $stem.mp3 $stem.wav
done

echo "==Processing prosody with Praat"
#praat praat-script-syllable-nuclei-v2dir.praat -25 2 0.1 no /home/gina/Downloads/Archive/skeptoid  2>&1 | tee -a praatresults.csv


echo "==============================================================="
