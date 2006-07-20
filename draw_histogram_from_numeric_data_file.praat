# This script opens a text file containing one number per line and draws a histogram of the data.
# 
# This script is distributed under the GNU General Public License.
# Copyright 22.5.2003 Mietta Lennes

form Draw histogram from numeric data in a text file
   comment Give the path of the text file:
   text Input_file /home/lennes/durations.txt
   comment Save picture file as:
   text Output_file /home/lennes/durations.prapic
   comment Log file:
   text Logfile /home/lennes/log.txt
   sentence Title Distribution
   sentence X_axis_label  
   real Bin_size 0.01
   real Minimum_value 0
   real Maximum_value 0.3
   real Maximum_frequency 400
   positive Multiply_numbers_by_factor 1000
endform

if fileReadable(input_file$)
   Read Matrix from raw text file... 'input_file$'
   Rename... temp
   call CalculateStatisticsFromSimpleMatrix
   select Matrix temp
   call DrawHistogramFromSimpleMatrix

   # Log some data
   fileappend 'logfile$'  (N = 'numberOfRows')'newline$'
   fileappend 'logfile$' File =	'input_file$''newline$'
   fileappend 'logfile$' Mean =	'mean''newline$'
   fileappend 'logfile$' Stdev =	'stdev''newline$'
   fileappend 'logfile$' Min =	'min''newline$'
   fileappend 'logfile$' Max =	'max''newline$'
endif


#-------
procedure CalculateStatisticsFromSimpleMatrix

	To TableOfReal
	mean = Get column mean (index)... 1
	stdev = Get column stdev (index)... 1

	# Calculate maximum and minimum

	numberOfRows = Get number of rows

	min = undefined
	next = 0
	while min = undefined and next < numberOfRows
		next = next + 1
		min = Get value... next 1
	endwhile

	max = undefined
	next = 0
	while max = undefined and next < numberOfRows
		next = next + 1
		max = Get value... next 1
	endwhile

	for row to numberOfRows
		val = Get value... row 1
		if val > max
			max = val
		endif
		if val < min
			min = val
		endif
	endfor

	range = max - min

	Remove

endproc

#--------
procedure DrawHistogramFromSimpleMatrix

Erase all
Font size... 14
Black

drawrange = maximum_value - minimum_value
binnumber = drawrange / bin_size

if binnumber <= 0
	binnumber = 1
endif

Draw distribution... 0 0 0 0 minimum_value maximum_value binnumber 0 maximum_frequency no
Draw inner box

One mark left... maximum_frequency yes yes no
One mark left... 0 yes yes no

Text top... yes 'title$'
Text top... no N = 'numberOfRows'
Text bottom... yes 'x_axis_label$'
x_axis_numbers_at = (bin_size * (binnumber / 5)) * multiply_numbers_by_factor
scaler = 1 / multiply_numbers_by_factor
Marks bottom every... scaler x_axis_numbers_at yes yes no
minimum_value_draw = minimum_value * multiply_numbers_by_factor
maximum_value_draw = maximum_value * multiply_numbers_by_factor
One mark bottom... minimum_value no yes yes 'minimum_value_draw'
One mark bottom... maximum_value no yes yes 'maximum_value_draw'

# Draw a dotted line at the mean
One mark bottom... mean no yes yes

# Draw dotted lines at stdev from mean
Red
stdevup = mean + stdev
stdevdown = mean - stdev
if stdevup >= minimum_value and stdevup <= maximum_value
   One mark bottom... stdevup no yes yes
endif
if stdevdown >= minimum_value and stdevdown <= maximum_value
   One mark bottom... stdevdown no yes yes
endif

Write to praat picture file... 'output_file$'

endproc
