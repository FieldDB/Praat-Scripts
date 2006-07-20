# This script will read simple text files that contain information about 
# the segmentations of the corresponding sound files and import the segment boundaries and labels
# to new TextGrid objects, which will be saved in the same directory.
# The text files should have the format: 
# end point of seg1 - space - segment label - line break.
# The segments must be ordered according to time points.
#
# NB: If you have text files where the numbers are the starting points of segments,
# please use the script called make_textgrid_from_segment_data.praat instead!
# 
# This script is distributed under the GNU General Public License.
# Copyright 30.6.2003 Mietta Lennes

form Make TextGrids for text and sound files
	sentence Directory ../tmp/
	sentence Sound_file_extension .wav
	sentence Text_file_extension .phn
endform

overwrite = 0

# Check the contents of the user-specified directory and open appropriate files:
Create Strings as file list... list 'directory$'*
numberOfFiles = Get number of strings
for soundfile to numberOfFiles
	soundfilename$ = Get string... soundfile
		if right$ (soundfilename$, (length (sound_file_extension$))) = sound_file_extension$
			# if a sound file was found, check if there is a corresponding text file:
			filename$ = left$ (soundfilename$, (length (soundfilename$) - (length (sound_file_extension$))))
			for textfile to numberOfFiles
				textfilename$ = Get string... textfile
				# check if the left part of the filename is identical to left part of sound filename
				if left$ (textfilename$, (length (filename$))) = filename$ and (right$ (textfilename$, (length (textfilename$) - length (filename$))) = text_file_extension$)
					# open both files if they match
					Read Strings from raw text file... 'directory$''textfilename$'
					Read from file... 'directory$''soundfilename$'
					call BuildTextGrid
					select Strings 'filename$'
					Remove
					select Strings list
				endif
			endfor
		endif
endfor

select Strings list
Remove

#-------------------
procedure BuildTextGrid

To TextGrid... segments
duration = Get duration

select Strings 'filename$'
numberOfSegments = Get number of strings

for segment from 1 to numberOfSegments
	select Strings 'filename$'
	string$ = Get string... segment
	end$ = left$ (string$, (index (string$, " ") - 1))
	end = 'end$'
	label$ = right$ (string$, (length (string$) - index (string$, " ")))
	select TextGrid 'filename$'
	Set interval text... 1 segment 'label$'
	if end <> 0 and end < duration
		Insert boundary... 1 end
	endif
endfor

gridfilename$ = "'directory$''filename$'.TextGrid"
if fileReadable (gridfilename$) and overwrite = 0
	pause There appear to be TextGrid files for the sound files in 'directory$'. Do you want to overwrite them with new TextGrids?
	overwrite = 1
endif
Write to text file... 'gridfilename$'

endproc
