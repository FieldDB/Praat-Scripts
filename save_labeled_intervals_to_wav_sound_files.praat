# This script saves each interval in the selected IntervalTier of a TextGrid to a separate WAV sound file.
# The source sound must be a LongSound object, and both the TextGrid and 
# the LongSound must have identical names and they have to be selected 
# before running the script.
# Files are named with the corresponding interval labels (plus a running index number when necessary).
#
# NOTE: You have to take care yourself that the interval labels do not contain forbidden characters!!!!
# 
# This script is distributed under the GNU General Public License.
# Copyright 8.3.2002 Mietta Lennes
#

form Save intervals to small WAV sound files
	comment Which IntervalTier in this TextGrid would you like to process?
	integer Tier 1
	comment Starting and ending at which interval? 
	integer Start_from 1
	integer End_at_(0=last) 0
	boolean Exclude_empty_labels 1
	boolean Exclude_intervals_labeled_as_xxx 1
	boolean Exclude_intervals_starting_with_dot_(.) 1
	comment Give a small margin for the files if you like:
	positive Margin_(seconds) 0.15
	comment Give the folder where to save the sound files:
	sentence Folder /home/lennes/tmp/
	comment Give an optional prefix for all filenames:
	sentence Prefix TMP_
	comment Give an optional suffix for all filenames (.wav will be added anyway):
	sentence Suffix 
endform

gridname$ = selected$ ("TextGrid", 1)
soundname$ = selected$ ("LongSound", 1)
select TextGrid 'gridname$'
numberOfIntervals = Get number of intervals... tier
if start_from > numberOfIntervals
	exit There are not that many intervals in the IntervalTier!
endif
if end_at > numberOfIntervals
	end_at = numberOfIntervals
endif
if end_at = 0
	end_at = numberOfIntervals
endif

# Default values for variables
files = 0
intervalstart = 0
intervalend = 0
interval = 1
intname$ = ""
intervalfile$ = ""
endoffile = Get finishing time

# ask if the user wants to go through with saving all the files:
for interval from start_from to end_at
	xxx$ = Get label of interval... tier interval
	check = 0
	if xxx$ = "xxx" and exclude_intervals_labeled_as_xxx = 1
		check = 1
	endif
	if xxx$ = "" and exclude_empty_labels = 1
		check = 1
	endif
	if left$ (xxx$,1) = "." and exclude_intervals_starting_with_dot = 1
		check = 1
	endif
	if check = 0
	   files = files + 1
	endif
endfor
interval = 1
pause 'files' sound files will be saved. Continue?

# Loop through all intervals in the selected tier of the TextGrid
for interval from start_from to end_at
	select TextGrid 'gridname$'
	intname$ = ""
	intname$ = Get label of interval... tier interval
	check = 0
	if intname$ = "xxx" and exclude_intervals_labeled_as_xxx = 1
		check = 1
	endif
	if intname$ = "" and exclude_empty_labels = 1
		check = 1
	endif
	if left$ (intname$,1) = "." and exclude_intervals_starting_with_dot = 1
		check = 1
	endif
	if check = 0
		intervalstart = Get starting point... tier interval
			if intervalstart > margin
				intervalstart = intervalstart - margin
			else
				intervalstart = 0
			endif
	
		intervalend = Get end point... tier interval
			if intervalend < endoffile - margin
				intervalend = intervalend + margin
			else
				intervalend = endoffile
			endif
	
		select LongSound 'soundname$'
		Extract part... intervalstart intervalend no
		filename$ = intname$
		intervalfile$ = "'folder$'" + "'prefix$'" + "'filename$'" + "'suffix$'" + ".wav"
		indexnumber = 0
		while fileReadable (intervalfile$)
			indexnumber = indexnumber + 1
			intervalfile$ = "'folder$'" + "'prefix$'" + "'filename$'" + "'suffix$''indexnumber'" + ".wav"
		endwhile
		Write to WAV file... 'intervalfile$'
		Remove
	endif
endfor
