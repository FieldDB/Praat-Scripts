# This script will draw pitch curves from all sound files in a given directory to the
# same picture. A tabulated text file will be saved with data from each
# Pitch curve.
# 
# This script is distributed under the GNU General Public License.
# Copyright 2.10.2006 Mietta Lennes

######### This is where you can define various parameters for file paths, pitch extraction and drawing:

form Draw pitch curves from all sound files in a directory
	comment Sound file directory:
	text Sound_file_directory /home/lennes/tmp/
	sentence Sound_file_extension .aiff
	sentence Pitch_file_extension .Pitch
	boolean Normalize_time no
	optionmenu Frequency_scale_for_the_picture 1
	option Linear (Hertz)
	option Logarithmic
	option Semitones (re 100 Hz)
	option Mel
	option Erb
	optionmenu Draw_as 1
	option Pitch object, plain line
	option Pitch object, speckle
	option PitchTier object
	optionmenu Line_style 1
	option Switch colours between file groups
	option Switch line style (only Pitch, plain line)
	option Keep basic line style and colour for all groups and files
	boolean Smooth_pitch_curves no
	comment Pitch parameters:
	real Time_step 0.01
	real Default_minimum_pitch 75
	real Default_maximum_pitch 500
	comment Pitch parameter file (optional):
	text Pitch_parameter_file_(optional) 
	positive Minimum_pitch_for_drawing 50
	positive Maximum_pitch_for_drawing 400
	comment Output files:
	text Picture_file /home/lennes/tmp/pic.eps
	text Pitch_data_file /home/lennes/tmp/picdata.txt
endform

# The optional pitch parameter file should be in the format:
#groupcode	minimumpitch(Hz)	maximumpitch(Hz)
# E.g.,
#S1	75	500
#S2	120	300
# etc.

echo Drawing pitch curves for sound files in 'sound_file_directory$'...
printline

group_id$ = ""
# Here you can define where in the file name string the group code is given (file extension not included).
# You can also use this parameter to switch between different conditions, e.g., read/spontaneous speech.
# The example below will consider the first two characters of the filename as the group ID code.
# Edit and uncomment the next line, if you wish to use this option!
#group_id$ = "left$ (filename$, 2)"

# Pitch smoothing:
smoothing_by_bandwidth = 10

latestcondition$ = ""
conditions = 0
newcolour = 0
newstyle = 0
condition$ = ""

########## This is where the actual script begins

# Check whether the given files already exist:
if fileReadable (picture_file$)
	pause Older picture 'picture_file$' will be overwritten! Are you sure?
	printline Older picture file 'picture_file$' will be overwritten!
	printline
	filedelete 'picture_file$'
endif
if fileReadable (pitch_data_file$)
	pause Older data file 'pitch_data_file$' will be overwritten! Are you sure?
	printline Older data file 'pitch_data_file$' will be overwritten!
	printline
	filedelete 'pitch_data_file$'
	titleline$ = "File
		...	Duration (s)	"
	if frequency_scale_for_the_picture = 1
	titleline$ = titleline$ + "
		...	F0min (Hz)
		...	F0max (Hz)
		...	F0mean (Hz)
		...	F0median (Hz)
		...	F0stdev (Hz)"
	elsif frequency_scale_for_the_picture = 2
	titleline$ = titleline$ + "
		...	F0min (logHz)
		...	F0max (logHz)
		...	F0mean (logHz)
		...	F0median (logHz)
		...	F0stdev (logHz)"
	elsif frequency_scale_for_the_picture = 3
	titleline$ = titleline$ + "
		...	F0min (ST)
		...	F0max (ST)
		...	F0mean (ST)
		...	F0median (ST)
		...	F0stdev (ST)"
	elsif frequency_scale_for_the_picture = 4
	titleline$ = titleline$ + "
		...	F0min (mel)
		...	F0max (mel)
		...	F0mean (mel)
		...	F0median (mel)
		...	F0stdev (mel)"	
	else
	titleline$ = titleline$ + "
		...	F0min (ERB)
		...	F0max (ERB)
		...	F0mean (ERB)
		...	F0median (ERB)
		...	F0stdev (ERB)"
	endif
	titleline$ = titleline$ + "	MinPitchParam(Hz)	MaxPitchParam(Hz)	Drawing colour in 'picture_file$'"
	if group_id$ <> ""
		titleline$ = titleline$ + "	" + "Group"
	endif
	titleline$ = titleline$ + newline$
	fileappend 'pitch_data_file$' 'titleline$'
endif
if pitch_parameter_file$ <> ""
	if fileReadable (pitch_parameter_file$)
		Read Strings from raw text file... 'pitch_parameter_file$'
		Rename... parameters
		printline Individualized pitch parameters read from 'pitch_parameter_file$'.
	else
		printline Individualized pitch parameter file 'pitch_parameter_file$' was not found.
		printline    (Individual pitch parameters will not be used!)
	endif
endif

filenumber = 0
colour = 0
colour$ = "Black"
style = 0
maxduration = 0
minfreq = minimum_pitch_for_drawing
maxfreq = maximum_pitch_for_drawing
textpos1 = 4
textpos2 = 4.2

# Read lists of sound and Pitch files from the given directory:
Create Strings as file list... soundfiles 'sound_file_directory$'*'sound_file_extension$'
Sort
numberOfSoundFiles = Get number of strings

# Open any existing Pitch files and calculate Pitch from sounds without Pitch
select Strings soundfiles
for ifile to numberOfSoundFiles
	soundfilename$ = Get string... ifile
	filename$ = left$ (soundfilename$, (length (soundfilename$) - length (sound_file_extension$)))
	pitchfilepath$ = sound_file_directory$ + filename$ + pitch_file_extension$
	if fileReadable (pitchfilepath$)
		Read from file... 'pitchfilepath$'
		call PreAnalysis
	else
		Read from file... 'sound_file_directory$''soundfilename$'
		if group_id$ <> "" and pitch_parameter_file$ <> ""
			# Get pitch parameters:
			call GetPitchParameters
		else
			min_pitch = default_minimum_pitch
			max_pitch = default_maximum_pitch
		endif
		# Calculate and save pitch
		To Pitch... time_step min_pitch max_pitch
		Write to short text file... 'pitchfilepath$'
		Remove
		select Sound 'filename$'
		if normalize_time = 0
			call PreAnalysis
		endif
		Remove
	endif
	filenumber = filenumber + 1
	text'filenumber'$ = ""
	select Strings soundfiles
endfor

# Remove the sound file list:
Remove

# Build a new list of Pitch files:
Create Strings as file list... pitchfiles 'sound_file_directory$'*'pitch_file_extension$'
Sort
numberOfPitchFiles = Get number of strings

call PictureWindow

filenumber = 0
# make a second round through the files, now to draw everything as requested:
for ifile to numberOfPitchFiles
	pitchfilename$ = Get string... ifile
	Read from file... 'sound_file_directory$''pitchfilename$'
	dur = Get total duration
	filenumber = filenumber + 1
	filename$ = left$ (pitchfilename$, (length (pitchfilename$) - length (pitch_file_extension$)))
	if group_id$ <> ""
		call GetConditionFromFilename
	elsif line_style = 1
		colour = colour + 1
	elsif line_style = 2
		style = style + 1
	endif
	if group_id$ <> "" and pitch_parameter_file$ <> ""
		# Get pitch parameters:
		call GetPitchParameters
	else
		min_pitch = default_minimum_pitch
		max_pitch = default_maximum_pitch
	endif
	select Pitch 'filename$'
	call Drawing
	call SaveStatistics
	Remove
	select Strings pitchfiles
endfor
select Strings pitchfiles
Remove

if frequency_scale_for_the_picture = 1
	Text left... yes Pitch (Hz)
	Marks left every... 1 100 yes yes yes
elsif frequency_scale_for_the_picture = 2
	Text left... yes Pitch (log Hz)
	Marks left every... 1 100 yes yes yes
elsif frequency_scale_for_the_picture = 3
	Text left... yes Pitch (semitones re 100Hz)
	Marks left every... 1 5 yes yes yes
elsif frequency_scale_for_the_picture = 4
	Text left... yes Pitch (mel)
	Marks left every... 1 50 yes yes yes
elsif frequency_scale_for_the_picture = 5
	Text left... yes Pitch (erb)
	Marks left every... 1 50 yes yes yes
else
	Text left... yes Pitch (Hz)
	Marks left every... 1 100 yes yes yes
endif

if normalize_time = 1
	Text bottom... no Normalized time
else
	Text bottom... yes Time (seconds)
	Marks bottom every... 1.0 0.5 yes yes no
endif

Viewport... 0 7 0 textpos2
Write to EPS file... 'picture_file$'

printline 'filenumber' F0 curves were drawn and saved to 'picture_file$'.
printline Finished!


#--------------
procedure PreAnalysis

duration = Get duration
if duration > maxduration
	maxduration = duration
endif

endproc

#--------------
procedure Drawing

duration = Get total duration
# Get values in Hertz
if frequency_scale_for_the_picture = 1
	max = Get maximum... 0 0 Hertz None
	min = Get minimum... 0 0 Hertz None
	mean = Get mean... 0 0 Hertz
	median = Get quantile... 0 0 0.5 Hertz
	stdev = Get standard deviation... 0 0 Hertz
# Get values in log(Hertz)
elsif frequency_scale_for_the_picture = 2
	max = Get maximum... 0 0 logHertz None
	min = Get minimum... 0 0 logHertz None
	mean = Get mean... 0 0 logHertz
	median = Get quantile... 0 0 0.5 logHertz
	stdev = Get standard deviation... 0 0 Hertz
# Get values in semitones (re 100 Hz)
elsif frequency_scale_for_the_picture = 3
	max = Get maximum... 0 0 "semitones re 100 Hz" None
	min = Get minimum... 0 0 "semitones re 100 Hz" None
	mean = Get mean... 0 0 semitones re 100 Hz
	median = Get quantile... 0 0 0.5 semitones re 100 Hz
	stdev = Get standard deviation... 0 0 semitones
# Get values in mels:
elsif frequency_scale_for_the_picture = 4
	max = Get maximum... 0 0 mel None
	min = Get minimum... 0 0 mel None
	mean = Get mean... 0 0 mel
	median = Get quantile... 0 0 0.5 mel
	stdev = Get standard deviation... 0 0 mel
# Get values in ERB:
else
	max = Get maximum... 0 0 ERB None
	min = Get minimum... 0 0 ERB None
	mean = Get mean... 0 0 ERB
	median = Get quantile... 0 0 0.5 ERB
	stdev = Get standard deviation... 0 0 ERB
endif

if smooth_pitch_curves = 1
	Smooth... smoothing_by_bandwidth
endif

if normalize_time = 0
	xmax = maxduration
else
	xmax = Get total duration
endif

if line_style = 1
	call SwitchColours
elsif line_style = 2 and draw_as = 1
	call SwitchLineStyles
else
	Black
	Plain line
	Line width... 2
endif

# minfreq and maxfreq are the global minimum and maximum.

if draw_as = 1
	if frequency_scale_for_the_picture = 1
		Draw... 0 xmax minfreq maxfreq no
	elsif frequency_scale_for_the_picture = 2
		Draw logarithmic... 0 xmax minfreq maxfreq no
	elsif frequency_scale_for_the_picture = 3
		bottomfreq = hertzToSemitones (minfreq)
		topfreq = hertzToSemitones (maxfreq)
		Draw semitones... 0 xmax bottomfreq topfreq no
	elsif frequency_scale_for_the_picture = 4
		bottomfreq = hertzToMel (minfreq)
		topfreq = hertzToMel (maxfreq)
		Draw mel... 0 xmax bottomfreq topfreq no
	elsif frequency_scale_for_the_picture = 5
		bottomfreq = hertzToErb (minfreq)
		topfreq = hertzToErb (maxfreq)
		Draw erb... 0 xmax bottomfreq topfreq no
	endif
elsif draw_as = 2
	if frequency_scale_for_the_picture = 1
		Speckle... 0 xmax minfreq maxfreq no
	elsif frequency_scale_for_the_picture = 2
		Speckle logarithmic... 0 xmax minfreq maxfreq no
	elsif frequency_scale_for_the_picture = 3
		bottomfreq = hertzToSemitones (minfreq)
		topfreq = hertzToSemitones (maxfreq)
		Speckle semitones... 0 xmax bottomfreq topfreq no
	elsif frequency_scale_for_the_picture = 4
		bottomfreq = hertzToMel (minfreq)
		topfreq = hertzToMel (maxfreq)
		Speckle mel... 0 xmax bottomfreq topfreq no
	elsif frequency_scale_for_the_picture = 5
		bottomfreq = hertzToErb (minfreq)
		topfreq = hertzToErb (maxfreq)
		Speckle erb... 0 xmax bottomfreq topfreq no
	endif
else
	Down to PitchTier
	Draw... 0 xmax minfreq maxfreq no
	Remove
endif

Line width... 2

select Pitch 'filename$'

endproc

#------------

procedure SwitchColours

if colour = 1
	colour$ = "Black"
	Black
elsif colour = 2
	colour$ = "Red"
	Red
elsif colour = 3
	colour$ = "Green"
	Green
elsif colour = 4
	colour$ = "Blue"
	Blue
elsif colour = 5
	colour$ = "Magenta"
	Magenta
elsif colour = 6
	colour$ = "Cyan"
	Cyan
elsif colour = 7
	colour$ = "Maroon"
	Maroon
elsif colour = 8
	colour$ = "Navy"
	Navy
elsif colour = 9
	colour$ = "Lime"
	Lime
elsif colour = 10
	colour$ = "Teal"
	Teal
elsif colour = 11
	colour$ = "Purple"
	Purple
elsif colour = 12
	colour$ = "Olive"
	Olive
elsif colour = 13
	colour$ = "Silver"
	Silver
elsif colour = 14
	colour$ = "Grey"
	Grey
elsif colour = 15
	colour$ = "Yellow"
	Yellow
else
	colour = 1
	colour$ = "Black"
	Black
endif


endproc

#------------

procedure SwitchLineStyles

if style = 1
	Line width... 3
	Plain line
elsif style = 2
	Line width... 3
	Dashed line
elsif style = 3
	Line width... 4
	Plain line
elsif style = 4
	Line width... 4
	Dashed line
elsif style = 5
	Line width... 5
	Plain line
elsif style = 6
	Line width... 5
	Dashed line
else
	style = 1
	Line width... 3
	Plain line
endif


endproc

#---------------
procedure PictureWindow

Erase all
Viewport... 0 7 0 4
Black
Helvetica
Font size... 14
Plain line
Line width... 1
Draw inner box
Line width... 3

if smooth_pitch_curves = 1
	Text top... yes Comparison of smoothed pitch contours
else
	Text top... yes Comparison of pitch contours
endif

endproc



#-----------------
procedure SaveStatistics

	resultline$ = "'filename$'
		...	'dur'
		...	'min'
		...	'max'
		...	'mean'
		...	'median'
		...	'stdev'
		...	'min_pitch'
		...	'max_pitch'
		...	'colour$'"
	if group_id$ <> ""
		resultline$ = resultline$ + "	" + condition$ + newline$
	else
		resultline$ = resultline$ + newline$
	endif
	fileappend 'pitch_data_file$' 'resultline$'

	printline 'filename$': 'condition$' 'colour$' (dur 'dur' s)

endproc


#-----------------
procedure GetConditionFromFilename

	colour = 0
	style = 0
	condition$ = 'group_id$'
	if condition$ <> latestcondition$
		# check if the group was already encountered
		for cond to conditions
			if condition'cond'$ = condition$
				colour = colour'condition'
				style = style'condition'
			endif
		endfor
		#otherwise
		if colour = 0 and style = 0
			newcolour = newcolour + 1
			if newcolour = 16
				newcolour = 1
			endif
			newstyle = newstyle + 1
			if newstyle = 6
				newstyle = 1
			endif
			conditions = conditions + 1
			condition'conditions'$ = condition$
			colour'conditions' = newcolour
			style'conditions' = newstyle
			colour = newcolour
			style = newstyle
		endif
		if line_style = 1
			call SwitchColours
		elsif line_style = 2
			call SwitchLineStyles
		endif
	endif

	latestcondition$ = condition$
	
endproc


#-----------------
procedure GetPitchParameters

group$ = 'group_id$'
min_pitch = default_minimum_pitch
max_pitch = default_maximum_pitch

select Strings parameters
numberOfGroups = Get number of strings
for group to numberOfGroups
	groupline$ = Get string... group
	if left$ (groupline$, (index(groupline$,"	")-1)) = group$
		parameters$ = right$ (groupline$, length (groupline$) - index (groupline$, "	"))
		min_pitch$ = left$ (parameters$, (index (parameters$, "	") - 1))
		min_pitch = 'min_pitch$'
		max_pitch$ = right$ (parameters$, length (parameters$) - (index (parameters$, "	")))
		max_pitch = 'max_pitch$'
		group = numberOfGroups
	endif
endfor

endproc


