# This script will convert a Windows Media Script .TXT file
# created by, e.g., SoundForge into a Praat TextGrid file, 
# which will be saved in the same directory.
# 
# This script is distributed under the GNU General Public License.
# Copyright 25.3.2004 Mietta Lennes

form Make TextGrid from SoundForge file 
	comment Give the full directory path to the .txt document:
	text file D:\Testit\litteraatiokoe.txt
	optionmenu Sound_file_type 1
	option .wav
	option .aif
endform

overwrite = 0
textfilename$ = file$
while index (textfilename$, "\") > 0
	textfilename$ = right$ (textfilename$, (length (textfilename$) - index (textfilename$, "\")))
endwhile
directory$ = left$ (file$, (length (file$) - length (textfilename$)))
echo Trying to convert file 'textfilename$'...
printline 'temp'

if fileReadable(file$) = 1
	filename$ = left$ (textfilename$, length (textfilename$) - 4) 
	soundfile$ = filename$ + sound_file_type$
	Open long sound file... 'directory$''soundfile$'
	duration = Get duration
	Read Strings from raw text file... 'directory$''textfilename$'
	call BuildTextGrid
	printline File 'textfilename$' was converted into 'gridfile$'.
	printline You can find both files in directory:
	printline    'directory$'
	printline
	printline If you want to see the result, select the LongSound and the TextGrid
	printline objects together and press Edit.
	select Strings 'filename$'
	Remove
else
	exit File 'file$' was not found! Please check the directory path.
endif

#-------------------
procedure BuildTextGrid

Create TextGrid... 0 duration segments
Rename... 'filename$'
select Strings 'filename$'
numberOfSegments = Get number of strings
numberOfSegments = numberOfSegments - 2
start_previous = -1
interval = 1

for segment from 2 to numberOfSegments
	select Strings 'filename$'
	string$ = Get string... segment
	label$ = right$ (string$, (length (string$) - index (string$, " ")))
	if index (label$, "Marker ") = 0
		start$ = left$ (string$, (index (string$, " ") - 1))
		start_hours$ = left$ (start$, 2)
		start_hours = 'start_hours$'
		start$ = right$ (start$, length (start$) - 3)
		start_minutes$ = left$ (start$, 2)
		start_minutes = 'start_minutes$'
		start$ = right$ (start$, length (start$) - 3)
		start_seconds$ = left$ (start$, 4)
		start_seconds = 'start_seconds$'
		start = (60 * 60 * start_hours) + (60 * start_minutes) + start_seconds
		select TextGrid 'filename$'
		if start_previous = start
			start = start + 0.05
		endif
		if start > 0
			Insert boundary... 1 start
			interval = interval + 1
			start_previous = start
		endif
		Set interval text... 1 interval 'label$'
	endif
endfor

printline 'interval' intervals were added to the TextGrid!

gridfilename$ = "'directory$''filename$'.TextGrid"
if fileReadable (gridfilename$) and overwrite = 0
	pause There appear to be TextGrid files for the sound files in 'directory$'. Do you want to overwrite them with new TextGrids?
	overwrite = 1
endif
Write to text file... 'gridfilename$'

endproc
