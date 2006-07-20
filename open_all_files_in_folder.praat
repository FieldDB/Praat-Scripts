# This script will open all the files in a given folder.
# All the files must be recognized by Praat (either sound files
# such as AIFF or WAV or Praat analysis files like TextGrid).
# 
# This script is distributed undr the GNU General Public License.
# Copyright 11.3.2002 Mietta Lennes

form Open all files in directory
  sentence Directory ../tmp/
endform

Create Strings as file list... list 'directory$'*
numberOfFiles = Get number of strings
for ifile to numberOfFiles
	filename$ = Get string... ifile
		# You can add some filename extensions that you want to be excluded to the next line.
		if right$ (filename$, 4) <> ".doc" and right$ (filename$, 4) <> ".xls" and right$ (filename$, 4) <> ".XLS" and right$ (filename$, 4) <> ".TXT" and right$ (filename$, 4) <> ".txt" and right$ (filename$, 4) <> ".dat" and right$ (filename$, 4) <> ".DAT"
			Read from file... 'directory$''filename$'
		endif
	select Strings list
endfor
select Strings list
Remove




