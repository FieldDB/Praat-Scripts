# This script reads Praat picture files (with the extension ".prapic")
# from a given directory and converts them into EPS files.
# 
# This script is distributed under the GNU General Public License.
# Copyright 22.5.2003 Mietta Lennes

form View Praat picture files
	comment Give the directory of the files:
	text directory /home/lennes/analysis/durations/
	sentence File_extension .prapic
endform

Create Strings as file list... files 'directory$'*'file_extension$'
numberOfFiles = Get number of strings

if numberOfFiles > 0

for file to numberOfFiles
	select Strings files
	file$ = Get string... file
	Erase all
	Read from praat picture file... 'directory$''file$'
        newname$ = left$ (file$, (length (file$) - 7)) + ".eps"
        if left$ (file$, 4) = "read"
           Viewport... 0 5 4 8
        else
           Viewport... 0 5 0 4
        endif
        Write to EPS file... 'directory$''newname$'
endfor

else
	exit No 'file_extension$' files in dir 'directory$'! 
endif
