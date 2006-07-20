# This script will convert all AIFF audio files in a given directory into 
# 16 kHz WAV files (e.g., for automatic segmentation).
#
# This script is distributed under the GNU General Public License.
# Copyright 7.7.2005 Mietta Lennes

form Convert AIFF audio files to 16 kHz WAV
	comment Give the directory path with AIFF sound files:
	text aiffdir /home/lennes/bin/autoseg/
	boolean Delete_AIFF_files_after_conversion yes
	comment NB: Existing WAV files will be overwritten!
endform

Create Strings as file list... aifffiles 'aiffdir$'*.aif
numberOfFiles = Get number of strings

for file to numberOfFiles
	select Strings aifffiles
	file$ = Get string... file
	Read from file... 'aiffdir$''file$'
	soundname$ = selected$ ("Sound", 1)
	Rename... temp
	printline Converting file 'file$'...
	Resample... 16000 50
	Rename... 'soundname$'
	select Sound temp
	Remove
	select Sound 'soundname$'
	Write to WAV file... 'aiffdir$''soundname$'.wav
	if delete_AIFF_files_after_conversion = 1
		filedelete 'aiffdir$''file$'
	endif
	Remove
endfor
