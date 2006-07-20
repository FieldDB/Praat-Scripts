# With this script you can browse sound and TextGrid files that are located
# in the same directory as this script.
#
# This script is distributed under the GNU General Public License.
# Copyright 27.3.2002 Mietta Lennes
#

form Browse sound files together with the corresponding TextGrid files
choice Location_of_the_files 1
button The files are in the same directory as this script
button The files are in the following subdirectories:
comment Subdirectory of the TextGrid files:
text grid_directory textgrids
comment Subdirectory of the sound files:
text sound_directory sounds
choice Open_sound_files_as 1
button Sound objects
button LongSound objects (for very long sound files)
endform

filepair = 0
echo Looking for matching files...

if location_of_the_files = 1
	sound_directory$ = ""
	grid_directory$ = ""
endif


# Check the contents of the user-specified directory and open appropriate Sound and TextGrid pairs:
Create Strings as file list... grids 'grid_directory$'*
numberOfGrids = Get number of strings
Create Strings as file list... sounds 'sound_directory$'*
numberOfSounds = Get number of strings
for gridfile to numberOfGrids
	select Strings grids
	gridfilename$ = Get string... gridfile
		if right$ (gridfilename$, 9) = ".textgrid" or right$ (gridfilename$, 9) = ".TextGrid"  or right$ (gridfilename$, 9) = ".TEXTGRID"
			# if a textgrid file was found, check if there is a corresponding sound file:
			filename$ = left$ (gridfilename$, (length (gridfilename$) - 9))
			for soundfile to numberOfSounds
				select Strings sounds
				soundfilename$ = Get string... soundfile
				# check if the left part of the filename is identical to left part of textgrid and if the extension is wav or aif
				if left$ (soundfilename$, (length (filename$))) = filename$ and (right$ (soundfilename$, (length (soundfilename$) - length (filename$))) = ".wav" or right$ (soundfilename$, (length (soundfilename$) - length (filename$))) = ".WAV" or right$ (soundfilename$, (length (soundfilename$) - length (filename$))) = ".aif" or right$ (soundfilename$, 5) = ".aiff" or right$ (soundfilename$, (length (soundfilename$) - length (filename$))) = ".AIF" or right$ (soundfilename$, (length (soundfilename$) - length (filename$))) = ".AIFF")
					# open both files if they match
					if open_sound_files_as = 1
						Read from file... 'sound_directory$''soundfilename$'
					else
						Open long sound file... 'sound_directory$''soundfilename$'
					endif
					gridfilename$ = grid_directory$ + gridfilename$
					Read from file... "'gridfilename$'"
					filepair = filepair + 1
					if open_sound_files_as = 1
						printline Opened Sound and TextGrid... 'filename$'
					else
						printline Opened LongSound and TextGrid... 'filename$'
					endif
					# Let the user view the sound and textgrid objects:
					if open_sound_files_as = 1
						select Sound 'filename$'
						plus TextGrid 'filename$'
						Edit
					else
						select LongSound 'filename$'
						plus TextGrid 'filename$'
						View
					endif
					pause Continue to the next pair of files?
					editor
					if open_sound_files_as = 1
						select Sound 'filename$'
						plus TextGrid 'filename$'
					else
						select LongSound 'filename$'
						plus TextGrid 'filename$'
					endif
					Remove
					select Strings list
				endif
			endfor
		endif
endfor

select Strings grids
Remove
select Strings sounds
Remove

printline 'filepair' file pairs were found and opened.
