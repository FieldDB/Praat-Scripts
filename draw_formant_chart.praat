# Draw formant chart from segments in the sound files of a specified directory
# Sound files must be .aif or .wav
# TextGrid files must be .textgrid
#
# This script is distributed under the GNU General Public License.
# Copyright Mietta Lennes 13.3.2002

form Draw a vowel chart from the centre points of selected segments
comment Give the path of the directory containing the sound and TextGrid files:
text directory ../../sounds/
comment Which tier of the TextGrid files should be used for analysis?
integer Tier 1
comment Which segments should be analysed?
sentence Segment_label a
comment Where would you like to save the results?
text resultfile ../../results.txt
comment Formant analysis options
positive Time_step 0.01
integer Max_number_of_formants 5
positive Maximum_formant_(Hz) 5500 (= adult female)
positive Window_length_(s) 0.025
positive Preemphasis_from_(Hz) 50
choice Picture 1
button Erase the Picture window before drawing
button Overlay the old picture
endform

echo Files in directory 'directory$' will now be checked...
token = 0
filepair = 0
# this is a "safety margin" (in seconds) for formant analysis, in case the vowel segment is very short:
margin = 0.02

# Check if the result text file already exists. If it does, ask the user for permission to overwrite it.
if fileReadable (resultfile$) = 1
	pause The text file 'resultfile$' already exists. Do you want to continue and overwrite it?
endif
filedelete 'resultfile$'
# add the column titles to the text file:
titleline$ = "File	F1	F2'newline$'"
fileappend 'resultfile$' 'titleline$'

# Prepare the Picture window and draw a chart grid for formant analysis:
if picture = 1
	Erase all
endif
Viewport... 0 6 6.5 9
Font size... 18
Line width... 1
Viewport... 0 6 0 6
Axes... 100 900 600 2900
Text top... yes Formant chart
Text bottom... yes F_1 (Hz)
Text left... yes F_2 (Hz)
Font size... 14
Marks bottom every... 1 100 yes yes yes
Marks left every... 1 500 yes yes yes
Plain line

# Check the contents of the user-specified directory and open appropriate Sound and TextGrid pairs:
Create Strings as file list... list 'directory$'*
numberOfFiles = Get number of strings
for gridfile to numberOfFiles
	gridfilename$ = Get string... gridfile
		if right$ (gridfilename$, 9) = ".textgrid" or right$ (gridfilename$, 9) = ".TextGrid"  or right$ (gridfilename$, 9) = ".TEXTGRID"
			# if a textgrid file was found, check if there is a corresponding sound file:
			filename$ = left$ (gridfilename$, (length (gridfilename$) - 9))
			for soundfile to numberOfFiles
				soundfilename$ = Get string... soundfile
				# check if the left part of the filename is identical to left part of textgrid and if the extension is wav or aif
				if left$ (soundfilename$, (length (filename$))) = filename$ and (right$ (soundfilename$, (length (soundfilename$) - length (filename$))) = ".wav" or right$ (soundfilename$, (length (soundfilename$) - length (filename$))) = ".WAV" or right$ (soundfilename$, (length (soundfilename$) - length (filename$))) = ".aif" or right$ (soundfilename$, 5) = ".aiff" or right$ (soundfilename$, (length (soundfilename$) - length (filename$))) = ".AIF" or right$ (soundfilename$, (length (soundfilename$) - length (filename$))) = ".AIFF")
					# open both files if they match
					Read from file... 'directory$''soundfilename$'
					Read from file... 'directory$''gridfilename$'
					filepair = filepair + 1
					printline Opened Sound and TextGrid... 'filename$'
					call Measurements
					select Sound 'filename$'
					Remove
					select TextGrid 'filename$'
					Remove
					select Strings list
				endif
			endfor
		endif
endfor

select Strings list
Remove

printline 'filepair' matching pairs of Sound and TextGrid files were found. 
printline The (F1,F2) formant points of 'token' tokens of segment "'segment_label$'" were plotted on the chart. 
printline The results were saved in 'resultfile$'.


#----------------------
procedure Measurements

# look at the TextGrid object
select TextGrid 'filename$'
numberOfIntervals = Get number of intervals... tier
filestart = Get starting time
fileend = Get finishing time

for interval to numberOfIntervals

select TextGrid 'filename$'
label$ = Get label of interval... tier interval
if label$ = segment_label$
	token = token + 1
	segstart = Get starting point... tier interval
	segend = Get end point... tier interval

	# Create a window for analyses (possibly adding the "safety margin"):
	if (segstart - margin) > filestart
		windowstart = segstart - margin
	else
		windowstart = filestart
	endif	
	if (segend + margin) < fileend
		windowend = segend + margin
	else
		windowend = fileend
	endif	
	segduration = segend - segstart
	
	select Sound 'filename$'
	Extract part... windowstart windowend Rectangular 1 yes
	Rename... window
			
	# measure F1 and F2
	select Sound window
	To Formant (burg)... time_step max_number_of_formants maximum_formant window_length preemphasis_from
	Rename... formants
	# Note: the Track command only makes sense if you have a continuous vowel segment that
	# you think should have a fixed number of formants.
	Track... 3 550 1650 2750 3850 4950 1 1 1
	Rename... formanttracks
	measurepoint = (segstart + segend) / 2
	vowF1 = Get value at time... 1 measurepoint Hertz Linear
	vowF2 = Get value at time... 2 measurepoint Hertz Linear
	Viewport... 0 6 0 6
	Draw circle... vowF1 vowF2 27
	# if you want a vowel symbol drawn in the middle of each vowel circle, leave the next line untouched:
	Text... vowF1 Centre vowF2 Half 'segment_label$'
	# record the results to the text file:
	resultline$ = "'filename$'	'vowF1'	'vowF2''newline$'"
	fileappend 'resultfile$' 'resultline$'
	
	# remove the Sound object of the analysed segment
	select Sound window
	Remove
	# now we have to remove the original Formant object
	select Formant formants
	Remove
	# and also the second Formant object that was created by the Track command
	select Formant formanttracks
	Remove
endif

endfor

endproc

