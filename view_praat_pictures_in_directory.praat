# This script reads Praat picture files (with the extension ".prapic")
# from a given directory and displays them one by one.
# The script will loop through the files forever until you stop it.
# 
# This script is distributed under the GNU General Public License.
# Copyright 31.1.2003 Mietta Lennes

form View Praat picture files
	comment Give the directory of the files:
	text directory /home/lennes/analysis/intas/f0/pics/
	sentence File_extension .prapic
endform

Create Strings as file list... files 'directory$'*'file_extension$'
Sort
numberOfFiles = Get number of strings

if numberOfFiles > 0

repeat

for file to numberOfFiles
	select Strings files
	file$ = Get string... file
	Erase all
	Read from praat picture file... 'directory$''file$'
	echo 'file$'
	pause Picture 'file'/'numberOfFiles': Show next picture?
endfor

until file = 0

else
	exit No 'file_extension$' files in dir 'directory$'! 
endif
