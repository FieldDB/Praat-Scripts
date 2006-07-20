# This script will open all the files that have a user-specified file extension in a given folder.
# 
# This script is distributed under the GNU General Public License.
# Copyright 16.3.2002 Mietta Lennes

form Open all files in directory
	sentence Directory ../tmp/
	sentence File_extension .wav
endform

Create Strings as file list... list 'directory$'*'file_extension$'
numberOfFiles = Get number of strings
for ifile to numberOfFiles
	filename$ = Get string... ifile
			Read from file... 'directory$''filename$'
	select Strings list
endfor
select Strings list
Remove




