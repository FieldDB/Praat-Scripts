# This script calculates the total duration of those intervals in the selected tier
# which have a regular label or transcription (not those labeled 'xxx' or starting with .)
# You can also give the name of a criterion tier and a criterion label:
# only those segments will be counted that are part of an interval in the
# criterion tier that has the criterion label. 
# A TextGrid object has to be selected before running this script.
#
# The script is useful for measuring your progress when you are labeling a LongSound file!
# It is handy if you add a button for it in the dynamic menu.
#
# This script is distributed under the GNU General Public Licence.
# Copyright 19.3.2002 Mietta Lennes

form Calculate the total duration of intervals
comment Calculate total duration of intervals in tier:
integer Duration_tier 1
comment Intervals labeled with 'xxx', starting with '.' or empty intervals will not be included.
comment Additional criterion for included intervals: They must be part of intervals in tier number
integer Criterion_tier 0
comment that are labeled as:
sentence Label 
endform

total_duration = 0
count = 0
	
numberOfIntervals = Get number of intervals... duration_tier

# Loop through all intervals in the selected tier:
for i from 1 to numberOfIntervals
	
	label1$ = Get label of interval... duration_tier i

	# The next line will make sure that intervals with empty or "forbidden" labels are not included:
	if label1$ <> "" and left$(label1$,1) <> "." and left$(label1$,3) <> "xxx"

		start1 = Get starting point... duration_tier i	
		end1 = Get end point... duration_tier i
		duration = end1 - start1
		middle1 = (start1 + end1) / 2

		if criterion_tier > 0
			criterion = Get interval at time... criterion_tier middle1
			start2 = Get starting point... criterion_tier criterion
			end2 = Get end point... criterion_tier criterion
	
			label2$ = Get label of interval... criterion_tier criterion
			
			if start2 <= start1 and end2 >= end1 and label2$ = label$
				total_duration = total_duration + duration
				count = count + 1
			endif
		else
			total_duration = total_duration + duration
			count = count + 1	
		endif
	endif

endfor

# Print the results to the Info window
echo The total duration of the intervals in tier number 'duration_tier' was calculated.
printline Those intervals whose label is "xxx" or starts with "." (dot) were not included.
if criterion_tier > 0
	printline Only those intervals that are part of another interval in tier 'criterion_tier'
	printline having the label "'label$'" were included.
endif

duration_in_minutes = 'total_duration' / 60
printline
printline Total duration of the 'count' intervals (fulfilling the criteria) is 'total_duration' seconds. 
printline That is 'duration_in_minutes' minutes.
