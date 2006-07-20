# This script calculates basic F0 statistics from a LongSound object
# and plots all the F0 measurement points to the Picture window.
# The goal is to find the F0 distribution for a single speaker.
#
# This script is distributed under the GNU General Public License.
# Copyright Mietta Lennes 12.6.2002

form Basic F0 statistics from utterances in a LongSound object
	positive Minimum_pitch_(Hz) 50
	positive Maximum_pitch_(Hz) 400
	integer Time_step_(s) 0.01
	integer Tier 5
	integer left_Interval_range 0
	integer right_Interval_range 0
	integer Max_number_of_curves 0
	integer Criterion 0
	sentence Text 
	optionmenu Drawing_options 1
	option Add statistics to picture (mean, stdev, mode)
	option Do not add statistics yet, I want to add more data
	integer Add_percentage_of_values 70 (=percent of f0 points)
	integer Add_statistics_from_N_subregions 1
	boolean Calculate_mode 0
	positive Class_interval_(Hz) 5
	comment Save F0 point data to text files in directory:
	text file /home/lennes/tmp/data/
	boolean Remove_old_files 1 (not the Pitch files)
endform

if left_Interval_range < 0 or right_Interval_range < 0
	exit Interval numbers may only be zero or greater.
endif

if left_Interval_range > right_Interval_range
	exit The first interval must be greater or equal to the last interval to be analyzed!
endif

percent = add_percentage_of_values

echo F0 statistics from utterances in a LongSound object 
printline (on the basis of a corresponding TextGrid object)
printline

if time_step = 0
	time_step = 0.01
endif

dir$ = file$

if add_statistics_from_N_subregions > 1
	for part to add_statistics_from_N_subregions
		file'part'$ = file$ + "f0points_part'part'.txt"
		if remove_old_files = 1
			temp$ = file'part'$
			filedelete 'temp$'
		endif
	endfor
endif

labelfile$ = file$ + "f0utterances.txt"
file$ = file$ + "f0points_all.txt"

if fileReadable (file$) and remove_old_files = 1
	filedelete 'file$'
endif

# This is the "safety margin" around each utterance for Pitch calculation:
margin = 0.03

soundname$ = selected$ ("LongSound")
gridname$ = selected$ ("TextGrid")

select TextGrid 'gridname$'
	duration = Get finishing time
	count = 0
	numberOfUtterances = 0
	windowstart = 0
	windowend = 0
	frame = 0
	frames = 0
	time = 0
	f0 = 0

# Calculate number of utterances:

numberOfIntervals = Get number of intervals... tier
if left_Interval_range > numberOfIntervals
	exit The first interval is greater than the number of intervals in tier 'tier'.
endif
if right_Interval_range > numberOfIntervals
	right_Interval_range = numberOfIntervals
endif

for int to numberOfIntervals
	label$ = Get label of interval... tier int
	if label$ <> "" and label$ <> "xxx" and left$ (label$, 1) <> "."
		call FulfilsCriterion tier int criterion 'text$'
		if fulfils = 1
			if int >= left_Interval_range and (int <= right_Interval_range or right_Interval_range = 0)
				numberOfUtterances = numberOfUtterances + 1
			endif
		endif
	endif
endfor

if numberOfUtterances = 0
	exit No utterances were found in this interval range. Nothing was drawn.
endif

select LongSound 'soundname$'
#----------------------------
#Prepare the Picture window:

if remove_old_files = 1
	Erase all
endif

Font size... 16
id$ = left$ (gridname$, 4)
Text top... yes 'id$': F0 statistics

Font size... 12
Line width... 1
Helvetica
Plain line
Silver

#-------------------------------------------------------------------
count = 1
for interval to numberOfIntervals
	select TextGrid 'gridname$'
	label$ = Get label of interval... tier interval
	if label$ <> "" and label$ <> "xxx" and left$ (label$, 1) <> "."
		call FulfilsCriterion tier interval criterion 'text$'
		if fulfils = 1
			if interval >= left_Interval_range and (interval <= right_Interval_range or right_Interval_range = 0)
				windowstart = Get starting point... tier interval
				windowstart = windowstart - margin
				windowend = Get end point... tier interval
				windowend = windowend + margin
				if windowend > duration
					windowend = duration
				endif
				select LongSound 'soundname$'
				Extract part... windowstart windowend yes
				windowname$ = "'gridname$'_'interval'"
				Rename... 'windowname$'
				#-------------------------------------------------------
				# CALCULATE F0
				pitchfile$ = dir$ + "'gridname$'_'interval'.Pitch"
				if fileReadable (pitchfile$)
					Read from file... 'pitchfile$'
				else
					To Pitch... time_step minimum_pitch maximum_pitch
					Write to text file... 'pitchfile$'
				endif
				Speckle... 0 0 0 maximum_pitch no
				if count = 1
					Draw inner box
					Marks left every... 1 100 yes yes yes
					Marks left every... 1 10 no yes no
					Font size... 14
					Text left... yes F0 (Hz)
					Text bottom... yes Relative time within each interval
					Font size... 12
				endif
				numberOfFrames = Get number of frames
				time = windowend - windowstart
				#----------------------------------------------------------
				# Loop through all frames in the Pitch object:
				select Pitch 'windowname$'
				partsize = time / add_statistics_from_N_subregions
				for iframe to numberOfFrames
					f0 = Get value in frame... iframe Hertz
					if f0 <> undefined
						fileappend 'file$' 'f0''newline$'
						if add_statistics_from_N_subregions > 1
							timepoint = Get time from frame... iframe
							for part to add_statistics_from_N_subregions
								if timepoint < (windowstart + (part * partsize)) and timepoint > (windowstart + ((part - 1) * partsize))
									partfile$ = "file'part'$"
									partfile$ = 'partfile$'
									fileappend 'partfile$' 'f0''newline$'
								endif
							endfor
						endif
					endif
				endfor
				#-------------------------------------------------------------
				select Sound 'windowname$'
				Remove
				select Pitch 'windowname$'
				Remove
				count = count + 1
				fileappend 'labelfile$' 'label$''newline$'
			endif
		endif
	endif
	if max_number_of_curves > 0 and count = max_number_of_curves
		interval = numberOfIntervals
	endif
endfor

if count = 0
	exit No utterances were found in the interval range. Nothing was drawn.
endif

One mark left... 0 yes yes no
One mark left... maximum_pitch yes yes no

# Add some statistical information to the picture, if the user asked for it:

if drawing_options = 1 and add_statistics_from_N_subregions > 1
	for part to (add_statistics_from_N_subregions - 1)
		pos = windowstart + (part * partsize)
		One mark bottom... pos no yes yes
	endfor

	halfpartsize = partsize / 2
	pos = windowstart - halfpartsize

	for part to add_statistics_from_N_subregions
		summary'part'$ = "Region 'part': "
		partfile$ = "file'part'$"
		partfile$ = 'partfile$'
		Read Matrix from raw text file... 'partfile$'
		Rename... values
		To TableOfReal
		mean_f0_part'part' = Get column mean (index)... 1
		stdev_f0_part'part' = Get column stdev (index)... 1
		mean = mean_f0_part'part'
		stdev = stdev_f0_part'part'
		summary'part'$ = summary'part'$ + "mean 'mean'; stdev 'stdev'; "
		pos = pos + partsize
		One mark bottom... pos no no no 'part'		Paint circle (mm)... Blue pos mean_f0_part'part' 3
		ypos1 = mean_f0_part'part' + stdev_f0_part'part'
		ypos2 = mean_f0_part'part' - stdev_f0_part'part'
		Paint circle (mm)... Red pos ypos1 2
		Paint circle (mm)... Red pos ypos2 2
		if calculate_mode = 1
			call CalculateModes class_interval 1
			for x to nextnumberOfModes
				ypos = minimum_pitch + (nextmode'x' * class_interval) - (class_interval / 2)
				Paint circle (mm)... Grey pos ypos 2
				modemax = minimum_pitch + (nextmode'x' * class_interval)
				modemin = modemax - class_interval
			endfor
			for x to numberOfModes
				ypos = minimum_pitch + (mode'x' * class_interval) - (class_interval / 2)
				Paint circle (mm)... Black pos ypos 2
				modemax = minimum_pitch + (mode'x' * class_interval)
				modemin = modemax - class_interval
				summary'part'$ = summary'part'$ + "mode 'x': 'modemin' to 'modemax' Hz, "
			endfor
			summary'part'$ = summary'part'$ + "(class frequency N='mode', next class frequency N='nextmode')"
		endif
		Remove
		select Matrix values
		Remove
	endfor
endif

if drawing_options = 1 and count >= 1
	# Calculate overall mean and standard deviation
	Read Matrix from raw text file... 'file$'
	Rename... values
	To TableOfReal
	mean_f0 = Get column mean (index)... 1
	stdev_f0 = Get column stdev (index)... 1
	Sort by column... 1 0
	numberOfPoints = Get number of rows
	min_f0 = Get value... 1 1
	max_f0 = Get value... numberOfPoints 1
	range_f0 = max_f0 - min_f0
	if calculate_mode = 1
		call CalculateModes class_interval 1
	endif
	if percent > 0 and percent < 100
		call CalculateMajorityRange 1 percent majorityrangemin majorityrangemax
	endif
	Remove
	select Matrix values
	Remove

	# Add lines for overall mean and standard deviation
	Blue
	One mark left... mean_f0 no yes no
	One mark right... mean_f0 no yes no Mean='mean_f0:1'
	Draw line... windowstart mean_f0 windowend mean_f0
	Red
	stdevmax = mean_f0 + stdev_f0
	One mark left... stdevmax no yes no
	One mark right... stdevmax no yes no +stdev='stdevmax:1'
	Draw line... windowstart stdevmax windowend stdevmax
	stdevmin = mean_f0 - stdev_f0
	One mark left... stdevmin no yes no
	One mark right... stdevmin no yes no -stdev='stdevmin:1'
	Draw line... windowstart stdevmin windowend stdevmin
	if calculate_mode = 1
		for x to numberOfModes
			Black
			ypos = minimum_pitch + (mode'x' * class_interval) - (class_interval / 2)
			One mark left... ypos no yes no
			One mark right... ypos no yes no
			Draw line... windowstart ypos windowend ypos
		endfor
	endif
	Green
	One mark left... majorityrangemin  no yes no
	One mark right... majorityrangemax no yes no 'percent'\%
	Draw line... windowstart majorityrangemin windowend majorityrangemin
	Draw line... windowstart majorityrangemax windowend majorityrangemax
	Black
endif

#------- Add Info

resultfile$ = dir$ + "f0results_" + "'left_Interval_range'-'right_Interval_range'.txt"
resultpic$ = dir$ + "f0results_" + "'left_Interval_range'-'right_Interval_range'.prapic"
if fileReadable (resultfile$)
	filedelete 'resultfile$'
endif

printline 'count' utterances (or other intervals in tier 'tier') were analyzed.
printline Please see the text file 'resultfile$' for precise results!

fileappend 'resultfile$' 'count' utterances (or other intervals in tier 'tier') were analyzed.'newline$'
if right_Interval_range > 0
	fileappend 'resultfile$' Interval range analyzed: 'left_Interval_range'-'right_Interval_range'.'newline$'
endif

fileappend 'resultfile$' The resulting picture is saved in file 'resultpic$'.'newline$'

fileappend 'resultfile$' mean	'mean_f0''newline$'
fileappend 'resultfile$' stdev	'stdev_f0''newline$'
fileappend 'resultfile$' min	'min_f0''newline$'
fileappend 'resultfile$' max	'max_f0''newline$'
fileappend 'resultfile$' range	'range_f0''newline$'
if percent > 0 and percent < 100
	fileappend 'resultfile$' majority range minimum ('percent' %)	'majorityrangemin''newline$'
	fileappend 'resultfile$'  majority range maximum ('percent' %)	'majorityrangemax''newline$'
endif

fileappend 'resultfile$' The total number of Pitch points was 'numberOfPoints'.'newline$'
fileappend 'resultfile$' All Pitch points were saved to 'file$'.'newline$'
fileappend 'resultfile$' The labels of the analyzed intervals in tier 'tier' were saved to 'labelfile$'.'newline$'

fileappend 'resultfile$' The following Pitch analysis options were used:'newline$'
fileappend 'resultfile$' time step	'time_step' (= frame length in Pitch object)'newline$'
fileappend 'resultfile$' minimum pitch	'minimum_pitch''newline$'
fileappend 'resultfile$' maximum pitch	'maximum_pitch''newline$'

if calculate_mode = 1
	fileappend 'resultfile$' 'newline$'
	fileappend 'resultfile$' Mode was calculated (the results are shown in black in the picture).'newline$'
	fileappend 'resultfile$' Class interval for mode calculation was 'class_interval' Hz.'newline$'
endif

if add_statistics_from_N_subregions > 1
	fileappend 'resultfile$' Separate data were calculated and saved for 'add_statistics_from_N_subregions' subregions of each utterance.'newline$'
endif

if drawing_options = 1 and add_statistics_from_N_subregions > 1
	fileappend 'resultfile$' Statistics were calculated for 'add_statistics_from_N_subregions' subregions:'newline$'
	for region to add_statistics_from_N_subregions
		summary$ = "summary'region'$"
		summary$ = 'summary$'
		fileappend 'resultfile$' 'summary$''newline$'
	endfor
endif

if drawing_options = 1
	One mark right... 0 no no no N = 'count'
endif

Write to praat picture file... 'resultpic$'


#-------------------------
procedure FulfilsCriterion sel_tier sel_interval crittier crittext$

in_interval = 0

if crittier > 0
	tempstart1 = Get starting point... sel_tier sel_interval
	tempend1 = Get end point... sel_tier sel_interval
	midtime1 = (tempstart1 + tempend1) / 2

	tempcriterion = Get interval at time... crittier midtime1
	tempstart2 = Get starting point... crittier tempcriterion
	tempend2 = Get end point... crittier tempcriterion

	temp_label2$ = Get label of interval... crittier tempcriterion

	# if criterion text is empty, any interval label other than "" will be accepted
	if crittext$ = "" and temp_label2$ <> ""
		crittext$ = temp_label2$
	endif

	if tempstart2 <= tempstart1 and tempend2 >= tempend1
		in_interval = tempcriterion
	endif

	if temp_label2$ = crittext$ and tempstart2 <= tempstart1 and tempend2 >= tempend1
		fulfils = 1
	else
		fulfils = 0
	endif
else 
	fulfils = 1
endif

endproc

#-------------
procedure CalculateModes class_interval column

numberOfModes = 1
mode = 0
min = 1
max = 0
nextmode = 0

numberOfRows = Get number of rows

# Check minimum and maximum values from column
for row to numberOfRows
	value = Get value... row column
	if value < min or row = 1
		min = value
	endif
	if value > max or row = 1
		max = value
	endif
endfor

scale = max - min
numberOfClasses = ceiling (scale / class_interval)

# initialize class frequencies
for class to numberOfClasses
	class'class' = 0
endfor

# Classify values in column (count class frequencies)
low = min
for class to numberOfClasses
	high = low + class_interval
	for row to numberOfRows
		value = Get value... row column
		if value >= low and value < high
			class'class' = class'class' + 1
		endif
	endfor
	low = low + class_interval
endfor

# Check for modes
for class to numberOfClasses
	if class = 1
		mode = class'class'
		mode1 = class
	elsif class'class' > mode
		nextmode = mode
		for z to numberOfModes
			nextmode'z' = mode'z'
		endfor
		nextnumberOfModes = numberOfModes
		numberOfModes = 1
		mode = class'class'
		mode1 = class
	elsif class'class' = mode
		numberOfModes = numberOfModes + 1
		mode'numberOfModes' = class	
	endif	
endfor

# Result: 
# Variable 'mode' contains frequency for the mode class
# Variable 'nextmode' contains frequency for the class with the second highest frequency
# Variable numberOfModes contains the number of mode classes with equal frequency
# Variables from mode1 to mode'numberOfModes' contain class indexes for mode classes

endproc

#------

procedure CalculateMajorityRange col percent outputmin$ outputmax$
# Calculate the smallest possible range of values (around the median value) that
# covers 'percent' % of the values in the 'col' column of the TableOfReal.
# This procedure requires that a TableOfReal is selected.

	numberOfPoints = Get number of rows

	median = round (numberOfPoints / 2)
	valuenumber = ceiling (numberOfPoints / 100 * percent)

	currentlowrow = median
	currenthighrow = median
	value = Get value... median col
	values = 1
	minvalue = value
	maxvalue = value

	while values < valuenumber
		nextlowrow = currentlowrow - 1
		nexthighrow = currenthighrow + 1
		if nextlowrow >= 1
			newlowvalue = Get value... nextlowrow col
		endif
		if nexthighrow >= 1
			newhighvalue = Get value... nexthighrow col
		endif
		lowdifference = minvalue - newlowvalue
		highdifference = newhighvalue - maxvalue
		if lowdifference < highdifference	
			currentlowrow = currentlowrow - 1
			minvalue = newlowvalue
		else
			currenthighrow = currenthighrow + 1
			maxvalue = newhighvalue
		endif
		values = values + 1
	endwhile

	'outputmin$' = minvalue
	'outputmax$' = maxvalue

endproc
